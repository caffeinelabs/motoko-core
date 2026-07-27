// @testmode wasi

// Exercises the index block machinery at its Nat32 size bound, which
// caps the List at exactly 2^61 elements (see the comment on
// newIndexBlockLength in src/List.mo). The bound is unreachable
// directly (2^61 elements; even a faked top state needs a ~26 GB index
// block), so the functions below are 1-1 copies of their src/List.mo
// counterparts (dataBlockSize, newIndexBlockLength,
// growIndexBlockIfNeeded, shrinkIndexBlockIfNeeded, add, removeLast)
// with a single change: Nat32 is narrowed to Nat8 (the offsets 30 -> 6
// and 31 -> 7, and the conversions accordingly). That moves the bound
// from the top rung 3 * 2^30 (size 2^61) down to 3 * 2^6 = 192
// (size 2^13 = 8_192), so the boundary machinery runs for real on
// 8_192-element lists. KEEP THE COPIES IN SYNC WITH src/List.mo.
//
// The copies operate on the real List<T> record, so the real List.size /
// List.at can be used for assertions on the same list.
//
// The two trapping behaviors at the bound (add at the full size, and
// the index block corruption that the early return in
// shrinkIndexBlockIfNeeded prevents) cannot be asserted here because a
// trap aborts the whole wasi test run; they were verified manually with
// these same copies.

import List "../src/List";
import Nat8 "../src/Nat8";
import Nat32 "../src/Nat32";
import Nat "../src/Nat";
import VarArray "../src/VarArray";
import { test } "mo:test";

// verbatim copy (only renamed) of newIndexBlockLength from src/List.mo,
// probing the Nat32 arithmetic at the real bound
func newIndexBlockLength32(blockIndex : Nat32) : Nat {
  if (blockIndex <= 1) 2 else {
    let s = 30 - Nat32.bitcountLeadingZero(blockIndex);
    Nat32.toNat(((blockIndex >> s) +% 1) << s)
  }
};

test(
  "Nat32 rung arithmetic at the top",
  func() {
    assert newIndexBlockLength32(131_072) == 196_608; // an ordinary rung
    assert newIndexBlockLength32(2_147_483_648) == 3_221_225_472; // 2^31 -> top rung 3*2^30
    assert newIndexBlockLength32(3_221_225_471) == 3_221_225_472; // last valid input
    assert newIndexBlockLength32(3_221_225_472) == 0 // top rung: 4 << 30 wraps
  }
);

// ---- 1-1 copies from src/List.mo, narrowed: Nat32 -> Nat8 ----

func dataBlockSize(blockIndex : Nat) : Nat {
  Nat8.toNat(1 <>> Nat8.bitcountLeadingZero(Nat.toNat8(blockIndex) / 3))
};

func newIndexBlockLength(blockIndex : Nat8) : Nat {
  if (blockIndex <= 1) 2 else {
    let s = 6 - Nat8.bitcountLeadingZero(blockIndex);
    Nat8.toNat(((blockIndex >> s) +% 1) << s)
  }
};

func growIndexBlockIfNeeded<T>(list : List.List<T>) {
  if (list.blocks.size() == list.blockIndex) {
    let newBlocks = VarArray.repeat<[var ?T]>([var], newIndexBlockLength(Nat.toNat8(list.blockIndex)));
    var i = 0;
    while (i < list.blockIndex) {
      newBlocks[i] := list.blocks[i];
      i += 1
    };
    list.blocks := newBlocks
  }
};

