// @testmode wasi
import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";
import Test "mo:test";
import Map "../src/Map";
import Iter "../src/Iter";
import Nat "../src/Nat";
import Runtime "../src/Runtime";
import Text "../src/Text";
import Array "../src/Array";
import PureMap "../src/pure/Map";
import { Tuple2 } "../src/Tuples";

let { run; test; suite } = Suite;

let entryTestable = T.tuple2Testable(T.natTestable, T.textTestable);

run(
  suite(
    "empty",
    [
      test(
        "size",
        Map.empty<Nat, Text>().size(),
        M.equals(T.nat(0))
      ),
      test(
        "is empty",
        Map.empty<Nat, Text>().isEmpty(),
        M.equals(T.bool(true))
      ),
      test(
        "add empty",
        do {
          let map = Map.empty<Nat, Text>();
          map.add(Nat.compare, 0, "0");
          map.entries().toArray()
        },
        M.equals(T.array(entryTestable, [(0, "0")]))
      ),
      test(
        "insert empty",
        do {
          let map = Map.empty<Nat, Text>();
          assert map.insert(0, "0");
          map.entries().toArray()
        },
        M.equals(T.array(entryTestable, [(0, "0")]))
      ),
      test(
        "remove empty",
        do {
          let map = Map.empty<Nat, Text>();
          map.remove(0);
          map.entries().toArray()
        },
        M.equals(T.array(entryTestable, []))
      ),
      test(
        "delete empty",
        do {
          let map = Map.empty<Nat, Text>();
          assert (not map.delete(0));
          map.entries().toArray()
        },
        M.equals(T.array(entryTestable, []))
      ),
      test(
        "take absent",
        do {
          let map = Map.empty<Nat, Text>();
          map.take(0)
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "clone",
        do {
          let original = Map.empty<Nat, Text>();
          let clone = original.clone();
          clone.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "clone no alias",
        do {
          let original = Map.empty<Nat, Text>();
          let clone = original.clone();
          original.add(0, "0");
          clone.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "iterate forward",
        Map.empty<Nat, Text>().entries().toArray(),
        M.equals(T.array(entryTestable, []))
      ),
      test(
        "iterate backward",
        Map.empty<Nat, Text>().reverseEntries().toArray(),
        M.equals(T.array(entryTestable, []))
      ),
      test(
        "contains key",
        do {
          let map = Map.empty<Nat, Text>();
          map.containsKey(0)
        },
        M.equals(T.bool(false))
      ),
      test(
        "get absent",
        do {
          let map = Map.empty<Nat, Text>();
          map.get(0)
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "update absent",
        do {
          let map = Map.empty<Nat, Text>();
          map.swap(0, "0")
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "replace if exists",
        do {
          let map = Map.empty<Nat, Text>();
          assert (map.replace(0, "0") == null);
          map.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "clear",
        do {
          let map = Map.empty<Nat, Text>();
          map.clear();
          map.isEmpty()
        },
        M.equals(T.bool(true))
      ),
      test(
        "equal",
        do {
          let map1 = Map.empty<Nat, Text>();
          let map2 = Map.empty<Nat, Text>();
          // Note: This is pretty neat, both the comparison for K as well as equals for V are implicit
          map1.equal(map2)
        },
        M.equals(T.bool(true))
      ),
      test(
        "maximum entry",
        do {
          let map = Map.empty<Nat, Text>();
          map.maxEntry()
        },
        M.equals(T.optional(entryTestable, null : ?(Nat, Text)))
      ),
      test(
        "minimum entry",
        do {
          let map = Map.empty<Nat, Text>();
          map.minEntry()
        },
        M.equals(T.optional(entryTestable, null : ?(Nat, Text)))
      ),
      test(
        "iterate keys",
        Map.empty<Nat, Text>().keys().toArray(),
        M.equals(T.array(T.natTestable, []))
      ),
      test(
        "iterate values",
        Map.empty<Nat, Text>().values().toArray(),
        M.equals(T.array(T.textTestable, []))
      ),
      test(
        "from iterator",
        do {
          let map = Map.fromIter<Nat, Text>(Iter.empty<(Nat, Text)>());
          map.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "for each",
        do {
          let map = Map.empty<Nat, Text>();
          map.forEach(
            func(_, _) {
              assert false
            }
          );
          map.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "filter",
        do {
          let input = Map.empty<Nat, Text>();
          let output = input.filter(
            func(_, _) {
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
          let input = Map.empty<Nat, Text>();
          let output = input.map<Nat, Text, Int>(
            func(_, _) {
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
          let input = Map.empty<Nat, Text>();
          let output = input.filterMap<Nat, Text, Int>(
            func(_, _) {
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
          let map = Map.empty<Nat, Text>();
          map.foldLeft(
            0,
            func(_, _, _) {
              Runtime.trap("test failed")
            }
          )
        },
        M.equals(T.nat(0))
      ),
      test(
        "fold right",
        do {
          let map = Map.empty<Nat, Text>();
          map.foldRight(
            0,
            func(_, _, _) {
              Runtime.trap("test failed")
            }
          )
        },
        M.equals(T.nat(0))
      ),
      test(
        "all",
        do {
          let map = Map.empty<Nat, Text>();
          map.all(
            func(_, _) {
              Runtime.trap("test failed")
            }
          )
        },
        M.equals(T.bool(true))
      ),
      test(
        "any",
        do {
          let map = Map.empty<Nat, Text>();
          map.any(
            func(_, _) {
              Runtime.trap("test failed")
            }
          )
        },
        M.equals(T.bool(false))
      ),
      test(
        "to text",
        do {
          let map = Map.empty<Nat, Text>();
          map.toText()
        },
        M.equals(T.text("Map{}"))
      ),
      test(
        "compare",
        do {
          let map1 = Map.empty<Nat, Text>();
          let map2 = Map.empty<Nat, Text>();
          // NOTE: Can't make both compare's implicit because of the name overlap
          assert (map1.compare(map2, Nat.compare, Text.compare) == #equal);
          true
        },
        M.equals(T.bool(true))
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
        Map.size<Nat, Text>(Map.singleton(0, "0")),
        M.equals(T.nat(1))
      ),
      test(
        "is empty",
        Map.isEmpty<Nat, Text>(Map.singleton(0, "0")),
        M.equals(T.bool(false))
      ),
      test(
        "add singleton old",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.add(Nat.compare, 0, "1");
          map.entries().toArray()
        },
        M.equals(T.array(entryTestable, [(0, "1")]))
      ),
      test(
        "add singleton new",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.add(Nat.compare, 1, "1");
          map.entries().toArray()
        },
        M.equals(T.array(entryTestable, [(0, "0"), (1, "1")]))
      ),
      test(
        "insert singleton old",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          assert (not map.insert(Nat.compare, 0, "1"));
          map.entries().toArray()
        },
        M.equals(T.array(entryTestable, [(0, "1")]))
      ),
      test(
        "insert singleton new",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          assert map.insert(Nat.compare, 1, "1");
          map.entries().toArray()
        },
        M.equals(T.array(entryTestable, [(0, "0"), (1, "1")]))
      ),
      test(
        "remove singleton old",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.remove(Nat.compare, 0);
          map.entries().toArray()
        },
        M.equals(T.array(entryTestable, []))
      ),
      test(
        "remove singleton new",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.remove(Nat.compare, 1);
          map.entries().toArray()
        },
        M.equals(T.array(entryTestable, [(0, "0")]))
      ),
      test(
        "delete singleton old",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          assert (map.delete(Nat.compare, 0));
          map.entries().toArray()
        },
        M.equals(T.array(entryTestable, []))
      ),
      test(
        "delete singleton new",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          assert (not map.delete(Nat.compare, 1));
          map.entries().toArray()
        },
        M.equals(T.array(entryTestable, [(0, "0")]))
      ),
      test(
        "take function result",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.take(Nat.compare, 0)
        },
        M.equals(T.optional(T.textTestable, ?"0"))
      ),
      test(
        "take map result",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          ignore map.take(Nat.compare, 0);
          map.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "clone",
        do {
          let original = Map.singleton<Nat, Text>(0, "0");
          let clone = original.clone();
          assert (original.equal(clone, Nat.compare, Text.equal));
          clone.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "clone no alias",
        do {
          let original = Map.singleton<Nat, Text>(0, "0");
          let clone = original.clone();
          original.add(Nat.compare, 0, "1");
          assert (clone.get(Nat.compare, 0) == ?"0");
          clone.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "iterate forward",
        Map.singleton<Nat, Text>(0, "0").entries().toArray(),
        M.equals(T.array(entryTestable, [(0, "0")]))
      ),
      test(
        "iterate backward",
        Map.singleton<Nat, Text>(0, "0").reverseEntries().toArray(),
        M.equals(T.array(entryTestable, [(0, "0")]))
      ),
      test(
        "contains present key",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.containsKey(Nat.compare, 0)
        },
        M.equals(T.bool(true))
      ),
      test(
        "contains absent key",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.containsKey(Nat.compare, 1)
        },
        M.equals(T.bool(false))
      ),
      test(
        "get present",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.get(Nat.compare, 0)
        },
        M.equals(T.optional(T.textTestable, ?"0"))
      ),
      test(
        "get absent",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.get(Nat.compare, 1)
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "update present",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.swap(Nat.compare, 0, "Zero")
        },
        M.equals(T.optional(T.textTestable, ?"0"))
      ),
      test(
        "update absent",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.swap(Nat.compare, 1, "1")
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "replace if exists present",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          assert (map.replace(Nat.compare, 0, "Zero") == ?"0");
          map.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "replace if exists absent",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          assert (map.replace(Nat.compare, 1, "1") == null);
          map.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "delete",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          assert map.delete(Nat.compare, 0);
          map.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "clear",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.clear();
          map.isEmpty()
        },
        M.equals(T.bool(true))
      ),
      test(
        "equal",
        do {
          let map1 = Map.singleton<Nat, Text>(0, "0");
          let map2 = Map.singleton<Nat, Text>(0, "0");
          map1.equal(map2, Nat.compare, Text.equal)
        },
        M.equals(T.bool(true))
      ),
      test(
        "not equal",
        do {
          let map1 = Map.singleton<Nat, Text>(0, "0");
          let map2 = Map.singleton<Nat, Text>(1, "1");
          map1.equal(map2, Nat.compare, Text.equal)
        },
        M.equals(T.bool(false))
      ),
      test(
        "maximum entry",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.maxEntry()
        },
        M.equals(T.optional(entryTestable, ?(0, "0")))
      ),
      test(
        "minimum entry",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.minEntry()
        },
        M.equals(T.optional(entryTestable, ?(0, "0")))
      ),
      test(
        "iterate keys",
        Map.singleton<Nat, Text>(0, "0").keys().toArray(),
        M.equals(T.array(T.natTestable, [0]))
      ),
      test(
        "iterate values",
        Map.singleton<Nat, Text>(0, "0").values().toArray(),
        M.equals(T.array(T.textTestable, ["0"]))
      ),
      test(
        "from iterator",
        do {
          let map = Map.fromIter([(0, "0")].values(), Nat.compare);
          assert (map.get(Nat.compare, 0) == ?"0");
          assert (map.equal(Map.singleton<Nat, Text>(0, "0"), Nat.compare, Text.equal));
          map.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "for each",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.forEach(
            func(key, value) {
              assert (key == 0);
              assert (value == "0")
            }
          );
          map.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "filter",
        do {
          let input = Map.singleton<Nat, Text>(0, "0");
          let output = input.filter(
            Nat.compare,
            func(key, value) {
              assert (key == 0);
              assert (value == "0");
              true
            }
          );
          assert (input.equal(output, Nat.compare, Text.equal));
          output.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "map",
        do {
          let input = Map.singleton<Nat, Text>(0, "0");
          let output = input.map(
            func(key, value) {
              assert (key == 0);
              assert (value == "0");
              +key
            }
          );
          assert (output.get(Nat.compare, 0) == ?+0);
          output.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "filter map",
        do {
          let input = Map.singleton<Nat, Text>(0, "0");
          let output = input.filterMap(
            Nat.compare,
            func(key, value) {
              assert (key == 0);
              assert (value == "0");
              ?+key
            }
          );
          assert (output.get(Nat.compare, 0) == ?+0);
          output.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "fold left",
        do {
          let map = Map.singleton<Nat, Text>(1, "1");
          map.foldLeft(
            0,
            func(accumulator, key, value) {
              accumulator + key
            }
          )
        },
        M.equals(T.nat(1))
      ),
      test(
        "fold right",
        do {
          let map = Map.singleton<Nat, Text>(1, "1");
          map.foldRight(
            0,
            func(key, value, accumulator) {
              key + accumulator
            }
          )
        },
        M.equals(T.nat(1))
      ),
      test(
        "all",
        do {
          let map = Map.singleton<Nat, Text>(1, "1");
          map.all(
            func(key, value) {
              key == 1 and value == "1"
            }
          )
        },
        M.equals(T.bool(true))
      ),
      test(
        "not all",
        do {
          let map = Map.singleton<Nat, Text>(1, "1");
          map.all(
            func(key, value) {
              key == 0
            }
          )
        },
        M.equals(T.bool(false))
      ),
      test(
        "any",
        do {
          let map = Map.singleton<Nat, Text>(1, "1");
          map.any(
            func(key, value) {
              key == 1 and value == "1"
            }
          )
        },
        M.equals(T.bool(true))
      ),
      test(
        "not any",
        do {
          let map = Map.singleton<Nat, Text>(1, "1");
          map.any(
            func(key, value) {
              key == 0
            }
          )
        },
        M.equals(T.bool(false))
      ),
      test(
        "to text",
        do {
          let map = Map.singleton<Nat, Text>(1, "1");
          map.toText(Nat.toText, func(value) { value })
        },
        M.equals(T.text("Map{(1, 1)}"))
      ),
      test(
        "compare less key",
        do {
          let map1 = Map.singleton<Nat, Text>(0, "0");
          let map2 = Map.singleton<Nat, Text>(1, "1");
          assert (map1.compare(map2, Nat.compare, Text.compare) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare less value",
        do {
          let map1 = Map.singleton<Nat, Text>(0, "0");
          let map2 = Map.singleton<Nat, Text>(0, "Zero");
          assert (map1.compare(map2, Nat.compare, Text.compare) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare equal",
        do {
          let map1 = Map.singleton<Nat, Text>(0, "0");
          let map2 = Map.singleton<Nat, Text>(0, "0");
          assert (map1.compare(map2, Nat.compare, Text.compare) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater key",
        do {
          let map1 = Map.singleton<Nat, Text>(1, "1");
          let map2 = Map.singleton<Nat, Text>(0, "0");
          assert (map1.compare(map2, Nat.compare, Text.compare) == #greater);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater value",
        do {
          let map1 = Map.singleton<Nat, Text>(0, "Zero");
          let map2 = Map.singleton<Nat, Text>(0, "0");
          assert (map1.compare(map2, Nat.compare, Text.compare) == #greater);
          true
        },
        M.equals(T.bool(true))
      ),
      // TODO: Test freeze and thaw
    ]
  )
);

let smallSize = 100;
func smallMap() : Map.Map<Nat, Text> {
  let map = Map.empty<Nat, Text>();
  for (index in Nat.range(0, smallSize)) {
    map.add(Nat.compare, index, index.toText())
  };
  map
};

run(
  suite(
    "small map",
    [
      test(
        "size",
        smallMap().size(),
        M.equals(T.nat(smallSize))
      ),
      test(
        "is empty",
        smallMap().isEmpty(),
        M.equals(T.bool(false))
      ),
      test(
        "clone",
        do {
          let original = smallMap();
          let clone = original.clone();
          assert (original.equal(clone, Nat.compare, Text.equal));
          clone.size()
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "clone no alias",
        do {
          let original = smallMap();
          let copy = smallMap();
          let clone = original.clone();
          let keys = original.keys().toArray();
          for (key in keys.values()) {
            original.add(Nat.compare, key, "X")
          };
          for (key in keys.values()) {
            assert clone.get(Nat.compare, key) == copy.get(Nat.compare, key)
          };
          clone.size()
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "iterate forward",
        smallMap().entries().toArray(),
        M.equals(
          T.array(
            entryTestable,
            Array.tabulate(smallSize, func(index) { (index, index.toText()) })
          )
        )
      ),
      test(
        "iterate backward",
        smallMap().reverseEntries().toArray(),
        M.equals(T.array(entryTestable, Array.tabulate(smallSize, func(index) { (index, index.toText()) }).reverse()))
      ),
      test(
        "contains present keys",
        do {
          let map = smallMap();
          for (index in Nat.range(0, smallSize)) {
            assert (map.containsKey(Nat.compare, index))
          };
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "contains absent key",
        do {
          let map = smallMap();
          map.containsKey(Nat.compare, smallSize)
        },
        M.equals(T.bool(false))
      ),
      test(
        "get present",
        do {
          let map = smallMap();
          for (index in Nat.range(0, smallSize)) {
            assert (map.get(Nat.compare, index) == ?index.toText())
          };
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "get absent",
        do {
          let map = smallMap();
          map.get(Nat.compare, smallSize)
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "update present",
        do {
          let map = smallMap();
          for (index in Nat.range(0, smallSize)) {
            assert (map.swap(Nat.compare, index, index.toText() # "!") == ?index.toText())
          };
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "update absent",
        do {
          let map = smallMap();
          map.swap(Nat.compare, smallSize, smallSize.toText())
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "replace if exists present",
        do {
          let map = smallMap();
          for (index in Nat.range(0, smallSize)) {
            assert (map.replace(Nat.compare, index, index.toText() # "!") == ?index.toText())
          };
          map.size()
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "replace if exists absent",
        do {
          let map = smallMap();
          assert (map.replace(Nat.compare, smallSize, smallSize.toText()) == null);
          map.size()
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "delete",
        do {
          let map = smallMap();
          for (index in Nat.range(0, smallSize)) {
            assert map.delete(Nat.compare, index)
          };
          map.isEmpty()
        },
        M.equals(T.bool(true))
      ),
      test(
        "clear",
        do {
          let map = smallMap();
          map.clear();
          map.isEmpty()
        },
        M.equals(T.bool(true))
      ),
      test(
        "equal",
        do {
          let map1 = smallMap();
          let map2 = smallMap();
          map1.equal(map2, Nat.compare, Text.equal)
        },
        M.equals(T.bool(true))
      ),
      test(
        "not equal",
        do {
          let map1 = smallMap();
          let map2 = smallMap();
          assert map2.delete(Nat.compare, smallSize - 1 : Nat);
          map1.equal(map2, Nat.compare, Text.equal)
        },
        M.equals(T.bool(false))
      ),
      test(
        "maximum entry",
        do {
          let map = smallMap();
          map.maxEntry()
        },
        M.equals(T.optional(entryTestable, ?(smallSize - 1 : Nat, Nat.toText(smallSize - 1))))
      ),
      test(
        "minimum entry",
        do {
          let map = smallMap();
          map.minEntry()
        },
        M.equals(T.optional(entryTestable, ?(0, "0")))
      ),
      test(
        "iterate keys",
        smallMap().keys().toArray(),
        M.equals(T.array(T.natTestable, Array.tabulate(smallSize, func(index) { index })))
      ),
      test(
        "iterate values",
        smallMap().values().toArray(),
        M.equals(T.array(T.textTestable, Array.tabulate(smallSize, func(index) { index.toText() })))
      ),
      test(
        "from iterator",
        do {
          let array = Array.tabulate(smallSize, func(index) { (index, index.toText()) });
          let map = Map.fromIter(array.values(), Nat.compare);
          for (index in Nat.range(0, smallSize)) {
            assert (map.get(Nat.compare, index) == ?index.toText())
          };
          assert (map.equal(smallMap(), Nat.compare, Text.equal));
          map.size()
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "for each",
        do {
          let map = smallMap();
          var index = 0;
          map.forEach(
            func(key, value) {
              assert (key == index);
              assert (value == index.toText());
              index += 1
            }
          );
          map.size()
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "filter",
        do {
          let input = smallMap();
          let output = input.filter(
            Nat.compare,
            func(key, value) {
              key % 2 == 0
            }
          );
          for (index in Nat.range(0, smallSize)) {
            let present = output.containsKey(Nat.compare, index);
            if (index % 2 == 0) {
              assert (present);
              assert (output.get(Nat.compare, index) == ?index.toText())
            } else {
              assert (not present);
              assert (output.get(Nat.compare, index) == null)
            }
          };
          output.size()
        },
        M.equals(T.nat((smallSize + 1) / 2))
      ),
      test(
        "map",
        do {
          let input = smallMap();
          let output = input.map(
            func(key, value) {
              +key
            }
          );
          for (index in Nat.range(0, smallSize)) {
            assert (output.get(Nat.compare, index) == ?+index)
          };
          output.size()
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "filter map",
        do {
          let input = smallMap();
          let output = input.filterMap(
            Nat.compare,
            func(key, value) {
              if (key % 2 == 0) {
                ?+key
              } else {
                null
              }
            }
          );
          for (index in Nat.range(0, smallSize)) {
            let present = output.containsKey(Nat.compare, index);
            if (index % 2 == 0) {
              assert (present);
              assert (output.get(Nat.compare, index) == ?+index)
            } else {
              assert (not present);
              assert (output.get(Nat.compare, index) == null)
            }
          };
          output.size()
        },
        M.equals(T.nat((smallSize + 1) / 2))
      ),
      test(
        "fold left",
        do {
          let map = smallMap();
          map.foldLeft(
            0,
            func(accumulator, key, value) {
              accumulator + key
            }
          )
        },
        M.equals(T.nat((smallSize * (smallSize - 1)) / 2))
      ),
      test(
        "fold right",
        do {
          let map = smallMap();
          map.foldRight(
            0,
            func(key, value, accumulator) {
              key + accumulator
            }
          )
        },
        M.equals(T.nat((smallSize * (smallSize - 1)) / 2))
      ),
      test(
        "all",
        do {
          let map = smallMap();
          map.all(
            func(key, value) {
              key < smallSize
            }
          )
        },
        M.equals(T.bool(true))
      ),
      test(
        "any",
        do {
          let map = smallMap();
          map.any(
            func(key, value) {
              key == (smallSize - 1 : Nat)
            }
          )
        },
        M.equals(T.bool(true))
      ),
      test(
        "to text",
        do {
          let map = smallMap();
          map.toText(Nat.toText, func(value) { value })
        },
        do {
          var text = "Map{";
          for (index in Nat.range(0, smallSize)) {
            if (text != "Map{") {
              text #= ", "
            };
            text #= "(" # index.toText() # ", " # index.toText() # ")"
          };
          text #= "}";
          M.equals(T.text(text))
        }
      ),
      test(
        "compare less key",
        do {
          let map1 = smallMap();
          assert map1.delete(Nat.compare, smallSize - 1 : Nat);
          let map2 = smallMap();
          assert (map1.compare(map2, Nat.compare, Text.compare) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare less value",
        do {
          let map1 = smallMap();
          let map2 = smallMap();
          ignore map2.swap(Nat.compare, smallSize - 1 : Nat, "Last");
          assert (map1.compare(map2, Nat.compare, Text.compare) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare equal",
        do {
          let map1 = smallMap();
          let map2 = smallMap();
          assert (map1.compare(map2, Nat.compare, Text.compare) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater key",
        do {
          let map1 = smallMap();
          let map2 = smallMap();
          assert map2.delete(Nat.compare, smallSize - 1 : Nat);
          assert (map1.compare(map2, Nat.compare, Text.compare) == #greater);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater value",
        do {
          let map1 = smallMap();
          ignore map1.swap(Nat.compare, smallSize - 1 : Nat, "Last");
          let map2 = smallMap();
          assert (map1.compare(map2, Nat.compare, Text.compare) == #greater);
          true
        },
        M.equals(T.bool(true))
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
let numberOfEntries = 10_000;

run(
  suite(
    "large map",
    [
      test(
        "add",
        do {
          let map = Map.empty<Nat, Text>();
          for (index in Nat.range(0, numberOfEntries)) {
            map.add(Nat.compare, index, index.toText());
            assert (map.size() == index + 1);
            assert (map.get(Nat.compare, index) == ?index.toText())
          };
          for (index in Nat.range(0, numberOfEntries)) {
            assert (map.get(Nat.compare, index) == ?index.toText())
          };
          assert (map.get(Nat.compare, numberOfEntries) == null);
          map.assertValid(Nat.compare);
          map.size()
        },
        M.equals(T.nat(numberOfEntries))
      ),
      test(
        "insert",
        do {
          let map = Map.empty<Nat, Text>();
          for (index in Nat.range(0, numberOfEntries)) {
            assert map.insert(Nat.compare, index, index.toText());
            assert (map.size() == index + 1);
            assert (map.get(Nat.compare, index) == ?index.toText())
          };
          for (index in Nat.range(0, numberOfEntries)) {
            assert (not map.insert(Nat.compare, index, index.toText()));
            assert (map.get(Nat.compare, index) == ?index.toText())
          };
          assert (map.get(Nat.compare, numberOfEntries) == null);
          map.assertValid(Nat.compare);
          map.size()
        },
        M.equals(T.nat(numberOfEntries))
      ),
      test(
        "get",
        do {
          let map = Map.empty<Nat, Text>();
          let random = Random(randomSeed);
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            ignore map.swap(Nat.compare, key, key.toText())
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            assert (map.get(Nat.compare, key) == ?key.toText())
          };
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "update",
        do {
          let map = Map.empty<Nat, Text>();
          let random = Random(randomSeed);
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            ignore map.swap(Nat.compare, key, key.toText())
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            assert (map.containsKey(Nat.compare, key));
            let oldValue = map.swap(Nat.compare, key, key.toText() # "!");
            assert (oldValue != null)
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            assert (map.containsKey(Nat.compare, key));
            assert (map.get(Nat.compare, key) == ?(key.toText() # "!"))
          };
          map.assertValid(Nat.compare);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "remove",
        do {
          let map = Map.empty<Nat, Text>();
          let random = Random(randomSeed);
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            ignore map.swap(Nat.compare, key, key.toText())
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            assert (map.containsKey(Nat.compare, key));
            assert (map.get(Nat.compare, key) == ?key.toText())
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            if (map.containsKey(Nat.compare, key)) {
              map.remove(Nat.compare, key);
              assert (not map.containsKey(Nat.compare, key))
            } else {
              map.remove(Nat.compare, key)
            };
            assert (map.get(Nat.compare, key) == null)
          };
          map.assertValid(Nat.compare);
          map.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "delete",
        do {
          let map = Map.empty<Nat, Text>();
          let random = Random(randomSeed);
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            ignore map.swap(Nat.compare, key, key.toText())
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            assert (map.containsKey(Nat.compare, key));
            assert (map.get(Nat.compare, key) == ?key.toText())
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            if (map.containsKey(Nat.compare, key)) {
              assert map.delete(Nat.compare, key);
              assert (not map.containsKey(Nat.compare, key))
            } else {
              assert not map.delete(Nat.compare, key)
            };
            assert (map.get(Nat.compare, key) == null)
          };
          map.assertValid(Nat.compare);
          map.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "take",
        do {
          let map = Map.empty<Nat, Text>();
          let random = Random(randomSeed);
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            ignore map.swap(Nat.compare, key, key.toText())
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            assert (map.containsKey(Nat.compare, key));
            assert (map.get(Nat.compare, key) == ?key.toText())
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            if (map.containsKey(Nat.compare, key)) {
              assert map.take(Nat.compare, key) == ?(key.toText());
              assert (not map.containsKey(Nat.compare, key))
            } else {
              assert map.take(Nat.compare, key) == null
            };
            assert (map.get(Nat.compare, key) == null)
          };
          map.assertValid(Nat.compare);
          map.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "iterate",
        do {
          let map = Map.empty<Nat, Text>();
          for (index in Nat.range(0, numberOfEntries)) {
            map.add(Nat.compare, index, index.toText())
          };
          var index = 0;
          for ((key, value) in map.entries()) {
            assert (key == index);
            assert (value == index.toText());
            index += 1
          };
          index
        },
        M.equals(T.nat(numberOfEntries))
      ),
      test(
        "reverseIterate",
        do {
          let map = Map.empty<Nat, Text>();
          for (index in Nat.range(0, numberOfEntries)) {
            map.add(Nat.compare, index, index.toText())
          };
          var index = numberOfEntries;
          for ((key, value) in map.reverseEntries()) {
            index -= 1;
            assert (key == index);
            assert (value == index.toText())
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
    "add, update, put",
    [
      test(
        "add disjoint",
        do {
          let map = Map.empty<Nat, Text>();
          map.add(Nat.compare, 0, "0");
          map.add(Nat.compare, 1, "1");
          map.size()
        },
        M.equals(T.nat(2))
      ),
      test(
        "put existing",
        do {
          let map = Map.empty<Nat, Text>();
          map.add(Nat.compare, 0, "0");
          map.add(Nat.compare, 0, "Zero");
          map.get(Nat.compare, 0)
        },
        M.equals(T.optional(T.textTestable, ?"Zero"))
      )
    ]
  )
);

run(
  suite(
    "map conversion",
    [
      test(
        "toPure",
        do {
          let map = Map.empty<Nat, Text>();
          for (index in Nat.range(0, numberOfEntries)) {
            map.add(Nat.compare, index, index.toText())
          };
          let pureMap = map.toPure(Nat.compare);
          for (index in Nat.range(0, numberOfEntries)) {
            assert (pureMap.get(Nat.compare, index) == ?index.toText())
          };
          pureMap.assertValid(Nat.compare);
          pureMap.size()
        },
        M.equals(T.nat(numberOfEntries))
      ),
      test(
        "fromPure",
        do {
          var pureMap = PureMap.empty<Nat, Text>();
          for (index in Nat.range(0, numberOfEntries)) {
            pureMap := pureMap.add(Nat.compare, index, index.toText())
          };
          let map = Map.fromPure(pureMap, Nat.compare);
          for (index in Nat.range(0, numberOfEntries)) {
            assert (map.get(Nat.compare, index) == ?index.toText())
          };
          map.assertValid(Nat.compare);
          map.size()
        },
        M.equals(T.nat(numberOfEntries))
      )
    ]
  )
);

Test.suite(
  "entriesFrom",
  func() {
    Test.test(
      "Simple",
      func() {
        let map = Map.empty<Nat, Text>();
        map.add(Nat.compare, 1, "1");
        map.add(Nat.compare, 2, "2");
        map.add(Nat.compare, 4, "4");
        func check(from : Nat, expected : [(Nat, Text)]) {
          let actual = map.entriesFrom(Nat.compare, from).toArray();
          Test.expect.array(actual, Tuple2.makeToText(Nat.toText, Text.toText), Tuple2.makeEqual(Nat.equal, Text.equal)).equal(expected)
        };
        check(0, [(1, "1"), (2, "2"), (4, "4")]);
        check(1, [(1, "1"), (2, "2"), (4, "4")]);
        check(2, [(2, "2"), (4, "4")]);
        check(3, [(4, "4")]);
        check(4, [(4, "4")]);
        check(5, [])
      }
    );
    Test.test(
      "Extensive 2D test",
      func() {
        let map = Map.empty<Nat, Text>();
        let n = 100;
        for (i in Nat.rangeBy(1, n, 2)) {
          map.add(Nat.compare, i, i.toText());
          for (j in Nat.range(0, i + 2)) {
            let actual = map.entriesFrom(Nat.compare, j).toArray();
            let expected = map.entries().dropWhile(func(k, v) = k < j).toArray();
            Test.expect.array(actual, Tuple2.makeToText(Nat.toText, Text.toText), Tuple2.makeEqual(Nat.equal, Text.equal)).equal(expected)
          }
        }
      }
    )
  }
);

Test.suite(
  "reverseEntriesFrom",
  func() {
    Test.test(
      "Simple",
      func() {
        let map = Map.empty<Nat, Text>();
        map.add(Nat.compare, 1, "1");
        map.add(Nat.compare, 2, "2");
        map.add(Nat.compare, 4, "4");
        func check(from : Nat, expected : [(Nat, Text)]) {
          let actual = map.reverseEntriesFrom(Nat.compare, from).toArray();
          Test.expect.array(actual, Tuple2.makeToText(Nat.toText, Text.toText), Tuple2.makeEqual(Nat.equal, Text.equal)).equal(expected)
        };
        check(0, []);
        check(1, [(1, "1")]);
        check(2, [(2, "2"), (1, "1")]);
        check(3, [(2, "2"), (1, "1")]);
        check(4, [(4, "4"), (2, "2"), (1, "1")]);
        check(5, [(4, "4"), (2, "2"), (1, "1")])
      }
    );
    Test.test(
      "Extensive 2D test",
      func() {
        let map = Map.empty<Nat, Text>();
        let n = 100;
        for (i in Nat.rangeBy(1, n, 2)) {
          map.add(Nat.compare, i, i.toText());
          for (j in Nat.range(0, i + 2)) {
            let actual = map.reverseEntriesFrom(Nat.compare, j).toArray();
            let expected = map.reverseEntries().dropWhile(func(k, v) = k > j).toArray();
            Test.expect.array(actual, Tuple2.makeToText(Nat.toText, Text.toText), Tuple2.makeEqual(Nat.equal, Text.equal)).equal(expected)
          }
        }
      }
    )
  }
)
