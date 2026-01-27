import VarArray "../src/VarArray";
import Int "../src/Int";
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
    display = func(xs : [var A]) : Text = "[var " # joinWith(VarArray.map<A, Text>(xs, testableA.display), ", ") # "]";
    equals = func(xs1 : [var A], xs2 : [var A]) : Bool = VarArray.equal(xs1, xs2, testableA.equals)
  }
};

func varArray<A>(testableA : T.Testable<A>, xs : [var A]) : T.TestableItem<[var A]> {
  let testableAs = varArrayTestable<A>(testableA);
  {
    item = xs;
    display = testableAs.display;
    equals = testableAs.equals
  }
};

// used to test sort
func bubbleSort<T>(array : [var T], compare : (T, T) -> Order.Order) : [var T] {
  let a = VarArray.clone(array);
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
      VarArray.find<Nat>([var 1, 9, 4, 8], func x = x == 9),
      M.equals(T.optional(T.natTestable, ?9))
    ),
    Suite.test(
      "find fail",
      VarArray.find<Nat>([var 1, 9, 4, 8], func _ = false),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "find empty",
      VarArray.find<Nat>([var], func _ = true),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "findIndex",
      VarArray.findIndex<Nat>([var 1, 9, 4, 8], func x = x == 9),
      M.equals(T.optional(T.natTestable, ?1))
    ),
    Suite.test(
      "findIndex fail",
      VarArray.findIndex<Nat>([var 1, 9, 4, 8], func _ = false),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "findIndex empty",
      VarArray.findIndex<Nat>([var], func _ = true),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "contains",
      VarArray.contains<Nat>([var 1, 9, 4, 8], Nat.equal, 9),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "contains not found",
      VarArray.contains<Nat>([var 1, 9, 4, 8], Nat.equal, 5),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "contains empty",
      VarArray.contains<Nat>([var], Nat.equal, 1),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "contains first element",
      VarArray.contains<Nat>([var 1, 2, 3], Nat.equal, 1),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "contains last element",
      VarArray.contains<Nat>([var 1, 2, 3], Nat.equal, 3),
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
      VarArray.sort(VarArray.tabulate<Int>(30, func i = (i * 123) % 100 - 50), Int.compare),
      M.equals(
        varArray<Int>(
          T.intTestable,
          bubbleSort<Int>(
            VarArray.tabulate<Int>(30, func i = (i * 123) % 100 - 50),
            Int.compare
          )
        )
      )
    ),
    Suite.test(
      "sort",
      VarArray.sort([var 1], Nat.compare),
      M.equals(varArray<Nat>(T.natTestable, [var 1]))
    ),
    Suite.test(
      "sort",
      VarArray.sort([var 2, 3, 1], Nat.compare),
      M.equals(varArray<Nat>(T.natTestable, [var 1, 2, 3]))
    ),
    Suite.test(
      "sort",
      VarArray.sort([var 7, 6, 5, 4, 3, 2, 1], Nat.compare),
      M.equals(varArray<Nat>(T.natTestable, [var 1, 2, 3, 4, 5, 6, 7]))
    ),
    Suite.test(
      "sort",
      VarArray.sort([var 7, 6, 5, 4, 3, 2, 1, 0], Nat.compare),
      M.equals(varArray<Nat>(T.natTestable, [var 0, 1, 2, 3, 4, 5, 6, 7]))
    ),
    Suite.test(
      "sort empty array",
      VarArray.sort<Nat>([var], Nat.compare),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "sort already sorted",
      VarArray.sort([var 1, 2, 3, 4, 5], Nat.compare),
      M.equals(varArray<Nat>(T.natTestable, [var 1, 2, 3, 4, 5]))
    ),
    Suite.test(
      "sort repeated elements",
      VarArray.sort([var 2, 2, 2, 2, 2], Nat.compare),
      M.equals(varArray<Nat>(T.natTestable, [var 2, 2, 2, 2, 2]))
    ),
    Suite.test(
      "reverse",
      VarArray.reverse<Nat>([var 0, 1, 2, 2, 3]),
      M.equals(varArray<Nat>(T.natTestable, [var 3, 2, 2, 1, 0]))
    ),
    Suite.test(
      "reverse empty",
      VarArray.reverse<Nat>([var]),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "reverse singleton",
      VarArray.reverse<Nat>([var 0]),
      M.equals(varArray<Nat>(T.natTestable, [var 0]))
    ),
    Suite.test(
      "map",
      VarArray.map<Nat, Bool>([var 1, 2, 3], func x = x % 2 == 0),
      M.equals(varArray<Bool>(T.boolTestable, [var false, true, false]))
    ),
    Suite.test(
      "map empty",
      VarArray.map<Nat, Bool>([var], func x = x % 2 == 0),
      M.equals(varArray<Bool>(T.boolTestable, [var]))
    ),
    Suite.test(
      "filter",
      VarArray.filter<Nat>([var 1, 2, 3, 4, 5, 6], func x = x % 2 == 0),
      M.equals(varArray<Nat>(T.natTestable, [var 2, 4, 6]))
    ),
    Suite.test(
      "filter empty",
      VarArray.filter<Nat>([var], func x = x % 2 == 0),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "mapEntries",
      VarArray.mapEntries<Nat, Nat>([var 1, 2, 3], func(x, i) = x + i),
      M.equals(varArray<Nat>(T.natTestable, [var 1, 3, 5]))
    ),
    Suite.test(
      "mapEntries empty",
      VarArray.mapEntries<Nat, Nat>([var], func(x, i) = x + i),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "filterMap",
      VarArray.filterMap<Nat, Nat>([var 1, 2, 3, 4, 5, 6], func x { if (x % 2 == 0) ?x else null }),
      M.equals(varArray<Nat>(T.natTestable, [var 2, 4, 6]))
    ),
    Suite.test(
      "filterMap keep all",
      VarArray.filterMap<Nat, Nat>([var 1, 2, 3], func x = ?x),
      M.equals(varArray<Nat>(T.natTestable, [var 1, 2, 3]))
    ),
    Suite.test(
      "filterMap keep none",
      VarArray.filterMap<Nat, Nat>([var 1, 2, 3], func _ = null),
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
      M.equals(T.result<[var Nat], Text>(varArrayTestable(T.natTestable), T.textTestable, #ok([var 1, 2, 3])))
    ),
    Suite.test(
      "mapResult fail first",
      VarArray.mapResult<Int, Nat, Text>(
        [var -1, 2, 3],
        func x { if (x >= 0) { #ok(Int.abs x) } else { #err "error message" } }
      ),
      M.equals(T.result<[var Nat], Text>(varArrayTestable(T.natTestable), T.textTestable, #err "error message"))
    ),
    Suite.test(
      "mapResult fail last",
      VarArray.mapResult<Int, Nat, Text>(
        [var 1, 2, -3],
        func x { if (x >= 0) { #ok(Int.abs x) } else { #err "error message" } }
      ),
      M.equals(T.result<[var Nat], Text>(varArrayTestable(T.natTestable), T.textTestable, #err "error message"))
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
      VarArray.flatMap<Int, Int>([var 0, 1, 2], func x = [x, -x].vals()),
      M.equals(varArray<Int>(T.intTestable, [var 0, 0, 1, -1, 2, -2]))
    ),
    Suite.test(
      "flatMap empty",
      VarArray.flatMap<Int, Int>([var], func x = [x, -x].vals()),
      M.equals(varArray<Int>(T.intTestable, [var]))
    ),
    Suite.test(
      "flatMap mix",
      VarArray.flatMap<Nat, Nat>(
        [var 1, 2, 1, 2, 3],
        func n = VarArray.tabulate<Nat>(n, func i = i).vals()
      ),
      M.equals(varArray<Nat>(T.natTestable, [var 0, 0, 1, 0, 0, 1, 0, 1, 2]))
    ),
    Suite.test(
      "flatMap mix empty right",
      VarArray.flatMap<Nat, Nat>(
        [var 0, 1, 2, 0, 1, 2, 3, 0],
        func n = VarArray.tabulate<Nat>(n, func i = i).vals()
      ),
      M.equals(varArray<Nat>(T.natTestable, [var 0, 0, 1, 0, 0, 1, 0, 1, 2]))
    ),
    Suite.test(
      "flatMap mix empties right",
      VarArray.flatMap<Nat, Nat>(
        [var 0, 1, 2, 0, 1, 2, 3, 0, 0, 0],
        func n = VarArray.tabulate<Nat>(n, func i = i).vals()
      ),
      M.equals(varArray<Nat>(T.natTestable, [var 0, 0, 1, 0, 0, 1, 0, 1, 2]))
    ),
    Suite.test(
      "flatMap mix empty left",
      VarArray.flatMap<Nat, Nat>(
        [var 0, 1, 2, 0, 1, 2, 3],
        func n = VarArray.tabulate<Nat>(n, func i = i).vals()
      ),
      M.equals(varArray<Nat>(T.natTestable, [var 0, 0, 1, 0, 0, 1, 0, 1, 2]))
    ),
    Suite.test(
      "flatMap mix empties left",
      VarArray.flatMap<Nat, Nat>(
        [var 0, 0, 0, 1, 2, 0, 1, 2, 3],
        func n = VarArray.tabulate<Nat>(n, func i = i).vals()
      ),
      M.equals(varArray<Nat>(T.natTestable, [var 0, 0, 1, 0, 0, 1, 0, 1, 2]))
    ),
    Suite.test(
      "flatMap mix empties middle",
      VarArray.flatMap<Nat, Nat>(
        [var 0, 1, 2, 0, 0, 0, 1, 2, 3],
        func n = VarArray.tabulate<Nat>(n, func i = i).vals()
      ),
      M.equals(varArray<Nat>(T.natTestable, [var 0, 0, 1, 0, 0, 1, 0, 1, 2]))
    ),
    Suite.test(
      "flatMap mix empties",
      VarArray.flatMap<Nat, Nat>(
        [var 0, 0, 0],
        func n = VarArray.tabulate<Nat>(n, func i = i).vals()
      ),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "flatMap mix empty",
      VarArray.flatMap<Nat, Nat>(
        [var],
        func n = VarArray.tabulate<Nat>(n, func i = i).vals()
      ),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "foldLeft",
      VarArray.foldLeft<Text, Text>([var "a", "b", "c"], "", Text.concat),
      M.equals(T.text("abc"))
    ),
    Suite.test(
      "foldLeft empty",
      VarArray.foldLeft<Text, Text>([var], "base", Text.concat),
      M.equals(T.text("base"))
    ),
    Suite.test(
      "foldRight",
      VarArray.foldRight<Text, Text>([var "a", "b", "c"], "", func(x, acc) = acc # x),
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
      VarArray.sliceToArray<Nat>([var 2, 4, 6, 8, 10], 0, 5),
      M.equals(T.array(T.natTestable, [2, 4, 6, 8, 10]))
    ),
    Suite.test(
      "sliceToArray if including all but last index",
      VarArray.sliceToArray<Nat>([var 2, 4, 6, 8, 10], 0, -1),
      M.equals(T.array(T.natTestable, [2, 4, 6, 8]))
    ),
    Suite.test(
      "sliceToArray if including all but first index",
      VarArray.sliceToArray<Nat>([var 2, 4, 6, 8, 10], 1, 5),
      M.equals(T.array(T.natTestable, [4, 6, 8, 10]))
    ),
    Suite.test(
      "sliceToArray if including middle of array",
      VarArray.sliceToArray<Nat>([var 2, 4, 6, 8, 10], 1, 4),
      M.equals(T.array(T.natTestable, [4, 6, 8]))
    ),
    Suite.test(
      "sliceToArray if including middle of array (negative indices)",
      VarArray.sliceToArray<Nat>([var 2, 4, 6, 8, 10], -4, -1),
      M.equals(T.array(T.natTestable, [4, 6, 8]))
    ),
    Suite.test(
      "sliceToArray if including start, but not end of array",
      VarArray.sliceToArray<Nat>([var 2, 4, 6, 8, 10], 0, -2),
      M.equals(T.array(T.natTestable, [2, 4, 6]))
    ),
    Suite.test(
      "sliceToArray if including end, but not start of array",
      VarArray.sliceToArray<Nat>([var 2, 4, 6, 8, 10], 2, 5),
      M.equals(T.array(T.natTestable, [6, 8, 10]))
    ),
    Suite.test(
      "sliceToArray if including end, but not start of array (negative indices)",
      VarArray.sliceToArray<Nat>([var 2, 4, 6, 8, 10], -3, 5),
      M.equals(T.array(T.natTestable, [6, 8, 10]))
    ),
    Suite.test(
      "sliceToArray with empty result when start >= end",
      VarArray.sliceToArray<Nat>([var 1, 2, 3, 4, 5], 3, 2),
      M.equals(T.array<Nat>(T.natTestable, []))
    ),
    Suite.test(
      "sliceToArray with negative fromInclusive and positive toExclusive",
      VarArray.sliceToArray<Nat>([var 1, 2, 3, 4, 5], -2, 4),
      M.equals(T.array(T.natTestable, [4]))
    ),
    Suite.test(
      "sliceToArray with negative fromInclusive and zero toExclusive",
      VarArray.sliceToArray<Nat>([var 1, 2, 3, 4, 5], -2, 0),
      M.equals(T.array<Nat>(T.natTestable, []))
    ),
    Suite.test(
      "sliceToArray with both negative indices where start > end",
      VarArray.sliceToArray<Nat>([var 1, 2, 3, 4, 5], -1, -3),
      M.equals(T.array<Nat>(T.natTestable, []))
    ),
    Suite.test(
      "sliceToVarArray if including entire array",
      VarArray.sliceToVarArray<Nat>([var 2, 4, 6, 8, 10], 0, 5),
      M.equals(varArray<Nat>(T.natTestable, [var 2, 4, 6, 8, 10]))
    ),
    Suite.test(
      "sliceToVarArray if including all but last index",
      VarArray.sliceToVarArray<Nat>([var 2, 4, 6, 8, 10], 0, -1),
      M.equals(varArray<Nat>(T.natTestable, [var 2, 4, 6, 8]))
    ),
    Suite.test(
      "sliceToVarArray if including all but first index",
      VarArray.sliceToVarArray<Nat>([var 2, 4, 6, 8, 10], 1, 5),
      M.equals(varArray<Nat>(T.natTestable, [var 4, 6, 8, 10]))
    ),
    Suite.test(
      "sliceToVarArray if including middle of array",
      VarArray.sliceToVarArray<Nat>([var 2, 4, 6, 8, 10], 1, 4),
      M.equals(varArray<Nat>(T.natTestable, [var 4, 6, 8]))
    ),
    Suite.test(
      "sliceToVarArray if including middle of array (negative indices)",
      VarArray.sliceToVarArray<Nat>([var 2, 4, 6, 8, 10], -4, -1),
      M.equals(varArray<Nat>(T.natTestable, [var 4, 6, 8]))
    ),
    Suite.test(
      "sliceToVarArray if including start, but not end of array",
      VarArray.sliceToVarArray<Nat>([var 2, 4, 6, 8, 10], 0, -2),
      M.equals(varArray<Nat>(T.natTestable, [var 2, 4, 6]))
    ),
    Suite.test(
      "sliceToVarArray if including end, but not start of array",
      VarArray.sliceToVarArray<Nat>([var 2, 4, 6, 8, 10], 2, 5),
      M.equals(varArray<Nat>(T.natTestable, [var 6, 8, 10]))
    ),
    Suite.test(
      "sliceToVarArray if including end, but not start of array (negative indices)",
      VarArray.sliceToVarArray<Nat>([var 2, 4, 6, 8, 10], -3, 5),
      M.equals(varArray<Nat>(T.natTestable, [var 6, 8, 10]))
    ),
    Suite.test(
      "sliceToVarArray with empty result when start >= end",
      VarArray.sliceToVarArray<Nat>([var 1, 2, 3, 4, 5], 3, 2),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "sliceToVarArray with negative fromInclusive and positive toExclusive",
      VarArray.sliceToVarArray<Nat>([var 1, 2, 3, 4, 5], -2, 4),
      M.equals(varArray<Nat>(T.natTestable, [var 4]))
    ),
    Suite.test(
      "sliceToVarArray with negative fromInclusive and zero toExclusive",
      VarArray.sliceToVarArray<Nat>([var 1, 2, 3, 4, 5], -2, 0),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "sliceToVarArray with both negative indices where start > end",
      VarArray.sliceToVarArray<Nat>([var 1, 2, 3, 4, 5], -1, -3),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "nextIndexOf start",
      VarArray.nextIndexOf<Char>([var 'c', 'o', 'f', 'f', 'e', 'e'], Char.equal, 'c', 0),
      M.equals(T.optional(T.natTestable, ?0))
    ),
    Suite.test(
      "nextIndexOf not found from offset",
      VarArray.nextIndexOf<Char>([var 'c', 'o', 'f', 'f', 'e', 'e'], Char.equal, 'c', 1),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "nextIndexOf middle",
      VarArray.nextIndexOf<Char>([var 'c', 'o', 'f', 'f', 'e', 'e'], Char.equal, 'f', 0),
      M.equals(T.optional(T.natTestable, ?2))
    ),
    Suite.test(
      "nextIndexOf repeat",
      VarArray.nextIndexOf<Char>([var 'c', 'o', 'f', 'f', 'e', 'e'], Char.equal, 'f', 2),
      M.equals(T.optional(T.natTestable, ?2))
    ),
    Suite.test(
      "nextIndexOf start from the middle",
      VarArray.nextIndexOf<Char>([var 'c', 'o', 'f', 'f', 'e', 'e'], Char.equal, 'f', 3),
      M.equals(T.optional(T.natTestable, ?3))
    ),
    Suite.test(
      "nextIndexOf not found",
      VarArray.nextIndexOf<Char>([var 'c', 'o', 'f', 'f', 'e', 'e'], Char.equal, 'g', 0),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "nextIndexOf index out of bounds",
      VarArray.nextIndexOf<Char>([var 'c', 'o', 'f', 'f', 'e', 'e'], Char.equal, 'f', 100),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),

    Suite.test(
      "prevIndexOf first",
      VarArray.prevIndexOf<Char>([var 'c', 'o', 'f', 'f', 'e', 'e'], Char.equal, 'c', 6),
      M.equals(T.optional(T.natTestable, ?0))
    ),
    Suite.test(
      "prevIndexOf last",
      VarArray.prevIndexOf<Char>([var 'c', 'o', 'f', 'f', 'e', 'e'], Char.equal, 'e', 6),
      M.equals(T.optional(T.natTestable, ?5))
    ),
    Suite.test(
      "prevIndexOf middle",
      VarArray.prevIndexOf<Char>([var 'c', 'o', 'f', 'f', 'e', 'e'], Char.equal, 'f', 6),
      M.equals(T.optional(T.natTestable, ?3))
    ),
    Suite.test(
      "prevIndexOf start from the middle",
      VarArray.prevIndexOf<Char>([var 'c', 'o', 'f', 'f', 'e', 'e'], Char.equal, 'f', 3),
      M.equals(T.optional(T.natTestable, ?2))
    ),
    Suite.test(
      "prevIndexOf existing not found",
      VarArray.prevIndexOf<Char>([var 'c', 'o', 'f', 'f', 'e', 'e'], Char.equal, 'f', 2),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "prevIndexOf not found",
      VarArray.prevIndexOf<Char>([var 'c', 'o', 'f', 'f', 'e', 'e'], Char.equal, 'g', 6),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "Iter conversions",
      VarArray.fromIter<Nat>(VarArray.values([var 1, 2, 3])),
      M.equals(varArray<Nat>(T.natTestable, [var 1, 2, 3]))
    ),
    Suite.test(
      "Iter conversions empty",
      VarArray.fromIter<Nat>(VarArray.values([var])),
      M.equals(varArray<Nat>(T.natTestable, [var]))
    ),
    Suite.test(
      "enumerate empty array",
      do {
        var hasItem = false;
        for (_ in VarArray.enumerate([var])) {
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
        for ((i, x) in VarArray.enumerate([var 10, 20, 30])) {
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
        for ((i, _) in VarArray.enumerate([var 'a', 'b', 'c'])) {
          indices #= Nat.toText(i)
        };
        indices
      },
      M.equals(T.text("012"))
    ),
    Suite.test(
      "enumerate preserves values",
      do {
        var values = "";
        for ((_, x) in VarArray.enumerate([var 'a', 'b', 'c'])) {
          values #= Char.toText(x)
        };
        values
      },
      M.equals(T.text("abc"))
    ),
    Suite.test(
      "binarySearch found",
      VarArray.binarySearch<Nat>([var 1, 3, 5, 7, 9, 11], Nat.compare, 5) == #found(2),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "binarySearch not found",
      VarArray.binarySearch<Nat>([var 1, 3, 5, 7, 9, 11], Nat.compare, 6) == #insertionIndex(3),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "binarySearch first element",
      do {
        VarArray.binarySearch<Nat>([var 1, 3, 5, 7, 9, 11], Nat.compare, 1) == #found(0)
      },
      M.equals(T.bool(true))
    ),
    Suite.test(
      "binarySearch last element",
      do {
        VarArray.binarySearch<Nat>([var 1, 3, 5, 7, 9, 11], Nat.compare, 11) == #found(5)
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
        VarArray.binarySearch<Nat>([var 42], Nat.compare, 42) == #found(0)
      },
      M.equals(T.bool(true))
    ),
    Suite.test(
      "binarySearch single element not found",
      do {
        VarArray.binarySearch<Nat>([var 42], Nat.compare, 43) == #insertionIndex(1)
      },
      M.equals(T.bool(true))
    ),
    Suite.test(
      "binarySearch duplicates",
      do {
        let result = VarArray.binarySearch<Nat>([var 1, 2, 2, 2, 3], Nat.compare, 2);
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
      VarArray.isSorted<Nat>([var 42], Nat.compare),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "isSorted already sorted",
      VarArray.isSorted<Nat>([var 1, 2, 3, 4, 5], Nat.compare),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "isSorted with duplicates",
      VarArray.isSorted<Nat>([var 1, 2, 2, 3, 3, 3], Nat.compare),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "isSorted not sorted",
      VarArray.isSorted<Nat>([var 1, 3, 2, 4, 5], Nat.compare),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "isSorted reverse sorted",
      VarArray.isSorted<Nat>([var 5, 4, 3, 2, 1], Nat.compare),
      M.equals(T.bool(false))
    )
  ]
);

Suite.run(suite)
