// @testmode wasi
import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";
import Test "mo:test";
import Set "../src/Set";
import Iter "../src/Iter";
import Nat "../src/Nat";
import Int "../src/Int";
import Runtime "../src/Runtime";
import Array "../src/Array";

let { run; test; suite } = Suite;

run(
  suite(
    "empty",
    [
      test(
        "size",
        Set.size(Set.empty<Nat>()),
        M.equals(T.nat(0))
      ),
      test(
        "is empty",
        Set.isEmpty(Set.empty<Nat>()),
        M.equals(T.bool(true))
      ),
      test(
        "add empty",
        do {
          let set = Set.empty<Nat>();
          set.add(0);
          Iter.toArray(set.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [0]))
      ),
      test(
        "insert empty",
        do {
          let set = Set.empty<Nat>();
          assert set.insert(0);
          Iter.toArray(set.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [0]))
      ),
      test(
        "remove empty",
        do {
          let set = Set.empty<Nat>();
          set.remove(0);
          Iter.toArray(set.values())
        },
        M.equals(T.array<Nat>(T.natTestable, []))
      ),
      test(
        "delete empty",
        do {
          let set = Set.empty<Nat>();
          assert (not set.delete(0));
          Iter.toArray(set.values())
        },
        M.equals(T.array<Nat>(T.natTestable, []))
      ),
      test(
        "clone no alias",
        do {
          let original = Set.empty<Nat>();
          let clone = original.clone();
          original.add(0);
          assert original.size() == 1;
          clone.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "clone",
        do {
          let original = Set.empty<Nat>();
          let clone = original.clone();
          clone.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "iterate forward",
        Iter.toArray(Set.values(Set.empty<Nat>())),
        M.equals(T.array<Nat>(T.natTestable, []))
      ),
      test(
        "iterate backward",
        Iter.toArray(Set.reverseValues(Set.empty<Nat>())),
        M.equals(T.array<Nat>(T.natTestable, []))
      ),
      test(
        "contains present",
        do {
          let set = Set.empty<Nat>();
          set.add(0);
          set.contains(0)
        },
        M.equals(T.bool(true))
      ),
      test(
        "contains absent",
        do {
          let set = Set.empty<Nat>();
          set.contains(0)
        },
        M.equals(T.bool(false))
      ),
      test(
        "clear",
        do {
          let set = Set.empty<Nat>();
          set.clear();
          set.isEmpty()
        },
        M.equals(T.bool(true))
      ),
      test(
        "equal",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.empty<Nat>();
          set1.equal(set2)
        },
        M.equals(T.bool(true))
      ),
      test(
        "maximum",
        do {
          let set = Set.empty<Nat>();
          Set.max(set)
        },
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
      test(
        "minimum",
        do {
          let set = Set.empty<Nat>();
          Set.min(set)
        },
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
      test(
        "from iterator",
        do {
          let set = Set.fromIter<Nat>(Iter.fromArray<Nat>([]));
          set.size()
        },
        M.equals(T.nat(0))
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
          set.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "filter",
        do {
          let input = Set.empty<Nat>();
          let output = input.filter<Nat>(
            func(_) {
              Runtime.trap("test failed")
            }
          );
          output.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "map",
        do {
          let input = Set.empty<Nat>();
          let output = input.map<Nat, Int>(
            func(_) {
              Runtime.trap("test failed")
            }
          );
          output.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "filter map",
        do {
          let input = Set.empty<Nat>();
          let output = input.filterMap<Nat, Int>(
            func(_) {
              Runtime.trap("test failed")
            }
          );
          output.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "fold left",
        do {
          let set = Set.empty<Nat>();
          Set.foldLeft<Nat, Nat>(
            set,
            0,
            func(_, _) {
              Runtime.trap("test failed")
            }
          )
        },
        M.equals(T.nat(0))
      ),
      test(
        "fold right",
        do {
          let set = Set.empty<Nat>();
          Set.foldRight<Nat, Nat>(
            set,
            0,
            func(_, _) {
              Runtime.trap("test failed")
            }
          )
        },
        M.equals(T.nat(0))
      ),
      test(
        "all",
        do {
          let set = Set.empty<Nat>();
          Set.all<Nat>(
            set,
            func(_) {
              Runtime.trap("test failed")
            }
          )
        },
        M.equals(T.bool(true))
      ),
      test(
        "any",
        do {
          let set = Set.empty<Nat>();
          Set.any<Nat>(
            set,
            func(_) {
              Runtime.trap("test failed")
            }
          )
        },
        M.equals(T.bool(false))
      ),
      test(
        "to text",
        do {
          let set = Set.empty<Nat>();
          set.toText()
        },
        M.equals(T.text("Set{}"))
      ),
      test(
        "compare",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.empty<Nat>();
          assert (set1.compare(set2) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "is sub-set",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([]), Nat.compare);
          let set2 = set1.clone();
          set1.isSubset(set2)
        },
        M.equals(T.bool(true))
      ),
      test(
        "join",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([]), Nat.compare);
          let set2 = set1.clone();
          let set3 = set2.clone();
          let combined = Set.join(Iter.fromArray([set1, set2, set3]));
          combined.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "flatten",
        do {
          let subSet1 = Set.fromIter(Iter.fromArray<Nat>([]), Nat.compare);
          let subSet2 = subSet1.clone();
          let subSet3 = subSet2.clone();
          let iterator = Iter.fromArray([subSet1, subSet2, subSet3]);
          let setOfSets = Set.fromIter<Set.Set<Nat>>(iterator, func(first, second) { first.compare(second) });
          let combined = Set.flatten(setOfSets);
          combined.size()
        },
        M.equals(T.nat(0))
      ),
      // TODO: Test freeze and thaw
    ]
  )
);

run(
  suite(
    "singleton",
    [
      test(
        "size",
        Set.size<Nat>(Set.singleton(0)),
        M.equals(T.nat(1))
      ),
      test(
        "is empty",
        Set.isEmpty<Nat>(Set.singleton(0)),
        M.equals(T.bool(false))
      ),
      test(
        "add singleton old",
        do {
          let set = Set.singleton<Nat>(0);
          set.add(0);
          Iter.toArray(set.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [0]))
      ),
      test(
        "add singleton new",
        do {
          let set = Set.singleton<Nat>(0);
          set.add(1);
          Iter.toArray(set.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [0, 1]))
      ),
      test(
        "insert singleton old",
        do {
          let set = Set.singleton<Nat>(0);
          assert (not set.insert(0));
          Iter.toArray(set.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [0]))
      ),
      test(
        "insert singleton new",
        do {
          let set = Set.singleton<Nat>(0);
          assert set.insert(1);
          Iter.toArray(set.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [0, 1]))
      ),
      test(
        "remove singleton old",
        do {
          let set = Set.singleton<Nat>(0);
          set.remove(0);
          Iter.toArray(set.values())
        },
        M.equals(T.array<Nat>(T.natTestable, []))
      ),
      test(
        "remove singleton new",
        do {
          let set = Set.singleton<Nat>(0);
          set.remove(1);
          Iter.toArray(set.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [0]))
      ),
      test(
        "delete singleton old",
        do {
          let set = Set.singleton<Nat>(0);
          assert (set.delete(0));
          Iter.toArray(set.values())
        },
        M.equals(T.array<Nat>(T.natTestable, []))
      ),
      test(
        "delete singleton new",
        do {
          let set = Set.singleton<Nat>(0);
          assert (not set.delete(1));
          Iter.toArray(set.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [0]))
      ),
      test(
        "clone",
        do {
          let original = Set.singleton<Nat>(0);
          let clone = original.clone();
          assert (original.equal(clone));
          clone.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "clone no alias",
        do {
          let original = Set.singleton<Nat>(0);
          assert original.size() == 1;
          let clone = original.clone();
          original.remove(0);
          assert original.size() == 0;
          assert not original.contains(0);
          assert clone.contains(0);
          clone.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "iterate forward",
        Iter.toArray(Set.values(Set.singleton<Nat>(0))),
        M.equals(T.array<Nat>(T.natTestable, [0]))
      ),
      test(
        "iterate backward",
        Iter.toArray(Set.reverseValues(Set.singleton<Nat>(0))),
        M.equals(T.array<Nat>(T.natTestable, [0]))
      ),
      test(
        "contains present key",
        do {
          let set = Set.singleton<Nat>(0);
          set.contains(0)
        },
        M.equals(T.bool(true))
      ),
      test(
        "contains absent key",
        do {
          let set = Set.singleton<Nat>(0);
          set.contains(1)
        },
        M.equals(T.bool(false))
      ),
      test(
        "add duplicate",
        do {
          let set = Set.singleton<Nat>(0);
          set.add(0);
          assert (set.contains(0));
          set.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "remove",
        do {
          let set = Set.singleton<Nat>(0);
          set.remove(0);
          set.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "clear",
        do {
          let set = Set.singleton<Nat>(0);
          set.clear();
          set.isEmpty()
        },
        M.equals(T.bool(true))
      ),
      test(
        "equal",
        do {
          let set1 = Set.singleton<Nat>(0);
          let set2 = Set.singleton<Nat>(0);
          set1.equal(set2)
        },
        M.equals(T.bool(true))
      ),
      test(
        "not equal",
        do {
          let set1 = Set.singleton<Nat>(0);
          let set2 = Set.singleton<Nat>(1);
          set1.equal(set2)
        },
        M.equals(T.bool(false))
      ),
      test(
        "maximum",
        do {
          let set = Set.singleton<Nat>(0);
          Set.max(set)
        },
        M.equals(T.optional(T.natTestable, ?0))
      ),
      test(
        "minimum",
        do {
          let set = Set.singleton<Nat>(0);
          Set.min(set)
        },
        M.equals(T.optional(T.natTestable, ?0))
      ),
      test(
        "iterate forward",
        Iter.toArray(Set.values(Set.singleton<Nat>(0))),
        M.equals(T.array<Nat>(T.natTestable, [0]))
      ),
      test(
        "iterate backwards",
        Iter.toArray(Set.reverseValues(Set.singleton<Nat>(0))),
        M.equals(T.array<Nat>(T.natTestable, [0]))
      ),
      test(
        "from iterator",
        do {
          let set = Set.fromIter<Nat>(Iter.fromArray<Nat>([0]), Nat.compare);
          assert (set.contains(0));
          assert (Set.equal(set, Set.singleton<Nat>(0), Nat.compare));
          set.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "for each",
        do {
          let set = Set.singleton<Nat>(0);
          Set.forEach<Nat>(
            set,
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
          let input = Set.singleton<Nat>(0);
          let output = Set.filter<Nat>(
            input,
            Nat.compare,
            func(number) {
              assert (number == 0);
              true
            }
          );
          assert (input.equal(output));
          output.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "map",
        do {
          let input = Set.singleton<Nat>(0);
          let output = Set.map<Nat, Int>(
            input,
            Int.compare,
            func(number) {
              assert (number == 0);
              +number
            }
          );
          assert (Set.contains(output, Int.compare, 0));
          output.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "filter map",
        do {
          let input = Set.singleton<Nat>(0);
          let output = Set.filterMap<Nat, Int>(
            input,
            Int.compare,
            func(number) {
              assert (number == 0);
              ?+number
            }
          );
          assert (Set.contains(output, Int.compare, 0));
          output.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "fold left",
        do {
          let set = Set.singleton<Nat>(1);
          Set.foldLeft<Nat, Nat>(
            set,
            0,
            func(accumulator, number) {
              accumulator + number
            }
          )
        },
        M.equals(T.nat(1))
      ),
      test(
        "fold right",
        do {
          let set = Set.singleton<Nat>(1);
          Set.foldRight<Nat, Nat>(
            set,
            0,
            func(number, accumulator) {
              number + accumulator
            }
          )
        },
        M.equals(T.nat(1))
      ),
      test(
        "all",
        do {
          let set = Set.singleton<Nat>(1);
          Set.all<Nat>(
            set,
            func(number) {
              number == 1
            }
          )
        },
        M.equals(T.bool(true))
      ),
      test(
        "not all",
        do {
          let set = Set.singleton<Nat>(1);
          Set.all<Nat>(
            set,
            func(number) {
              number == 2
            }
          )
        },
        M.equals(T.bool(false))
      ),
      test(
        "any",
        do {
          let set = Set.singleton<Nat>(1);
          Set.any<Nat>(
            set,
            func(number) {
              number == 1
            }
          )
        },
        M.equals(T.bool(true))
      ),
      test(
        "not any",
        do {
          let set = Set.singleton<Nat>(1);
          Set.any<Nat>(
            set,
            func(number) {
              number == 0
            }
          )
        },
        M.equals(T.bool(false))
      ),
      test(
        "to text",
        do {
          let set = Set.singleton<Nat>(1);
          Set.toText<Nat>(set, Nat.toText)
        },
        M.equals(T.text("Set{1}"))
      ),
      test(
        "compare less",
        do {
          let set1 = Set.singleton<Nat>(0);
          let set2 = Set.singleton<Nat>(1);
          assert (set1.compare(set2) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare equal",
        do {
          let set1 = Set.singleton<Nat>(0);
          let set2 = Set.singleton<Nat>(0);
          assert (set1.compare(set2) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater key",
        do {
          let set1 = Set.singleton<Nat>(1);
          let set2 = Set.singleton<Nat>(0);
          assert (set1.compare(set2) == #greater);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "is sub-set",
        do {
          let set1 = Set.singleton<Nat>(0);
          let set2 = Set.singleton<Nat>(0);
          set1.isSubset(set2)
        },
        M.equals(T.bool(true))
      ),
      test(
        "is not sub-set",
        do {
          let set1 = Set.singleton<Nat>(0);
          let set2 = Set.singleton<Nat>(1);
          set1.isSubset(set2)
        },
        M.equals(T.bool(false))
      ),
      test(
        "is strict sub-set",
        do {
          let set1 = Set.singleton<Nat>(1);
          let set2 = Set.fromIter<Nat>(Iter.fromArray<Nat>([0, 1, 2]), Nat.compare);
          set1.isSubset(set2)
        },
        M.equals(T.bool(true))
      ),
      test(
        "union",
        do {
          let set1 = Set.singleton<Nat>(1);
          let set2 = Set.singleton<Nat>(2);
          let union = set1.union(set2);
          Iter.toArray(union.values())
        },
        M.equals(
          T.array<Nat>(
            T.natTestable,
            [1, 2]
          )
        )
      ),
      test(
        "union duplicate",
        do {
          let set1 = Set.singleton<Nat>(1);
          let set2 = Set.singleton<Nat>(1);
          let union = set1.union(set2);
          Iter.toArray(union.values())
        },
        M.equals(
          T.array<Nat>(
            T.natTestable,
            [1]
          )
        )
      ),
      test(
        "intersection empty",
        do {
          let set1 = Set.singleton<Nat>(0);
          let set2 = Set.singleton<Nat>(1);
          let intersection = set1.intersection(set2);
          Iter.toArray(intersection.values())
        },
        M.equals(
          T.array<Nat>(
            T.natTestable,
            []
          )
        )
      ),
      test(
        "intersection duplicate",
        do {
          let set1 = Set.singleton<Nat>(1);
          let set2 = Set.singleton<Nat>(1);
          let intersection = set1.intersection(set2);
          Iter.toArray(intersection.values())
        },
        M.equals(
          T.array<Nat>(
            T.natTestable,
            [1]
          )
        )
      ),
      test(
        "difference empty",
        do {
          let set1 = Set.singleton<Nat>(1);
          let set2 = Set.singleton<Nat>(1);
          let difference = set1.difference(set2);
          Iter.toArray(difference.values())
        },
        M.equals(
          T.array<Nat>(
            T.natTestable,
            []
          )
        )
      ),
      test(
        "difference non-empty",
        do {
          let set1 = Set.singleton<Nat>(0);
          let set2 = Set.singleton<Nat>(1);
          let difference = set1.difference(set2);
          Iter.toArray(difference.values())
        },
        M.equals(
          T.array<Nat>(
            T.natTestable,
            [0]
          )
        )
      ),
      test(
        "join",
        do {
          let set1 = Set.singleton<Nat>(0);
          let set2 = Set.singleton<Nat>(1);
          let set3 = Set.singleton<Nat>(2);
          let combined = Set.join(Iter.fromArray([set1, set2, set3]), Nat.compare);
          Iter.toArray(combined.values())
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
          let subSet1 = Set.singleton<Nat>(0);
          let subSet2 = Set.singleton<Nat>(1);
          let subSet3 = Set.singleton<Nat>(2);
          let iterator = Iter.fromArray([subSet1, subSet2, subSet3]);
          let setOfSets = Set.fromIter<Set.Set<Nat>>(iterator, func(first, second) { first.compare(second) });
          let combined = setOfSets.flatten();
          Iter.toArray(combined.values())
        },
        M.equals(
          T.array<Nat>(
            T.natTestable,
            [0, 1, 2]
          )
        )
      ),
      // TODO: Test freeze and thaw
    ]
  )
);

let smallSize = 100;
func smallSet() : Set.Set<Nat> {
  let set = Set.empty<Nat>();
  for (index in Nat.range(0, smallSize)) {
    set.add(index)
  };
  set
};

run(
  suite(
    "small set",
    [
      test(
        "size",
        Set.size<Nat>(smallSet()),
        M.equals(T.nat(smallSize))
      ),
      test(
        "size after clone",
        do {
          let set1 = smallSet();
          let set2 = set1.clone();
          set1.size() == set2.size()
        },
        M.equals(T.bool(true))
      ),
      test(
        "size after adding elements",
        do {
          let set = Set.empty<Nat>();
          set.add(1);
          set.add(2);
          set.add(3);
          set.size()
        },
        M.equals(T.nat(3))
      ),
      test(
        "size after adding and removing elements",
        do {
          let set = Set.empty<Nat>();
          set.add(1);
          set.add(2);
          set.add(3);
          set.remove(1);
          set.remove(2);
          set.remove(3);
          set.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "is empty",
        Set.isEmpty<Nat>(smallSet()),
        M.equals(T.bool(false))
      ),
      test(
        "clone",
        do {
          let original = smallSet();
          let clone = original.clone();
          assert (original.equal(clone));
          clone.size()
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "clone no alias",
        do {
          let original = smallSet();
          let copy = smallSet();
          let clone = original.clone();
          let keys = Iter.toArray(original.values());
          for (key in keys.vals()) {
            original.remove(key)
          };
          for (key in keys.vals()) {
            assert clone.contains(key) == copy.contains(key)
          };
          clone.size()
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "iterate forward",
        Iter.toArray(Set.values(smallSet())),
        M.equals(
          T.array<Nat>(
            T.natTestable,
            Array.tabulate<Nat>(smallSize, func(index) { index })
          )
        )
      ),
      test(
        "iterate backward",
        Iter.toArray(Set.reverseValues(smallSet())),
        M.equals(T.array<Nat>(T.natTestable, Array.reverse(Array.tabulate<Nat>(smallSize, func(index) { index }))))
      ),
      test(
        "contains present",
        do {
          let set = smallSet();
          for (index in Nat.range(0, smallSize)) {
            assert (set.contains(index))
          };
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "contains absent",
        do {
          let set = smallSet();
          set.contains(smallSize)
        },
        M.equals(T.bool(false))
      ),
      test(
        "remove",
        do {
          let set = smallSet();
          for (index in Nat.range(0, smallSize)) {
            set.remove(index)
          };
          set.isEmpty()
        },
        M.equals(T.bool(true))
      ),
      test(
        "clear",
        do {
          let set = smallSet();
          set.clear();
          set.isEmpty()
        },
        M.equals(T.bool(true))
      ),
      test(
        "equal",
        do {
          let set1 = smallSet();
          let set2 = smallSet();
          set1.equal(set2)
        },
        M.equals(T.bool(true))
      ),
      test(
        "not equal",
        do {
          let set1 = smallSet();
          let set2 = smallSet();
          set2.remove(smallSize - 1 : Nat);
          set1.equal(set2)
        },
        M.equals(T.bool(false))
      ),
      test(
        "maximum",
        do {
          let set = smallSet();
          Set.max(set)
        },
        M.equals(T.optional(T.natTestable, ?(smallSize - 1 : Nat)))
      ),
      test(
        "minimum",
        do {
          let set = smallSet();
          Set.min(set)
        },
        M.equals(T.optional(T.natTestable, ?0))
      ),
      test(
        "forward iteration",
        Iter.toArray(Set.values(smallSet())),
        M.equals(T.array<Nat>(T.natTestable, Array.tabulate<Nat>(smallSize, func(index) { index })))
      ),
      test(
        "backwards iteration",
        Iter.toArray(Set.reverseValues(smallSet())),
        M.equals(T.array<Nat>(T.natTestable, Array.tabulate<Nat>(smallSize, func(index) { smallSize - 1 - index : Nat })))
      ),
      test(
        "from iterator",
        do {
          let array = Array.tabulate<Nat>(smallSize, func(index) { index });
          let set = Set.fromIter<Nat>(Iter.fromArray(array), Nat.compare);
          for (index in Nat.range(0, smallSize)) {
            assert (set.contains(index))
          };
          assert (Set.equal(set, smallSet(), Nat.compare));
          set.size()
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "for each",
        do {
          let set = smallSet();
          var index = 0;
          Set.forEach<Nat>(
            set,
            func(element) {
              assert (element == index);
              index += 1
            }
          );
          set.size()
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "filter",
        do {
          let input = smallSet();
          let output = Set.filter<Nat>(
            input,
            Nat.compare,
            func(number) {
              number % 2 == 0
            }
          );
          for (index in Nat.range(0, smallSize)) {
            let present = output.contains(index);
            if (index % 2 == 0) {
              assert (present)
            } else {
              assert (not present)
            }
          };
          output.size()
        },
        M.equals(T.nat((smallSize + 1) / 2))
      ),
      test(
        "map",
        do {
          let input = smallSet();
          let output = Set.map<Nat, Int>(
            input,
            Int.compare,
            func(number) {
              +number
            }
          );
          for (index in Nat.range(0, smallSize)) {
            assert (Set.contains(output, Int.compare, index))
          };
          output.size()
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "filter map",
        do {
          let input = smallSet();
          let output = Set.filterMap<Nat, Int>(
            input,
            Int.compare,
            func(number) {
              if (number % 2 == 0) {
                ?+number
              } else {
                null
              }
            }
          );
          for (index in Nat.range(0, smallSize)) {
            let present = Set.contains(output, Int.compare, index);
            if (index % 2 == 0) {
              assert (present)
            } else {
              assert (not present)
            }
          };
          output.size()
        },
        M.equals(T.nat((smallSize + 1) / 2))
      ),
      test(
        "fold left",
        do {
          let set = smallSet();
          Set.foldLeft<Nat, Nat>(
            set,
            0,
            func(accumulator, element) {
              accumulator + element
            }
          )
        },
        M.equals(T.nat((smallSize * (smallSize - 1)) / 2))
      ),
      test(
        "fold right",
        do {
          let set = smallSet();
          Set.foldRight<Nat, Nat>(
            set,
            0,
            func(element, accumulator) {
              element + accumulator
            }
          )
        },
        M.equals(T.nat((smallSize * (smallSize - 1)) / 2))
      ),
      test(
        "all",
        do {
          let set = smallSet();
          Set.all<Nat>(
            set,
            func(number) {
              number < smallSize
            }
          )
        },
        M.equals(T.bool(true))
      ),
      test(
        "any",
        do {
          let set = smallSet();
          Set.any<Nat>(
            set,
            func(number) {
              number == (smallSize - 1 : Nat)
            }
          )
        },
        M.equals(T.bool(true))
      ),
      test(
        "to text",
        do {
          let set = smallSet();
          Set.toText<Nat>(set, Nat.toText)
        },
        do {
          var text = "Set{";
          for (index in Nat.range(0, smallSize)) {
            if (text != "Set{") {
              text #= ", "
            };
            text #= Nat.toText(index)
          };
          text #= "}";
          M.equals(T.text(text))
        }
      ),
      test(
        "compare less key",
        do {
          let set1 = smallSet();
          set1.remove(smallSize - 1 : Nat);
          let set2 = smallSet();
          assert (set1.compare(set2) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare equal",
        do {
          let set1 = smallSet();
          let set2 = smallSet();
          assert (set1.compare(set2) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater key",
        do {
          let set1 = smallSet();
          let set2 = smallSet();
          set2.remove(smallSize - 1 : Nat);
          assert (set1.compare(set2) == #greater);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "union",
        do {
          let set1 = Set.map<Nat, Int>(smallSet(), Int.compare, func(number) { +number });
          let set2 = Set.map<Nat, Int>(smallSet(), Int.compare, func(number) { -number });
          let union = Set.union(set1, set2, Int.compare);
          Iter.toArray(union.values())
        },
        M.equals(
          T.array<Int>(
            T.intTestable,
            Array.tabulate<Int>(
              smallSize * 2 - 1 : Nat,
              func(index) {
                index + 1 - smallSize
              }
            )
          )
        )
      ),
      test(
        "intersection",
        do {
          let set1 = Set.map<Nat, Int>(smallSet(), Int.compare, func(number) { +number });
          Set.add(set1, Int.compare, -1);
          let set2 = Set.map<Nat, Int>(smallSet(), Int.compare, func(number) { -number });
          Set.add(set2, Int.compare, 1);
          let intersection = Set.intersection(set1, set2, Int.compare);
          Iter.toArray(intersection.values())
        },
        M.equals(
          T.array<Int>(
            T.intTestable,
            [-1, 0, 1]
          )
        )
      ),
      test(
        "difference",
        do {
          let set1 = smallSet();
          let set2 = smallSet();
          set2.remove(0);
          set2.remove(1);
          set2.remove(2);
          let difference = set1.difference(set2);
          Iter.toArray(difference.values())
        },
        M.equals(
          T.array<Nat>(
            T.natTestable,
            [0, 1, 2]
          )
        )
      ),
      test(
        "join",
        do {
          let set1 = Set.map<Nat, Int>(smallSet(), Int.compare, func(number) { +number });
          let set2 = Set.map<Nat, Int>(smallSet(), Int.compare, func(number) { -number });
          let set3 = Set.fromIter(Iter.fromArray<Int>([-1, 1]), Int.compare);
          let combined = Set.join(Iter.fromArray([set1, set2, set3]), Int.compare);
          Iter.toArray(combined.values())
        },
        M.equals(
          T.array<Int>(
            T.intTestable,
            Array.tabulate<Int>(
              smallSize * 2 - 1 : Nat,
              func(index) {
                index + 1 - smallSize
              }
            )
          )
        )
      ),
      test(
        "flatten",
        do {
          let subSet1 = Set.map<Nat, Int>(smallSet(), Int.compare, func(number) { +number });
          let subSet2 = Set.map<Nat, Int>(smallSet(), Int.compare, func(number) { -number });
          let subSet3 = Set.fromIter(Iter.fromArray<Int>([-1, 1]), Int.compare);
          let iterator = Iter.fromArray([subSet1, subSet2, subSet3]);
          let setOfSets = Set.fromIter<Set.Set<Int>>(iterator, func(first, second) { Set.compare(first, second, Int.compare) });
          let combined = Set.flatten(setOfSets, Int.compare);
          Iter.toArray(combined.values())
        },
        M.equals(
          T.array<Int>(
            T.intTestable,
            Array.tabulate<Int>(
              smallSize * 2 - 1 : Nat,
              func(index) {
                index + 1 - smallSize
              }
            )
          )
        )
      ),
      // TODO: Test freeze and thaw
    ]
  )
);

// TODO: Use `mo:core/Random`
class Random(seed : Nat) {
  var number = seed;

  public func reset() {
    number := seed
  };

  public func next() : Nat {
    number := (123138118391 * number + 133489131) % 9999;
    number
  }
};

let randomSeed = 4711;
let numberOfElements = 10_000;

run(
  suite(
    "large set",
    [
      test(
        "add",
        do {
          let set = Set.empty<Nat>();
          for (index in Nat.range(0, numberOfElements)) {
            set.add(index);
            assert (set.size() == index + 1);
            assert (set.contains(index))
          };
          for (index in Nat.range(0, numberOfElements)) {
            assert (set.contains(index))
          };
          assert (not set.contains(numberOfElements));
          set.assertValid();
          set.size()
        },
        M.equals(T.nat(numberOfElements))
      ),
      test(
        "insert",
        do {
          let set = Set.empty<Nat>();
          for (index in Nat.range(0, numberOfElements)) {
            assert (set.insert(index));
            assert (set.size() == index + 1);
            assert (set.contains(index))
          };
          for (index in Nat.range(0, numberOfElements)) {
            assert (not (set.insert(index)))
          };
          for (index in Nat.range(0, numberOfElements)) {
            assert (set.contains(index))
          };
          assert (not set.contains(numberOfElements));
          set.assertValid();
          set.size()
        },
        M.equals(T.nat(numberOfElements))
      ),
      test(
        "contains",
        do {
          let set = Set.empty<Nat>();
          let random = Random(randomSeed);
          for (index in Nat.range(0, numberOfElements)) {
            let element = random.next();
            if (not set.contains(element)) {
              set.add(element)
            }
          };
          random.reset();
          for (index in Nat.range(0, numberOfElements)) {
            let element = random.next();
            assert (set.contains(element))
          };
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "remove",
        do {
          let set = Set.empty<Nat>();
          let random = Random(randomSeed);
          for (index in Nat.range(0, numberOfElements)) {
            let element = random.next();
            if (not set.contains(element)) {
              set.add(element)
            }
          };
          assert (set.size() > 0);
          random.reset();
          for (index in Nat.range(0, numberOfElements)) {
            let element = random.next();
            assert (set.contains(element))
          };
          random.reset();
          for (index in Nat.range(0, numberOfElements)) {
            let element = random.next();
            if (set.contains(element)) {
              set.remove(element);
              assert (not set.contains(element))
            };
            assert (not set.contains(element))
          };
          set.assertValid();
          set.size()
        },
        M.equals(T.nat(0))
      ),

      test(
        "delete",
        do {
          let set = Set.empty<Nat>();
          let random = Random(randomSeed);
          for (index in Nat.range(0, numberOfElements)) {
            let element = random.next();
            if (not set.contains(element)) {
              set.add(element)
            }
          };
          assert (set.size() > 0);
          random.reset();
          for (index in Nat.range(0, numberOfElements)) {
            let element = random.next();
            assert (set.contains(element))
          };
          random.reset();
          for (index in Nat.range(0, numberOfElements)) {
            let element = random.next();
            if (set.contains(element)) {
              assert set.delete(element);
              assert (not set.contains(element))
            } else {
              assert (not set.delete(element))
            };
            assert (not set.contains(element))
          };
          set.assertValid();
          set.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "iterate",
        do {
          let set = Set.empty<Nat>();
          for (index in Nat.range(0, numberOfElements)) {
            set.add(index)
          };
          var index = 0;
          for (element in set.values()) {
            assert (element == index);
            index += 1
          };
          index
        },
        M.equals(T.nat(numberOfElements))
      ),
      test(
        "reverseIterate",
        do {
          let set = Set.empty<Nat>();
          for (index in Nat.range(0, numberOfElements)) {
            set.add(index)
          };
          var index = numberOfElements;
          for (element in Set.reverseValues(set)) {
            index -= 1;
            assert (element == index)
          };
          index
        },
        M.equals(T.nat(0))
      )
    ]
  )
);

run(
  suite(
    "other",
    [
      test(
        "union both empty",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.empty<Nat>();
          let union = set1.union(set2);
          union.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "union first non-empty",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let union = set1.union(set2);
          Iter.toArray(union.values())
        },
        M.equals(T.array(T.natTestable, [1, 2, 3]))
      ),
      test(
        "union first non-empty",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let set2 = Set.empty<Nat>();
          let union = set1.union(set2);
          Iter.toArray(union.values())
        },
        M.equals(T.array(T.natTestable, [1, 2, 3]))
      ),
      test(
        "union both non-empty disjoint",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let set2 = Set.fromIter<Nat>(Iter.fromArray<Nat>([4, 5, 6]), Nat.compare);
          let union = set1.union(set2);
          union.size()
        },
        M.equals(T.nat(6))
      ),
      test(
        "union both non-empty overlapping",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let set2 = Set.fromIter<Nat>(Iter.fromArray<Nat>([2, 3, 4]), Nat.compare);
          let union = set1.union(set2);
          union.size()
        },
        M.equals(T.nat(4))
      ),
      test(
        "intersect both empty",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.empty<Nat>();
          let intersection = set1.intersection(set2);
          intersection.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "intersect first non-empty",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let set2 = Set.empty<Nat>();
          let intersection = set1.intersection(set2);
          intersection.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "intersect second non-empty",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let intersection = set1.intersection(set2);
          intersection.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "intersect both non-empty disjoint",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let set2 = Set.fromIter<Nat>(Iter.fromArray<Nat>([4, 5, 6]), Nat.compare);
          let intersection = set1.intersection(set2);
          intersection.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "intersect both non-empty overlapping",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let set2 = Set.fromIter<Nat>(Iter.fromArray<Nat>([2, 3, 4]), Nat.compare);
          let intersection = set1.intersection(set2);
          Iter.toArray(intersection.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [2, 3]))
      ),
      test(
        "diff both empty",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.empty<Nat>();
          let difference = set1.difference(set2);
          difference.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "diff first non-empty",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let set2 = Set.empty<Nat>();
          let difference = set1.difference(set2);
          Iter.toArray(difference.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [1, 2, 3]))
      ),
      test(
        "diff second non-empty",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let difference = set1.difference(set2);
          difference.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "diff both non-empty disjoint",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let set2 = Set.fromIter<Nat>(Iter.fromArray<Nat>([4, 5, 6]), Nat.compare);
          let difference = set1.difference(set2);
          Iter.toArray(difference.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [1, 2, 3]))
      ),
      test(
        "diff both non-empty overlapping",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let set2 = Set.fromIter<Nat>(Iter.fromArray<Nat>([2, 3, 4]), Nat.compare);
          let difference = set1.difference(set2);
          Iter.toArray(difference.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [1]))
      ),
      test(
        "addAll both empty",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.empty<Nat>();
          set1.addAll(set2.values());
          set1.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "addAll first non-empty",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let set2 = Set.empty<Nat>();
          set1.addAll(set2.values());
          Iter.toArray(set1.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [1, 2, 3]))
      ),
      test(
        "addAll second non-empty",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          set1.addAll(set2.values());
          Iter.toArray(set1.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [1, 2, 3]))
      ),
      test(
        "addAll both non-empty disjoint",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let set2 = Set.fromIter<Nat>(Iter.fromArray<Nat>([4, 5, 6]), Nat.compare);
          set1.addAll(set2.values());
          Iter.toArray(set1.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [1, 2, 3, 4, 5, 6]))
      ),
      test(
        "addAll both non-empty overlapping",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let set2 = Set.fromIter<Nat>(Iter.fromArray<Nat>([2, 3, 4]), Nat.compare);
          set1.addAll(set2.values());
          Iter.toArray(set1.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [1, 2, 3, 4]))
      ),
      test(
        "retainAll empty",
        do {
          let set = Set.empty<Nat>();
          assert (not Set.retainAll<Nat>(set, Nat.compare, func(n) { true }));
          set.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "retainAll all",
        do {
          let set = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          assert (not Set.retainAll<Nat>(set, Nat.compare, func(n) { true }));
          Iter.toArray(set.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [1, 2, 3]))
      ),
      test(
        "retainAll none",
        do {
          let set = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          assert (Set.retainAll<Nat>(set, Nat.compare, func(n) { false }));
          set.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "retainAll even",
        do {
          let set = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3, 4]), Nat.compare);
          assert (Set.retainAll<Nat>(set, Nat.compare, func(n) { n % 2 == 0 }));
          Iter.toArray(set.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [2, 4]))
      ),
      test(
        "retainAll predicate",
        do {
          let set = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3, 4, 5]), Nat.compare);
          assert (Set.retainAll<Nat>(set, Nat.compare, func(n) { n > 2 and n < 5 }));
          Iter.toArray(set.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [3, 4]))
      ),
      test(
        "deleteAll both empty",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.empty<Nat>();
          assert (not set1.deleteAll(set2.values()));
          set1.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "deleteAll first non-empty",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let set2 = Set.empty<Nat>();
          assert (not set1.deleteAll(set2.values()));
          Iter.toArray(set1.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [1, 2, 3]))
      ),
      test(
        "deleteAll both non-empty equal",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let set2 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          assert (set1.deleteAll(set2.values()));
          set1.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "deleteAll second non-empty",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          assert (not (set1.deleteAll(set2.values())));
          set1.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "deleteAll both non-empty disjoint",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let set2 = Set.fromIter<Nat>(Iter.fromArray<Nat>([4, 5, 6]), Nat.compare);
          assert (not (set1.deleteAll(set2.values())));
          Iter.toArray(set1.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [1, 2, 3]))
      ),
      test(
        "deleteAll both non-empty overlapping",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let set2 = Set.fromIter<Nat>(Iter.fromArray<Nat>([2, 3, 4]), Nat.compare);
          assert set1.deleteAll(set2.values());
          Iter.toArray(set1.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [1]))
      ),

      test(
        "insertAll first non-empty",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let set2 = Set.empty<Nat>();
          assert (not set1.insertAll(set2.values()));
          Iter.toArray(set1.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [1, 2, 3]))
      ),
      test(
        "insertAll both non-empty equal",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let set2 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          assert (not set1.insertAll(set2.values()));
          set1.size()
        },
        M.equals(T.nat(3))
      ),
      test(
        "insertAll second non-empty",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          assert (set1.insertAll(set2.values()));
          set1.size()
        },
        M.equals(T.nat(3))
      ),
      test(
        "insertAll both non-empty disjoint",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let set2 = Set.fromIter<Nat>(Iter.fromArray<Nat>([4, 5, 6]), Nat.compare);
          assert (set1.insertAll(set2.values()));
          Iter.toArray(set1.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [1, 2, 3, 4, 5, 6]))
      ),
      test(
        "insertAll both non-empty overlapping",
        do {
          let set1 = Set.fromIter<Nat>(Iter.fromArray<Nat>([1, 2, 3]), Nat.compare);
          let set2 = Set.fromIter<Nat>(Iter.fromArray<Nat>([2, 3, 4]), Nat.compare);
          assert set1.insertAll(set2.values());
          Iter.toArray(set1.values())
        },
        M.equals(T.array<Nat>(T.natTestable, [1, 2, 3, 4]))
      ),

    ]
  )
);

Test.suite(
  "valuesFrom",
  func() {
    Test.test(
      "Simple",
      func() {
        let set = Set.empty<Nat>();
        set.add(1);
        set.add(2);
        set.add(4);
        func check(from : Nat, expected : [Nat]) {
          let actual = Iter.toArray(set.valuesFrom(from));
          Test.expect.array(actual, Nat.toText, Nat.equal).equal(expected)
        };
        check(0, [1, 2, 4]);
        check(1, [1, 2, 4]);
        check(2, [2, 4]);
        check(3, [4]);
        check(4, [4])
      }
    );
    Test.test(
      "Extensive 2D test",
      func() {
        let set = Set.empty<Nat>();
        let n = 100;
        for (i in Nat.rangeBy(1, n, 2)) {
          set.add(i);
          for (j in Nat.range(0, i + 2)) {
            let actual = Iter.toArray(set.valuesFrom(j));
            let expected = Iter.toArray(Iter.dropWhile<(Nat)>(set.values(), func(k) = k < j));
            Test.expect.array(actual, Nat.toText, Nat.equal).equal(expected)
          }
        }
      }
    )
  }
);

Test.suite(
  "reverseValuesFrom",
  func() {
    Test.test(
      "Simple",
      func() {
        let set = Set.empty<Nat>();
        set.add(1);
        set.add(2);
        set.add(4);
        func check(from : Nat, expected : [Nat]) {
          let actual = Iter.toArray(set.reverseValuesFrom(from));
          Test.expect.array(actual, Nat.toText, Nat.equal).equal(expected)
        };
        check(0, []);
        check(1, [1]);
        check(2, [2, 1]);
        check(3, [2, 1]);
        check(4, [4, 2, 1]);
        check(5, [4, 2, 1])
      }
    );
    Test.test(
      "Extensive 2D test",
      func() {
        let set = Set.empty<Nat>();
        let n = 100;
        for (i in Nat.rangeBy(1, n, 2)) {
          set.add(i);
          for (j in Nat.range(0, i + 2)) {
            let actual = Iter.toArray(set.reverseValuesFrom(j));
            let expected = Iter.toArray(Iter.dropWhile<(Nat)>(Set.reverseValues(set), func(k) = k > j));
            Test.expect.array(actual, Nat.toText, Nat.equal).equal(expected)
          }
        }
      }
    )
  }
)
