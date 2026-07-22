import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";
import Test "mo:test";

import Prim "mo:⛔";
import Iter "../src/Iter";
import Array "../src/Array";
import Nat32 "../src/Nat32";
import Nat "../src/Nat";
import Order "../src/Order";
import List "../src/List";
import Runtime "../src/Runtime";
import Int "../src/Int";
import Debug "../src/Debug";
import { Tuple2 } "../src/Tuples";
import VarArray "../src/VarArray";
import PureList "../src/pure/List";
import Option "../src/Option";

// IMPLEMENTATION DETAILS BEGIN

// The structure of list is as follows:
// number of block - size
// 0 - 0
// 1 - 1
// 2 - 1
// 3 - 2
// ...
// 5 - 2
// 6 - 4
// ...
// 11 - 4
// 12 - 8
// ...
// 23 - 8
// 24 - 16
// ...
// 47 - 16
// ..
// 3 * 2 ** i - 2 ** (i + 1)
// 3 * 2 ** (i + 1) - 2 ** (i + 1)
// ...

func locate_readable<X>(index : Nat) : (Nat, Nat) {
  // index is any Nat32 except for
  // blocks before super block s == 2 ** s
  let i = Nat.toNat32(index);
  // element with index 0 located in data block with index 1
  if (i == 0) {
    return (1, 0)
  };
  let lz = Nat32.bitcountLeadingZero(i);
  // super block s = bit length - 1 = (32 - leading zeros) - 1
  // i in binary = zeroes; 1; bits blocks mask; bits element mask
  // bit lengths =     lz; 1;     floor(s / 2);       ceil(s / 2)
  let s = 31 - lz;
  // floor(s / 2)
  let down = s >> 1;
  // ceil(s / 2) = floor((s + 1) / 2)
  let up = (s + 1) >> 1;
  // element mask = ceil(s / 2) ones in binary
  let e_mask = 1 << up - 1;
  //block mask = floor(s / 2) ones in binary
  let b_mask = 1 << down - 1;
  // data blocks in even super blocks before current = 2 ** ceil(s / 2)
  // data blocks in odd super blocks before current = 2 ** floor(s / 2)
  // data blocks before the super block = element mask + block mask
  // elements before the super block = 2 ** s
  // first floor(s / 2) bits in index after the highest bit = index of data block in super block
  // the next ceil(s / 2) to the end of binary representation of index + 1 = index of element in data block
  (Nat32.toNat(e_mask + b_mask + 2 + (i >> up) & b_mask), Nat32.toNat(i & e_mask))
};

// this was optimized in terms of instructions
func locate_optimal<X>(index : Nat) : (Nat, Nat) {
  // super block s = bit length - 1 = (32 - leading zeros) - 1
  // blocks before super block s == 2 ** s
  let i = Nat.toNat32(index);
  let lz = Nat32.bitcountLeadingZero(i);
  let lz2 = lz >> 1;
  // we split into cases to apply different optimizations in each one
  if (lz & 1 == 0) {
    // ceil(s / 2)  = 16 - lz2
    // floor(s / 2) = 15 - lz2
    // i in binary = zeroes; 1; bits blocks mask; bits element mask
    // bit lengths =     lz; 1;         15 - lz2;          16 - lz2
    // blocks before = 2 ** ceil(s / 2) + 2 ** floor(s / 2)

    // so in order to calculate index of the data block
    // we need to shift i by 16 - lz2 and set bit with number 16 - lz2, bit 15 - lz2 is already set

    // element mask = 2 ** (16 - lz2) = (1 << 16) >> lz2 = 0xFFFF >> lz2
    let mask = 0xFFFF >> lz2;
    (Nat32.toNat(((i << lz2) >> 16) ^ (0x10000 >> lz2)), Nat32.toNat(i & mask))
  } else {
    // s / 2 = ceil(s / 2) = floor(s / 2) = 15 - lz2
    // i in binary = zeroes; 1; bits blocks mask; bits element mask
    // bit lengths =     lz; 1;         15 - lz2;          15 - lz2
    // block mask = element mask = mask = 2 ** (s / 2) - 1 = 2 ** (15 - lz2) - 1 = (1 << 15) >> lz2 = 0x7FFF >> lz2
    // blocks before = 2 * 2 ** (s / 2)

    // so in order to calculate index of the data block
    // we need to shift i by 15 - lz2, set bit with number 16 - lz2 and unset bit 15 - lz2

    let mask = 0x7FFF >> lz2;
    (Nat32.toNat(((i << lz2) >> 15) ^ (0x18000 >> lz2)), Nat32.toNat(i & mask))
  }
};

let locate_n = 1_000;
var i = 0;
while (i < locate_n) {
  assert (locate_readable(i) == locate_optimal(i));
  assert (locate_readable(1_000_000 + i) == locate_optimal(1_000_000 + i));
  assert (locate_readable(1_000_000_000 + i) == locate_optimal(1_000_000_000 + i));
  assert (locate_readable(2_000_000_000 + i) == locate_optimal(2_000_000_000 + i));
  assert (locate_readable(2 ** 32 - 1 - i : Nat) == locate_optimal(2 ** 32 - 1 - i : Nat));
  i += 1
};

// IMPLEMENTATION DETAILS END

func assertValid(list : List.List<Nat>) {
  let blocks = list.blocks;
  let blockCount = blocks.size();

  func good(x : Nat) : Bool {
    var y = x;
    while (y % 2 == 0) y := y / 2;
    y == 1 or y == 3
  };

  assert good(blocks.size());

  assert blocks[0].size() == 0;

  var index = 0;
  var i = 1;
  var nullCount = 0;
  while (i < blockCount) {
    let db = blocks[i];
    let sz = db.size();
    assert i >= list.blockIndex or sz == Nat32.toNat(1 <>> Nat32.bitcountLeadingZero(Nat.toNat32(i) / 3));
    if (sz == 0) assert index >= List.size(list);

    var j = 0;
    while (j < sz) {
      if (index == List.size(list)) assert i == list.blockIndex and j == list.elementIndex;
      assert Option.isNull(db[j]) == (index >= List.size(list));
      index += 1;
      j += 1
    };

    if (VarArray.any<?Nat>(db, Option.isNull)) {
      nullCount += 1;
      assert i == list.blockIndex or i == list.blockIndex + 1
    };
    i += 1
  };
  assert nullCount <= 2;

  let b = list.blockIndex;
  let e = list.elementIndex;
  List.add(list, 2 ** 64);
  assert list.blocks[b][e] == ?(2 ** 64);
  assert List.removeLast(list) == ?(2 ** 64)
};

let { run; test; suite } = Suite;

func unwrap<T>(x : ?T) : T = switch (x) {
  case (?v) v;
  case (_) Prim.trap "internal error in unwrap()"
};

let n = 100;
var list = List.empty<Nat>();

let sizes = List.empty<Nat>();
for (i in Nat.rangeInclusive(0, n)) {
  sizes.add(list.size());
  list.add(i)
};
sizes.add(list.size());

class OrderTestable(initItem : Order.Order) : T.TestableItem<Order.Order> {
  public let item = initItem;
  public func display(order : Order.Order) : Text {
    switch (order) {
      case (#less) {
        "#less"
      };
      case (#greater) {
        "#greater"
      };
      case (#equal) {
        "#equal"
      }
    }
  };
  public let equals = Order.equal
};

run(
  suite(
    "clone",
    [
      test(
        "clone",
        list.clone().toArray(),
        M.equals(T.array(T.natTestable, list.toArray()))
      )
    ]
  )
);

run(
  suite(
    "add",
    [
      test(
        "sizes",
        sizes.toArray(),
        M.equals(T.array(T.natTestable, Nat.rangeInclusive(0, n + 1).toArray()))
      ),
      test(
        "elements",
        list.toArray(),
        M.equals(T.array(T.natTestable, Nat.rangeInclusive(0, n).toArray()))
      )
    ]
  )
);

assert list.find(func(a : Nat) : Bool = a == 123456) == null;
assert list.find(func(a : Nat) : Bool = a == 0) == ?0;

assert list.indexOf(Nat.equal, n + 1) == null;
assert list.findIndex(func(a : Nat) : Bool = a == n + 1) == null;
assert list.indexOf(Nat.equal, n) == ?n;
assert list.findIndex(func(a : Nat) : Bool = a == n) == ?n;

assert list.lastIndexOf(Nat.equal, n + 1) == null;
assert list.findLastIndex(func(a : Nat) : Bool = a == n + 1) == null;

assert list.lastIndexOf(Nat.equal, 0) == ?0;
assert list.findLastIndex(func(a : Nat) : Bool = a == 0) == ?0;

assert list.all(func(x : Nat) : Bool = 0 <= x and x <= n);
assert list.any(func(x : Nat) : Bool = x == n / 2);

