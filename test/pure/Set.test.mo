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
    Debug.print(debug_show (actual.values().toArray()) # " should be " # debug_show (expected))
  };

  public func matches(actual : Set.Set<Nat>) : Bool {
    actual.values().toArray() == expected
  }
};

func insert(s : Set.Set<Nat>, key : Nat) : Set.Set<Nat> {
  let s1 = s.add(Nat.compare, key);
  s1.assertValid(Nat.compare);
  s1
};

func concatenateKeys(key : Nat, accum : Text) : Text {
  accum # debug_show (key)
};

func concatenateKeys2(accum : Text, key : Nat) : Text {
  accum # debug_show (key)
};

func containsAll(set : Set.Set<Nat>, elems : [Nat]) {
  for (elem in elems.values()) {
    assert (set.contains(Nat.compare, elem))
  }
};

func clear(initialSet : Set.Set<Nat>) : Set.Set<Nat> {
  var set = initialSet;
  for (elem in initialSet.values()) {
    let newSet = set.remove(Nat.compare, elem);
    set := newSet;
    set.assertValid(Nat.compare)
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
        buildTestSet().size(),
        M.equals(T.nat(0))
      ),
      test(
        "values",
        buildTestSet().values().toArray(),
        M.equals(T.array(entryTestable, []))
      ),
      test(
        "reverseValues",
        buildTestSet().reverseValues().toArray(),
        M.equals(T.array(entryTestable, []))
      ),
      test(
        "empty from iter",
        Set.fromIter(Iter.empty<Nat>(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "contains absent",
        buildTestSet().contains(Nat.compare, 0),
        M.equals(T.bool(false))
      ),
      test(
        "empty right fold",
        buildTestSet().foldRight("", concatenateKeys),
        M.equals(T.text(""))
      ),
      test(
        "empty left fold",
        buildTestSet().foldLeft("", concatenateKeys2),
        M.equals(T.text(""))
      ),
      test(
        "for each",
        do {
          let set = Set.empty<Nat>();
          set.forEach(
            func(_) {
              Runtime.trap("test failed")
            }
          );
          set.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "filter",
        do {
          let input = Set.empty<Nat>();
          let output = input.filter(
            Nat.compare,
            func(_) {
              Runtime.trap("test failed")
            }
          );
          output.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "traverse empty set",
        buildTestSet().map(Nat.compare, add1),
        SetMatcher([])
      ),
      test(
        "empty filter map",
        buildTestSet().filterMap(Nat.compare, ifElemLessThan(0, add1)),
        SetMatcher([])
      ),
      test(
        "is empty",
        buildTestSet().isEmpty(),
        M.equals(T.bool(true))
      ),
      test(
        "max",
        buildTestSet().max(),
        M.equals(T.optional(entryTestable, null : ?Nat))
      ),
      test(
        "min",
        buildTestSet().min(),
        M.equals(T.optional(entryTestable, null : ?Nat))
      ),
      test(
        "compare",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.empty<Nat>();
          assert (set1.compare(set2, Nat.compare) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "join",
        do {
          let set1 = Set.fromIter(Iter.empty<Nat>(), Nat.compare);
          let set2 = set1;
          let set3 = set2;
          let combined = [set1, set2, set3].values().join(Nat.compare);
          combined.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "flatten",
        do {
          let subSet1 = Set.fromIter(Iter.empty<Nat>(), Nat.compare);
          let subSet2 = subSet1;
          let subSet3 = subSet2;
          let iterator = [subSet1, subSet2, subSet3].values();
          let setOfSets = Set.fromIter(iterator, func(first, second) { first.compare(second, Nat.compare) });
          let combined = setOfSets.flatten(Nat.compare);
          combined.size()
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
        buildTestSet().size(),
        M.equals(T.nat(1))
      ),
      test(
        "values",
        buildTestSet().values().toArray(),
        M.equals(T.array(entryTestable, expected))
      ),
      test(
        "reverseValues",
        buildTestSet().reverseValues().toArray(),
        M.equals(T.array(entryTestable, expected))
      ),
      test(
        "from iter",
        Set.fromIter(expected.values(), Nat.compare),
        SetMatcher(expected)
      ),
      test(
        "contains",
        buildTestSet().contains(Nat.compare, 0),
        M.equals(T.bool(true))
      ),
      test(
        "remove",
        buildTestSet().remove(Nat.compare, 0),
        SetMatcher([])
      ),
      test(
        "for each",
        do {
          let set = buildTestSet();
          set.forEach(
            func(number) {
              assert (number == 0)
            }
          );
          set.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "filter",
        do {
          let input = buildTestSet();
          let output = input.filter(
            Nat.compare,
            func(number) {
              assert (number == 0);
              true
            }
          );
          assert (input.equal(output, Nat.compare));
          output.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "right fold",
        buildTestSet().foldRight("", concatenateKeys),
        M.equals(T.text("0"))
      ),
      test(
        "left fold",
        buildTestSet().foldLeft("", concatenateKeys2),
        M.equals(T.text("0"))
      ),
      test(
        "traverse set",
        buildTestSet().map(Nat.compare, add1),
        SetMatcher([1])
      ),
      test(
        "filterMap / filter all",
        buildTestSet().filterMap(Nat.compare, ifElemLessThan(0, add1)),
        SetMatcher([])
      ),
      test(
        "filterMap / no filter",
        buildTestSet().filterMap(Nat.compare, ifElemLessThan(1, add1)),
        SetMatcher([1])
      ),
      test(
        "is empty",
        buildTestSet().isEmpty(),
        M.equals(T.bool(false))
      ),
      test(
        "max",
        buildTestSet().max(),
        M.equals(T.optional(entryTestable, ?0))
      ),
      test(
        "min",
        buildTestSet().min(),
        M.equals(T.optional(entryTestable, ?0))
      ),
      test(
        "all",
        buildTestSet().all(func(k) = (k == 0)),
        M.equals(T.bool(true))
      ),
      test(
        "any",
        buildTestSet().any(func(k) = (k == 0)),
        M.equals(T.bool(true))
      ),
      test(
        "compare less",
        do {
          let set1 = Set.singleton(0);
          let set2 = Set.singleton(1);
          assert (set1.compare(set2, Nat.compare) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare equal",
        do {
          let set1 = Set.singleton(0);
          let set2 = Set.singleton(0);
          assert (set1.compare(set2, Nat.compare) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater key",
        do {
          let set1 = Set.singleton(1);
          let set2 = Set.singleton(0);
          assert (set1.compare(set2, Nat.compare) == #greater);
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
          let combined = [set1, set2, set3].values().join(Nat.compare);
          combined.values().toArray()
        },
        M.equals(
          T.array(
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
          let iterator = [subSet1, subSet2, subSet3].values();
          let setOfSets = Set.fromIter(iterator, func(first, second) { first.compare(second, Nat.compare) });
          let combined = setOfSets.flatten(Nat.compare);
          combined.values().toArray()
        },
        M.equals(
          T.array(
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
    buildTestSet().size(),
    M.equals(T.nat(3))
  ),
  test(
    "Set match",
    buildTestSet(),
    SetMatcher(expected)
  ),
  test(
    "values",
    buildTestSet().values().toArray(),
    M.equals(T.array(entryTestable, expected))
  ),
  test(
    "reverseValues",
    buildTestSet().reverseValues().toArray().reverse(),
    M.equals(T.array(entryTestable, expected))
  ),
  test(
    "from iter",
    Set.fromIter(expected.values(), Nat.compare),
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
    buildTestSet().foldRight("", concatenateKeys),
    M.equals(T.text("210"))
  ),
  test(
    "left fold",
    buildTestSet().foldLeft("", concatenateKeys2),
    M.equals(T.text("012"))
  ),
  test(
    "traverse set",
    buildTestSet().map(Nat.compare, add1),
    SetMatcher([1, 2, 3])
  ),
  test(
    "traverse set/reshape",
    buildTestSet().map(Nat.compare, func(x : Nat) : Nat { 5 }),
    SetMatcher([5])
  ),
  test(
    "for each",
    do {
      let set = buildTestSet();
      var index = 0;
      set.forEach(
        func(element) {
          assert (element == index);
          index += 1
        }
      );
      set.size()
    },
    M.equals(T.nat(buildTestSet().size()))
  ),
  test(
    "filter",
    do {
      let input = buildTestSet();
      let output = input.filter(
        Nat.compare,
        func(number) {
          number % 2 == 0
        }
      );
      for (index in Nat.range(0, input.size())) {
        let present = output.contains(Nat.compare, index);
        if (index % 2 == 0) {
          assert (present)
        } else {
          assert (not present)
        }
      };
      output.size()
    },
    M.equals(T.nat((buildTestSet().size() + 1) / 2))
  ),
  test(
    "filterMap / filter all",
    buildTestSet().filterMap(Nat.compare, ifElemLessThan(0, add1)),
    SetMatcher([])
  ),
  test(
    "filterMap / filter one",
    buildTestSet().filterMap(Nat.compare, ifElemLessThan(1, add1)),
    SetMatcher([1])
  ),
  test(
    "filterMap / no filer",
    buildTestSet().filterMap(Nat.compare, ifElemLessThan(3, add1)),
    SetMatcher([1, 2, 3])
  ),
  test(
    "is empty",
    buildTestSet().isEmpty(),
    M.equals(T.bool(false))
  ),
  test(
    "max",
    buildTestSet().max(),
    M.equals(T.optional(entryTestable, ?2))
  ),
  test(
    "min",
    buildTestSet().min(),
    M.equals(T.optional(entryTestable, ?0))
  ),
  test(
    "all true",
    buildTestSet().all(func(k) = (k >= 0)),
    M.equals(T.bool(true))
  ),
  test(
    "all false",
    buildTestSet().all(func(k) = (k > 0)),
    M.equals(T.bool(false))
  ),
  test(
    "any true",
    buildTestSet().any(func(k) = (k >= 2)),
    M.equals(T.bool(true))
  ),
  test(
    "any false",
    buildTestSet().any(func(k) = (k > 2)),
    M.equals(T.bool(false))
  ),
  test(
    "compare less key",
    do {
      let set1 = buildTestSet() |> _.remove(Nat.compare, _.size() - 1 : Nat);
      let set2 = buildTestSet();
      assert (set1.compare(set2, Nat.compare) == #less);
      true
    },
    M.equals(T.bool(true))
  ),
  test(
    "compare equal",
    do {
      let set1 = buildTestSet();
      let set2 = buildTestSet();
      assert (set1.compare(set2, Nat.compare) == #equal);
      true
    },
    M.equals(T.bool(true))
  ),
  test(
    "compare greater key",
    do {
      let set1 = buildTestSet();
      let set2 = buildTestSet() |> _.remove(Nat.compare, _.size() - 1 : Nat);

      assert (set1.compare(set2, Nat.compare) == #greater);
      true
    },
    M.equals(T.bool(true))
  ),
  test(
    "join",
    do {
      let set1 = buildTestSet().map(Int.compare, func(number) { +number });
      let set2 = buildTestSet().map(Int.compare, func(number) { -number });
      let set3 = Set.fromIter([-1, 1].values(), Int.compare);
      let combined = [set1, set2, set3].values().join(Int.compare);
      combined.values().toArray()
    },
    do {
      let size = buildTestSet().size();
      M.equals(
        T.array(
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
      let subSet1 = buildTestSet().map(Int.compare, func(number) { +number });
      let subSet2 = buildTestSet().map(Int.compare, func(number) { -number });
      let subSet3 = Set.fromIter([-1, 1].values(), Int.compare);
      let iterator = [subSet1, subSet2, subSet3].values();
      let setOfSets = Set.fromIter(iterator, func(first, second) { first.compare(second, Int.compare) });
      let combined = setOfSets.flatten(Int.compare);
      combined.values().toArray()
    },
    do {
      let size = buildTestSet().size();
      M.equals(
        T.array(
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
          assert (set.contains(Nat.compare, 1));
          set := set.add(Nat.compare, 1);
          set.size()
        },
        M.equals(T.nat(3))
      ),
      test(
        "repeated remove",
        do {
          var set = buildTestSet();
          set := set.remove(Nat.compare, 1);
          set.remove(Nat.compare, 1)
        },
        SetMatcher([0, 2])
      ),
      test(
        "repeated insert",
        do {
          var set = buildTestSet();
          assert (set.contains(Nat.compare, 1));
          let (_, changed) = set.insert(Nat.compare, 1);
          changed
        },
        M.equals(T.bool(false))
      ),
      test(
        "repeated delete",
        do {
          var set = buildTestSet();
          let (set1, true) = set.delete(Nat.compare, 1) else Runtime.unreachable();
          let (_, changed) = set1.delete(Nat.compare, 1);
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
        buildTestSet012().isSubset(buildTestSet012(), Nat.compare),
        M.equals(T.bool(true))
      ),
      test(
        "subset/empty set is subset of itself",
        Set.empty().isSubset(Set.empty(), Nat.compare),
        M.equals(T.bool(true))
      ),
      test(
        "subset/empty set is subset of another set",
        Set.isSubset(Set.empty(), buildTestSet012(), Nat.compare),
        M.equals(T.bool(true))
      ),
      test(
        "subset/subset",
        buildTestSet01().isSubset(buildTestSet012(), Nat.compare),
        M.equals(T.bool(true))
      ),
      test(
        "subset/not subset",
        buildTestSet012().isSubset(buildTestSet01(), Nat.compare),
        M.equals(T.bool(false))
      ),
      test(
        "equal/empty set",
        Set.empty().equal(Set.empty(), Nat.compare),
        M.equals(T.bool(true))
      ),
      test(
        "equal/equal",
        buildTestSet012().equal(buildTestSet012(), Nat.compare),
        M.equals(T.bool(true))
      ),
      test(
        "equal/not equal",
        buildTestSet012().equal(buildTestSet01(), Nat.compare),
        M.equals(T.bool(false))
      ),
      test(
        "union/empty set",
        Set.empty().union(Set.empty(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "union/union with empty set",
        buildTestSet012().union(Set.empty(), Nat.compare),
        SetMatcher([0, 1, 2])
      ),
      test(
        "union/union with itself",
        buildTestSet012().union(buildTestSet012(), Nat.compare),
        SetMatcher([0, 1, 2])
      ),
      test(
        "union/union with subset",
        buildTestSet012().union(buildTestSet01(), Nat.compare),
        SetMatcher([0, 1, 2])
      ),
      test(
        "union/union expand",
        buildTestSet012().union(buildTestSet234(), Nat.compare),
        SetMatcher([0, 1, 2, 3, 4])
      ),
      test(
        "intersection/empty set",
        Set.empty().intersection(Set.empty(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "intersection/intersection with empty set",
        buildTestSet012().intersection(Set.empty(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "intersection/intersection with itself",
        buildTestSet012().intersection(buildTestSet012(), Nat.compare),
        SetMatcher([0, 1, 2])
      ),
      test(
        "intersection/intersection with subset",
        buildTestSet012().intersection(buildTestSet01(), Nat.compare),
        SetMatcher([0, 1])
      ),
      test(
        "intersection/intersection",
        buildTestSet012().intersection(buildTestSet234(), Nat.compare),
        SetMatcher([2])
      ),
      test(
        "intersection/no intersectionion",
        buildTestSet012().intersection(buildTestSet345(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "difference/empty set",
        Set.empty().difference(Set.empty(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "difference/difference with empty set",
        buildTestSet012().difference(Set.empty(), Nat.compare),
        SetMatcher([0, 1, 2])
      ),
      test(
        "difference/difference with empty set 2",
        Set.difference(Set.empty(), buildTestSet012(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "difference/difference with subset",
        buildTestSet012().difference(buildTestSet01(), Nat.compare),
        SetMatcher([2])
      ),
      test(
        "difference/difference with subset 2",
        buildTestSet01().difference(buildTestSet012(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "difference/difference",
        buildTestSet012().difference(buildTestSet234(), Nat.compare),
        SetMatcher([0, 1])
      ),
      test(
        "difference/difference no intersection",
        buildTestSet012().difference(buildTestSet345(), Nat.compare),
        SetMatcher([0, 1, 2])
      )
    ]
  )
);

// TODO: port smallSet and largeSet test from "../Set/test.mo"
