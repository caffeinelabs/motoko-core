import VarArray "../src/VarArray";
import Int "../src/Int";
import Iter "../src/Iter";
import Char "../src/Char";
import Nat "../src/Nat";
import Text "../src/Text";
import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";
import Order "../src/Order";

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

// used to test sort
func bubbleSort<T>(array : [var T], compare : (T, T) -> Order.Order) : [var T] {
  let a = array.clone();
  let n = a.size();
  var i = 0;
  while (i < n) {
    var j = 0;
    while (j + 1 < n) {
      if (compare(a[j], a[j + 1]) == #greater) {
        let t = a[j];
        a[j] := a[j + 1];
        a[j + 1] := t
      };
      j += 1
    };
    i += 1
  };
  a
};

let suite = Suite.suite(
  "VarArray",
  [
    Suite.test(
      "repeat",
      VarArray.repeat<Int>(4, 3),
      M.equals(varArray<Int>(T.intTestable, [var 4, 4, 4]))
    ),
    Suite.test(
      "repeat empty",
      VarArray.repeat<Int>(4, 0),
      M.equals(varArray<Int>(T.intTestable, [var]))
    ),
    Suite.test(
      "tabulate",
      VarArray.tabulate<Int>(3, func(i : Nat) = i * 2),
      M.equals(varArray<Int>(T.intTestable, [var 0, 2, 4]))
    ),
    Suite.test(
      "tabulate empty",
      VarArray.tabulate<Int>(0, func(i : Nat) = i),
      M.equals(varArray<Int>(T.intTestable, [var]))
    ),
    Suite.test(
      "equal",
      VarArray.equal<Int>([var 1, 2, 3], [var 1, 2, 3], Int.equal),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "equal empty",
      VarArray.equal<Int>([var], [var], Int.equal),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "not equal one empty",
      VarArray.equal<Int>([var], [var 2, 3], Int.equal),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "not equal different lengths",
      VarArray.equal<Int>([var 1, 2, 3], [var 2, 4], Int.equal),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "not equal same lengths",
      VarArray.equal<Int>([var 1, 2, 3], [var 1, 2, 4], Int.equal),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "find",
      [var 1, 9, 4, 8].find(func x = x == 9),
      M.equals(T.optional(T.natTestable, ?9))
    ),
    Suite.test(
      "find fail",
      [var 1, 9, 4, 8].find(func _ = false),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "find empty",
      VarArray.find<Nat>([var], func _ = true),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "findIndex",
      [var 1, 9, 4, 8].findIndex(func x = x == 9),
      M.equals(T.optional(T.natTestable, ?1))
    ),
    Suite.test(
      "findIndex fail",
      [var 1, 9, 4, 8].findIndex(func _ = false),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "findIndex empty",
      VarArray.findIndex<Nat>([var], func _ = true),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "contains",
      [var 1, 9, 4, 8].contains(Nat.equal, 9),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "contains not found",
      [var 1, 9, 4, 8].contains(Nat.equal, 5),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "contains empty",
      VarArray.contains<Nat>([var], Nat.equal, 1),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "contains first element",
      [var 1, 2, 3].contains(Nat.equal, 1),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "contains last element",
      [var 1, 2, 3].contains(Nat.equal, 3),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "concat",
      VarArray.concat<Int>([var 1, 2, 3], [var 4, 5, 6]),
      M.equals(varArray<Int>(T.intTestable, [var 1, 2, 3, 4, 5, 6]))
    ),
    Suite.test(
      "concat first empty",
      VarArray.concat<Int>([var], [var 4, 5, 6]),
      M.equals(varArray<Int>(T.intTestable, [var 4, 5, 6]))
    ),
    Suite.test(
      "concat second empty",
      VarArray.concat<Int>([var 1, 2, 3], [var]),
      M.equals(varArray<Int>(T.intTestable, [var 1, 2, 3]))
    ),
    Suite.test(
      "concat both empty",
      VarArray.concat<Int>([var], [var]),
      M.equals(varArray<Int>(T.intTestable, [var]))
    ),
    Suite.test(
      "sort",
      VarArray.tabulate<Int>(30, func i = (i * 123) % 100 - 50).sort(Int.compare),
      M.equals(
        varArray(
          T.intTestable,
          bubbleSort(
            VarArray.tabulate<Int>(30, func i = (i * 123) % 100 - 50),
            Int.compare
          )
        )
      )
    ),
    Suite.test(
      "sort",
      [var 1].sort(Nat.compare),
      M.equals(varArray(T.natTestable, [var 1]))
    ),
    Suite.test(
      "sort",
      [var 2, 3, 1].sort(Nat.compare),
      M.equals(varArray(T.natTestable, [var 1, 2, 3]))
    ),
    Suite.test(
      "sort",
      [var 7, 6, 5, 4, 3, 2, 1].sort(Nat.compare),
      M.equals(varArray(T.natTestable, [var 1, 2, 3, 4, 5, 6, 7]))
    ),
    Suite.test(
      "sort",
      [var 7, 6, 5, 4, 3, 2, 1, 0].sort(Nat.compare),
      M.equals(varArray(T.natTestable, [var 0, 1, 2, 3, 4, 5, 6, 7]))
    ),
    Suite.test(
      "sort empty array",
      VarArray.sort<Nat>([var], Nat.compare),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "sort already sorted",
      [var 1, 2, 3, 4, 5].sort(Nat.compare),
      M.equals(varArray(T.natTestable, [var 1, 2, 3, 4, 5]))
    ),
    Suite.test(
      "sort repeated elements",
      [var 2, 2, 2, 2, 2].sort(Nat.compare),
      M.equals(varArray(T.natTestable, [var 2, 2, 2, 2, 2]))
    ),
    Suite.test(
      "reverse",
      [var 0, 1, 2, 2, 3].reverse(),
      M.equals(varArray(T.natTestable, [var 3, 2, 2, 1, 0]))
    ),
    Suite.test(
      "reverse empty",
      VarArray.reverse<Nat>([var]),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "reverse singleton",
      [var 0].reverse(),
      M.equals(varArray(T.natTestable, [var 0]))
    ),
    Suite.test(
      "map",
      [var 1, 2, 3].map(func x = x % 2 == 0),
      M.equals(varArray(T.boolTestable, [var false, true, false]))
    ),
    Suite.test(
      "map empty",
      VarArray.map<Nat, Bool>([var], func x = x % 2 == 0),
      M.equals(varArray<Bool>(T.boolTestable, [var]))
    ),
    Suite.test(
      "filter",
      [var 1, 2, 3, 4, 5, 6].filter(func x = x % 2 == 0),
      M.equals(varArray(T.natTestable, [var 2, 4, 6]))
    ),
    Suite.test(
      "filter empty",
      VarArray.filter<Nat>([var], func x = x % 2 == 0),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "mapEntries",
      [var 1, 2, 3].mapEntries<Nat, Nat>(func(x, i) = x + i),
      M.equals(varArray(T.natTestable, [var 1, 3, 5]))
    ),
    Suite.test(
      "mapEntries empty",
      VarArray.mapEntries<Nat, Nat>([var], func(x, i) = x + i),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "filterMap",
      [var 1, 2, 3, 4, 5, 6].filterMap<Nat, Nat>(func x { if (x % 2 == 0) ?x else null }),
      M.equals(varArray(T.natTestable, [var 2, 4, 6]))
    ),
    Suite.test(
      "filterMap keep all",
      [var 1, 2, 3].filterMap<Nat, Nat>(func x = ?x),
      M.equals(varArray(T.natTestable, [var 1, 2, 3]))
    ),
    Suite.test(
      "filterMap keep none",
      [var 1, 2, 3].filterMap<Nat, Nat>(func _ = null),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "filterMap empty",
      VarArray.filterMap<Nat, Nat>([var], func x { if (x % 2 == 0) ?x else null }),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "mapResult",
      VarArray.mapResult<Int, Nat, Text>(
        [var 1, 2, 3],
        func x { if (x >= 0) { #ok(Int.abs x) } else { #err "error message" } }
      ),
      M.equals(T.result(varArrayTestable(T.natTestable), T.textTestable, #ok([var 1, 2, 3])))
    ),
    Suite.test(
      "mapResult fail first",
      [var -1, 2, 3].mapResult<Int, Nat, Text>(
        func x { if (x >= 0) { #ok(Int.abs x) } else { #err "error message" } }
      ),
      M.equals(T.result(varArrayTestable(T.natTestable), T.textTestable, #err "error message"))
    ),
    Suite.test(
      "mapResult fail last",
      [var 1, 2, -3].mapResult<Int, Nat, Text>(
        func x { if (x >= 0) { #ok(Int.abs x) } else { #err "error message" } }
      ),
      M.equals(T.result(varArrayTestable(T.natTestable), T.textTestable, #err "error message"))
    ),
    Suite.test(
      "mapResult empty",
      VarArray.mapResult<Nat, Nat, Text>(
        [var],
        func x = #ok x
      ),
      M.equals(T.result<[var Nat], Text>(varArrayTestable(T.natTestable), T.textTestable, #ok([var])))
    ),
    Suite.test(
      "flatMap",
      VarArray.flatMap<Int, Int>([var 0, 1, 2], func x = [x, -x].values()),
      M.equals(varArray(T.intTestable, [var 0, 0, 1, -1, 2, -2]))
    ),
    Suite.test(
      "flatMap empty",
      VarArray.flatMap<Int, Int>([var], func x = [x, -x].values()),
      M.equals(varArray<Int>(T.intTestable, [var]))
    ),
    Suite.test(
      "flatMap mix",
      [var 1, 2, 1, 2, 3].flatMap<Nat, Nat>(
        func n = VarArray.tabulate<Nat>(n, func i = i).values()
      ),
      M.equals(varArray(T.natTestable, [var 0, 0, 1, 0, 0, 1, 0, 1, 2]))
    ),
    Suite.test(
      "flatMap mix empty right",
      [var 0, 1, 2, 0, 1, 2, 3, 0].flatMap<Nat, Nat>(
        func n = VarArray.tabulate<Nat>(n, func i = i).values()
      ),
      M.equals(varArray(T.natTestable, [var 0, 0, 1, 0, 0, 1, 0, 1, 2]))
    ),
    Suite.test(
      "flatMap mix empties right",
      [var 0, 1, 2, 0, 1, 2, 3, 0, 0, 0].flatMap<Nat, Nat>(
        func n = VarArray.tabulate<Nat>(n, func i = i).values()
      ),
      M.equals(varArray(T.natTestable, [var 0, 0, 1, 0, 0, 1, 0, 1, 2]))
    ),
    Suite.test(
      "flatMap mix empty left",
      [var 0, 1, 2, 0, 1, 2, 3].flatMap<Nat, Nat>(
        func n = VarArray.tabulate<Nat>(n, func i = i).values()
      ),
      M.equals(varArray(T.natTestable, [var 0, 0, 1, 0, 0, 1, 0, 1, 2]))
    ),
    Suite.test(
      "flatMap mix empties left",
      [var 0, 0, 0, 1, 2, 0, 1, 2, 3].flatMap<Nat, Nat>(
        func n = VarArray.tabulate<Nat>(n, func i = i).values()
      ),
      M.equals(varArray(T.natTestable, [var 0, 0, 1, 0, 0, 1, 0, 1, 2]))
    ),
    Suite.test(
      "flatMap mix empties middle",
      [var 0, 1, 2, 0, 0, 0, 1, 2, 3].flatMap<Nat, Nat>(
        func n = VarArray.tabulate<Nat>(n, func i = i).values()
      ),
      M.equals(varArray(T.natTestable, [var 0, 0, 1, 0, 0, 1, 0, 1, 2]))
    ),
    Suite.test(
      "flatMap mix empties",
      [var 0, 0, 0].flatMap<Nat, Nat>(
        func n = VarArray.tabulate<Nat>(n, func i = i).values()
      ),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "flatMap mix empty",
      VarArray.flatMap<Nat, Nat>(
        [var],
        func n = VarArray.tabulate<Nat>(n, func i = i).values()
      ),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "foldLeft",
      [var "a", "b", "c"].foldLeft("", Text.concat),
      M.equals(T.text("abc"))
    ),
    Suite.test(
      "foldLeft empty",
      VarArray.foldLeft<Text, Text>([var], "base", Text.concat),
      M.equals(T.text("base"))
    ),
    Suite.test(
      "foldRight",
      [var "a", "b", "c"].foldRight("", func(x, acc) = acc # x),
      M.equals(T.text("cba"))
    ),
    Suite.test(
      "foldRight empty",
      VarArray.foldRight<Text, Text>([var], "base", Text.concat),
      M.equals(T.text("base"))
    ),
    Suite.test(
      "flatten",
      VarArray.flatten<Int>([var [var 1, 2, 3], [var], [var 1]]),
      M.equals(varArray<Int>(T.intTestable, [var 1, 2, 3, 1]))
    ),
    Suite.test(
      "flatten empty start",
      VarArray.flatten<Int>([var [var], [var 1, 2, 3], [var], [var 1]]),
      M.equals(varArray<Int>(T.intTestable, [var 1, 2, 3, 1]))
    ),
    Suite.test(
      "flatten empty end",
      VarArray.flatten<Int>([var [var 1, 2, 3], [var], [var 1], [var]]),
      M.equals(varArray<Int>(T.intTestable, [var 1, 2, 3, 1]))
    ),
    Suite.test(
      "flatten singleton",
      VarArray.flatten<Int>([var [var 1, 2, 3]]),
      M.equals(varArray<Int>(T.intTestable, [var 1, 2, 3]))
    ),
    Suite.test(
      "flatten singleton empty",
      VarArray.flatten<Int>([var [var]]),
      M.equals(varArray<Int>(T.intTestable, [var]))
    ),
    Suite.test(
      "flatten empty",
      VarArray.flatten<Int>([var]),
      M.equals(varArray<Int>(T.intTestable, [var]))
    ),
    Suite.test(
      "make",
      VarArray.singleton<Int>(0),
      M.equals(varArray<Int>(T.intTestable, [var 0]))
    ),
    Suite.test(
      "values",
      do {
        var sum = 0;
        for (x in VarArray.values([var 1, 2, 3])) {
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
        for (x in VarArray.values([var])) {
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
        for (x in VarArray.keys([var 1, 2, 3])) {
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
        for (x in VarArray.keys([var])) {
          sum += x
        };
        sum
      },
      M.equals(T.nat(0))
    ),
    Suite.test(
      "sliceToArray if including entire array",
      [var 2, 4, 6, 8, 10].sliceToArray(0, 5),
      M.equals(T.array(T.natTestable, [2, 4, 6, 8, 10]))
    ),
    Suite.test(
      "sliceToArray if including all but last index",
      [var 2, 4, 6, 8, 10].sliceToArray(0, -1),
      M.equals(T.array(T.natTestable, [2, 4, 6, 8]))
    ),
    Suite.test(
      "sliceToArray if including all but first index",
      [var 2, 4, 6, 8, 10].sliceToArray(1, 5),
      M.equals(T.array(T.natTestable, [4, 6, 8, 10]))
    ),
    Suite.test(
      "sliceToArray if including middle of array",
      [var 2, 4, 6, 8, 10].sliceToArray(1, 4),
      M.equals(T.array(T.natTestable, [4, 6, 8]))
    ),
    Suite.test(
      "sliceToArray if including middle of array (negative indices)",
      [var 2, 4, 6, 8, 10].sliceToArray(-4, -1),
      M.equals(T.array(T.natTestable, [4, 6, 8]))
    ),
    Suite.test(
      "sliceToArray if including start, but not end of array",
      [var 2, 4, 6, 8, 10].sliceToArray(0, -2),
      M.equals(T.array(T.natTestable, [2, 4, 6]))
    ),
    Suite.test(
      "sliceToArray if including end, but not start of array",
      [var 2, 4, 6, 8, 10].sliceToArray(2, 5),
      M.equals(T.array(T.natTestable, [6, 8, 10]))
    ),
    Suite.test(
      "sliceToArray if including end, but not start of array (negative indices)",
      [var 2, 4, 6, 8, 10].sliceToArray(-3, 5),
      M.equals(T.array(T.natTestable, [6, 8, 10]))
    ),
    Suite.test(
      "sliceToArray with empty result when start >= end",
      [var 1, 2, 3, 4, 5].sliceToArray(3, 2),
      M.equals(T.array(T.natTestable, []))
    ),
    Suite.test(
      "sliceToArray with negative fromInclusive and positive toExclusive",
      [var 1, 2, 3, 4, 5].sliceToArray(-2, 4),
      M.equals(T.array(T.natTestable, [4]))
    ),
    Suite.test(
      "sliceToArray with negative fromInclusive and zero toExclusive",
      [var 1, 2, 3, 4, 5].sliceToArray(-2, 0),
      M.equals(T.array(T.natTestable, []))
    ),
    Suite.test(
      "sliceToArray with both negative indices where start > end",
      [var 1, 2, 3, 4, 5].sliceToArray(-1, -3),
      M.equals(T.array(T.natTestable, []))
    ),
    Suite.test(
      "sliceToVarArray if including entire array",
      [var 2, 4, 6, 8, 10].sliceToVarArray(0, 5),
      M.equals(varArray(T.natTestable, [var 2, 4, 6, 8, 10]))
    ),
    Suite.test(
      "sliceToVarArray if including all but last index",
      [var 2, 4, 6, 8, 10].sliceToVarArray(0, -1),
      M.equals(varArray(T.natTestable, [var 2, 4, 6, 8]))
    ),
    Suite.test(
      "sliceToVarArray if including all but first index",
      [var 2, 4, 6, 8, 10].sliceToVarArray(1, 5),
      M.equals(varArray(T.natTestable, [var 4, 6, 8, 10]))
    ),
    Suite.test(
      "sliceToVarArray if including middle of array",
      [var 2, 4, 6, 8, 10].sliceToVarArray(1, 4),
      M.equals(varArray(T.natTestable, [var 4, 6, 8]))
    ),
    Suite.test(
      "sliceToVarArray if including middle of array (negative indices)",
      [var 2, 4, 6, 8, 10].sliceToVarArray(-4, -1),
      M.equals(varArray(T.natTestable, [var 4, 6, 8]))
    ),
    Suite.test(
      "sliceToVarArray if including start, but not end of array",
      [var 2, 4, 6, 8, 10].sliceToVarArray(0, -2),
      M.equals(varArray(T.natTestable, [var 2, 4, 6]))
    ),
    Suite.test(
      "sliceToVarArray if including end, but not start of array",
      [var 2, 4, 6, 8, 10].sliceToVarArray(2, 5),
      M.equals(varArray(T.natTestable, [var 6, 8, 10]))
    ),
    Suite.test(
      "sliceToVarArray if including end, but not start of array (negative indices)",
      [var 2, 4, 6, 8, 10].sliceToVarArray(-3, 5),
      M.equals(varArray(T.natTestable, [var 6, 8, 10]))
    ),
    Suite.test(
      "sliceToVarArray with empty result when start >= end",
      [var 1, 2, 3, 4, 5].sliceToVarArray(3, 2),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "sliceToVarArray with negative fromInclusive and positive toExclusive",
      [var 1, 2, 3, 4, 5].sliceToVarArray(-2, 4),
      M.equals(varArray(T.natTestable, [var 4]))
    ),
    Suite.test(
      "sliceToVarArray with negative fromInclusive and zero toExclusive",
      [var 1, 2, 3, 4, 5].sliceToVarArray(-2, 0),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "sliceToVarArray with both negative indices where start > end",
      [var 1, 2, 3, 4, 5].sliceToVarArray(-1, -3),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "nextIndexOf start",
      [var 'c', 'o', 'f', 'f', 'e', 'e'].nextIndexOf(Char.equal, 'c', 0),
      M.equals(T.optional(T.natTestable, ?0))
    ),
    Suite.test(
      "nextIndexOf not found from offset",
      [var 'c', 'o', 'f', 'f', 'e', 'e'].nextIndexOf(Char.equal, 'c', 1),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "nextIndexOf middle",
      [var 'c', 'o', 'f', 'f', 'e', 'e'].nextIndexOf(Char.equal, 'f', 0),
      M.equals(T.optional(T.natTestable, ?2))
    ),
    Suite.test(
      "nextIndexOf repeat",
      [var 'c', 'o', 'f', 'f', 'e', 'e'].nextIndexOf(Char.equal, 'f', 2),
      M.equals(T.optional(T.natTestable, ?2))
    ),
    Suite.test(
      "nextIndexOf start from the middle",
      [var 'c', 'o', 'f', 'f', 'e', 'e'].nextIndexOf(Char.equal, 'f', 3),
      M.equals(T.optional(T.natTestable, ?3))
    ),
    Suite.test(
      "nextIndexOf not found",
      [var 'c', 'o', 'f', 'f', 'e', 'e'].nextIndexOf(Char.equal, 'g', 0),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "nextIndexOf index out of bounds",
      [var 'c', 'o', 'f', 'f', 'e', 'e'].nextIndexOf(Char.equal, 'f', 100),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),

    Suite.test(
      "prevIndexOf first",
      [var 'c', 'o', 'f', 'f', 'e', 'e'].prevIndexOf(Char.equal, 'c', 6),
      M.equals(T.optional(T.natTestable, ?0))
    ),
    Suite.test(
      "prevIndexOf last",
      [var 'c', 'o', 'f', 'f', 'e', 'e'].prevIndexOf(Char.equal, 'e', 6),
      M.equals(T.optional(T.natTestable, ?5))
    ),
    Suite.test(
      "prevIndexOf middle",
      [var 'c', 'o', 'f', 'f', 'e', 'e'].prevIndexOf(Char.equal, 'f', 6),
      M.equals(T.optional(T.natTestable, ?3))
    ),
    Suite.test(
      "prevIndexOf start from the middle",
      [var 'c', 'o', 'f', 'f', 'e', 'e'].prevIndexOf(Char.equal, 'f', 3),
      M.equals(T.optional(T.natTestable, ?2))
    ),
    Suite.test(
      "prevIndexOf existing not found",
      [var 'c', 'o', 'f', 'f', 'e', 'e'].prevIndexOf(Char.equal, 'f', 2),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "prevIndexOf not found",
      [var 'c', 'o', 'f', 'f', 'e', 'e'].prevIndexOf(Char.equal, 'g', 6),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "Iter conversions",
      VarArray.values([var 1, 2, 3]).toVarArray<Nat>(),
      M.equals(varArray(T.natTestable, [var 1, 2, 3]))
    ),
    Suite.test(
      "Iter conversions empty",
      Iter.toVarArray<Nat>(VarArray.values([var])),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "enumerate empty array",
      do {
        var hasItem = false;
        for (_ in [var].enumerate()) {
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
        for ((i, x) in [var 10, 20, 30].enumerate()) {
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
        for ((i, _) in [var 'a', 'b', 'c'].enumerate()) {
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
        for ((_, x) in [var 'a', 'b', 'c'].enumerate()) {
          values #= x.toText()
        };
        values
      },
      M.equals(T.text("abc"))
    ),
    Suite.test(
      "binarySearch found",
      [var 1, 3, 5, 7, 9, 11].binarySearch(Nat.compare, 5) == #found(2),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "binarySearch not found",
      [var 1, 3, 5, 7, 9, 11].binarySearch(Nat.compare, 6) == #insertionIndex(3),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "binarySearch first element",
      do {
        [var 1, 3, 5, 7, 9, 11].binarySearch(Nat.compare, 1) == #found(0)
      },
      M.equals(T.bool(true))
    ),
    Suite.test(
      "binarySearch last element",
      do {
        [var 1, 3, 5, 7, 9, 11].binarySearch(Nat.compare, 11) == #found(5)
      },
      M.equals(T.bool(true))
    ),
    Suite.test(
      "binarySearch empty array",
      do {
        VarArray.binarySearch<Nat>([var], Nat.compare, 5) == #insertionIndex(0)
      },
      M.equals(T.bool(true))
    ),
    Suite.test(
      "binarySearch single element found",
      do {
        [var 42].binarySearch(Nat.compare, 42) == #found(0)
      },
      M.equals(T.bool(true))
    ),
    Suite.test(
      "binarySearch single element not found",
      do {
        [var 42].binarySearch(Nat.compare, 43) == #insertionIndex(1)
      },
      M.equals(T.bool(true))
    ),
    Suite.test(
      "binarySearch duplicates",
      do {
        let result = [var 1, 2, 2, 2, 3].binarySearch(Nat.compare, 2);
        switch result {
          case (#found index) { index >= 1 and index <= 3 };
          case _ { false }
        }
      },
      M.equals(T.bool(true))
    ),
    Suite.test(
      "isSorted empty array",
      VarArray.isSorted<Nat>([var], Nat.compare),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "isSorted single element",
      [var 42].isSorted(Nat.compare),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "isSorted already sorted",
      [var 1, 2, 3, 4, 5].isSorted(Nat.compare),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "isSorted with duplicates",
      [var 1, 2, 2, 3, 3, 3].isSorted(Nat.compare),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "isSorted not sorted",
      [var 1, 3, 2, 4, 5].isSorted(Nat.compare),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "isSorted reverse sorted",
      [var 5, 4, 3, 2, 1].isSorted(Nat.compare),
      M.equals(T.bool(false))
    )
  ]
);

Suite.run(suite)