run(
  suite(
    "iterator",
    [
      test(
        "values",
        list.values().toArray(),
        M.equals(T.array(T.natTestable, Nat.rangeInclusive(0, n).toArray()))
      ),
      test(
        "reverseValues",
        list.reverseValues().toArray(),
        M.equals(T.array(T.natTestable, Nat.rangeInclusive(0, n).reverse().toArray()))
      ),
      test(
        "keys",
        list.keys().toArray(),
        M.equals(T.array(T.natTestable, Nat.rangeInclusive(0, n).toArray()))
      ),
      test(
        "enumerate1",
        list.enumerate().map(func((a, b)) { b }).toArray(),
        M.equals(T.array(T.natTestable, Nat.rangeInclusive(0, n).toArray()))
      ),
      test(
        "enumerate2",
        list.enumerate().map(func((a, b)) { a }).toArray(),
        M.equals(T.array(T.natTestable, Nat.rangeInclusive(0, n).toArray()))
      ),
      test(
        "reverseEnumerate1",
        list.reverseEnumerate().map(func((a, b)) { b }).toArray(),
        M.equals(T.array(T.natTestable, Nat.rangeInclusive(0, n).reverse().toArray()))
      ),
      test(
        "reverseEnumerate2",
        list.reverseEnumerate().map(func((a, b)) { a }).toArray(),
        M.equals(T.array(T.natTestable, Nat.rangeInclusive(0, n).reverse().toArray()))
      )
    ]
  )
);

let for_add_many = List.repeat<Nat>(0, n);
List.addRepeat(for_add_many, 0, n);

let for_add_iter = List.repeat<Nat>(0, n);
List.addAll(for_add_iter, Iter.repeat<Nat>(0, n));

run(
  suite(
    "init",
    [
      test(
        "init with toArray",
        List.repeat<Nat>(0, n).toArray(),
        M.equals(T.array(T.natTestable, Array.tabulate<Nat>(n, func(_) = 0)))
      ),
      test(
        "init with values",
        List.repeat<Nat>(0, n).values().toArray(),
        M.equals(T.array(T.natTestable, Array.tabulate<Nat>(n, func(_) = 0)))
      ),
      test(
        "add many with toArray",
        for_add_many.toArray(),
        M.equals(T.array(T.natTestable, Array.tabulate<Nat>(2 * n, func(_) = 0)))
      ),
      test(
        "add many with vals",
        Iter.toArray(for_add_many.values()),
        M.equals(T.array(T.natTestable, Array.tabulate<Nat>(2 * n, func(_) = 0)))
      ),
      test(
        "addFromIter",
        for_add_iter.toArray(),
        M.equals(T.array(T.natTestable, Array.tabulate<Nat>(2 * n, func(_) = 0)))
      )
    ]
  )
);

for (i in Nat.rangeInclusive(0, n)) {
  List.put(list, i, n - i : Nat)
};

run(
  suite(
    "put",
    [
      test(
        "size",
        list.size(),
        M.equals(T.nat(n + 1))
      ),
      test(
        "elements",
        list.toArray(),
        M.equals(T.array(T.natTestable, Nat.rangeInclusive(0, n).reverse().toArray()))
      )
    ]
  )
);

let removed = List.empty<Nat>();
for (i in Nat.rangeInclusive(0, n)) {
  removed.add(unwrap(list.removeLast()))
};

let empty = List.empty<Nat>();
let emptied = List.singleton<Nat>(0);
let _ = emptied.removeLast();

