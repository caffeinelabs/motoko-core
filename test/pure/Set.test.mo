// @testmode wasi

import Set "../../src/pure/Set";
import Array "../../src/Array";
import Nat "../../src/Nat";
import Int "../../src/Int";
import Iter "../../src/Iter";
import Debug "../../src/Debug";
import Runtime "../../src/Runtime";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

let entryTestable = T.natTestable;

class SetMatcher(expected : [Nat]) : M.Matcher<Set.Set<Nat>> {
  public func describeMismatch(actual : Set.Set<Nat>, _description : M.Description) {
    Debug.print(debug_show (Iter.toArray(Set.values(actual))) # " should be " # debug_show (expected))
  };

  public func matches(actual : Set.Set<Nat>) : Bool {
    Iter.toArray(Set.values(actual)) == expected
  }
};

func insert(s : Set.Set<Nat>, key : Nat) : Set.Set<Nat> {
  let s1 = Set.add(s, Nat.compare, key);
  Set.assertValid(s1, Nat.compare);
  s1
};

func concatenateKeys(key : Nat, accum : Text) : Text {
  accum # debug_show (key)
};

func concatenateKeys2(accum : Text, key : Nat) : Text {
  accum # debug_show (key)
};

func containsAll(set : Set.Set<Nat>, elems : [Nat]) {
  for (elem in elems.vals()) {
    assert (Set.contains(set, Nat.compare, elem))
  }
};

func clear(initialSet : Set.Set<Nat>) : Set.Set<Nat> {
  var set = initialSet;
  for (elem in Set.values(initialSet)) {
    let newSet = Set.remove(set, Nat.compare, elem);
    set := newSet;
    Set.assertValid(set, Nat.compare)
  };
  set
};

func add1(x : Nat) : Nat { x + 1 };

func ifElemLessThan(threshold : Nat, f : Nat -> Nat) : Nat -> ?Nat = func(x) {
  if (x < threshold) ?f(x) else null
};

/* --------------------------------------- */

var buildTestSet = func() : Set.Set<Nat> {
  Set.empty()
};

run(
  suite(
    "empty",
    [
      test(
        "size",
        Set.size(buildTestSet()),
        M.equals(T.nat(0))
      ),
      test(
        "values",
        Iter.toArray(Set.values(buildTestSet())),
        M.equals(T.array<Nat>(entryTestable, []))
      ),
      test(
        "reverseValues",
        Iter.toArray(Set.reverseValues(buildTestSet())),
        M.equals(T.array<Nat>(entryTestable, []))
      ),
      test(
        "empty from iter",
        Set.fromIter(([] : [Nat]).values(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "contains absent",
        Set.contains(buildTestSet(), Nat.compare, 0),
        M.equals(T.bool(false))
      ),
      test(
        "empty right fold",
        Set.foldRight(buildTestSet(), "", concatenateKeys),
        M.equals(T.text(""))
      ),
      test(
        "empty left fold",
        Set.foldLeft(buildTestSet(), "", concatenateKeys2),
        M.equals(T.text(""))
      ),
      test(
        "for each",
        do {
          let set = Set.empty<Nat>();
          Set.forEach<Nat>(
            set,
            func(_) {
              Runtime.trap("test failed")
            }
          );
          Set.size(set)
        },
        M.equals(T.nat(0))
      ),
      test(
        "filter",
        do {
          let input = Set.empty<Nat>();
          let output = Set.filter(
            input,
            Nat.compare,
            func(_) {
              Runtime.trap("test failed")
            }
          );
          Set.size(output)
        },
        M.equals(T.nat(0))
      ),
      test(
        "traverse empty set",
        Set.map(buildTestSet(), Nat.compare, add1),
        SetMatcher([])
      ),
      test(
        "empty filter map",
        Set.filterMap(buildTestSet(), Nat.compare, ifElemLessThan(0, add1)),
        SetMatcher([])
      ),
      test(
        "is empty",
        Set.isEmpty(buildTestSet()),
        M.equals(T.bool(true))
      ),
      test(
        "max",
        Set.max(buildTestSet()),
        M.equals(T.optional(entryTestable, null : ?Nat))
      ),
      test(
        "min",
        Set.min(buildTestSet()),
        M.equals(T.optional(entryTestable, null : ?Nat))
      ),
      test(
        "compare",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.empty<Nat>();
          assert (Set.compare(set1, set2, Nat.compare) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "join",
        do {
          let set1 = Set.fromIter(([] : [Nat]).values(), Nat.compare);
          let set2 = set1;
          let set3 = set2;
          let combined = Set.join(Array.values([set1, set2, set3]), Nat.compare);
          Set.size(combined)
        },
        M.equals(T.nat(0))
      ),
      test(
        "flatten",
        do {
          let subSet1 = Set.fromIter(([] : [Nat]).values(), Nat.compare);
          let subSet2 = subSet1;
          let subSet3 = subSet2;
          let iterator = Array.values([subSet1, subSet2, subSet3]);
          let setOfSets = Set.fromIter(iterator, func(first, second) { Set.compare(first, second, Nat.compare) });
          let combined = Set.flatten(setOfSets, Nat.compare);
          Set.size(combined)
        },
        M.equals(T.nat(0))
      )
    ]
  )
);

/* --------------------------------------- */

buildTestSet := func() : Set.Set<Nat> {
  insert(Set.empty(), 0)
};

var expected = [0];

run(
  suite(
    "singleton",
    [
      test(
        "size",
        Set.size(buildTestSet()),
        M.equals(T.nat(1))
      ),
      test(
        "values",
        Iter.toArray(Set.values(buildTestSet())),
        M.equals(T.array<Nat>(entryTestable, expected))
      ),
      test(
        "reverseValues",
        Iter.toArray(Set.reverseValues(buildTestSet())),
        M.equals(T.array<Nat>(entryTestable, expected))
      ),
      test(
        "from iter",
        Set.fromIter(Array.values(expected), Nat.compare),
        SetMatcher(expected)
      ),
      test(
        "contains",
        Set.contains(buildTestSet(), Nat.compare, 0),
        M.equals(T.bool(true))
      ),
      test(
        "remove",
        Set.remove(buildTestSet(), Nat.compare, 0),
        SetMatcher([])
      ),
      test(
        "for each",
        do {
          let set = buildTestSet();
          Set.forEach<Nat>(
            set,
            func(number) {
              assert (number == 0)
            }
          );
          Set.size(set)
        },
        M.equals(T.nat(1))
      ),
      test(
        "filter",
        do {
          let input = buildTestSet();
          let output = Set.filter(
            input,
            Nat.compare,
            func(number) {
              assert (number == 0);
              true
            }
          );
          assert (Set.equal(input, output, Nat.compare));
          Set.size(output)
        },
        M.equals(T.nat(1))
      ),
      test(
        "right fold",
        Set.foldRight(buildTestSet(), "", concatenateKeys),
        M.equals(T.text("0"))
      ),
      test(
        "left fold",
        Set.foldLeft(buildTestSet(), "", concatenateKeys2),
        M.equals(T.text("0"))
      ),
      test(
        "traverse set",
        Set.map(buildTestSet(), Nat.compare, add1),
        SetMatcher([1])
      ),
      test(
        "filterMap / filter all",
        Set.filterMap(buildTestSet(), Nat.compare, ifElemLessThan(0, add1)),
        SetMatcher([])
      ),
      test(
        "filterMap / no filter",
        Set.filterMap(buildTestSet(), Nat.compare, ifElemLessThan(1, add1)),
        SetMatcher([1])
      ),
      test(
        "is empty",
        Set.isEmpty(buildTestSet()),
        M.equals(T.bool(false))
      ),
      test(
        "max",
        Set.max(buildTestSet()),
        M.equals(T.optional(entryTestable, ?0))
      ),
      test(
        "min",
        Set.min(buildTestSet()),
        M.equals(T.optional(entryTestable, ?0))
      ),
      test(
        "all",
        Set.all<Nat>(buildTestSet(), func(k) = (k == 0)),
        M.equals(T.bool(true))
      ),
      test(
        "any",
        Set.any<Nat>(buildTestSet(), func(k) = (k == 0)),
        M.equals(T.bool(true))
      ),
      test(
        "compare less",
        do {
          let set1 = Set.singleton(0);
          let set2 = Set.singleton(1);
          assert (Set.compare(set1, set2, Nat.compare) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare equal",
        do {
          let set1 = Set.singleton(0);
          let set2 = Set.singleton(0);
          assert (Set.compare(set1, set2, Nat.compare) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater key",
        do {
          let set1 = Set.singleton(1);
          let set2 = Set.singleton(0);
          assert (Set.compare(set1, set2, Nat.compare) == #greater);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "join",
        do {
          let set1 = Set.singleton(0);
          let set2 = Set.singleton(1);
          let set3 = Set.singleton(2);
          let combined = Set.join(Array.values([set1, set2, set3]), Nat.compare);
          Iter.toArray(Set.values(combined))
        },
        M.equals(
          T.array<Nat>(
            T.natTestable,
            [0, 1, 2]
          )
        )
      ),
      test(
        "flatten",
        do {
          let subSet1 = Set.singleton(0);
          let subSet2 = Set.singleton(1);
          let subSet3 = Set.singleton(2);
          let iterator = Array.values([subSet1, subSet2, subSet3]);
          let setOfSets = Set.fromIter(iterator, func(first, second) { Set.compare(first, second, Nat.compare) });
          let combined = Set.flatten(setOfSets, Nat.compare);
          Iter.toArray(Set.values(combined))
        },
        M.equals(
          T.array<Nat>(
            T.natTestable,
            [0, 1, 2]
          )
        )
      )
    ]
  )
);

/* --------------------------------------- */

expected := [0, 1, 2];

func rebalanceTests(buildTestSet : () -> Set.Set<Nat>) : [Suite.Suite] = [
  test(
    "size",
    Set.size(buildTestSet()),
    M.equals(T.nat(3))
  ),
  test(
    "Set match",
    buildTestSet(),
    SetMatcher(expected)
  ),
  test(
    "values",
    Iter.toArray(Set.values(buildTestSet())),
    M.equals(T.array<Nat>(entryTestable, expected))
  ),
  test(
    "reverseValues",
    Array.reverse(Iter.toArray(Set.reverseValues(buildTestSet()))),
    M.equals(T.array<Nat>(entryTestable, expected))
  ),
  test(
    "from iter",
    Set.fromIter(Array.values(expected), Nat.compare),
    SetMatcher(expected)
  ),
  test(
    "contains all",
    do {
      let set = buildTestSet();
      containsAll(set, [0, 1, 2]);
      set
    },
    SetMatcher(expected)
  ),
  test(
    "clear",
    clear(buildTestSet()),
    SetMatcher([])
  ),
  test(
    "right fold",
    Set.foldRight(buildTestSet(), "", concatenateKeys),
    M.equals(T.text("210"))
  ),
  test(
    "left fold",
    Set.foldLeft(buildTestSet(), "", concatenateKeys2),
    M.equals(T.text("012"))
  ),
  test(
    "traverse set",
    Set.map(buildTestSet(), Nat.compare, add1),
    SetMatcher([1, 2, 3])
  ),
  test(
    "traverse set/reshape",
    Set.map(buildTestSet(), Nat.compare, func(x : Nat) : Nat { 5 }),
    SetMatcher([5])
  ),
  test(
    "for each",
    do {
      let set = buildTestSet();
      var index = 0;
      Set.forEach<Nat>(
        set,
        func(element) {
          assert (element == index);
          index += 1
        }
      );
      Set.size(set)
    },
    M.equals(T.nat(Set.size(buildTestSet())))
  ),
  test(
    "filter",
    do {
      let input = buildTestSet();
      let output = Set.filter(
        input,
        Nat.compare,
        func(number) {
          number % 2 == 0
        }
      );
      for (index in Nat.range(0, Set.size(input))) {
        let present = Set.contains(output, Nat.compare, index);
        if (index % 2 == 0) {
          assert (present)
        } else {
          assert (not present)
        }
      };
      Set.size(output)
    },
    M.equals(T.nat((Set.size(buildTestSet()) + 1) / 2))
  ),
  test(
    "filterMap / filter all",
    Set.filterMap(buildTestSet(), Nat.compare, ifElemLessThan(0, add1)),
    SetMatcher([])
  ),
  test(
    "filterMap / filter one",
    Set.filterMap(buildTestSet(), Nat.compare, ifElemLessThan(1, add1)),
    SetMatcher([1])
  ),
  test(
    "filterMap / no filer",
    Set.filterMap(buildTestSet(), Nat.compare, ifElemLessThan(3, add1)),
    SetMatcher([1, 2, 3])
  ),
  test(
    "is empty",
    Set.isEmpty(buildTestSet()),
    M.equals(T.bool(false))
  ),
  test(
    "max",
    Set.max(buildTestSet()),
    M.equals(T.optional(entryTestable, ?2))
  ),
  test(
    "min",
    Set.min(buildTestSet()),
    M.equals(T.optional(entryTestable, ?0))
  ),
  test(
    "all true",
    Set.all<Nat>(buildTestSet(), func(k) = (k >= 0)),
    M.equals(T.bool(true))
  ),
  test(
    "all false",
    Set.all<Nat>(buildTestSet(), func(k) = (k > 0)),
    M.equals(T.bool(false))
  ),
  test(
    "any true",
    Set.any<Nat>(buildTestSet(), func(k) = (k >= 2)),
    M.equals(T.bool(true))
  ),
  test(
    "any false",
    Set.any<Nat>(buildTestSet(), func(k) = (k > 2)),
    M.equals(T.bool(false))
  ),
  test(
    "compare less key",
    do {
      let set1 = buildTestSet() |> Set.remove(_, Nat.compare, Set.size(_) - 1 : Nat);
      let set2 = buildTestSet();
      assert (Set.compare(set1, set2, Nat.compare) == #less);
      true
    },
    M.equals(T.bool(true))
  ),
  test(
    "compare equal",
    do {
      let set1 = buildTestSet();
      let set2 = buildTestSet();
      assert (Set.compare(set1, set2, Nat.compare) == #equal);
      true
    },
    M.equals(T.bool(true))
  ),
  test(
    "compare greater key",
    do {
      let set1 = buildTestSet();
      let set2 = buildTestSet() |> Set.remove(_, Nat.compare, Set.size(_) - 1 : Nat);

      assert (Set.compare(set1, set2, Nat.compare) == #greater);
      true
    },
    M.equals(T.bool(true))
  ),
  test(
    "join",
    do {
      let set1 = Set.map(buildTestSet(), Int.compare, func(number) { +number });
      let set2 = Set.map(buildTestSet(), Int.compare, func(number) { -number });
      let set3 = Set.fromIter(Array.values([-1, 1]), Int.compare);
      let combined = Set.join(Array.values([set1, set2, set3]), Int.compare);
      Iter.toArray(Set.values(combined))
    },
    do {
      let size = Set.size(buildTestSet());
      M.equals(
        T.array<Int>(
          T.intTestable,
          Array.tabulate<Int>(
            size * 2 - 1 : Nat,
            func(index) {
              index + 1 - size
            }
          )
        )
      )
    }
  ),
  test(
    "flatten",
    do {
      let subSet1 = Set.map(buildTestSet(), Int.compare, func(number) { +number });
      let subSet2 = Set.map(buildTestSet(), Int.compare, func(number) { -number });
      let subSet3 = Set.fromIter(Array.values([-1, 1]), Int.compare);
      let iterator = Array.values([subSet1, subSet2, subSet3]);
      let setOfSets = Set.fromIter(iterator, func(first, second) { Set.compare(first, second, Int.compare) });
      let combined = Set.flatten(setOfSets, Int.compare);
      Iter.toArray(Set.values(combined))
    },
    do {
      let size = Set.size(buildTestSet());
      M.equals(
        T.array<Int>(
          T.intTestable,
          Array.tabulate<Int>(
            size * 2 - 1 : Nat,
            func(index) {
              index + 1 - size
            }
          )
        )
      )
    }
  )
];

buildTestSet := func() : Set.Set<Nat> {
  var set = Set.empty<Nat>();
  set := insert(set, 2);
  set := insert(set, 1);
  set := insert(set, 0);
  set
};

run(suite("rebalance left, left", rebalanceTests(buildTestSet)));

/* --------------------------------------- */

buildTestSet := func() : Set.Set<Nat> {
  var set = Set.empty<Nat>();
  set := insert(set, 2);
  set := insert(set, 0);
  set := insert(set, 1);
  set
};

run(suite("rebalance left, right", rebalanceTests(buildTestSet)));

/* --------------------------------------- */

buildTestSet := func() : Set.Set<Nat> {
  var set = Set.empty<Nat>();
  set := insert(set, 0);
  set := insert(set, 2);
  set := insert(set, 1);
  set
};

run(suite("rebalance right, left", rebalanceTests(buildTestSet)));

/* --------------------------------------- */

buildTestSet := func() : Set.Set<Nat> {
  var set = Set.empty<Nat>();
  set := insert(set, 0);
  set := insert(set, 1);
  set := insert(set, 2);
  set
};

run(suite("rebalance right, right", rebalanceTests(buildTestSet)));

/* --------------------------------------- */

run(
  suite(
    "repeated operations",
    [
      test(
        "repeated add",
        do {
          var set = buildTestSet();
          assert (Set.contains(set, Nat.compare, 1));
          set := Set.add(set, Nat.compare, 1);
          Set.size(set)
        },
        M.equals(T.nat(3))
      ),
      test(
        "repeated remove",
        do {
          var set = buildTestSet();
          set := Set.remove(set, Nat.compare, 1);
          Set.remove(set, Nat.compare, 1)
        },
        SetMatcher([0, 2])
      ),
      test(
        "repeated insert",
        do {
          var set = buildTestSet();
          assert (Set.contains(set, Nat.compare, 1));
          let (_, changed) = Set.insert(set, Nat.compare, 1);
          changed
        },
        M.equals(T.bool(false))
      ),
      test(
        "repeated delete",
        do {
          var set = buildTestSet();
          let (set1, true) = Set.delete(set, Nat.compare, 1) else Runtime.unreachable();
          let (_, changed) = Set.delete(set1, Nat.compare, 1);
          changed
        },
        M.equals(T.bool(false))
      )

    ]
  )
);

/* --------------------------------------- */

let buildTestSet012 = func() : Set.Set<Nat> {
  var set = Set.empty<Nat>();
  set := insert(set, 0);
  set := insert(set, 1);
  set := insert(set, 2);
  set
};

let buildTestSet01 = func() : Set.Set<Nat> {
  var set = Set.empty<Nat>();
  set := insert(set, 0);
  set := insert(set, 1);
  set
};

let buildTestSet234 = func() : Set.Set<Nat> {
  var set = Set.empty<Nat>();
  set := insert(set, 2);
  set := insert(set, 3);
  set := insert(set, 4);
  set
};

let buildTestSet345 = func() : Set.Set<Nat> {
  var set = Set.empty<Nat>();
  set := insert(set, 5);
  set := insert(set, 3);
  set := insert(set, 4);
  set
};

run(
  suite(
    "set operations",
    [
      test(
        "subset/subset of itself",
        Set.isSubset(buildTestSet012(), buildTestSet012(), Nat.compare),
        M.equals(T.bool(true))
      ),
      test(
        "subset/empty set is subset of itself",
        Set.isSubset(Set.empty(), Set.empty(), Nat.compare),
        M.equals(T.bool(true))
      ),
      test(
        "subset/empty set is subset of another set",
        Set.isSubset(Set.empty(), buildTestSet012(), Nat.compare),
        M.equals(T.bool(true))
      ),
      test(
        "subset/subset",
        Set.isSubset(buildTestSet01(), buildTestSet012(), Nat.compare),
        M.equals(T.bool(true))
      ),
      test(
        "subset/not subset",
        Set.isSubset(buildTestSet012(), buildTestSet01(), Nat.compare),
        M.equals(T.bool(false))
      ),
      test(
        "equal/empty set",
        Set.equal(Set.empty(), Set.empty(), Nat.compare),
        M.equals(T.bool(true))
      ),
      test(
        "equal/equal",
        Set.equal(buildTestSet012(), buildTestSet012(), Nat.compare),
        M.equals(T.bool(true))
      ),
      test(
        "equal/not equal",
        Set.equal(buildTestSet012(), buildTestSet01(), Nat.compare),
        M.equals(T.bool(false))
      ),
      test(
        "union/empty set",
        Set.union(Set.empty(), Set.empty(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "union/union with empty set",
        Set.union(buildTestSet012(), Set.empty(), Nat.compare),
        SetMatcher([0, 1, 2])
      ),
      test(
        "union/union with itself",
        Set.union(buildTestSet012(), buildTestSet012(), Nat.compare),
        SetMatcher([0, 1, 2])
      ),
      test(
        "union/union with subset",
        Set.union(buildTestSet012(), buildTestSet01(), Nat.compare),
        SetMatcher([0, 1, 2])
      ),
      test(
        "union/union expand",
        Set.union(buildTestSet012(), buildTestSet234(), Nat.compare),
        SetMatcher([0, 1, 2, 3, 4])
      ),
      test(
        "intersection/empty set",
        Set.intersection(Set.empty(), Set.empty(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "intersection/intersection with empty set",
        Set.intersection(buildTestSet012(), Set.empty(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "intersection/intersection with itself",
        Set.intersection(buildTestSet012(), buildTestSet012(), Nat.compare),
        SetMatcher([0, 1, 2])
      ),
      test(
        "intersection/intersection with subset",
        Set.intersection(buildTestSet012(), buildTestSet01(), Nat.compare),
        SetMatcher([0, 1])
      ),
      test(
        "intersection/intersection",
        Set.intersection(buildTestSet012(), buildTestSet234(), Nat.compare),
        SetMatcher([2])
      ),
      test(
        "intersection/no intersectionion",
        Set.intersection(buildTestSet012(), buildTestSet345(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "difference/empty set",
        Set.difference(Set.empty(), Set.empty(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "difference/difference with empty set",
        Set.difference(buildTestSet012(), Set.empty(), Nat.compare),
        SetMatcher([0, 1, 2])
      ),
      test(
        "difference/difference with empty set 2",
        Set.difference(Set.empty(), buildTestSet012(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "difference/difference with subset",
        Set.difference(buildTestSet012(), buildTestSet01(), Nat.compare),
        SetMatcher([2])
      ),
      test(
        "difference/difference with subset 2",
        Set.difference(buildTestSet01(), buildTestSet012(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "difference/difference",
        Set.difference(buildTestSet012(), buildTestSet234(), Nat.compare),
        SetMatcher([0, 1])
      ),
      test(
        "difference/difference no intersection",
        Set.difference(buildTestSet012(), buildTestSet345(), Nat.compare),
        SetMatcher([0, 1, 2])
      )
    ]
  )
);

// TODO: port smallSet and largeSet test from "../Set/test.mo"
