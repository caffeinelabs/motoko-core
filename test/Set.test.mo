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
        Set.empty<Nat>().size(),
        M.equals(T.nat(0))
      ),
      test(
        "is empty",
        Set.empty<Nat>().isEmpty(),
        M.equals(T.bool(true))
      ),
      test(
        "add empty",
        do {
          let set = Set.empty<Nat>();
          set.add(0);
          set.values().toArray()
        },
        M.equals(T.array(T.natTestable, [0]))
      ),
      test(
        "insert empty",
        do {
          let set = Set.empty<Nat>();
          assert set.insert(0);
          set.values().toArray()
        },
        M.equals(T.array(T.natTestable, [0]))
      ),
      test(
        "remove empty",
        do {
          let set = Set.empty<Nat>();
          set.remove(0);
          set.values().toArray()
        },
        M.equals(T.array(T.natTestable, []))
      ),
      test(
        "delete empty",
        do {
          let set = Set.empty<Nat>();
          assert (not set.delete(0));
          set.values().toArray()
        },
        M.equals(T.array(T.natTestable, []))
      ),
      test(
        "clone no alias",
        do {
          let original = Set.empty<Nat>();
          let clone = original.clone();
          original.add(Nat.compare, 0);
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
        Set.empty<Nat>().values().toArray(),
        M.equals(T.array(T.natTestable, []))
      ),
      test(
        "iterate backward",
        Set.empty<Nat>().reverseValues().toArray(),
        M.equals(T.array(T.natTestable, []))
      ),
      test(
        "contains present",
        do {
          let set = Set.empty<Nat>();
          set.add(Nat.compare, 0);
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
          set.max()
        },
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
      test(
        "minimum",
        do {
          let set = Set.empty<Nat>();
          set.min()
        },
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
      test(
        "from iterator",
        do {
          let set = Set.fromIter<Nat>(Iter.empty<Nat>());
          set.size()
        },
        M.equals(T.nat(0))
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
          set.foldLeft(
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
          set.foldRight(
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
          set.all(
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
          set.any(
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
          let set1 = Set.fromIter(Iter.empty<Nat>(), Nat.compare);
          let set2 = set1.clone();
          set1.isSubset(set2)
        },
        M.equals(T.bool(true))
      ),
      test(
        "join",
        do {
          let set1 = Set.fromIter(Iter.empty<Nat>(), Nat.compare);
          let set2 = set1.clone();
          let set3 = set2.clone();
          let combined = Set.join([set1, set2, set3].values());
          combined.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "flatten",
        do {
          let subSet1 = Set.fromIter(Iter.empty<Nat>(), Nat.compare);
          let subSet2 = subSet1.clone();
          let subSet3 = subSet2.clone();
          let iterator = [subSet1, subSet2, subSet3].values();
          let setOfSets = Set.fromIter<Set.Set<Nat>>(iterator, func(first, second) { first.compare(second) });
          let combined = setOfSets.flatten();
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
          set.add(Nat.compare, 0);
          set.values().toArray()
        },
        M.equals(T.array(T.natTestable, [0]))
      ),
      test(
        "add singleton new",
        do {
          let set = Set.singleton<Nat>(0);
          set.add(Nat.compare, 1);
          set.values().toArray()
        },
        M.equals(T.array(T.natTestable, [0, 1]))
      ),
      test(
        "insert singleton old",
        do {
          let set = Set.singleton<Nat>(0);
          assert (not set.insert(Nat.compare, 0));
          set.values().toArray()
        },
        M.equals(T.array(T.natTestable, [0]))
      ),
      test(
        "insert singleton new",
        do {
          let set = Set.singleton<Nat>(0);
          assert set.insert(Nat.compare, 1);
          set.values().toArray()
        },
        M.equals(T.array(T.natTestable, [0, 1]))
      ),
      test(
        "remove singleton old",
        do {
          let set = Set.singleton<Nat>(0);
          set.remove(Nat.compare, 0);
          set.values().toArray()
        },
        M.equals(T.array(T.natTestable, []))
      ),
      test(
        "remove singleton new",
        do {
          let set = Set.singleton<Nat>(0);
          set.remove(Nat.compare, 1);
          set.values().toArray()
        },
        M.equals(T.array(T.natTestable, [0]))
      ),
      test(
        "delete singleton old",
        do {
          let set = Set.singleton<Nat>(0);
          assert (set.delete(Nat.compare, 0));
          set.values().toArray()
        },
        M.equals(T.array(T.natTestable, []))
      ),
      test(
        "delete singleton new",
        do {
          let set = Set.singleton<Nat>(0);
          assert (not set.delete(Nat.compare, 1));
          set.values().toArray()
        },
        M.equals(T.array(T.natTestable, [0]))
      ),
      test(
        "clone",
        do {
          let original = Set.singleton<Nat>(0);
          let clone = original.clone();
          assert (original.equal(clone, Nat.compare));
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
          original.remove(Nat.compare, 0);
          assert original.size() == 0;
          assert not original.contains(Nat.compare, 0);
          assert clone.contains(Nat.compare, 0);
          clone.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "iterate forward",
        Set.singleton<Nat>(0).values().toArray(),
        M.equals(T.array(T.natTestable, [0]))
      ),
      test(
        "iterate backward",
        Set.singleton<Nat>(0).reverseValues().toArray(),
        M.equals(T.array(T.natTestable, [0]))
      ),
      test(
        "contains present key",
        do {
          let set = Set.singleton<Nat>(0);
          set.contains(Nat.compare, 0)
        },
        M.equals(T.bool(true))
      ),
      test(
        "contains absent key",
        do {
          let set = Set.singleton<Nat>(0);
          set.contains(Nat.compare, 1)
        },
        M.equals(T.bool(false))
      ),
      test(
        "add duplicate",
        do {
          let set = Set.singleton<Nat>(0);
          set.add(Nat.compare, 0);
          assert (set.contains(Nat.compare, 0));
          set.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "remove",
        do {
          let set = Set.singleton<Nat>(0);
          set.remove(Nat.compare, 0);
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
          set1.equal(set2, Nat.compare)
        },
        M.equals(T.bool(true))
      ),
      test(
        "not equal",
        do {
          let set1 = Set.singleton<Nat>(0);
          let set2 = Set.singleton<Nat>(1);
          set1.equal(set2, Nat.compare)
        },
        M.equals(T.bool(false))
      ),
      test(
        "maximum",
        do {
          let set = Set.singleton<Nat>(0);
          set.max()
        },
        M.equals(T.optional(T.natTestable, ?0))
      ),
      test(
        "minimum",
        do {
          let set = Set.singleton<Nat>(0);
          set.min()
        },
        M.equals(T.optional(T.natTestable, ?0))
      ),
      test(
        "iterate forward",
        Set.singleton<Nat>(0).values().toArray(),
        M.equals(T.array(T.natTestable, [0]))
      ),
      test(
        "iterate backwards",
        Set.singleton<Nat>(0).reverseValues().toArray(),
        M.equals(T.array(T.natTestable, [0]))
      ),
      test(
        "from iterator",
        do {
          let set = Set.fromIter([0].values(), Nat.compare);
          assert (set.contains(Nat.compare, 0));
          assert (set.equal(Set.singleton<Nat>(0), Nat.compare));
          set.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "for each",
        do {
          let set = Set.singleton<Nat>(0);
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
          let input = Set.singleton<Nat>(0);
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
        "map",
        do {
          let input = Set.singleton<Nat>(0);
          let output = input.map(
            Int.compare,
            func(number) {
              assert (number == 0);
              +number
            }
          );
          assert (output.contains(Int.compare, 0));
          output.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "filter map",
        do {
          let input = Set.singleton<Nat>(0);
          let output = input.filterMap(
            Int.compare,
            func(number) {
              assert (number == 0);
              ?+number
            }
          );
          assert (output.contains(Int.compare, 0));
          output.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "fold left",
        do {
          let set = Set.singleton<Nat>(1);
          set.foldLeft(
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
          set.foldRight(
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
          set.all(
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
          set.all(
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
          set.any(
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
          set.any(
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
          set.toText(Nat.toText)
        },
        M.equals(T.text("Set{1}"))
      ),
      test(
        "compare less",
        do {
          let set1 = Set.singleton<Nat>(0);
          let set2 = Set.singleton<Nat>(1);
          assert (set1.compare(set2, Nat.compare) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare equal",
        do {
          let set1 = Set.singleton<Nat>(0);
          let set2 = Set.singleton<Nat>(0);
          assert (set1.compare(set2, Nat.compare) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater key",
        do {
          let set1 = Set.singleton<Nat>(1);
          let set2 = Set.singleton<Nat>(0);
          assert (set1.compare(set2, Nat.compare) == #greater);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "is sub-set",
        do {
          let set1 = Set.singleton<Nat>(0);
          let set2 = Set.singleton<Nat>(0);
          set1.isSubset(set2, Nat.compare)
        },
        M.equals(T.bool(true))
      ),
      test(
        "is not sub-set",
        do {
          let set1 = Set.singleton<Nat>(0);
          let set2 = Set.singleton<Nat>(1);
          set1.isSubset(set2, Nat.compare)
        },
        M.equals(T.bool(false))
      ),
      test(
        "is strict sub-set",
        do {
          let set1 = Set.singleton<Nat>(1);
          let set2 = Set.fromIter([0, 1, 2].values(), Nat.compare);
          set1.isSubset(set2, Nat.compare)
        },
        M.equals(T.bool(true))
      ),
      test(
        "union",
        do {
          let set1 = Set.singleton<Nat>(1);
          let set2 = Set.singleton<Nat>(2);
          let union = set1.union(set2, Nat.compare);
          union.values().toArray()
        },
        M.equals(
          T.array(
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
          let union = set1.union(set2, Nat.compare);
          union.values().toArray()
        },
        M.equals(
          T.array(
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
          let intersection = set1.intersection(set2, Nat.compare);
          intersection.values().toArray()
        },
        M.equals(
          T.array(
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
          let intersection = set1.intersection(set2, Nat.compare);
          intersection.values().toArray()
        },
        M.equals(
          T.array(
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
          let difference = set1.difference(set2, Nat.compare);
          difference.values().toArray()
        },
        M.equals(
          T.array(
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
          let difference = set1.difference(set2, Nat.compare);
          difference.values().toArray()
        },
        M.equals(
          T.array(
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
          let combined = Set.join([set1, set2, set3].values(), Nat.compare);
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
          let subSet1 = Set.singleton<Nat>(0);
          let subSet2 = Set.singleton<Nat>(1);
          let subSet3 = Set.singleton<Nat>(2);
          let iterator = [subSet1, subSet2, subSet3].values();
          let setOfSets = Set.fromIter<Set.Set<Nat>>(iterator, func(first, second) { first.compare(second, Nat.compare) });
          let combined = setOfSets.flatten(Nat.compare);
          combined.values().toArray()
        },
        M.equals(
          T.array(
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
    set.add(Nat.compare, index)
  };
  set
};

run(
  suite(
    "small set",
    [
      test(
        "size",
        smallSet().size(),
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
          set.add(Nat.compare, 1);
          set.add(Nat.compare, 2);
          set.add(Nat.compare, 3);
          set.size()
        },
        M.equals(T.nat(3))
      ),
      test(
        "size after adding and removing elements",
        do {
          let set = Set.empty<Nat>();
          set.add(Nat.compare, 1);
          set.add(Nat.compare, 2);
          set.add(Nat.compare, 3);
          set.remove(Nat.compare, 1);
          set.remove(Nat.compare, 2);
          set.remove(Nat.compare, 3);
          set.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "is empty",
        smallSet().isEmpty(),
        M.equals(T.bool(false))
      ),
      test(
        "clone",
        do {
          let original = smallSet();
          let clone = original.clone();
          assert (original.equal(clone, Nat.compare));
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
          let keys = original.values().toArray();
          for (key in keys.values()) {
            original.remove(Nat.compare, key)
          };
          for (key in keys.values()) {
            assert clone.contains(Nat.compare, key) == copy.contains(Nat.compare, key)
          };
          clone.size()
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "iterate forward",
        smallSet().values().toArray(),
        M.equals(
          T.array(
            T.natTestable,
            Array.tabulate(smallSize, func(index) { index })
          )
        )
      ),
      test(
        "iterate backward",
        smallSet().reverseValues().toArray(),
        M.equals(T.array(T.natTestable, Array.tabulate(smallSize, func(index) { index }).reverse()))
      ),
      test(
        "contains present",
        do {
          let set = smallSet();
          for (index in Nat.range(0, smallSize)) {
            assert (set.contains(Nat.compare, index))
          };
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "contains absent",
        do {
          let set = smallSet();
          set.contains(Nat.compare, smallSize)
        },
        M.equals(T.bool(false))
      ),
      test(
        "remove",
        do {
          let set = smallSet();
          for (index in Nat.range(0, smallSize)) {
            set.remove(Nat.compare, index)
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
          set1.equal(set2, Nat.compare)
        },
        M.equals(T.bool(true))
      ),
      test(
        "not equal",
        do {
          let set1 = smallSet();
          let set2 = smallSet();
          set2.remove(Nat.compare, smallSize - 1 : Nat);
          set1.equal(set2, Nat.compare)
        },
        M.equals(T.bool(false))
      ),
      test(
        "maximum",
        do {
          let set = smallSet();
          set.max()
        },
        M.equals(T.optional(T.natTestable, ?(smallSize - 1 : Nat)))
      ),
      test(
        "minimum",
        do {
          let set = smallSet();
          set.min()
        },
        M.equals(T.optional(T.natTestable, ?0))
      ),
      test(
        "forward iteration",
        smallSet().values().toArray(),
        M.equals(T.array(T.natTestable, Array.tabulate(smallSize, func(index) { index })))
      ),
      test(
        "backwards iteration",
        smallSet().reverseValues().toArray(),
        M.equals(T.array(T.natTestable, Array.tabulate(smallSize, func(index) { smallSize - 1 - index : Nat })))
      ),
      test(
        "from iterator",
        do {
          let array = Array.tabulate(smallSize, func(index) { index });
          let set = Set.fromIter(array.values(), Nat.compare);
          for (index in Nat.range(0, smallSize)) {
            assert (set.contains(Nat.compare, index))
          };
          assert (set.equal(smallSet(), Nat.compare));
          set.size()
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "for each",
        do {
          let set = smallSet();
          var index = 0;
          set.forEach(
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
          let output = input.filter(
            Nat.compare,
            func(number) {
              number % 2 == 0
            }
          );
          for (index in Nat.range(0, smallSize)) {
            let present = output.contains(Nat.compare, index);
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
          let output = input.map(
            Int.compare,
            func(number) {
              +number
            }
          );
          for (index in Nat.range(0, smallSize)) {
            assert (output.contains(Int.compare, index))
          };
          output.size()
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "filter map",
        do {
          let input = smallSet();
          let output = input.filterMap(
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
            let present = output.contains(Int.compare, index);
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
          set.foldLeft(
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
          set.foldRight(
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
          set.all(
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
          set.any(
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
          set.toText(Nat.toText)
        },
        do {
          var text = "Set{";
          for (index in Nat.range(0, smallSize)) {
            if (text != "Set{") {
              text #= ", "
            };
            text #= index.toText()
          };
          text #= "}";
          M.equals(T.text(text))
        }
      ),
      test(
        "compare less key",
        do {
          let set1 = smallSet();
          set1.remove(Nat.compare, smallSize - 1 : Nat);
          let set2 = smallSet();
          assert (set1.compare(set2, Nat.compare) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare equal",
        do {
          let set1 = smallSet();
          let set2 = smallSet();
          assert (set1.compare(set2, Nat.compare) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater key",
        do {
          let set1 = smallSet();
          let set2 = smallSet();
          set2.remove(Nat.compare, smallSize - 1 : Nat);
          assert (set1.compare(set2, Nat.compare) == #greater);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "union",
        do {
          let set1 = smallSet().map(Int.compare, func(number) { +number });
          let set2 = smallSet().map(Int.compare, func(number) { -number });
          let union = set1.union(set2, Int.compare);
          union.values().toArray()
        },
        M.equals(
          T.array(
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
          let set1 = smallSet().map(Int.compare, func(number) { +number });
          set1.add(Int.compare, -1);
          let set2 = smallSet().map(Int.compare, func(number) { -number });
          set2.add(Int.compare, 1);
          let intersection = set1.intersection(set2, Int.compare);
          intersection.values().toArray()
        },
        M.equals(
          T.array(
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
          set2.remove(Nat.compare, 0);
          set2.remove(Nat.compare, 1);
          set2.remove(Nat.compare, 2);
          let difference = set1.difference(set2, Nat.compare);
          difference.values().toArray()
        },
        M.equals(
          T.array(
            T.natTestable,
            [0, 1, 2]
          )
        )
      ),
      test(
        "join",
        do {
          let set1 = smallSet().map(Int.compare, func(number) { +number });
          let set2 = smallSet().map(Int.compare, func(number) { -number });
          let set3 = Set.fromIter([-1, 1].values(), Int.compare);
          let combined = Set.join([set1, set2, set3].values(), Int.compare);
          combined.values().toArray()
        },
        M.equals(
          T.array(
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
          let subSet1 = smallSet().map(Int.compare, func(number) { +number });
          let subSet2 = smallSet().map(Int.compare, func(number) { -number });
          let subSet3 = Set.fromIter([-1, 1].values(), Int.compare);
          let iterator = [subSet1, subSet2, subSet3].values();
          let setOfSets = Set.fromIter<Set.Set<Int>>(iterator, func(first, second) { first.compare(second, Int.compare) });
          let combined = setOfSets.flatten(Int.compare);
          combined.values().toArray()
        },
        M.equals(
          T.array(
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
            set.add(Nat.compare, index);
            assert (set.size() == index + 1);
            assert (set.contains(Nat.compare, index))
          };
          for (index in Nat.range(0, numberOfElements)) {
            assert (set.contains(Nat.compare, index))
          };
          assert (not set.contains(Nat.compare, numberOfElements));
          set.assertValid(Nat.compare);
          set.size()
        },
        M.equals(T.nat(numberOfElements))
      ),
      test(
        "insert",
        do {
          let set = Set.empty<Nat>();
          for (index in Nat.range(0, numberOfElements)) {
            assert (set.insert(Nat.compare, index));
            assert (set.size() == index + 1);
            assert (set.contains(Nat.compare, index))
          };
          for (index in Nat.range(0, numberOfElements)) {
            assert (not (set.insert(Nat.compare, index)))
          };
          for (index in Nat.range(0, numberOfElements)) {
            assert (set.contains(Nat.compare, index))
          };
          assert (not set.contains(Nat.compare, numberOfElements));
          set.assertValid(Nat.compare);
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
            if (not set.contains(Nat.compare, element)) {
              set.add(Nat.compare, element)
            }
          };
          random.reset();
          for (index in Nat.range(0, numberOfElements)) {
            let element = random.next();
            assert (set.contains(Nat.compare, element))
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
            if (not set.contains(Nat.compare, element)) {
              set.add(Nat.compare, element)
            }
          };
          assert (set.size() > 0);
          random.reset();
          for (index in Nat.range(0, numberOfElements)) {
            let element = random.next();
            assert (set.contains(Nat.compare, element))
          };
          random.reset();
          for (index in Nat.range(0, numberOfElements)) {
            let element = random.next();
            if (set.contains(Nat.compare, element)) {
              set.remove(Nat.compare, element);
              assert (not set.contains(Nat.compare, element))
            };
            assert (not set.contains(Nat.compare, element))
          };
          set.assertValid(Nat.compare);
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
            if (not set.contains(Nat.compare, element)) {
              set.add(Nat.compare, element)
            }
          };
          assert (set.size() > 0);
          random.reset();
          for (index in Nat.range(0, numberOfElements)) {
            let element = random.next();
            assert (set.contains(Nat.compare, element))
          };
          random.reset();
          for (index in Nat.range(0, numberOfElements)) {
            let element = random.next();
            if (set.contains(Nat.compare, element)) {
              assert set.delete(Nat.compare, element);
              assert (not set.contains(Nat.compare, element))
            } else {
              assert (not set.delete(Nat.compare, element))
            };
            assert (not set.contains(Nat.compare, element))
          };
          set.assertValid(Nat.compare);
          set.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "iterate",
        do {
          let set = Set.empty<Nat>();
          for (index in Nat.range(0, numberOfElements)) {
            set.add(Nat.compare, index)
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
            set.add(Nat.compare, index)
          };
          var index = numberOfElements;
          for (element in set.reverseValues()) {
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
          let union = set1.union(set2, Nat.compare);
          union.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "union first non-empty",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let union = set1.union(set2, Nat.compare);
          union.values().toArray()
        },
        M.equals(T.array(T.natTestable, [1, 2, 3]))
      ),
      test(
        "union first non-empty",
        do {
          let set1 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let set2 = Set.empty<Nat>();
          let union = set1.union(set2, Nat.compare);
          union.values().toArray()
        },
        M.equals(T.array(T.natTestable, [1, 2, 3]))
      ),
      test(
        "union both non-empty disjoint",
        do {
          let set1 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let set2 = Set.fromIter([4, 5, 6].values(), Nat.compare);
          let union = set1.union(set2, Nat.compare);
          union.size()
        },
        M.equals(T.nat(6))
      ),
      test(
        "union both non-empty overlapping",
        do {
          let set1 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let set2 = Set.fromIter([2, 3, 4].values(), Nat.compare);
          let union = set1.union(set2, Nat.compare);
          union.size()
        },
        M.equals(T.nat(4))
      ),
      test(
        "intersect both empty",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.empty<Nat>();
          let intersection = set1.intersection(set2, Nat.compare);
          intersection.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "intersect first non-empty",
        do {
          let set1 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let set2 = Set.empty<Nat>();
          let intersection = set1.intersection(set2, Nat.compare);
          intersection.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "intersect second non-empty",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let intersection = set1.intersection(set2, Nat.compare);
          intersection.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "intersect both non-empty disjoint",
        do {
          let set1 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let set2 = Set.fromIter([4, 5, 6].values(), Nat.compare);
          let intersection = set1.intersection(set2, Nat.compare);
          intersection.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "intersect both non-empty overlapping",
        do {
          let set1 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let set2 = Set.fromIter([2, 3, 4].values(), Nat.compare);
          let intersection = set1.intersection(set2, Nat.compare);
          intersection.values().toArray()
        },
        M.equals(T.array(T.natTestable, [2, 3]))
      ),
      test(
        "diff both empty",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.empty<Nat>();
          let difference = set1.difference(set2, Nat.compare);
          difference.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "diff first non-empty",
        do {
          let set1 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let set2 = Set.empty<Nat>();
          let difference = set1.difference(set2, Nat.compare);
          difference.values().toArray()
        },
        M.equals(T.array(T.natTestable, [1, 2, 3]))
      ),
      test(
        "diff second non-empty",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let difference = set1.difference(set2, Nat.compare);
          difference.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "diff both non-empty disjoint",
        do {
          let set1 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let set2 = Set.fromIter([4, 5, 6].values(), Nat.compare);
          let difference = set1.difference(set2, Nat.compare);
          difference.values().toArray()
        },
        M.equals(T.array(T.natTestable, [1, 2, 3]))
      ),
      test(
        "diff both non-empty overlapping",
        do {
          let set1 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let set2 = Set.fromIter([2, 3, 4].values(), Nat.compare);
          let difference = set1.difference(set2, Nat.compare);
          difference.values().toArray()
        },
        M.equals(T.array(T.natTestable, [1]))
      ),
      test(
        "addAll both empty",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.empty<Nat>();
          set1.addAll(Nat.compare, set2.values());
          set1.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "addAll first non-empty",
        do {
          let set1 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let set2 = Set.empty<Nat>();
          set1.addAll(Nat.compare, set2.values());
          set1.values().toArray()
        },
        M.equals(T.array(T.natTestable, [1, 2, 3]))
      ),
      test(
        "addAll second non-empty",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          set1.addAll(Nat.compare, set2.values());
          set1.values().toArray()
        },
        M.equals(T.array(T.natTestable, [1, 2, 3]))
      ),
      test(
        "addAll both non-empty disjoint",
        do {
          let set1 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let set2 = Set.fromIter([4, 5, 6].values(), Nat.compare);
          set1.addAll(Nat.compare, set2.values());
          set1.values().toArray()
        },
        M.equals(T.array(T.natTestable, [1, 2, 3, 4, 5, 6]))
      ),
      test(
        "addAll both non-empty overlapping",
        do {
          let set1 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let set2 = Set.fromIter([2, 3, 4].values(), Nat.compare);
          set1.addAll(Nat.compare, set2.values());
          set1.values().toArray()
        },
        M.equals(T.array(T.natTestable, [1, 2, 3, 4]))
      ),
      test(
        "retainAll empty",
        do {
          let set = Set.empty<Nat>();
          assert (not set.retainAll(Nat.compare, func(n) { true }));
          set.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "retainAll all",
        do {
          let set = Set.fromIter([1, 2, 3].values(), Nat.compare);
          assert (not set.retainAll(Nat.compare, func(n) { true }));
          set.values().toArray()
        },
        M.equals(T.array(T.natTestable, [1, 2, 3]))
      ),
      test(
        "retainAll none",
        do {
          let set = Set.fromIter([1, 2, 3].values(), Nat.compare);
          assert (set.retainAll(Nat.compare, func(n) { false }));
          set.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "retainAll even",
        do {
          let set = Set.fromIter([1, 2, 3, 4].values(), Nat.compare);
          assert (set.retainAll(Nat.compare, func(n) { n % 2 == 0 }));
          set.values().toArray()
        },
        M.equals(T.array(T.natTestable, [2, 4]))
      ),
      test(
        "retainAll predicate",
        do {
          let set = Set.fromIter([1, 2, 3, 4, 5].values(), Nat.compare);
          assert (set.retainAll(Nat.compare, func(n) { n > 2 and n < 5 }));
          set.values().toArray()
        },
        M.equals(T.array(T.natTestable, [3, 4]))
      ),
      test(
        "deleteAll both empty",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.empty<Nat>();
          assert (not set1.deleteAll(Nat.compare, set2.values()));
          set1.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "deleteAll first non-empty",
        do {
          let set1 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let set2 = Set.empty<Nat>();
          assert (not set1.deleteAll(Nat.compare, set2.values()));
          set1.values().toArray()
        },
        M.equals(T.array(T.natTestable, [1, 2, 3]))
      ),
      test(
        "deleteAll both non-empty equal",
        do {
          let set1 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let set2 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          assert (set1.deleteAll(Nat.compare, set2.values()));
          set1.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "deleteAll second non-empty",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          assert (not (set1.deleteAll(Nat.compare, set2.values())));
          set1.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "deleteAll both non-empty disjoint",
        do {
          let set1 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let set2 = Set.fromIter([4, 5, 6].values(), Nat.compare);
          assert (not (set1.deleteAll(Nat.compare, set2.values())));
          set1.values().toArray()
        },
        M.equals(T.array(T.natTestable, [1, 2, 3]))
      ),
      test(
        "deleteAll both non-empty overlapping",
        do {
          let set1 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let set2 = Set.fromIter([2, 3, 4].values(), Nat.compare);
          assert set1.deleteAll(Nat.compare, set2.values());
          set1.values().toArray()
        },
        M.equals(T.array(T.natTestable, [1]))
      ),

      test(
        "insertAll first non-empty",
        do {
          let set1 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let set2 = Set.empty<Nat>();
          assert (not set1.insertAll(Nat.compare, set2.values()));
          set1.values().toArray()
        },
        M.equals(T.array(T.natTestable, [1, 2, 3]))
      ),
      test(
        "insertAll both non-empty equal",
        do {
          let set1 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let set2 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          assert (not set1.insertAll(Nat.compare, set2.values()));
          set1.size()
        },
        M.equals(T.nat(3))
      ),
      test(
        "insertAll second non-empty",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          assert (set1.insertAll(Nat.compare, set2.values()));
          set1.size()
        },
        M.equals(T.nat(3))
      ),
      test(
        "insertAll both non-empty disjoint",
        do {
          let set1 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let set2 = Set.fromIter([4, 5, 6].values(), Nat.compare);
          assert (set1.insertAll(Nat.compare, set2.values()));
          set1.values().toArray()
        },
        M.equals(T.array(T.natTestable, [1, 2, 3, 4, 5, 6]))
      ),
      test(
        "insertAll both non-empty overlapping",
        do {
          let set1 = Set.fromIter([1, 2, 3].values(), Nat.compare);
          let set2 = Set.fromIter([2, 3, 4].values(), Nat.compare);
          assert set1.insertAll(Nat.compare, set2.values());
          set1.values().toArray()
        },
        M.equals(T.array(T.natTestable, [1, 2, 3, 4]))
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
        set.add(Nat.compare, 1);
        set.add(Nat.compare, 2);
        set.add(Nat.compare, 4);
        func check(from : Nat, expected : [Nat]) {
          let actual = set.valuesFrom(Nat.compare, from).toArray();
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
          set.add(Nat.compare, i);
          for (j in Nat.range(0, i + 2)) {
            let actual = set.valuesFrom(Nat.compare, j).toArray();
            let expected = set.values().dropWhile(func(k) = k < j).toArray();
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
        set.add(Nat.compare, 1);
        set.add(Nat.compare, 2);
        set.add(Nat.compare, 4);
        func check(from : Nat, expected : [Nat]) {
          let actual = set.reverseValuesFrom(Nat.compare, from).toArray();
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
          set.add(Nat.compare, i);
          for (j in Nat.range(0, i + 2)) {
            let actual = set.reverseValuesFrom(Nat.compare, j).toArray();
            let expected = set.reverseValues().dropWhile(func(k) = k > j).toArray();
            Test.expect.array(actual, Nat.toText, Nat.equal).equal(expected)
          }
        }
      }
    )
  }
)