run(
  suite(
    "removeLast",
    [
      test(
        "size",
        list.size(),
        M.equals(T.nat(0))
      ),
      test(
        "elements",
        removed.toArray(),
        M.equals(T.array(T.natTestable, Nat.rangeInclusive(0, n).toArray()))
      ),
      test(
        "empty",
        List.removeLast(List.empty<Nat>()),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
      test(
        "emptied",
        List.removeLast(emptied),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      )
    ]
  )
);

// Test last and first
assert list.first() == null;
assert list.last() == null;

for (i in Nat.rangeInclusive(0, n)) {
  list.add(i);
  assert list.last() == ?i;
  assert list.first() == ?0
};

run(
  suite(
    "addAfterRemove",
    [
      test(
        "elements",
        list.toArray(),
        M.equals(T.array(T.natTestable, Nat.rangeInclusive(0, n).toArray()))
      )
    ]
  )
);

run(
  suite(
    "firstAndLast",
    [
      test(
        "first",
        list.first(),
        M.equals(T.optional(T.natTestable, ?0))
      ),
      test(
        "first empty",
        empty.first(),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
      test(
        "first emptied",
        emptied.first(),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
      test(
        "last of len N",
        list.last(),
        M.equals(T.optional(T.natTestable, ?n))
      ),
      test(
        "last of len 1",
        List.repeat<Nat>(1, 1).last(),
        M.equals(T.optional(T.natTestable, ?1))
      ),
      test(
        "last of 6",
        List.fromArray<Nat>([0, 1, 2, 3, 4, 5]).last(),
        M.equals(T.optional(T.natTestable, ?5))
      ),
      test(
        "last empty",
        List.empty<Nat>().last(),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
      test(
        "last emptied",
        emptied.last(),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      )
    ]
  )
);

Test.suite(
  "empty vs emptied",
  func() {
    Test.test(
      "empty",
      func() {
        Test.expect.nat(empty.blockIndex).equal(1);
        Test.expect.nat(empty.elementIndex).equal(0);
        Test.expect.bool(empty.blocks.size() == 1).equal(true)
      }
    );
    Test.test(
      "emptied",
      func() {
        Test.expect.nat(emptied.blockIndex).equal(1);
        Test.expect.nat(emptied.elementIndex).equal(0);
        Test.expect.bool(emptied.blocks.size() > 1).equal(true)
      }
    )
  }
);

var sumN = 0;
list.forEach(func(i) { sumN += i });
var sumRev = 0;
list.reverseForEach<Nat>(func(i) { sumRev += i });
var sum1 = 0;
List.repeat<Nat>(1, 1).forEach(func(i) { sum1 += i });
var sum0 = 0;
List.empty<Nat>().forEach(func(i) { sum0 += i });

run(
  suite(
    "iterate",
    [
      test(
        "sumN",
        [sumN],
        M.equals(T.array(T.natTestable, [n * (n + 1) / 2]))
      ),
      test(
        "sumRev",
        [sumRev],
        M.equals(T.array(T.natTestable, [n * (n + 1) / 2]))
      ),
      test(
        "sum1",
        [sum1],
        M.equals(T.array(T.natTestable, [1]))
      ),
      test(
        "sum0",
        [sum0],
        M.equals(T.array(T.natTestable, [0]))
      )
    ]
  )
);

/* --------------------------------------- */

var sumItems = 0;
list.forEachEntry<Nat>(func(i, x) { sumItems += i + x });
var sumItemsRev = 0;
list.forEachEntry<Nat>(func(i, x) { sumItemsRev += i + x });

run(
  suite(
    "iterateItems",
    [
      test(
        "sumItems",
        [sumItems],
        M.equals(T.array(T.natTestable, [n * (n + 1)]))
      ),
      test(
        "sumItemsRev",
        [sumItemsRev],
        M.equals(T.array(T.natTestable, [n * (n + 1)]))
      )
    ]
  )
);

/* --------------------------------------- */

list := List.fromArray<Nat>([0, 1, 2, 3, 4, 5]);

run(
  suite(
    "contains",
    [
      test(
        "true",
        list.contains(Nat.equal, 2),
        M.equals(T.bool(true))
      ),
      test(
        "true",
        list.contains(Nat.equal, 9),
        M.equals(T.bool(false))
      )
    ]
  )
);

/* --------------------------------------- */

list := List.empty<Nat>();

run(
  suite(
    "contains empty",
    [
      test(
        "true",
        list.contains(Nat.equal, 2),
        M.equals(T.bool(false))
      ),
      test(
        "true",
        list.contains(Nat.equal, 9),
        M.equals(T.bool(false))
      )
    ]
  )
);

/* --------------------------------------- */

list := List.fromArray<Nat>([2, 1, 10, 1, 0, 3]);

run(
  suite(
    "max",
    [
      test(
        "return value",
        list.max(Nat.compare),
        M.equals(T.optional(T.natTestable, ?10))
      )
    ]
  )
);

/* --------------------------------------- */

list := List.fromArray<Nat>([2, 1, 10, 1, 0, 3, 0]);

run(
  suite(
    "min",
    [
      test(
        "return value",
        list.min(Nat.compare),
        M.equals(T.optional(T.natTestable, ?0))
      )
    ]
  )
);

/* --------------------------------------- */

list := List.fromArray<Nat>([0, 1, 2, 3, 4, 5]);

var list2 = List.fromArray<Nat>([0, 1, 2]);

run(
  suite(
    "equal",
    [
      test(
        "empty lists",
        List.empty<Nat>().equal(List.empty<Nat>(), Nat.equal),
        M.equals(T.bool(true))
      ),
      test(
        "non-empty lists",
        list.equal(List.clone(list), Nat.equal),
        M.equals(T.bool(true))
      ),
      test(
        "non-empty and empty lists",
        list.equal(List.empty<Nat>(), Nat.equal),
        M.equals(T.bool(false))
      ),
      test(
        "non-empty lists mismatching lengths",
        list.equal<Nat>(list2, Nat.equal),
        M.equals(T.bool(false))
      )
    ]
  )
);

/* --------------------------------------- */

list := List.fromArray<Nat>([0, 1, 2, 3, 4, 5]);
list2 := List.fromArray<Nat>([0, 1, 2]);

var list3 = List.fromArray<Nat>([2, 3, 4, 5]);

run(
  suite(
    "compare",
    [
      test(
        "empty lists",
        List.empty<Nat>().compare(List.empty<Nat>(), Nat.compare),
        M.equals(OrderTestable(#equal))
      ),
      test(
        "non-empty lists equal",
        list.compare(List.clone(list), Nat.compare),
        M.equals(OrderTestable(#equal))
      ),
      test(
        "non-empty and empty lists",
        list.compare(List.empty<Nat>(), Nat.compare),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "non-empty lists mismatching lengths",
        list.compare(list2, Nat.compare),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "non-empty lists lexicographic difference",
        list.compare(list3, Nat.compare),
        M.equals(OrderTestable(#less))
      )
    ]
  )
);

/* --------------------------------------- */

list := List.fromArray<Nat>([0, 1, 2, 3, 4, 5]);

run(
  suite(
    "toText",
    [
      test(
        "empty list",
        List.empty<Nat>().toText(Nat.toText),
        M.equals(T.text("List[]"))
      ),
      test(
        "singleton list",
        List.singleton<Nat>(3).toText<Nat>(Nat.toText),
        M.equals(T.text("List[3]"))
      ),
      test(
        "non-empty list",
        list.toText(Nat.toText),
        M.equals(T.text("List[0, 1, 2, 3, 4, 5]"))
      )
    ]
  )
);

/* --------------------------------------- */

list := List.fromArray<Nat>([0, 1, 2, 3, 4, 5, 6, 7]);
list2 := List.fromArray<Nat>([0, 1, 2, 3, 4, 5, 6]);
list3 := List.empty<Nat>();

var list4 = List.singleton<Nat>(3);

list.reverseInPlace();
list2.reverseInPlace();
list3.reverseInPlace();
list4.reverseInPlace();

run(
  suite(
    "reverseInPlace",
    [
      test(
        "even elements",
        list.toArray(),
        M.equals(T.array(T.natTestable, [7, 6, 5, 4, 3, 2, 1, 0]))
      ),
      test(
        "odd elements",
        list2.toArray(),
        M.equals(T.array(T.natTestable, [6, 5, 4, 3, 2, 1, 0]))
      ),
      test(
        "empty",
        list3.toArray(),
        M.equals(T.array(T.natTestable, [] : [Nat]))
      ),
      test(
        "singleton",
        list4.toArray(),
        M.equals(T.array(T.natTestable, [3]))
      )
    ]
  )
);

/* --------------------------------------- */

list := List.fromArray<Nat>([0, 1, 2, 3, 4, 5, 6, 7]).reverse();
list2 := List.fromArray<Nat>([0, 1, 2, 3, 4, 5, 6]).reverse();
list3 := List.empty<Nat>().reverse();
list4 := List.singleton<Nat>(3).reverse();

run(
  suite(
    "reverse",
    [
      test(
        "even elements",
        list.toArray(),
        M.equals(T.array(T.natTestable, [7, 6, 5, 4, 3, 2, 1, 0]))
      ),
      test(
        "odd elements",
        list2.toArray(),
        M.equals(T.array(T.natTestable, [6, 5, 4, 3, 2, 1, 0]))
      ),
      test(
        "empty",
        list3.toArray(),
        M.equals(T.array(T.natTestable, [] : [Nat]))
      ),
      test(
        "singleton",
        list4.toArray(),
        M.equals(T.array(T.natTestable, [3]))
      )
    ]
  )
);

/* --------------------------------------- */

list := List.fromArray<Nat>([0, 1, 2, 3, 4, 5, 6]);

run(
  suite(
    "foldLeft",
    [
      test(
        "return value",
        list.foldLeft("", func(acc, x) = acc # Nat.toText(x)),
        M.equals(T.text("0123456"))
      ),
      test(
        "return value empty",
        List.empty<Nat>().foldLeft("", func(acc, x) = acc # Nat.toText(x)),
        M.equals(T.text(""))
      )
    ]
  )
);

/* --------------------------------------- */

list := List.fromArray<Nat>([0, 1, 2, 3, 4, 5, 6]);

run(
  suite(
    "foldRight",
    [
      test(
        "return value",
        list.foldRight("", func(x, acc) = acc # Nat.toText(x)),
        M.equals(T.text("6543210"))
      ),
      test(
        "return value empty",
        List.empty<Nat>().foldRight("", func(x, acc) = acc # Nat.toText(x)),
        M.equals(T.text(""))
      )
    ]
  )
);

/* --------------------------------------- */

list := List.singleton<Nat>(2);

run(
  suite(
    "isEmpty",
    [
      test(
        "true",
        List.empty<Nat>().isEmpty(),
        M.equals(T.bool(true))
      ),
      test(
        "false",
        list.isEmpty(),
        M.equals(T.bool(false))
      )
    ]
  )
);

/* --------------------------------------- */

list := List.fromArray<Nat>([0, 1, 2, 3, 4, 5, 6]);

run(
  suite(
    "map",
    [
      test(
        "map",
        list.map(Nat.toText).toArray(),
        M.equals(T.array(T.textTestable, ["0", "1", "2", "3", "4", "5", "6"]))
      ),
      test(
        "empty",
        List.empty<Nat>().map(Nat.toText).isEmpty(),
        M.equals(T.bool(true))
      )
    ]
  )
);

/* --------------------------------------- */

list := List.fromArray<Nat>([0, 1, 2, 3, 4, 5, 6]);

run(
  suite(
    "filter",
    [
      test(
        "filter evens",
        list.filter(func x = x % 2 == 0).toArray(),
        M.equals(T.array(T.natTestable, [0, 2, 4, 6]))
      ),
      test(
        "filter none",
        list.filter(func _ = false).toArray(),
        M.equals(T.array(T.natTestable, [] : [Nat]))
      ),
      test(
        "filter all",
        list.filter(func _ = true).toArray(),
        M.equals(T.array(T.natTestable, [0, 1, 2, 3, 4, 5, 6]))
      ),
      test(
        "filter empty",
        List.empty<Nat>().filter(func _ = true).isEmpty(),
        M.equals(T.bool(true))
      )
    ]
  )
);

/* --------------------------------------- */

list := List.fromArray<Nat>([0, 1, 2, 3, 4, 5, 6]);

run(
  suite(
    "filterMap",
    [
      test(
        "filterMap double evens",
        list.filterMap<Nat, Nat>(func x = if (x % 2 == 0) ?(x * 2) else null).toArray(),
        M.equals(T.array(T.natTestable, [0, 4, 8, 12]))
      ),
      test(
        "filterMap none",
        list.filterMap<Nat, Nat>(func _ = null).toArray(),
        M.equals(T.array(T.natTestable, [] : [Nat]))
      ),
      test(
        "filterMap all",
        list.filterMap<Nat, Text>(func x = ?(Nat.toText(x))).toArray(),
        M.equals(T.array(T.textTestable, ["0", "1", "2", "3", "4", "5", "6"]))
      ),
      test(
        "filterMap empty",
        List.empty<Nat>().filterMap<Nat, Nat>(func x = ?x).isEmpty(),
        M.equals(T.bool(true))
      )
    ]
  )
);

/* --------------------------------------- */

list := List.fromArray<Nat>([8, 6, 9, 10, 0, 4, 2, 3, 7, 1, 5]);

run(
  suite(
    "sort",
    [
      test(
        "sort",
        do { list.sortInPlace(Nat.compare); list.toArray() },
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10] |> M.equals(T.array(T.natTestable, _))
      )
    ]
  )
);

func joinWith(xs : List.List<Text>, sep : Text) : Text {
  let size = List.size(xs);

  if (size == 0) return "";
  if (size == 1) return List.at(xs, 0);

  var result = List.at(xs, 0);
  var i = 0;
  label l loop {
    i += 1;
    if (i >= size) { break l };
    result #= sep # List.at(xs, i)
  };
  result
};

func listTestable<A>(testableA : T.Testable<A>) : T.Testable<List.List<A>> {
  {
    display = func(xs : List.List<A>) : Text = "[var " # joinWith(List.map<A, Text>(xs, testableA.display), ", ") # "]";
    equals = func(xs1 : List.List<A>, xs2 : List.List<A>) : Bool = List.equal(xs1, xs2, testableA.equals)
  }
};

run(
  suite(
    "mapResult",
    [
      test(
        "mapResult",
        List.mapResult<Int, Nat, Text>(
          List.fromArray([1, 2, 3]),
          func x {
            if (x >= 0) { #ok(Int.abs x) } else { #err "error message" }
          }
        ),
        M.equals(T.result<List.List<Nat>, Text>(listTestable(T.natTestable), T.textTestable, #ok(List.fromArray([1, 2, 3]))))
      ),
      Suite.test(
        "mapResult fail first",
        List.mapResult<Int, Nat, Text>(
          List.fromArray([-1, 2, 3]),
          func x {
            if (x >= 0) { #ok(Int.abs x) } else { #err "error message" }
          }
        ),
        M.equals(T.result<List.List<Nat>, Text>(listTestable(T.natTestable), T.textTestable, #err "error message"))
      ),
      Suite.test(
        "mapResult fail last",
        List.mapResult<Int, Nat, Text>(
          List.fromArray([1, 2, -3]),
          func x {
            if (x >= 0) { #ok(Int.abs x) } else { #err "error message" }
          }
        ),
        M.equals(T.result<List.List<Nat>, Text>(listTestable(T.natTestable), T.textTestable, #err "error message"))
      ),
      Suite.test(
        "mapResult empty",
        List.mapResult<Nat, Nat, Text>(
          List.fromArray([]),
          func x = #ok x
        ),
        M.equals(T.result<List.List<Nat>, Text>(listTestable(T.natTestable), T.textTestable, #ok(List.fromArray([]))))
      )
    ]
  )
);

// Claude tests (from original Mops package)

// Helper function to run tests
func runTest(name : Text, test : (Nat) -> Bool) {
  let testSizes = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 100];
  for (n in testSizes.vals()) {
    if (test(n)) {
      Debug.print("✅ " # name # " passed for n = " # Nat.toText(n))
    } else {
      Runtime.trap("❌ " # name # " failed for n = " # Nat.toText(n))
    }
  }
};

// Test cases
func testNew(n : Nat) : Bool {
  if (n > 0) return true;

  let vec = List.empty<Nat>();
  assertValid(vec);
  List.size(vec) == 0
};

func testInit(n : Nat) : Bool {
  let vec = List.repeat<Nat>(1, n);
  assertValid(vec);
  if (List.size(vec) != n) {
    Debug.print("Init failed: expected size " # Nat.toText(n) # ", got " # Nat.toText(List.size(vec)));
    return false
  };
  for (i in Nat.range(0, n)) {
    if (List.at(vec, i) != 1) {
      Debug.print("Init failed at index " # Nat.toText(i) # ": expected 1, got " # Nat.toText(List.at(vec, i)));
      return false
    }
  };
  true
};

func testFill(n : Nat) : Bool {
  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func i = i + 1));
  List.fill(vec, 42);
  if (List.size(vec) != n) {
    Debug.print("Fill failed: expected size " # Nat.toText(n) # ", got " # Nat.toText(List.size(vec)));
    return false
  };
  if (not List.all<Nat>(vec, func x = x == 42)) {
    Debug.print("Fill failed");
    return false
  };
  true
};

func testAdd(n : Nat) : Bool {
  if (n == 0) return true;
  let vec = List.empty<Nat>();
  for (i in Nat.range(0, n)) {
    List.add(vec, i);
    assertValid(vec)
  };

  if (vec.size() != n) {
    Debug.print("Size mismatch: expected " # Nat.toText(n) # ", got " # Nat.toText(vec.size()));
    return false
  };

  for (i in Nat.range(0, n)) {
    let value = List.at(vec, i);
    assertValid(vec);
    if (value != i) {
      Debug.print("Value mismatch at index " # Nat.toText(i) # ": expected " # Nat.toText(i) # ", got " # Nat.toText(value));
      return false
    }
  };

  true
};

func testAddRepeat(n : Nat) : Bool {
  if (n > 10) return true;

  for (i in Nat.range(0, n + 1)) {
    for (j in Nat.range(0, n + 1)) {
      let vec = List.repeat<Nat>(0, i + n);
      for (_ in Nat.range(0, n)) ignore List.removeLast(vec);
      assertValid(vec);
      List.addRepeat(vec, 1, j);
      assertValid(vec);
      if (List.size(vec) != i + j) {
        Debug.print("Size mismatch: expected " # Nat.toText(i + j) # ", got " # Nat.toText(List.size(vec)));
        return false
      };
      for (k in Nat.range(0, i + j)) {
        let expected = if (k < i) 0 else 1;
        let got = List.at(vec, k);
        if (expected != got) {
          Debug.print("addRepat failed i = " # Nat.toText(i) # " j = " # Nat.toText(j) # " k = " # Nat.toText(k) # " expected = " # Nat.toText(expected) # " got = " # Nat.toText(got));
          return false
        }
      }
    }
  };

  true
};

func testAppend(n : Nat) : Bool {
  if (n > 10) return true;

  for (i in Nat.range(0, n + 1)) {
    for (j in Nat.range(0, n + 1)) {
      let first = List.tabulate<Nat>(i, func x = x);
      let second = List.tabulate<Nat>(j, func x = x);
      let sum = List.empty<Nat>();
      for (x in List.values(first)) List.add(sum, x);
      for (x in List.values(second)) List.add(sum, x);
      List.append(first, second);

      if (not List.equal(first, sum, Nat.equal)) {
        Debug.print("Append failed for " # List.toText(first, Nat.toText) # " and " # List.toText(second, Nat.toText));
        return false
      }
    }
  };

  true
};

func testTruncate(n : Nat) : Bool {
  for (i in Nat.range(0, n + 1)) {
    let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func j = j));
    List.truncate(vec, i);
    if (List.size(vec) != i) {
      Debug.print("Truncate failed: expected size " # Nat.toText(i) # ", got " # Nat.toText(List.size(vec)));
      return false
    };
    for (j in Nat.range(0, i)) {
      if (List.at(vec, j) != j) {
        Debug.print("Truncate failed at index " # Nat.toText(j) # ": expected " # Nat.toText(j) # ", got " # Nat.toText(List.at(vec, j)));
        return false
      }
    };
    let b = vec.blockIndex;
    let e = vec.elementIndex;
    let blocks = vec.blocks;
    if (b < blocks.size()) {
      let db = blocks[b];
      var i = e;
      while (i < db.size()) {
        if (db[i] != null) {
          Debug.print("Truncate failed: expected null at index " # Nat.toText(i) # ", got " # debug_show (db[i]));
          return false
        };
        i += 1
      }
    }
  };
  true
};

func testRemoveLast(n : Nat) : Bool {
  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i));
  assertValid(vec);

  var i = n;
  while (i > 0) {
    i -= 1;
    let last = List.removeLast(vec);
    assertValid(vec);
    if (last != ?i) {
      Debug.print("Unexpected value removed: expected ?" # Nat.toText(i) # ", got " # debug_show (last));
      return false
    };
    if (List.size(vec) != i) {
      Debug.print("Unexpected size after removal: expected " # Nat.toText(i) # ", got " # Nat.toText(vec.size()));
      return false
    }
  };

  // Try to remove from empty vector
  if (List.removeLast(vec) != null) {
    Debug.print("Expected null when removing from empty vector, but got a value");
    return false
  };

  if (List.size(vec) != 0) {
    Debug.print("List should be empty, but has size " # Nat.toText(vec.size()));
    return false
  };

  true
};

func testAt(n : Nat) : Bool {
  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i + 1));
  assertValid(vec);

  for (i in Nat.range(1, n + 1)) {
    let value = List.at(vec, i - 1 : Nat);
    if (value != i) {
      Debug.print("at: Mismatch at index " # Nat.toText(i) # ": expected " # Nat.toText(i) # ", got " # Nat.toText(value));
      return false
    }
  };

  true
};

func testGet(n : Nat) : Bool {
  let vec = List.tabulate<Nat>(n, func(i) = i);

  for (i in Nat.range(0, n)) {
    switch (List.get(vec, i)) {
      case (?value) {
        if (value != i) {
          Debug.print("get: Mismatch at index " # Nat.toText(i) # ": expected ?" # Nat.toText(i) # ", got ?" # Nat.toText(value));
          return false
        }
      };
      case (null) {
        Debug.print("get: Unexpected null at index " # Nat.toText(i));
        return false
      }
    }
  };

  for (i in Nat.range(n, 3 * n + 3)) {
    switch (List.get(vec, i)) {
      case (?value) {
        Debug.print("get: Unexpected value at index " # Nat.toText(i) # ": got ?" # Nat.toText(value));
        return false
      };
      case (null) {}
    }
  };

  true
};

func testPut(n : Nat) : Bool {
  let vec = List.fromArray<Nat>(Array.repeat<Nat>(0, n));
  for (i in Nat.range(0, n)) {
    List.put(vec, i, i + 1);
    let value = List.at(vec, i);
    if (value != i + 1) {
      Debug.print("put: Mismatch at index " # Nat.toText(i) # ": expected " # Nat.toText(i + 1) # ", got " # Nat.toText(value));
      return false
    }
  };
  true
};

func testClear(n : Nat) : Bool {
  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i));
  List.clear(vec);
  assertValid(vec);
  List.size(vec) == 0
};

func testClone(n : Nat) : Bool {
  if (n == 0) {
    let vec1 = List.empty<Nat>();
    let vec2 = List.clone(vec1);
    assertValid(vec2);
    if (not List.equal(vec1, vec2, Nat.equal)) return false
  };
  let vec1 = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i));
  assertValid(vec1);
  let vec2 = List.clone(vec1);
  assertValid(vec2);
  List.equal(vec1, vec2, Nat.equal)
};

func testMap(n : Nat) : Bool {
  if (n == 0) {
    let vec = List.map<Nat, Nat>(List.empty<Nat>(), func x = x * 2);
    assertValid(vec);
    if (not List.equal(List.empty<Nat>(), vec, Nat.equal)) return false
  };
  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i));
  assertValid(vec);
  let mapped = List.map<Nat, Nat>(vec, func(x) = x * 2);
  assertValid(mapped);
  List.equal(mapped, List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i * 2)), Nat.equal)
};

func testMapEntries(n : Nat) : Bool {
  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i));
  let mapped = List.mapEntries<Nat, Nat>(vec, func(i, x) = i * x);
  List.equal(mapped, List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i * i)), Nat.equal)
};

func testMapInPlace(n : Nat) : Bool {
  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i));
  List.mapInPlace<Nat>(vec, func(x) = x * 2);
  List.equal(vec, List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i * 2)), Nat.equal)
};

func testFlatMap(n : Nat) : Bool {
  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i));
  let flatMapped = List.flatMap<Nat, Nat>(vec, func(x) = [x, x].vals());

  let expected = List.fromArray<Nat>(Array.tabulate<Nat>(2 * n, func(i) = i / 2));
  List.equal(flatMapped, expected, Nat.equal)
};

func testRange(n : Nat) : Bool {
  if (n > 10) return true; // Skip large ranges for performance
  let vec = List.tabulate<Nat>(n, func(i) = i);
  for (left in Nat.range(0, n)) {
    for (right in Nat.range(left, n + 1)) {
      let range = Iter.toArray(List.range(vec, left, right));
      let expected = Array.tabulate(right - left, func(i) = left + i);
      if (range != expected) {
        Debug.print(
          "Range mismatch for left = " # Nat.toText(left) # ", right = " # Nat.toText(right) # ": expected " # debug_show (expected) # ", got " # debug_show (range)
        );
        return false
      }
    }
  };
  true
};

func testSliceToArray(n : Nat) : Bool {
  if (n > 10) return true; // Skip large ranges for performance
  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i));
  for (left in Nat.range(0, n)) {
    for (right in Nat.range(left, n + 1)) {
      let slice = List.sliceToArray(vec, left, right);
      let sliceVar = List.sliceToVarArray(vec, left, right);
      let expected = Array.tabulate(right - left, func(i) = left + i);
      let expectedVar = VarArray.tabulate<Nat>(right - left, func(i) = left + i);
      if (slice != expected or not VarArray.equal<Nat>(sliceVar, expectedVar, Nat.equal)) {
        Debug.print(
          "Slice mismatch for left = " # Nat.toText(left) # ", right = " # Nat.toText(right) # ": expected " # debug_show (expected) # ", got " # debug_show (slice)
        );
        return false
      }
    }
  };
  true
};

func testIndexOf(n : Nat) : Bool {
  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(2 * n, func(i) = i % n));
  if (n == 0) {
    vec.indexOf(Nat.equal, 0) == null
  } else {
    var allCorrect = true;
    for (i in Nat.range(0, n)) {
      let index = vec.indexOf(Nat.equal, i);
      if (index != ?i) {
        allCorrect := false;
        Debug.print("indexOf failed for i = " # Nat.toText(i) # ", expected ?" # Nat.toText(i) # ", got " # debug_show (index))
      }
    };
    allCorrect and vec.indexOf(Nat.equal, n) == null
  }
};

func testLastIndexOf(n : Nat) : Bool {
  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(2 * n, func(i) = i % n));
  if (n == 0) {
    vec.lastIndexOf(Nat.equal, 0) == null
  } else {
    var allCorrect = true;
    for (i in Nat.range(0, n)) {
      let index = vec.lastIndexOf(Nat.equal, i);
      if (index != ?(n + i)) {
        allCorrect := false;
        Debug.print("lastIndexOf failed for i = " # Nat.toText(i) # ", expected ?" # Nat.toText(n + i) # ", got " # debug_show (index))
      }
    };
    allCorrect and vec.lastIndexOf(Nat.equal, n) == null
  }
};

func testContains(n : Nat) : Bool {
  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i + 1));

  // Check if it contains all elements from 0 to n-1
  for (i in Nat.range(1, n + 1)) {
    if (not vec.contains(Nat.equal, i)) {
      Debug.print("List should contain " # Nat.toText(i) # " but it doesn't");
      return false
    }
  };

  // Check if it doesn't contain n (which should be out of range)
  if (vec.contains(Nat.equal, n + 1)) {
    Debug.print("List shouldn't contain " # Nat.toText(n + 1) # " but it does");
    return false
  };

  // Check if it doesn't contain n+1 (another out of range value)
  if (vec.contains(Nat.equal, n + 2)) {
    Debug.print("List shouldn't contain " # Nat.toText(n + 2) # " but it does");
    return false
  };

  true
};

func testReverse(n : Nat) : Bool {
  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i));
  assertValid(vec);
  let reversed = List.reverse(vec);
  assertValid(reversed);
  List.reverseInPlace(vec);
  assertValid(vec);

  let inPlaceEqual = List.equal(vec, List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = n - 1 - i)), Nat.equal);
  let reversedEqual = List.equal(reversed, List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = n - 1 - i)), Nat.equal);

  inPlaceEqual and reversedEqual
};

func testSort(n : Nat) : Bool {
  let array = Array.tabulate<Int>(n, func(i) = (i * 123) % 100 - 50);
  let vec = List.fromArray(array);

  let sorted = List.sort(vec, Int.compare);
  List.sortInPlace(vec, Int.compare);

  let expected = List.fromArray(Array.sort(array, Int.compare));

  List.equal(vec, expected, Int.equal) and List.equal(sorted, expected, Int.equal)
};

func testIsSorted(n : Nat) : Bool {
  let sorted = List.fromArray<Nat>(Array.tabulate<Nat>(n, func i = i));
  if (not List.isSorted(sorted, Nat.compare)) {
    Debug.print("isSorted fails on " # List.toText(sorted, Nat.toText));
    return false
  };

  let notSorted = List.fromArray<Nat>(Array.tabulate<Nat>(n, func i = n - i - 1));
  if (List.size(notSorted) >= 2 and List.isSorted(notSorted, Nat.compare)) {
    Debug.print("isSorted fails on " # List.toText(notSorted, Nat.toText));
    return false
  };

  true
};

func testDeduplicate(n : Nat) : Bool {
  if (n != 0) return true;

  let lists = [
    List.fromArray<Nat>([1, 1, 2, 2, 3, 3]),
    List.fromArray<Nat>([1, 2, 3]),
    List.fromArray<Nat>([1, 1, 2, 3])
  ];

  for (list in lists.vals()) {
    List.deduplicate(list, Nat.equal);
    if (not List.equal(list, List.fromArray<Nat>([1, 2, 3]), Nat.equal)) {
      Debug.print("Deduplicate failed for " # List.toText(list, Nat.toText));
      return false
    }
  };

  true
};

func testToArray(n : Nat) : Bool {
  let array = Array.tabulate(n, func(i) = i);
  let vec = List.fromArray<Nat>(array);
  assertValid(vec);
  Array.equal(List.toArray(vec), array, Nat.equal)
};

func testToVarArray(n : Nat) : Bool {
  let array = VarArray.tabulate<Nat>(n, func(i) = i);
  let vec = List.tabulate<Nat>(n, func(i) = i);
  VarArray.equal(List.toVarArray(vec), array, Nat.equal)
};

func testFromVarArray(n : Nat) : Bool {
  let array = VarArray.tabulate<Nat>(n, func(i) = i);
  let vec = List.fromVarArray(array);
  List.equal(vec, List.fromArray<Nat>(VarArray.toArray(array)), Nat.equal)
};

func testFromArray(n : Nat) : Bool {
  let array = Array.tabulate(n, func(i) = i);
  let vec = List.fromArray<Nat>(array);
  List.equal(vec, List.fromArray<Nat>(array), Nat.equal)
};

func testFromIter(n : Nat) : Bool {
  let iter = Nat.range(1, n + 1);
  let vec = List.fromIter<Nat>(iter);
  assertValid(vec);
  List.equal(vec, List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i + 1)), Nat.equal)
};

func testforEachInRange(n : Nat) : Bool {
  if (n > 10) return true; // Skip large ranges for performance
  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i));

  for (left in Nat.range(0, n)) {
    for (right in Nat.range(left, n + 1)) {
      let expected = VarArray.tabulate<Nat>(right - left, func(i) = left + i);
      let result = VarArray.repeat<Nat>(0, right - left);
      List.forEachInRange<Nat>(vec, func(i) = result[i - left] := i, left, right);
      if (VarArray.toArray(result) != VarArray.toArray(expected)) {
        Debug.print(
          "forEachInRange mismatch for left = " # Nat.toText(left) # ", right = " # Nat.toText(right) # ": expected " # debug_show (expected) # ", got " # debug_show (result)
        );
        return false
      }
    }
  };
  true
};

func testFoldLeft(n : Nat) : Bool {
  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i + 1));
  vec.foldLeft("", func(acc, x) = acc # Nat.toText(x)) == Array.foldLeft<Nat, Text>(Array.tabulate<Nat>(n, func(i) = i + 1), "", func(acc, x) = acc # Nat.toText(x))
};

func testFoldRight(n : Nat) : Bool {
  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i + 1));
  vec.foldRight("", func(x, acc) = Nat.toText(x) # acc) == Array.foldRight<Nat, Text>(Array.tabulate<Nat>(n, func(i) = i + 1), "", func(x, acc) = Nat.toText(x) # acc)
};

func testFilter(n : Nat) : Bool {
  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i));

  let evens = List.filter(vec, func x = x % 2 == 0);
  assertValid(evens);

  let expectedEvens = List.fromArray<Nat>(Array.tabulate<Nat>((n + 1) / 2, func(i) = i * 2));
  if (not evens.equal(expectedEvens, Nat.equal)) {
    Debug.print("Filter evens failed");
    return false
  };

  let none = List.filter(vec, func _ = false);
  assertValid(none);
  if (not List.isEmpty(none)) {
    Debug.print("Filter none failed");
    return false
  };

  let all = List.filter(vec, func _ = true);
  assertValid(all);
  if (not List.equal<Nat>(all, vec, Nat.equal)) {
    Debug.print("Filter all failed");
    return false
  };

  true
};

func testRetain(n : Nat) : Bool {
  if (n > 10) return true;

  for (mod in Nat.range(1, n + 1)) {
    for (rem in Nat.range(0, mod + 1)) {
      let f : Nat -> Bool = func x = x % mod == rem;
      let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i));
      let expected = List.filter(vec, f);
      List.retain<Nat>(vec, f);
      if (not List.equal<Nat>(vec, expected, Nat.equal)) {
        Debug.print("Retain failed for mod " # Nat.toText(mod) # " and rem " # Nat.toText(rem) # "");
        return false
      }
    }
  };

  true
};

func testFilterMap(n : Nat) : Bool {
  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i));

  let doubledEvens = List.filterMap<Nat, Nat>(vec, func x = if (x % 2 == 0) ?(x * 2) else null);
  assertValid(doubledEvens);

  let expectedDoubledEvens = List.fromArray<Nat>(Array.tabulate<Nat>((n + 1) / 2, func(i) = i * 4));
  if (not doubledEvens.equal(expectedDoubledEvens, Nat.equal)) {
    Debug.print("FilterMap doubled evens failed");
    return false
  };

  let none = List.filterMap<Nat, Nat>(vec, func _ = null);
  assertValid(none);
  if (not List.isEmpty(none)) {
    Debug.print("FilterMap none failed");
    return false
  };

  let all = List.filterMap<Nat, Nat>(vec, func x = ?x);
  assertValid(all);
  if (not List.equal<Nat>(all, vec, Nat.equal)) {
    Debug.print("FilterMap all failed");
    return false
  };

  true
};

func testPure(n : Nat) : Bool {
  let idArray = Array.tabulate(n, func(i) = i);
  let vec = List.fromArray<Nat>(idArray);
  let pureList = List.toPure(vec);
  let newVec = List.fromPure<Nat>(pureList);
  assertValid(newVec);

  if (not PureList.equal<Nat>(pureList, PureList.fromArray<Nat>(idArray), Nat.equal)) {
    Debug.print("PureList conversion failed");
    return false
  };
  if (not List.equal<Nat>(newVec, vec, Nat.equal)) {
    Debug.print("List conversion from PureList failed");
    return false
  };

  true
};

func testReverseForEach(n : Nat) : Bool {
  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i + 1));
  var revSum = 0;
  List.reverseForEach<Nat>(vec, func(x) = revSum += x);
  let expectedReversed = n * (n + 1) / 2;

  if (revSum != expectedReversed) {
    Debug.print("Reverse forEach failed: expected " # Nat.toText(expectedReversed) # ", got " # Nat.toText(revSum));
    return false
  };

  true
};

func testForEach(n : Nat) : Bool {
  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i + 1));
  var revSum = 0;
  List.forEach<Nat>(vec, func(x) = revSum += x);
  let expectedReversed = n * (n + 1) / 2;

  if (revSum != expectedReversed) {
    Debug.print("ForEach failed: expected " # Nat.toText(expectedReversed) # ", got " # Nat.toText(revSum));
    return false
  };

  true
};

func testBinarySearch(n : Nat) : Bool {
  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i * 2));
  if (n == 0) {
    return List.binarySearch(vec, Nat.compare, 0) == #insertionIndex(0) and List.binarySearch(vec, Nat.compare, 1) == #insertionIndex(0)
  };
  for (i in Nat.range(0, n)) {
    let value = i * 2;
    let index = List.binarySearch(vec, Nat.compare, value);
    if (index != #found i) {
      Debug.print("binarySearch failed for value = " # Nat.toText(value) # ", expected #found " # Nat.toText(i) # ", got " # debug_show (index));
      Debug.print("vec = " # debug_show (vec));
      return false
    };
    let notFoundIndex = List.binarySearch(vec, Nat.compare, value + 1);
    if (notFoundIndex != #insertionIndex(i + 1)) {
      Debug.print("binarySearch should have returned null for value = " # Nat.toText(value + 1) # ", but got " # debug_show (notFoundIndex));
      return false
    }
  };
  do {
    let vec = List.repeat<Nat>(0, n);
    switch (List.binarySearch(vec, Nat.compare, 0)) {
      case (#insertionIndex index) {
        Debug.print("binarySearch on all-equal elements failed, expected #found 0, got #insertionIndex " # Nat.toText(index));
        return false
      };
      case (_) {}
    }
  };
  List.binarySearch(vec, Nat.compare, n * 2) == #insertionIndex(n)
};

func testFlatten(n : Nat) : Bool {
  let vec = List.fromArray<List.List<Nat>>(
    Array.tabulate<List.List<Nat>>(
      n,
      func(i) = List.fromArray<Nat>(Array.tabulate<Nat>(i + 1, func(j) = j))
    )
  );
  let flattened = List.flatten(vec);
  let expectedSize = (n * (n + 1)) / 2;

  if (List.size(flattened) != expectedSize) {
    Debug.print("Flatten size mismatch: expected " # Nat.toText(expectedSize) # ", got " # Nat.toText(List.size(flattened)));
    return false
  };

  for (i in Nat.range(0, n)) {
    for (j in Nat.range(0, i + 1)) {
      if (List.at(flattened, (i * (i + 1)) / 2 + j) != j) {
        Debug.print("Flatten value mismatch at index " # Nat.toText((i * (i + 1)) / 2 + j) # ": expected " # Nat.toText(j));
        return false
      }
    }
  };

  true
};

func testJoin(n : Nat) : Bool {
  let iter = Array.tabulate(
    n,
    func(i) = List.fromArray<Nat>(Array.tabulate<Nat>(i + 1, func(j) = j))
  ).vals();
  let flattened = List.join(iter);
  let expectedSize = (n * (n + 1)) / 2;

  if (List.size(flattened) != expectedSize) {
    Debug.print("Flatten size mismatch: expected " # Nat.toText(expectedSize) # ", got " # Nat.toText(List.size(flattened)));
    return false
  };

  for (i in Nat.range(0, n)) {
    for (j in Nat.range(0, i + 1)) {
      if (List.at(flattened, (i * (i + 1)) / 2 + j) != j) {
        Debug.print("Flatten value mismatch at index " # Nat.toText((i * (i + 1)) / 2 + j) # ": expected " # Nat.toText(j));
        return false
      }
    }
  };

  true
};

func testTabulate(n : Nat) : Bool {
  let tabu = List.tabulate<Nat>(n, func(i) = i);

  if (List.size(tabu) != n) {
    Debug.print("Tabulate size mismatch: expected " # Nat.toText(n) # ", got " # Nat.toText(List.size(tabu)));
    return false
  };

  for (i in Nat.range(0, n)) {
    if (List.at(tabu, i) != i) {
      Debug.print("Tabulate value mismatch at index " # Nat.toText(i) # ": expected " # Nat.toText(i) # ", got " # Nat.toText(List.at(tabu, i)));
      return false
    }
  };

  true
};

func testNextIndexOf(n : Nat) : Bool {
  func nextIndexOf(vec : List.List<Nat>, element : Nat, from : Nat) : ?Nat {
    for (i in Nat.range(from, List.size(vec))) {
      if (List.at(vec, i) == element) {
        return ?i
      }
    };
    return null
  };

  if (n > 10) return true; // Skip large vectors for performance

  let vec = List.tabulate<Nat>(n, func(i) = i);
  for (from in Nat.range(0, n)) {
    for (element in Nat.range(0, n + 1)) {
      let actual = List.nextIndexOf(vec, Nat.equal, element, from);
      let expected = nextIndexOf(vec, element, from);
      if (expected != actual) {
        Debug.print(
          "nextIndexOf failed for element " # Nat.toText(element) # " from index " # Nat.toText(from) # ": expected " # debug_show (expected) # ", got " # debug_show (actual)
        );
        return false
      }
    }
  };
  true
};

func testPrevIndexOf(n : Nat) : Bool {
  func prevIndexOf(vec : List.List<Nat>, element : Nat, from : Nat) : ?Nat {
    var i = from;
    while (i > 0) {
      i -= 1;
      if (List.at(vec, i) == element) {
        return ?i
      }
    };
    return null
  };

  if (n > 10) return true; // Skip large vectors for performance

  let vec = List.tabulate<Nat>(n, func(i) = i);
  for (from in Nat.range(0, n + 1)) {
    for (element in Nat.range(0, n + 1)) {
      let actual = List.prevIndexOf(vec, Nat.equal, element, from);
      let expected = prevIndexOf(vec, element, from);
      if (expected != actual) {
        Debug.print(
          "prevIndexOf failed for element " # Nat.toText(element) # " from index " # Nat.toText(from) # ": expected " # debug_show (expected) # ", got " # debug_show (actual)
        );
        return false
      }
    }
  };
  true
};

func testMin(n : Nat) : Bool {
  if (n == 0) {
    let vec = List.empty<Nat>();
    if (List.min<Nat>(vec, Nat.compare) != null) {
      Debug.print("Min on empty list should return null");
      return false
    };
    return true
  };

  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i + 1));
  for (i in Nat.range(0, n)) {
    List.put(vec, i, 0);
    let min = List.min(vec, Nat.compare);
    if (min != ?0) {
      Debug.print("Min failed: expected ?0, got " # debug_show (min));
      return false
    };
    List.put(vec, i, i + 1)
  };
  true
};

func testMax(n : Nat) : Bool {
  if (n == 0) {
    let vec = List.empty<Nat>();
    if (List.max<Nat>(vec, Nat.compare) != null) {
      Debug.print("Max on empty list should return null");
      return false
    };
    return true
  };

  let vec = List.fromArray<Nat>(Array.tabulate<Nat>(n, func(i) = i + 1));
  for (i in Nat.range(0, n)) {
    List.put(vec, i, n + 1);
    let max = List.max(vec, Nat.compare);
    if (max != ?(n + 1)) {
      Debug.print("Max failed: expected ?" # Nat.toText(n + 1) # ", got " # debug_show (max));
      return false
    };
    List.put(vec, i, i + 1)
  };
  true
};

func testReader(n : Nat) : Bool {
  let vec = List.tabulate<Nat>(2 * n, func i = i);
  let reader = List.reader(vec, n);
  for (i in Nat.range(0, n)) {
    let x = reader();
    if (x != i + n) {
      Debug.print("Reader expected " # Nat.toText(i + n) # ", got " # Nat.toText(x));
      return false
    }
  };
  return true
};

// Run all tests
func runAllTests() {
  runTest("testNew", testNew);
  runTest("testInit", testInit);
  runTest("testFill", testFill);
  runTest("testAdd", testAdd);
  runTest("testAddRepeat", testAddRepeat);
  runTest("testAppend", testAppend);
  runTest("testTruncate", testTruncate);
  runTest("testRemoveLast", testRemoveLast);
  runTest("testAt", testAt);
  runTest("testGet", testGet);
  runTest("testPut", testPut);
  runTest("testClear", testClear);
  runTest("testClone", testClone);
  runTest("testMap", testMap);
  runTest("testMapEntries", testMapEntries);
  runTest("testMapInPlace", testMapInPlace);
  runTest("testFlatMap", testFlatMap);
  runTest("testRange", testRange);
  runTest("testSliceToArray", testSliceToArray);
  runTest("testIndexOf", testIndexOf);
  runTest("testLastIndexOf", testLastIndexOf);
  runTest("testContains", testContains);
  runTest("testReverse", testReverse);
  runTest("testSort", testSort);
  runTest("testIsSorted", testIsSorted);
  runTest("testDeduplicate", testDeduplicate);
  runTest("testToArray", testToArray);
  runTest("testToVarArray", testToVarArray);
  runTest("testFromVarArray", testFromVarArray);
  runTest("testFromArray", testFromArray);
  runTest("testFromIter", testFromIter);
  runTest("testFoldLeft", testFoldLeft);
  runTest("testFoldRight", testFoldRight);
  runTest("testforEachInRange", testforEachInRange);
  runTest("testFilter", testFilter);
  runTest("testRetain", testRetain);
  runTest("testFilterMap", testFilterMap);
  runTest("testPure", testPure);
  runTest("testReverseForEach", testReverseForEach);
  runTest("testForEach", testForEach);
  runTest("testBinarySearch", testBinarySearch);
  runTest("testFlatten", testFlatten);
  runTest("testJoin", testJoin);
  runTest("testTabulate", testTabulate);
  runTest("testNextIndexOf", testNextIndexOf);
  runTest("testPrevIndexOf", testPrevIndexOf);
  runTest("testMin", testMin);
  runTest("testMax", testMax);
  runTest("testReader", testReader)
};

// Run all tests
runAllTests();

Test.suite(
  "Regression tests",
  func() {
    Test.test(
      "test adding many elements",
      func() {
        let list = List.empty<Nat>();

        var blockSize = list.blocks.size();
        var sizes = List.empty<(Nat, Nat)>();
        sizes.add((blockSize, 0));

        let expectedSize = 100_000;
        for (i in Nat.range(0, expectedSize)) {
          list.add(i);

          let size = list.blocks.size();
          assert blockSize <= size;
          if (blockSize < size) {
            blockSize := size;
            sizes.add((blockSize, list.size()))
          }
        };
        Test.expect.nat(list.size()).equal(expectedSize);

        // Check how block size grows with the number of elements
        let expectedBlockResizes = [
          (1, 0),
          (2, 1),
          (3, 2),
          (4, 3),
          (6, 5),
          (8, 9),
          (12, 17),
          (16, 33),
          (24, 65),
          (32, 129),
          (48, 257),
          (64, 513),
          (96, 1_025),
          (128, 2_049),
          (192, 4_097),
          (256, 8_193),
          (384, 16_385),
          (512, 32_769),
          (768, 65_537)
        ];
        Test.expect.array<(Nat, Nat)>(sizes.toArray(), Tuple2.makeToText(Nat.toText, Nat.toText), Tuple2.makeEqual<Nat, Nat>(Nat.equal, Nat.equal)).equal(expectedBlockResizes)
      }
    )
  }
);

Test.suite(
  "Out-of-bounds and inverted index handling",
  func() {
    let vec = List.fromArray<Nat>([0, 1, 2, 3, 4]);

    Test.test(
      "range clamps negative fromInclusive without over-reading",
      func() {
        Test.expect.array<Nat>(Iter.toArray(List.range(vec, -3, 3)), Nat.toText, Nat.equal).equal([2]);
        Test.expect.array<Nat>(Iter.toArray(List.range(vec, -100, 2)), Nat.toText, Nat.equal).equal([0, 1]);
        Test.expect.array<Nat>(Iter.toArray(List.range(vec, -1, 4)), Nat.toText, Nat.equal).equal([]);
        Test.expect.array<Nat>(Iter.toArray(List.range(vec, -1, 2)), Nat.toText, Nat.equal).equal([])
      }
    );

    Test.test(
      "sliceToArray returns empty for inverted range",
      func() {
        Test.expect.array<Nat>(List.sliceToArray(vec, 3, 1), Nat.toText, Nat.equal).equal([]);
        Test.expect.array<Nat>(List.sliceToArray(vec, -1, -3), Nat.toText, Nat.equal).equal([]);
        Test.expect.bool(VarArray.equal<Nat>(List.sliceToVarArray(vec, 3, 1), [var], Nat.equal)).equal(true);
        Test.expect.bool(VarArray.equal<Nat>(List.sliceToVarArray(vec, -1, -3), [var], Nat.equal)).equal(true)
      }
    );

    Test.test(
      "get returns null for index >= 2^32",
      func() {
        Test.expect.bool(List.get<Nat>(vec, 4294967296) == null).equal(true);
        Test.expect.bool(List.get<Nat>(vec, 100) == null).equal(true);
        Test.expect.bool(List.get<Nat>(vec, 1) == ?1).equal(true)
      }
    )
  }
);

Test.suite(
  "Null on empty",
  func() {
    Test.test(
      "indexOf",
      func() {
        Test.expect.bool(List.indexOf(empty, Nat.equal, 0) == null).equal(true);
        Test.expect.bool(List.indexOf(emptied, Nat.equal, 0) == null).equal(true)
      }
    );
    Test.test(
      "lastIndexOf",
      func() {
        Test.expect.bool(List.lastIndexOf(empty, Nat.equal, 0) == null).equal(true);
        Test.expect.bool(List.lastIndexOf(emptied, Nat.equal, 0) == null).equal(true)
      }
    );
    Test.test(
      "find",
      func() {
        Test.expect.bool(List.find<Nat>(empty, func x = x == 0) == null).equal(true);
        Test.expect.bool(List.find<Nat>(emptied, func x = x == 0) == null).equal(true)
      }
    );
    Test.test(
      "findIndex",
      func() {
        Test.expect.bool(List.findIndex<Nat>(empty, func x = x == 0) == null).equal(true);
        Test.expect.bool(List.findIndex<Nat>(emptied, func x = x == 0) == null).equal(true)
      }
    );
    Test.test(
      "findLastIndex",
      func() {
        Test.expect.bool(List.findLastIndex<Nat>(empty, func x = x == 0) == null).equal(true);
        Test.expect.bool(List.findLastIndex<Nat>(emptied, func x = x == 0) == null).equal(true)
      }
    );
    Test.test(
      "max",
      func() {
        Test.expect.bool(List.max(empty, Nat.compare) == null).equal(true);
        Test.expect.bool(List.max(emptied, Nat.compare) == null).equal(true)
      }
    );
    Test.test(
      "min",
      func() {
        Test.expect.bool(List.min(empty, Nat.compare) == null).equal(true);
        Test.expect.bool(List.min(emptied, Nat.compare) == null).equal(true)
      }
    );
    Test.test(
      "binarySearch",
      func() {
        let result1 = List.binarySearch(empty, Nat.compare, 0);
        let result2 = List.binarySearch(emptied, Nat.compare, 0);
        Test.expect.bool(result1 == #insertionIndex(0)).equal(true);
        Test.expect.bool(result2 == #insertionIndex(0)).equal(true)
      }
    )
  }
);

// Additional binarySearch tests
Test.suite(
  "binarySearch",
  func() {
    Test.test(
      "found",
      func() {
        let list = List.fromArray<Nat>([1, 3, 5, 7, 9, 11]);
        let result = List.binarySearch(list, Nat.compare, 5);
        Test.expect.bool(result == #found(2)).equal(true)
      }
    );
    Test.test(
      "not found",
      func() {
        let list = List.fromArray<Nat>([1, 3, 5, 7, 9, 11]);
        let result = List.binarySearch(list, Nat.compare, 6);
        Test.expect.bool(result == #insertionIndex(3)).equal(true)
      }
    );
    Test.test(
      "first element",
      func() {
        let list = List.fromArray<Nat>([1, 3, 5, 7, 9, 11]);
        let result = List.binarySearch(list, Nat.compare, 1);
        Test.expect.bool(result == #found(0)).equal(true)
      }
    );
    Test.test(
      "last element",
      func() {
        let list = List.fromArray<Nat>([1, 3, 5, 7, 9, 11]);
        let result = List.binarySearch(list, Nat.compare, 11);
        Test.expect.bool(result == #found(5)).equal(true)
      }
    );
    Test.test(
      "single element found",
      func() {
        let list = List.fromArray<Nat>([42]);
        let result = List.binarySearch(list, Nat.compare, 42);
        Test.expect.bool(result == #found(0)).equal(true)
      }
    );
    Test.test(
      "single element not found",
      func() {
        let list = List.fromArray<Nat>([42]);
        let result = List.binarySearch(list, Nat.compare, 43);
        Test.expect.bool(result == #insertionIndex(1)).equal(true)
      }
    );
    Test.test(
      "duplicates",
      func() {
        let list = List.fromArray<Nat>([1, 2, 2, 2, 3]);
        let result = List.binarySearch(list, Nat.compare, 2);
        let ok = switch result {
          case (#found index) { index >= 1 and index <= 3 };
          case _ { false }
        };
        Test.expect.bool(ok).equal(true)
      }
    )
  }
);

// The maximum size 2^32 cannot be reached by actually adding elements
// (32 GB of data blocks), so these tests craft the List's internal state
// directly. size() derives the size purely from the (blockIndex,
// elementIndex) insertion position, so the data blocks can remain empty.
// The crafted states follow the pattern of real full lists, checked
// against reachable sizes: a full list of size 2^(2m) has
// blockIndex = 2^(m+1) and elementIndex = 0 (e.g. size 2^24 has
// blockIndex = 8192); the state one element earlier is
// blockIndex = 2^(m+1) - 1, elementIndex = lastBlockSize - 1.
Test.suite(
  "size at the 2^32 capacity boundary",
  func() {
    Test.test(
      "size 2^32 - 1",
      func() {
        let almostFull : List.List<Nat> = {
          var blocks = [var] : [var [var ?Nat]];
          var blockIndex = 131_071;
          var elementIndex = 65_535
        };
        Test.expect.nat(List.size(almostFull)).equal(4_294_967_295)
      }
    );
    Test.test(
      "size 2^32 (completely full list)",
      func() {
        let full : List.List<Nat> = {
          var blocks = [var] : [var [var ?Nat]];
          var blockIndex = 131_072;
          var elementIndex = 0
        };
        Test.expect.nat(List.size(full)).equal(4_294_967_296)
      }
    )
  }
);

// binarySearch on a faked completely full list of size 2^32 (see the size
// tests above for the crafted blockIndex/elementIndex values). A real list
// of this size would need ~32 GB, but binarySearch only reads O(log n)
// slots, so only the data blocks actually hit by the search are
// instantiated, and only as long as needed:
// - phase 1 (epoch scan) probes blocks[3 * 2^(epoch-1)][0]; searching for
//   the maximum it stops at the first probe: blocks[98_304][0]
//   (b = 131_071, epoch = 32 - lz32(b/3) = 16, lessOrEqual = 2^16/2)
// - phase 2 bisects block indices in [98_304, 131_072) reading only
//   slot 0 of each probed block, so those blocks have length 1; every
//   probe compares #less because the target is the maximum
// - phase 3 bisects inside block 131_071; its `right` bound is the
//   block's PHYSICAL size, so this one block must be full-length (65_536)
// The probed slots hold ?0 (any value < target keeps the outcomes #less);
// the target sits in the very last slot. Every slot NOT instantiated
// traps when read (empty block or unwrap of null), so this test also
// asserts the exact probe set of the search.
Test.suite(
  "binarySearch on a faked full 2^32 list",
  func() {
    Test.test(
      "finds the last element",
      func() {
        let target = 4_294_967_295; // == the last index; all other probed slots hold 0
        let dataBlocks = VarArray.repeat<[var ?Nat]>([var], 131_072);

        // phase 1 probe
        dataBlocks[98_304] := [var ?0];

        // phase 2 probes: replicate the bisection index arithmetic,
        // outcome is #less (left := mid) at every step
        var left = 98_304;
        var right = 131_072;
        while (right - left : Nat > 1) {
          let mid = (left + right) / 2;
          dataBlocks[mid] := [var ?0];
          left := mid
        };
        // left is now 131_071, the block holding the last element

        // phase 3 probes inside the (full-length) last block,
        // outcome is #less (left := mid + 1) until the final probe
        let lastBlock = VarArray.repeat<?Nat>(null, 65_536);
        lastBlock[0] := ?0; // probed by phase 2 (its final mid is 131_071)
        var l = 0;
        var r = 65_536;
        label sim while (l != r) {
          let mid = (l + r) / 2;
          if (mid == 65_535) break sim;
          lastBlock[mid] := ?0;
          l := mid + 1
        };
        lastBlock[65_535] := ?target;
        dataBlocks[131_071] := lastBlock;

        let fake : List.List<Nat> = {
          var blocks = dataBlocks;
          var blockIndex = 131_072;
          var elementIndex = 0
        };

        let result = List.binarySearch(fake, Nat.compare, target);
        Test.expect.bool(result == #found(4_294_967_295)).equal(true)
      }
    );
    Test.test(
      "insertion point past the last element",
      func() {
        // Same fake and probe set as above, but every probed slot (including
        // the very last one) holds 0 and we search for 1, which is greater
        // than everything: the search must report insertion index 2^32.
        // This is the one case where indexByBlockElement's Nat32 arithmetic
        // overflows: blockStart(131_071) + 65_536 = 2^32 wraps to 0, so a
        // caller would be told to insert the LARGEST element at the FRONT.
        // (Any list shorter than the full 2^32 yields insertion indices
        // < 2^32, which fit Nat32 — only the completely full list is
        // affected.)
        let dataBlocks = VarArray.repeat<[var ?Nat]>([var], 131_072);
        dataBlocks[98_304] := [var ?0];
        var left = 98_304;
        let right = 131_072;
        while (right - left : Nat > 1) {
          let mid = (left + right) / 2;
          dataBlocks[mid] := [var ?0];
          left := mid
        };
        let lastBlock = VarArray.repeat<?Nat>(null, 65_536);
        lastBlock[0] := ?0;
        var l = 0;
        let r = 65_536;
        while (l != r) {
          let mid = (l + r) / 2;
          lastBlock[mid] := ?0;
          l := mid + 1
        };
        dataBlocks[131_071] := lastBlock;

        let fake : List.List<Nat> = {
          var blocks = dataBlocks;
          var blockIndex = 131_072;
          var elementIndex = 0
        };

        switch (List.binarySearch(fake, Nat.compare, 1)) {
          case (#insertionIndex i) Test.expect.nat(i).equal(4_294_967_296);
          case (#found i) Test.expect.nat(i).equal(4_294_967_296) // unreachable; fails informatively
        }
      }
    )
  }
)
;

// Operations whose argument is a SIZE (not an index) must accept the value
// 2^32 — the size of a completely full list. Internally they pass it to
// locate(), whose Nat32 conversion can only express indices (<= 2^32 - 1),
// so today all three trap with "losing precision". locate(2^32) must
// return the normalized one-past-the-end position (131_072, 0), like it
// already does at every smaller data-block boundary (e.g. locate(8) is
// the start of the next block).
// The same defect makes repeat/tabulate/addRepeat trap when constructing
// a list of size exactly 2^32; that case has no value-asserting test
// because a successful construction needs ~32 GB of data blocks.
Test.suite(
  "size-valued arguments at the 2^32 capacity boundary",
  func() {
    Test.test(
      "lastIndexOf scans from the very end",
      func() {
        // fake full list; only the last slot holds a (matching) element,
        // so the backward scan succeeds on its first probe
        let dataBlocks = VarArray.repeat<[var ?Nat]>([var], 131_072);
        let lastBlock = VarArray.repeat<?Nat>(null, 65_536);
        lastBlock[65_535] := ?7;
        dataBlocks[131_071] := lastBlock;
        let fake : List.List<Nat> = {
          var blocks = dataBlocks;
          var blockIndex = 131_072;
          var elementIndex = 0
        };
        switch (List.lastIndexOf<Nat>(fake, Nat.equal, 7)) {
          case (?i) Test.expect.nat(i).equal(4_294_967_295);
          case null Test.expect.nat(0).equal(4_294_967_295) // fails informatively
        }
      }
    );
    Test.test(
      "truncate to the current size 2^32 is a no-op",
      func() {
        let fake : List.List<Nat> = {
          var blocks = VarArray.repeat<[var ?Nat]>([var], 131_072);
          var blockIndex = 131_072;
          var elementIndex = 0
        };
        List.truncate(fake, 4_294_967_296);
        Test.expect.nat(List.size(fake)).equal(4_294_967_296)
      }
    );
    Test.test(
      "addRepeat of zero elements at full capacity is a no-op",
      func() {
        let fake : List.List<Nat> = {
          var blocks = VarArray.repeat<[var ?Nat]>([var], 131_072);
          var blockIndex = 131_072;
          var elementIndex = 0
        };
        List.addRepeat(fake, 7, 0);
        Test.expect.nat(List.size(fake)).equal(4_294_967_296)
      }
    )
  }
)
