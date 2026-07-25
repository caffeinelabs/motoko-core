// @testmode wasi

// Exercises index block growth and shrinking at the maximum block index.
// At the real capacity boundary the index block has 131_072 entries and
// the list 2^32 elements (~32 GB), so this cannot be tested directly.
// Instead the functions below are 1-1 copies of their src/List.mo
// counterparts (dataBlockSize, newIndexBlockLength, growIndexBlockIfNeeded,
// shrinkIndexBlockIfNeeded, add, removeLast) with a single change: the
// capacity guard's threshold 131_071 is scaled down to 47. That gives max
// data block index 47, maximum index block length 48 and capacity
// 2 * 4^4 = 512 elements, so the boundary machinery runs for real on
// 512-element lists. KEEP THE COPIES IN SYNC WITH src/List.mo.
//
// The copies operate on the real List<T> record, so the real List.size /
// List.at can be used for assertions on the same list.

import List "../src/List";
import Nat32 "../src/Nat32";
import Nat "../src/Nat";
import VarArray "../src/VarArray";
import Prim "mo:⛔";
import { test } "mo:test";

// ---- 1-1 copies from src/List.mo, scaled: guard threshold 131_071 -> 47 ----

func dataBlockSize(blockIndex : Nat) : Nat {
  Nat32.toNat(1 <>> Nat32.bitcountLeadingZero(Nat.toNat32(blockIndex) / 3))
};

func newIndexBlockLength(blockIndex : Nat32) : Nat {
  if (blockIndex > 47) Prim.trap "List capacity of 512 elements exceeded";
  if (blockIndex <= 1) 2 else {
    let s = 30 - Nat32.bitcountLeadingZero(blockIndex);
    Nat32.toNat(((blockIndex >> s) +% 1) << s)
  }
};

func growIndexBlockIfNeeded<T>(list : List.List<T>) {
  if (list.blocks.size() == list.blockIndex) {
    let newBlocks = VarArray.repeat<[var ?T]>([var], newIndexBlockLength(Nat.toNat32(list.blockIndex)));
    var i = 0;
    while (i < list.blockIndex) {
      newBlocks[i] := list.blocks[i];
      i += 1
    };
    list.blocks := newBlocks
  }
};

func shrinkIndexBlockIfNeeded<T>(list : List.List<T>) {
  let blockIndex = Nat.toNat32(list.blockIndex);
  // kind of index of the first block in the super block
  if ((blockIndex << Nat32.bitcountLeadingZero(blockIndex)) << 2 == 0) {
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

// ---- tests against the real src/List.mo at the real boundary ----
//
// On this branch the maximal index block has 131_072 entries (~1 MB), so
// states at the real capacity boundary can be crafted directly and driven
// through the REAL functions. Only full traversal of the growth ladder
// needs the scaled copies below.

test(
  "real grow to the maximal index block length",
  func() {
    // a real list of size 2^31 has the state (98_304, 0) with the index
    // block exactly full at length 98_304; the next add grows the index
    // block to its maximal length 131_072
    let fake : List.List<Nat> = {
      var blocks = VarArray.repeat<[var ?Nat]>([var], 98_304);
      var blockIndex = 98_304;
      var elementIndex = 0
    };
    List.add(fake, 7);
    assert fake.blocks.size() == 131_072;
    assert List.size(fake) == 2_147_483_649; // 2^31 + 1
    assert List.at(fake, 2_147_483_648) == 7
  }
);

test(
  "real removeLast from the completely full 2^32 list",
  func() {
    // the shrink path runs at the one-past-the-end state (131_072, 0),
    // where newIndexBlockLength's capacity guard must not fire
    let dataBlocks = VarArray.repeat<[var ?Nat]>([var], 131_072);
    dataBlocks[131_071] := VarArray.repeat<?Nat>(?7, 65_536);
    let fake : List.List<Nat> = {
      var blocks = dataBlocks;
      var blockIndex = 131_072;
      var elementIndex = 0
    };
    assert List.removeLast(fake) == ?7;
    assert List.size(fake) == 4_294_967_295; // 2^32 - 1
    assert fake.blockIndex == 131_071;
    assert fake.blocks.size() == 131_072 // no shrink possible at the top
  }
);

test(
  "real shrink of the maximal index block",
  func() {
    // state (65_536, 0) (size 2^30) with the index block still at its
    // maximal length, as after draining from full without an intervening
    // shrink opportunity; the next removeLast crosses the rung 65_536 and
    // shrinks the index block to 98_304
    let dataBlocks = VarArray.repeat<[var ?Nat]>([var], 131_072);
    dataBlocks[65_535] := VarArray.repeat<?Nat>(?7, 32_768);
    let fake : List.List<Nat> = {
      var blocks = dataBlocks;
      var blockIndex = 65_536;
      var elementIndex = 0
    };
    assert List.removeLast(fake) == ?7;
    assert fake.blocks.size() == 98_304;
    assert List.size(fake) == 1_073_741_823 // 2^30 - 1
  }
);

// ---- tests (scaled copies) ----

let capacity = 512;

test(
  "grow to the (scaled) maximum: index block reaches its exactly-full length",
  func() {
    let l = List.empty<Nat>();
    var i = 0;
    while (i < capacity) {
      add(l, i);
      i += 1
    };
    assert List.size(l) == capacity;
    assert l.blockIndex == 48;
    assert l.elementIndex == 0;
    assert l.blocks.size() == 48; // exactly full, no slack at capacity
    assert List.at(l, 0) == 0;
    assert List.at(l, 511) == 511
  }
);

test(
  "removeLast from the completely full list works and drains with shrinking",
  func() {
    let l = List.empty<Nat>();
    var i = 0;
    while (i < capacity) {
      add(l, i);
      i += 1
    };

    // the very first removeLast runs shrinkIndexBlockIfNeeded at the
    // one-past-the-end state (48, 0), where newIndexBlockLength's
    // capacity guard must not fire
    assert removeLast(l) == ?511;
    assert List.size(l) == 511;

    var expected = 510;
    while (List.size(l) > 0) {
      assert removeLast(l) == ?expected;
      if (expected > 0) expected -= 1
    };
    assert List.size(l) == 0;
    assert removeLast(l) == null;
    // the index block shrank on the way down
    assert l.blocks.size() < 48
  }
);

test(
  "add/removeLast cycle at the capacity boundary does not trap",
  func() {
    let l = List.empty<Nat>();
    var i = 0;
    while (i < capacity) {
      add(l, i);
      i += 1
    };
    var k = 0;
    while (k < 3) {
      assert removeLast(l) == ?511;
      add(l, 511);
      k += 1
    };
    assert List.size(l) == capacity;
    assert List.at(l, 511) == 511
  }
)
