import Array "../src/Array";
import VarArray "../src/VarArray";
import Iter "../src/Iter";
import Int "../src/Int";
import Char "../src/Char";
import Nat "../src/Nat";
import Text "../src/Text";
import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

func joinWith(xs : [var Text], sep : Text) : Text {
  let size = xs.size();

  if (size == 0) return "";
  if (size == 1) return xs[0];

  var result = xs[0];
  var i = 0;
  label l loop {
    i += 1;
    if (i >= size) { break l };
    result #= sep # xs[i]
  };
  result
};

func varArrayTestable<A>(testableA : T.Testable<A>) : T.Testable<[var A]> {
  {
    display = func(xs : [var A]) : Text = "[var " # joinWith(xs.map(testableA.display), ", ") # "]";
    equals = func(xs1 : [var A], xs2 : [var A]) : Bool = xs1.equal(xs2, testableA.equals)
  }
};

func varArray<A>(testableA : T.Testable<A>, xs : [var A]) : T.TestableItem<[var A]> {
  let testableAs = varArrayTestable(testableA);
  {
    item = xs;
    display = testableAs.display;
    equals = testableAs.equals
  }
};

let suite = Suite.suite(
  "Array",
  [
    Suite.test(
      "repeat",
      Array.repeat<Int>(4, 3),
      M.equals(T.array<Int>(T.intTestable, [4, 4, 4]))
    ),
    Suite.test(
      "repeat empty",
      Array.repeat<Int>(4, 0),
      M.equals(T.array<Int>(T.intTestable, []))
    ),
    Suite.test(
      "tabulate",
      Array.tabulate<Int>(3, func(i : Nat) = i * 2),
      M.equals(T.array<Int>(T.intTestable, [0, 2, 4]))
    ),
    Suite.test(
      "tabulate empty",
      Array.tabulate<Int>(0, func(i : Nat) = i),
      M.equals(T.array<Int>(T.intTestable, []))
    ),
    Suite.test(
      "VarArray.toArray",
      VarArray.toArray<Int>([var 1, 2, 3]),
      M.equals(T.array<Int>(T.intTestable, [1, 2, 3]))
    ),
    Suite.test(
      "VarArray.toArray empty",
      VarArray.toArray<Int>([var]),
      M.equals(T.array<Int>(T.intTestable, []))
    ),
    Suite.test(
      "toVarArray round trip",
      Array.toVarArray<Int>([1, 2, 3]).toArray(),
      M.equals(T.array<Int>(T.intTestable, [1, 2, 3]))
    ),
    Suite.test(
      "toVarArray round trip empty",
      Array.toVarArray<Int>([]).toArray(),
      M.equals(T.array<Int>(T.intTestable, []))
    ),
    Suite.test(
      "equal",
      Array.equal<Int>([1, 2, 3], [1, 2, 3], Int.equal),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "equal empty",
      Array.equal<Int>([], [], Int.equal),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "not equal one empty",
      Array.equal<Int>([], [2, 3], Int.equal),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "not equal different lengths",
      Array.equal<Int>([1, 2, 3], [2, 4], Int.equal),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "not equal same lengths",
      Array.equal<Int>([1, 2, 3], [1, 2, 4], Int.equal),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "find",
      [1, 9, 4, 8].find(func x = x == 9),
      M.equals(T.optional(T.natTestable, ?9))
    ),
    Suite.test(
      "find fail",
      [1, 9, 4, 8].find(func _ = false),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "find empty",
      Array.find<Nat>([], func _ = true),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "findIndex",
      [1, 9, 4, 8].findIndex(func x = x == 9),
      M.equals(T.optional(T.natTestable, ?1))
    ),
    Suite.test(
      "findIndex fail",
      [1, 9, 4, 8].findIndex(func _ = false),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "findIndex empty",
      Array.findIndex<Nat>([], func _ = true),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "contains",
      [1, 9, 4, 8].contains(Nat.equal, 9),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "contains not found",
      [1, 9, 4, 8].contains(Nat.equal, 5),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "contains empty",
      Array.contains([], Nat.equal, 1),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "contains first element",
      [1, 2, 3].contains(Nat.equal, 1),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "contains last element",
      [1, 2, 3].contains(Nat.equal, 3),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "concat",
      Array.concat<Int>([1, 2, 3], [4, 5, 6]),
      M.equals(T.array<Int>(T.intTestable, [1, 2, 3, 4, 5, 6]))
    ),
    Suite.test(
      "concat first empty",
      Array.concat<Int>([], [4, 5, 6]),
      M.equals(T.array<Int>(T.intTestable, [4, 5, 6]))
    ),
    Suite.test(
      "concat second empty",
      Array.concat<Int>([1, 2, 3], []),
      M.equals(T.array<Int>(T.intTestable, [1, 2, 3]))
    ),
    Suite.test(
      "concat both empty",
      Array.concat<Int>([], []),
      M.equals(T.array<Int>(T.intTestable, []))
    ),
    Suite.test(
      "sort",
      [2, 3, 1].sort(Nat.compare),
      M.equals(T.array(T.natTestable, [1, 2, 3]))
    ),
    Suite.test(
      "sort empty array",
      [].sort(Nat.compare),
      M.equals(T.array(T.natTestable, []))
    ),
    Suite.test(
      "sort already sorted",
      [1, 2, 3, 4, 5].sort(Nat.compare),
      M.equals(T.array(T.natTestable, [1, 2, 3, 4, 5]))
    ),
    Suite.test(
      "sort repeated elements",
      [2, 2, 2, 2, 2].sort(Nat.compare),
      M.equals(T.array(T.natTestable, [2, 2, 2, 2, 2]))
    ),
    Suite.test(
      "reverse",
      [0, 1, 2, 2, 3].reverse(),
      M.equals(T.array(T.natTestable, [3, 2, 2, 1, 0]))
    ),
    Suite.test(
      "reverse empty",
      Array.reverse<Nat>([]),
      M.equals(T.array(T.natTestable, []))
    ),
    Suite.test(
      "reverse singleton",
      [0].reverse(),
      M.equals(T.array(T.natTestable, [0]))
    ),
    Suite.test(
      "map",
      [1, 2, 3].map(func x = x % 2 == 0),
      M.equals(T.array(T.boolTestable, [false, true, false]))
    ),
    Suite.test(
      "map empty",
      Array.map<Nat, Bool>([], func x = x % 2 == 0),
      M.equals(T.array(T.boolTestable, []))
    ),
    Suite.test(
      "filter",
      [1, 2, 3, 4, 5, 6].filter(func x = x % 2 == 0),
      M.equals(T.array(T.natTestable, [2, 4, 6]))
    ),
    Suite.test(
      "filter empty",
      Array.filter<Nat>([], func x = x % 2 == 0),
      M.equals(T.array(T.natTestable, []))
    ),
    Suite.test(
      "mapEntries",
      [1, 2, 3].mapEntries(func(x, i) = x + i),
      M.equals(T.array(T.natTestable, [1, 3, 5]))
    ),
    Suite.test(
      "mapEntries empty",
      Array.mapEntries<Nat, Nat>([], func(x, i) = x + i),
      M.equals(T.array(T.natTestable, []))
    ),
    Suite.test(
      "filterMap",
      [1, 2, 3, 4, 5, 6].filterMap(func x { if (x % 2 == 0) ?x else null }),
      M.equals(T.array(T.natTestable, [2, 4, 6]))
    ),
    Suite.test(
      "filterMap keep all",
      [1, 2, 3].filterMap(func x = ?x),
      M.equals(T.array(T.natTestable, [1, 2, 3]))
    ),
    Suite.test(
      "filterMap keep none",
      [1, 2, 3].filterMap<Nat, Nat>(func _ = null),
      M.equals(T.array(T.natTestable, []))
    ),
    Suite.test(
      "filterMap empty",
      Array.filterMap<Nat, Nat>([], func x { if (x % 2 == 0) ?x else null }),
      M.equals(T.array(T.natTestable, []))
    ),
    Suite.test(
      "mapResult",
      Array.mapResult<Int, Nat, Text>(
        [1, 2, 3],
        func x { if (x >= 0) { #ok(Int.abs x) } else { #err "error message" } }
      ),
      M.equals(T.result(T.arrayTestable(T.natTestable), T.textTestable, #ok([1, 2, 3])))
    ),
    Suite.test(
      "mapResult fail first",
      [-1, 2, 3].mapResult(
        func x { if (x >= 0) { #ok(Int.abs x) } else { #err "error message" } }
      ),
      M.equals(T.result(T.arrayTestable(T.natTestable), T.textTestable, #err "error message"))
    ),
    Suite.test(
      "mapResult fail last",
      [1, 2, -3].mapResult(
        func x { if (x >= 0) { #ok(Int.abs x) } else { #err "error message" } }
      ),
      M.equals(T.result(T.arrayTestable(T.natTestable), T.textTestable, #err "error message"))
    ),
    Suite.test(
      "mapResult empty",
      Array.mapResult<Nat, Nat, Text>(
        [],
        func x = #ok x
      ),
      M.equals(T.result<[Nat], Text>(T.arrayTestable(T.natTestable), T.textTestable, #ok([])))
    ),
    Suite.test(
      "flatMap",
      Array.flatMap<Int, Int>([0, 1, 2], func x = [x, -x].values()),
      M.equals(T.array(T.intTestable, [0, 0, 1, -1, 2, -2]))
    ),
    Suite.test(
      "flatMap empty",
      Array.flatMap<Int, Int>([], func x = [x, -x].values()),
      M.equals(T.array<Int>(T.intTestable, []))
    ),
    Suite.test(
      "flatMap mix",
      [1, 2, 1, 2, 3].flatMap(
        func n = Array.tabulate(n, func i = i).values()
      ),
      M.equals(T.array(T.natTestable, [0, 0, 1, 0, 0, 1, 0, 1, 2]))
    ),
    Suite.test(
      "flatMap mix empty right",
      [0, 1, 2, 0, 1, 2, 3, 0].flatMap(
        func n = Array.tabulate(n, func i = i).values()
      ),
      M.equals(T.array(T.natTestable, [0, 0, 1, 0, 0, 1, 0, 1, 2]))
    ),
    Suite.test(
      "flatMap mix empties right",
      [0, 1, 2, 0, 1, 2, 3, 0, 0, 0].flatMap(
        func n = Array.tabulate(n, func i = i).values()
      ),
      M.equals(T.array(T.natTestable, [0, 0, 1, 0, 0, 1, 0, 1, 2]))
    ),
    Suite.test(
      "flatMap mix empty left",
      [0, 1, 2, 0, 1, 2, 3].flatMap(
        func n = Array.tabulate(n, func i = i).values()
      ),
      M.equals(T.array(T.natTestable, [0, 0, 1, 0, 0, 1, 0, 1, 2]))
    ),
    Suite.test(
      "flatMap mix empties left",
      [0, 0, 0, 1, 2, 0, 1, 2, 3].flatMap(
        func n = Array.tabulate(n, func i = i).values()
      ),
      M.equals(T.array(T.natTestable, [0, 0, 1, 0, 0, 1, 0, 1, 2]))
    ),
    Suite.test(
      "flatMap mix empties middle",
      [0, 1, 2, 0, 0, 0, 1, 2, 3].flatMap(
        func n = Array.tabulate(n, func i = i).values()
      ),
      M.equals(T.array(T.natTestable, [0, 0, 1, 0, 0, 1, 0, 1, 2]))
    ),
    Suite.test(
      "flatMap mix empties",
      [0, 0, 0].flatMap(
        func n = Array.tabulate(n, func i = i).values()
      ),
      M.equals(T.array(T.natTestable, []))
    ),
    Suite.test(
      "flatMap mix empty",
      Array.flatMap<Nat, Nat>(
        [],
        func n = Array.tabulate(n, func i = i).values()
      ),
      M.equals(T.array(T.natTestable, []))
    ),
    Suite.test(
      "foldLeft",
      ["a", "b", "c"].foldLeft("", Text.concat),
      M.equals(T.text("abc"))
    ),
    Suite.test(
      "foldLeft empty",
      Array.foldLeft<Text, Text>([], "base", Text.concat),
      M.equals(T.text("base"))
    ),
    Suite.test(
      "foldRight",
      ["a", "b", "c"].foldRight("", func(x, acc) = acc # x),
      M.equals(T.text("cba"))
    ),
    Suite.test(
      "foldRight empty",
      Array.foldRight<Text, Text>([], "base", Text.concat),
      M.equals(T.text("base"))
    ),
    Suite.test(
      "flatten",
      Array.flatten<Int>([[1, 2, 3], [], [1]]),
      M.equals(T.array<Int>(T.intTestable, [1, 2, 3, 1]))
    ),
    Suite.test(
      "flatten empty start",
      Array.flatten<Int>([[], [1, 2, 3], [], [1]]),
      M.equals(T.array<Int>(T.intTestable, [1, 2, 3, 1]))
    ),
    Suite.test(
      "flatten empty end",
      Array.flatten<Int>([[1, 2, 3], [], [1], []]),
      M.equals(T.array<Int>(T.intTestable, [1, 2, 3, 1]))
    ),
    Suite.test(
      "flatten singleton",
      Array.flatten<Int>([[1, 2, 3]]),
      M.equals(T.array<Int>(T.intTestable, [1, 2, 3]))
    ),
    Suite.test(
      "flatten singleton empty",
      Array.flatten<Int>([[]]),
      M.equals(T.array<Int>(T.intTestable, []))
    ),
    Suite.test(
      "flatten empty",
      Array.flatten<Int>([]),
      M.equals(T.array<Int>(T.intTestable, []))
    ),
    Suite.test(
      "make",
      Array.singleton<Int>(0),
      M.equals(T.array<Int>(T.intTestable, [0]))
    ),
    Suite.test(
      "values",
      do {
        var sum = 0;
        for (x in Array.values([1, 2, 3])) {
          sum += x
        };
        sum
      },
      M.equals(T.nat(6))
    ),
    Suite.test(
      "values empty",
      do {
        var sum = 0;
        for (x in Array.values([])) {
          sum += x
        };
        sum
      },
      M.equals(T.nat(0))
    ),
    Suite.test(
      "keys",
      do {
        var sum = 0;
        for (x in Array.keys([1, 2, 3])) {
          sum += x
        };
        sum
      },
      M.equals(T.nat(3))
    ),
    Suite.test(
      "keys empty",
      do {
        var sum = 0;
        for (x in Array.keys([])) {
          sum += x
        };
        sum
      },
      M.equals(T.nat(0))
    ),
    Suite.test(
      "sliceToArray if including entire array",
      [2, 4, 6, 8, 10].sliceToArray(0, 5),
      M.equals(T.array(T.natTestable, [2, 4, 6, 8, 10]))
    ),
    Suite.test(
      "sliceToArray if including all but last index",
      [2, 4, 6, 8, 10].sliceToArray(0, -1),
      M.equals(T.array(T.natTestable, [2, 4, 6, 8]))
    ),
    Suite.test(
      "sliceToArray if including all but first index",
      [2, 4, 6, 8, 10].sliceToArray(1, 5),
      M.equals(T.array(T.natTestable, [4, 6, 8, 10]))
    ),
    Suite.test(
      "sliceToArray if including middle of array",
      [2, 4, 6, 8, 10].sliceToArray(1, 4),
      M.equals(T.array(T.natTestable, [4, 6, 8]))
    ),
    Suite.test(
      "sliceToArray if including middle of array (negative indices)",
      [2, 4, 6, 8, 10].sliceToArray(-4, -1),
      M.equals(T.array(T.natTestable, [4, 6, 8]))
    ),
    Suite.test(
      "sliceToArray if including start, but not end of array",
      [2, 4, 6, 8, 10].sliceToArray(0, -2),
      M.equals(T.array(T.natTestable, [2, 4, 6]))
    ),
    Suite.test(
      "sliceToArray if including end, but not start of array",
      [2, 4, 6, 8, 10].sliceToArray(2, 5),
      M.equals(T.array(T.natTestable, [6, 8, 10]))
    ),
    Suite.test(
      "sliceToArray if including end, but not start of array (negative indices)",
      [2, 4, 6, 8, 10].sliceToArray(-3, 5),
      M.equals(T.array(T.natTestable, [6, 8, 10]))
    ),
    Suite.test(
      "sliceToArray with empty result when start >= end",
      [1, 2, 3, 4, 5].sliceToArray(3, 2),
      M.equals(T.array(T.natTestable, []))
    ),
    Suite.test(
      "sliceToArray with negative fromInclusive and positive toExclusive",
      [1, 2, 3, 4, 5].sliceToArray(-2, 4),
      M.equals(T.array(T.natTestable, [4]))
    ),
    Suite.test(
      "sliceToArray with negative fromInclusive and zero toExclusive",
      [1, 2, 3, 4, 5].sliceToArray(-2, 0),
      M.equals(T.array(T.natTestable, []))
    ),
    Suite.test(
      "sliceToArray with both negative indices where start > end",
      [1, 2, 3, 4, 5].sliceToArray(-1, -3),
      M.equals(T.array(T.natTestable, []))
    ),
    Suite.test(
      "sliceToVarArray if including entire array",
      [2, 4, 6, 8, 10].sliceToVarArray<Nat>(0, 5),
      M.equals(varArray(T.natTestable, [var 2, 4, 6, 8, 10]))
    ),
    Suite.test(
      "sliceToVarArray if including all but last index",
      [2, 4, 6, 8, 10].sliceToVarArray<Nat>(0, -1),
      M.equals(varArray(T.natTestable, [var 2, 4, 6, 8]))
    ),
    Suite.test(
      "sliceToVarArray if including all but first index",
      [2, 4, 6, 8, 10].sliceToVarArray<Nat>(1, 5),
      M.equals(varArray(T.natTestable, [var 4, 6, 8, 10]))
    ),
    Suite.test(
      "sliceToVarArray if including middle of array",
      [2, 4, 6, 8, 10].sliceToVarArray<Nat>(1, 4),
      M.equals(varArray(T.natTestable, [var 4, 6, 8]))
    ),
    Suite.test(
      "sliceToVarArray if including middle of array (negative indices)",
      [2, 4, 6, 8, 10].sliceToVarArray<Nat>(-4, -1),
      M.equals(varArray(T.natTestable, [var 4, 6, 8]))
    ),
    Suite.test(
      "sliceToVarArray if including start, but not end of array",
      [2, 4, 6, 8, 10].sliceToVarArray<Nat>(0, -2),
      M.equals(varArray(T.natTestable, [var 2, 4, 6]))
    ),
    Suite.test(
      "sliceToVarArray if including end, but not start of array",
      [2, 4, 6, 8, 10].sliceToVarArray<Nat>(2, 5),
      M.equals(varArray(T.natTestable, [var 6, 8, 10]))
    ),
    Suite.test(
      "sliceToVarArray if including end, but not start of array (negative indices)",
      [2, 4, 6, 8, 10].sliceToVarArray<Nat>(-3, 5),
      M.equals(varArray(T.natTestable, [var 6, 8, 10]))
    ),
    Suite.test(
      "sliceToVarArray with empty result when start >= end",
      [1, 2, 3, 4, 5].sliceToVarArray<Nat>(3, 2),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "sliceToVarArray with negative fromInclusive and positive toExclusive",
      [1, 2, 3, 4, 5].sliceToVarArray<Nat>(-2, 4),
      M.equals(varArray(T.natTestable, [var 4]))
    ),
    Suite.test(
      "sliceToVarArray with negative fromInclusive and zero toExclusive",
      [1, 2, 3, 4, 5].sliceToVarArray<Nat>(-2, 0),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "sliceToVarArray with both negative indices where start > end",
      [1, 2, 3, 4, 5].sliceToVarArray<Nat>(-1, -3),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "nextIndexOf start",
      ['c', 'o', 'f', 'f', 'e', 'e'].nextIndexOf(Char.equal, 'c', 0),
      M.equals(T.optional(T.natTestable, ?0))
    ),
    Suite.test(
      "nextIndexOf not found from offset",
      ['c', 'o', 'f', 'f', 'e', 'e'].nextIndexOf(Char.equal, 'c', 1),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "nextIndexOf middle",
      ['c', 'o', 'f', 'f', 'e', 'e'].nextIndexOf(Char.equal, 'f', 0),
      M.equals(T.optional(T.natTestable, ?2))
    ),
    Suite.test(
      "nextIndexOf repeat",
      ['c', 'o', 'f', 'f', 'e', 'e'].nextIndexOf(Char.equal, 'f', 2),
      M.equals(T.optional(T.natTestable, ?2))
    ),
    Suite.test(
      "nextIndexOf start from the middle",
      ['c', 'o', 'f', 'f', 'e', 'e'].nextIndexOf(Char.equal, 'f', 3),
      M.equals(T.optional(T.natTestable, ?3))
    ),
    Suite.test(
      "nextIndexOf not found",
      ['c', 'o', 'f', 'f', 'e', 'e'].nextIndexOf(Char.equal, 'g', 0),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "nextIndexOf index out of bounds",
      ['c', 'o', 'f', 'f', 'e', 'e'].nextIndexOf(Char.equal, 'f', 100),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),

    Suite.test(
      "prevIndexOf first",
      ['c', 'o', 'f', 'f', 'e', 'e'].prevIndexOf(Char.equal, 'c', 6),
      M.equals(T.optional(T.natTestable, ?0))
    ),
    Suite.test(
      "prevIndexOf last",
      ['c', 'o', 'f', 'f', 'e', 'e'].prevIndexOf(Char.equal, 'e', 6),
      M.equals(T.optional(T.natTestable, ?5))
    ),
    Suite.test(
      "prevIndexOf middle",
      ['c', 'o', 'f', 'f', 'e', 'e'].prevIndexOf(Char.equal, 'f', 6),
      M.equals(T.optional(T.natTestable, ?3))
    ),
    Suite.test(
      "prevIndexOf start from the middle",
      ['c', 'o', 'f', 'f', 'e', 'e'].prevIndexOf(Char.equal, 'f', 3),
      M.equals(T.optional(T.natTestable, ?2))
    ),
    Suite.test(
      "prevIndexOf existing not found",
      ['c', 'o', 'f', 'f', 'e', 'e'].prevIndexOf(Char.equal, 'f', 2),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "prevIndexOf not found",
      ['c', 'o', 'f', 'f', 'e', 'e'].prevIndexOf(Char.equal, 'g', 6),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "Iter conversions",
      Array.values([1, 2, 3]).toArray(),
      M.equals(T.array(T.natTestable, [1, 2, 3]))
    ),
    Suite.test(
      "Iter conversions empty",
      Array.values([]).toArray(),
      M.equals(T.array(T.natTestable, []))
    ),
    Suite.test(
      "enumerate empty array",
      do {
        var hasItem = false;
        for (_ in [].enumerate()) {
          hasItem := true
        };
        hasItem
      },
      M.equals(T.bool(false))
    ),
    Suite.test(
      "enumerate non-empty array",
      do {
        var sum = 0;
        for ((i, x) in [10, 20, 30].enumerate()) {
          sum += i + x
        };
        sum // Should be (0+10) + (1+20) + (2+30) = 63
      },
      M.equals(T.nat(63))
    ),
    Suite.test(
      "enumerate preserves indices",
      do {
        var indices = "";
        for ((i, _) in ['a', 'b', 'c'].enumerate()) {
          indices #= i.toText()
        };
        indices
      },
      M.equals(T.text("012"))
    ),
    Suite.test(
      "enumerate preserves values",
      do {
        var values = "";
        for ((_, x) in ['a', 'b', 'c'].enumerate()) {
          values #= x.toText()
        };
        values
      },
      M.equals(T.text("abc"))
    ),
    Suite.test(
      "binarySearch found",
      [1, 3, 5, 7, 9, 11].binarySearch(Nat.compare, 5) == #found(2),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "binarySearch not found",
      [1, 3, 5, 7, 9, 11].binarySearch(Nat.compare, 6) == #insertionIndex(3),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "binarySearch first element",
      do {
        [1, 3, 5, 7, 9, 11].binarySearch(Nat.compare, 1) == #found(0)
      },
      M.equals(T.bool(true))
    ),
    Suite.test(
      "binarySearch last element",
      do {
        [1, 3, 5, 7, 9, 11].binarySearch(Nat.compare, 11) == #found(5)
      },
      M.equals(T.bool(true))
    ),
    Suite.test(
      "binarySearch empty array",
      do {
        Array.binarySearch([], Nat.compare, 5) == #insertionIndex(0)
      },
      M.equals(T.bool(true))
    ),
    Suite.test(
      "binarySearch single element found",
      do {
        [42].binarySearch(Nat.compare, 42) == #found(0)
      },
      M.equals(T.bool(true))
    ),
    Suite.test(
      "binarySearch single element not found",
      do {
        [42].binarySearch(Nat.compare, 43) == #insertionIndex(1)
      },
      M.equals(T.bool(true))
    ),
    Suite.test(
      "binarySearch duplicates",
      do {
        let result = [1, 2, 2, 2, 3].binarySearch(Nat.compare, 2);
        switch result {
          case (#found index) { index >= 1 and index <= 3 };
          case _ { false }
        }
      },
      M.equals(T.bool(true))
    ),
    Suite.test(
      "isSorted empty array",
      Array.isSorted<Nat>([], Nat.compare),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "isSorted single element",
      [42].isSorted(Nat.compare),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "isSorted already sorted",
      [1, 2, 3, 4, 5].isSorted(Nat.compare),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "isSorted with duplicates",
      [1, 2, 2, 3, 3, 3].isSorted(Nat.compare),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "isSorted not sorted",
      [1, 3, 2, 4, 5].isSorted(Nat.compare),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "isSorted reverse sorted",
      [5, 4, 3, 2, 1].isSorted(Nat.compare),
      M.equals(T.bool(false))
    )
  ]
);

Suite.run(suite)