func shrinkIndexBlockIfNeeded<T>(list : List.List<T>) {
  let blockIndex = Nat.toNat8(list.blockIndex);
  // No shrink is possible for blockIndex >= 2^31: the only rung there
  // is the top rung 3 * 2^30 (the completely full 2^61 List), where
  // the index block is at its exactly-full maximal length -- but
  // newIndexBlockLength would wrap to 0 there and shrink the index
  // block to nothing, so return early.
  if (blockIndex >> 7 != 0) return;
  // only when blockIndex is the first block of a super block (i.e. of
  // the form 2^j or 3 * 2^j, the index block ladder) can a shrink be due
  if ((blockIndex << Nat8.bitcountLeadingZero(blockIndex)) << 2 == 0) {
    let newLength = newIndexBlockLength(blockIndex);
    if (newLength < list.blocks.size()) {
      let newBlocks = VarArray.repeat<[var ?T]>([var], newLength);
      var i = 0;
      while (i < newLength) {
        newBlocks[i] := list.blocks[i];
        i += 1
      };
      list.blocks := newBlocks
    }
  }
};

func add<T>(self : List.List<T>, element : T) {
  var elementIndex = self.elementIndex;
  if (elementIndex == 0) {
    growIndexBlockIfNeeded(self);
    let blockIndex = self.blockIndex;

    // When removing last we keep one more data block, so can be not empty
    if (self.blocks[blockIndex].size() == 0) {
      self.blocks[blockIndex] := VarArray.repeat<?T>(
        null,
        dataBlockSize(blockIndex)
      )
    }
  };

  let lastDataBlock = self.blocks[self.blockIndex];

  lastDataBlock[elementIndex] := ?element;

  elementIndex += 1;
  if (elementIndex == lastDataBlock.size()) {
    elementIndex := 0;
    self.blockIndex += 1
  };
  self.elementIndex := elementIndex
};

func removeLast<T>(self : List.List<T>) : ?T {
  var elementIndex = self.elementIndex;
  if (elementIndex == 0) {
    var blockIndex = self.blockIndex;
    if (blockIndex == 1) {
      return null
    };

    shrinkIndexBlockIfNeeded(self);

    blockIndex -= 1;
    elementIndex := self.blocks[blockIndex].size();

    // Keep one totally empty block when removing
    if (blockIndex + 2 < self.blocks.size()) self.blocks[blockIndex + 2] := [var];

    self.blockIndex := blockIndex
  };
  elementIndex -= 1;

  let lastDataBlock = self.blocks[self.blockIndex];

  let element = lastDataBlock[elementIndex];
  lastDataBlock[elementIndex] := null;

  self.elementIndex := elementIndex;
  return element
};

// ---- tests ----

// the scaled maximum size: end of epoch 6, insertion state (192, 0)
let maxSize = 8_192;

func fullList() : List.List<Nat> {
  let l = List.empty<Nat>();
  var i = 0;
  while (i < maxSize) { add(l, i); i += 1 };
  l
};

test(
  "the maximum size is reached intact",
  func() {
    let l = fullList();
    assert List.size(l) == maxSize;
    assert l.blockIndex == 192;
    assert l.elementIndex == 0;
    assert l.blocks.size() == 192; // exactly full at the top rung
    assert List.at(l, 0) == 0;
    assert List.at(l, maxSize - 1) == maxSize - 1
  }
);

test(
  "removeLast at the maximum size works via the early return",
  func() {
    let l = fullList();
    assert removeLast(l) == ?(maxSize - 1);
    assert List.size(l) == maxSize - 1;
    assert l.blocks.size() == 192 // untouched: no shrink possible at the top
  }
);

test(
  "full drain from the maximum size shrinks the index block",
  func() {
    let l = fullList();
    var expected = maxSize - 1 : Nat;
    while (List.size(l) > 0) {
      assert removeLast(l) == ?expected;
      if (expected > 0) expected -= 1
    };
    assert removeLast(l) == null;
    assert l.blocks.size() < 192
  }
);

test(
  "add/removeLast cycle at the maximum size",
  func() {
    let l = fullList();
    var k = 0;
    while (k < 3) {
      assert removeLast(l) == ?(maxSize - 1);
      add(l, maxSize - 1);
      k += 1
    };
    assert List.size(l) == maxSize;
    assert List.at(l, maxSize - 1) == maxSize - 1
  }
)
