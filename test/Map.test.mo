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
        Map.size(Map.empty<Nat, Text>()),
        M.equals(T.nat(0))
      ),
      test(
        "is empty",
        Map.isEmpty(Map.empty<Nat, Text>()),
        M.equals(T.bool(true))
      ),
      test(
        "add empty",
        do {
          let map = Map.empty<Nat, Text>();
          map.add(0, "0");
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
        M.equals(T.array<(Nat, Text)>(entryTestable, []))
      ),
      test(
        "delete empty",
        do {
          let map = Map.empty<Nat, Text>();
          assert (not map.delete(0));
          map.entries().toArray()
        },
        M.equals(T.array<(Nat, Text)>(entryTestable, []))
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
        M.equals(T.array<(Nat, Text)>(entryTestable, []))
      ),
      test(
        "iterate backward",
        Map.empty<Nat, Text>().reverseEntries().toArray(),
        M.equals(T.array<(Nat, Text)>(entryTestable, []))
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
        M.equals(T.array<Nat>(T.natTestable, []))
      ),
      test(
        "iterate values",
        Map.empty<Nat, Text>().values().toArray(),
        M.equals(T.array<Text>(T.textTestable, []))
      ),
      test(
        "from iterator",
        do {
          let map = Map.fromIter<Nat, Text>(Iter.fromArray<(Nat, Text)>([]));
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
          let output = input.filter<Nat, Text>(
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
          map.foldLeft<Nat, Text, Nat>(
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
          map.foldRight<Nat, Text, Nat>(
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
          map.all<Nat, Text>(
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
          map.any<Nat, Text>(
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
          assert (map1.compare(map2) == #equal);
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
          map.add(0, "1");
          map.entries().toArray()
        },
        M.equals(T.array<(Nat, Text)>(entryTestable, [(0, "1")]))
      ),
      test(
        "add singleton new",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.add(1, "1");
          map.entries().toArray()
        },
        M.equals(T.array<(Nat, Text)>(entryTestable, [(0, "0"), (1, "1")]))
      ),
      test(
        "insert singleton old",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          assert (not map.insert(0, "1"));
          map.entries().toArray()
        },
        M.equals(T.array<(Nat, Text)>(entryTestable, [(0, "1")]))
      ),
      test(
        "insert singleton new",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          assert map.insert(1, "1");
          map.entries().toArray()
        },
        M.equals(T.array<(Nat, Text)>(entryTestable, [(0, "0"), (1, "1")]))
      ),
      test(
        "remove singleton old",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.remove(0);
          map.entries().toArray()
        },
        M.equals(T.array<(Nat, Text)>(entryTestable, []))
      ),
      test(
        "remove singleton new",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.remove(1);
          map.entries().toArray()
        },
        M.equals(T.array<(Nat, Text)>(entryTestable, [(0, "0")]))
      ),
      test(
        "delete singleton old",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          assert (map.delete(0));
          map.entries().toArray()
        },
        M.equals(T.array<(Nat, Text)>(entryTestable, []))
      ),
      test(
        "delete singleton new",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          assert (not map.delete(1));
          map.entries().toArray()
        },
        M.equals(T.array<(Nat, Text)>(entryTestable, [(0, "0")]))
      ),
      test(
        "take function result",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.take(0)
        },
        M.equals(T.optional(T.textTestable, ?"0"))
      ),
      test(
        "take map result",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          ignore map.take(0);
          map.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "clone",
        do {
          let original = Map.singleton<Nat, Text>(0, "0");
          let clone = original.clone();
          assert (original.equal(clone));
          clone.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "clone no alias",
        do {
          let original = Map.singleton<Nat, Text>(0, "0");
          let clone = original.clone();
          original.add(0, "1");
          assert (clone.get(0) == ?"0");
          clone.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "iterate forward",
        Map.singleton<Nat, Text>(0, "0").entries().toArray(),
        M.equals(T.array<(Nat, Text)>(entryTestable, [(0, "0")]))
      ),
      test(
        "iterate backward",
        Map.singleton<Nat, Text>(0, "0").reverseEntries().toArray(),
        M.equals(T.array<(Nat, Text)>(entryTestable, [(0, "0")]))
      ),
      test(
        "contains present key",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.containsKey(0)
        },
        M.equals(T.bool(true))
      ),
      test(
        "contains absent key",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.containsKey(1)
        },
        M.equals(T.bool(false))
      ),
      test(
        "get present",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.get(0)
        },
        M.equals(T.optional(T.textTestable, ?"0"))
      ),
      test(
        "get absent",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.get(1)
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "update present",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.swap(0, "Zero")
        },
        M.equals(T.optional(T.textTestable, ?"0"))
      ),
      test(
        "update absent",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          map.swap(1, "1")
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "replace if exists present",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          assert (map.replace(0, "Zero") == ?"0");
          map.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "replace if exists absent",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          assert (map.replace(1, "1") == null);
          map.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "delete",
        do {
          let map = Map.singleton<Nat, Text>(0, "0");
          assert map.delete(0);
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
          map1.equal(map2)
        },
        M.equals(T.bool(true))
      ),
      test(
        "not equal",
        do {
          let map1 = Map.singleton<Nat, Text>(0, "0");
          let map2 = Map.singleton<Nat, Text>(1, "1");
          map1.equal(map2)
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
        M.equals(T.array<Nat>(T.natTestable, [0]))
      ),
      test(
        "iterate values",
        Map.singleton<Nat, Text>(0, "0").values().toArray(),
        M.equals(T.array<Text>(T.textTestable, ["0"]))
      ),
      test(
        "from iterator",
        do {
          let map = Map.fromIter<Nat, Text>(Iter.fromArray<(Nat, Text)>([(0, "0")]), Nat.compare);
          assert (map.get(0) == ?"0");
          assert (map.equal(Map.singleton<Nat, Text>(0, "0")));
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
          let output = input.filter<Nat, Text>(
            func(key, value) {
              assert (key == 0);
              assert (value == "0");
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
          let input = Map.singleton<Nat, Text>(0, "0");
          let output = input.map<Nat, Text, Int>(
            func(key, value) {
              assert (key == 0);
              assert (value == "0");
              +key
            }
          );
          assert (output.get(0) == ?+0);
          output.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "filter map",
        do {
          let input = Map.singleton<Nat, Text>(0, "0");
          let output = input.filterMap<Nat, Text, Int>(
            func(key, value) {
              assert (key == 0);
              assert (value == "0");
              ?+key
            }
          );
          assert (output.get(0) == ?+0);
          output.size()
        },
        M.equals(T.nat(1))
      ),
      test(
        "fold left",
        do {
          let map = Map.singleton<Nat, Text>(1, "1");
          map.foldLeft<Nat, Text, Nat>(
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
          map.foldRight<Nat, Text, Nat>(
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
          map.all<Nat, Text>(
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
          map.all<Nat, Text>(
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
          map.any<Nat, Text>(
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
          map.any<Nat, Text>(
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
          map.toText()
        },
        M.equals(T.text("Map{(1, 1)}"))
      ),
      test(
        "compare less key",
        do {
          let map1 = Map.singleton<Nat, Text>(0, "0");
          let map2 = Map.singleton<Nat, Text>(1, "1");
          assert (map1.compare(map2) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare less value",
        do {
          let map1 = Map.singleton<Nat, Text>(0, "0");
          let map2 = Map.singleton<Nat, Text>(0, "Zero");
          assert (map1.compare(map2) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare equal",
        do {
          let map1 = Map.singleton<Nat, Text>(0, "0");
          let map2 = Map.singleton<Nat, Text>(0, "0");
          assert (map1.compare(map2) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater key",
        do {
          let map1 = Map.singleton<Nat, Text>(1, "1");
          let map2 = Map.singleton<Nat, Text>(0, "0");
          assert (map1.compare(map2) == #greater);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater value",
        do {
          let map1 = Map.singleton<Nat, Text>(0, "Zero");
          let map2 = Map.singleton<Nat, Text>(0, "0");
          assert (map1.compare(map2) == #greater);
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
    map.add(index, Nat.toText(index))
  };
  map
};

run(
  suite(
    "small map",
    [
      test(
        "size",
        Map.size<Nat, Text>(smallMap()),
        M.equals(T.nat(smallSize))
      ),
      test(
        "is empty",
        Map.isEmpty<Nat, Text>(smallMap()),
        M.equals(T.bool(false))
      ),
      test(
        "clone",
        do {
          let original = smallMap();
          let clone = original.clone();
          assert (original.equal(clone));
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
            original.add(key, "X")
          };
          for (key in keys.values()) {
            assert clone.get(key) == copy.get(key)
          };
          clone.size()
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "iterate forward",
        smallMap().entries().toArray(),
        M.equals(
          T.array<(Nat, Text)>(
            entryTestable,
            Array.tabulate<(Nat, Text)>(smallSize, func(index) { (index, Nat.toText(index)) })
          )
        )
      ),
      test(
        "iterate backward",
        smallMap().reverseEntries().toArray(),
        M.equals(T.array<(Nat, Text)>(entryTestable, Array.reverse(Array.tabulate<(Nat, Text)>(smallSize, func(index) { (index, Nat.toText(index)) }))))
      ),
      test(
        "contains present keys",
        do {
          let map = smallMap();
          for (index in Nat.range(0, smallSize)) {
            assert (map.containsKey(index))
          };
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "contains absent key",
        do {
          let map = smallMap();
          map.containsKey(smallSize)
        },
        M.equals(T.bool(false))
      ),
      test(
        "get present",
        do {
          let map = smallMap();
          for (index in Nat.range(0, smallSize)) {
            assert (map.get(index) == ?Nat.toText(index))
          };
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "get absent",
        do {
          let map = smallMap();
          map.get(smallSize)
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "update present",
        do {
          let map = smallMap();
          for (index in Nat.range(0, smallSize)) {
            assert (map.swap(index, Nat.toText(index) # "!") == ?Nat.toText(index))
          };
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "update absent",
        do {
          let map = smallMap();
          map.swap(smallSize, Nat.toText(smallSize))
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "replace if exists present",
        do {
          let map = smallMap();
          for (index in Nat.range(0, smallSize)) {
            assert (map.replace(index, Nat.toText(index) # "!") == ?Nat.toText(index))
          };
          map.size()
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "replace if exists absent",
        do {
          let map = smallMap();
          assert (map.replace(smallSize, Nat.toText(smallSize)) == null);
          map.size()
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "delete",
        do {
          let map = smallMap();
          for (index in Nat.range(0, smallSize)) {
            assert map.delete(index)
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
          map1.equal(map2)
        },
        M.equals(T.bool(true))
      ),
      test(
        "not equal",
        do {
          let map1 = smallMap();
          let map2 = smallMap();
          assert map2.delete(smallSize - 1 : Nat);
          map1.equal(map2)
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
        M.equals(T.array<Nat>(T.natTestable, Array.tabulate<Nat>(smallSize, func(index) { index })))
      ),
      test(
        "iterate values",
        smallMap().values().toArray(),
        M.equals(T.array<Text>(T.textTestable, Array.tabulate<Text>(smallSize, func(index) { Nat.toText(index) })))
      ),
      test(
        "from iterator",
        do {
          let array = Array.tabulate<(Nat, Text)>(smallSize, func(index) { (index, Nat.toText(index)) });
          let map = Map.fromIter<Nat, Text>(Iter.fromArray(array), Nat.compare);
          for (index in Nat.range(0, smallSize)) {
            assert (map.get(index) == ?Nat.toText(index))
          };
          assert (map.equal(smallMap()));
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
              assert (value == Nat.toText(index));
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
          let output = input.filter<Nat, Text>(
            func(key, value) {
              key % 2 == 0
            }
          );
          for (index in Nat.range(0, smallSize)) {
            let present = output.containsKey(index);
            if (index % 2 == 0) {
              assert (present);
              assert (output.get(index) == ?Nat.toText(index))
            } else {
              assert (not present);
              assert (output.get(index) == null)
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
          let output = input.map<Nat, Text, Int>(
            func(key, value) {
              +key
            }
          );
          for (index in Nat.range(0, smallSize)) {
            assert (output.get(index) == ?+index)
          };
          output.size()
        },
        M.equals(T.nat(smallSize))
      ),
      test(
        "filter map",
        do {
          let input = smallMap();
          let output = input.filterMap<Nat, Text, Int>(
            func(key, value) {
              if (key % 2 == 0) {
                ?+key
              } else {
                null
              }
            }
          );
          for (index in Nat.range(0, smallSize)) {
            let present = output.containsKey(index);
            if (index % 2 == 0) {
              assert (present);
              assert (output.get(index) == ?+index)
            } else {
              assert (not present);
              assert (output.get(index) == null)
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
          map.foldLeft<Nat, Text, Nat>(
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
          map.foldRight<Nat, Text, Nat>(
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
          map.all<Nat, Text>(
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
          map.any<Nat, Text>(
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
          map.toText()
        },
        do {
          var text = "Map{";
          for (index in Nat.range(0, smallSize)) {
            if (text != "Map{") {
              text #= ", "
            };
            text #= "(" # Nat.toText(index) # ", " # Nat.toText(index) # ")"
          };
          text #= "}";
          M.equals(T.text(text))
        }
      ),
      test(
        "compare less key",
        do {
          let map1 = smallMap();
          assert map1.delete(smallSize - 1 : Nat);
          let map2 = smallMap();
          assert (map1.compare(map2) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare less value",
        do {
          let map1 = smallMap();
          let map2 = smallMap();
          ignore map2.swap(smallSize - 1 : Nat, "Last");
          assert (map1.compare(map2) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare equal",
        do {
          let map1 = smallMap();
          let map2 = smallMap();
          assert (map1.compare(map2) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater key",
        do {
          let map1 = smallMap();
          let map2 = smallMap();
          assert map2.delete(smallSize - 1 : Nat);
          assert (map1.compare(map2) == #greater);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater value",
        do {
          let map1 = smallMap();
          ignore map1.swap(smallSize - 1 : Nat, "Last");
          let map2 = smallMap();
          assert (map1.compare(map2) == #greater);
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
            map.add(index, Nat.toText(index));
            assert (map.size() == index + 1);
            assert (map.get(index) == ?Nat.toText(index))
          };
          for (index in Nat.range(0, numberOfEntries)) {
            assert (map.get(index) == ?Nat.toText(index))
          };
          assert (map.get(numberOfEntries) == null);
          map.assertValid();
          map.size()
        },
        M.equals(T.nat(numberOfEntries))
      ),
      test(
        "insert",
        do {
          let map = Map.empty<Nat, Text>();
          for (index in Nat.range(0, numberOfEntries)) {
            assert map.insert(index, Nat.toText(index));
            assert (map.size() == index + 1);
            assert (map.get(index) == ?Nat.toText(index))
          };
          for (index in Nat.range(0, numberOfEntries)) {
            assert (not map.insert(index, Nat.toText(index)));
            assert (map.get(index) == ?Nat.toText(index))
          };
          assert (map.get(numberOfEntries) == null);
          map.assertValid();
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
            ignore map.swap(key, Nat.toText(key))
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            assert (map.get(key) == ?Nat.toText(key))
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
            ignore map.swap(key, Nat.toText(key))
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            assert (map.containsKey(key));
            let oldValue = map.swap(key, Nat.toText(key) # "!");
            assert (oldValue != null)
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            assert (map.containsKey(key));
            assert (map.get(key) == ?(Nat.toText(key) # "!"))
          };
          map.assertValid();
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
            ignore map.swap(key, Nat.toText(key))
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            assert (map.containsKey(key));
            assert (map.get(key) == ?Nat.toText(key))
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            if (map.containsKey(key)) {
              map.remove(key);
              assert (not map.containsKey(key))
            } else {
              map.remove(key)
            };
            assert (map.get(key) == null)
          };
          map.assertValid();
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
            ignore map.swap(key, Nat.toText(key))
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            assert (map.containsKey(key));
            assert (map.get(key) == ?Nat.toText(key))
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            if (map.containsKey(key)) {
              assert map.delete(key);
              assert (not map.containsKey(key))
            } else {
              assert not map.delete(key)
            };
            assert (map.get(key) == null)
          };
          map.assertValid();
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
            ignore map.swap(key, Nat.toText(key))
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            assert (map.containsKey(key));
            assert (map.get(key) == ?Nat.toText(key))
          };
          random.reset();
          for (index in Nat.range(0, numberOfEntries)) {
            let key = random.next();
            if (map.containsKey(key)) {
              assert map.take(key) == ?(Nat.toText(key));
              assert (not map.containsKey(key))
            } else {
              assert map.take(key) == null
            };
            assert (map.get(key) == null)
          };
          map.assertValid();
          map.size()
        },
        M.equals(T.nat(0))
      ),
      test(
        "iterate",
        do {
          let map = Map.empty<Nat, Text>();
          for (index in Nat.range(0, numberOfEntries)) {
            map.add(index, Nat.toText(index))
          };
          var index = 0;
          for ((key, value) in map.entries()) {
            assert (key == index);
            assert (value == Nat.toText(index));
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
            map.add(index, Nat.toText(index))
          };
          var index = numberOfEntries;
          for ((key, value) in map.reverseEntries()) {
            index -= 1;
            assert (key == index);
            assert (value == Nat.toText(index))
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
          map.add(0, "0");
          map.add(1, "1");
          map.size()
        },
        M.equals(T.nat(2))
      ),
      test(
        "put existing",
        do {
          let map = Map.empty<Nat, Text>();
          map.add(0, "0");
          map.add(0, "Zero");
          map.get(0)
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
            map.add(index, Nat.toText(index))
          };
          let pureMap = map.toPure();
          for (index in Nat.range(0, numberOfEntries)) {
            assert (pureMap.get(index) == ?Nat.toText(index))
          };
          pureMap.assertValid();
          pureMap.size
        },
        M.equals(T.nat(numberOfEntries))
      ),
      test(
        "fromPure",
        do {
          var pureMap = PureMap.empty<Nat, Text>();
          for (index in Nat.range(0, numberOfEntries)) {
            pureMap := pureMap.add(index, Nat.toText(index))
          };
          let map = Map.fromPure<Nat, Text>(pureMap);
          for (index in Nat.range(0, numberOfEntries)) {
            assert (map.get(index) == ?Nat.toText(index))
          };
          map.assertValid();
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
        map.add(1, "1");
        map.add(2, "2");
        map.add(4, "4");
        func check(from : Nat, expected : [(Nat, Text)]) {
          let actual = (map.entriesFrom(from)).toArray();
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
          map.add(i, Nat.toText(i));
          for (j in Nat.range(0, i + 2)) {
            let actual = (map.entriesFrom(j)).toArray();
            let expected = (Iter.dropWhile<(Nat, Text)>(map.entries(), func(k, v) = k < j)).toArray();
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
        map.add(1, "1");
        map.add(2, "2");
        map.add(4, "4");
        func check(from : Nat, expected : [(Nat, Text)]) {
          let actual = (map.reverseEntriesFrom(from)).toArray();
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
          map.add(i, Nat.toText(i));
          for (j in Nat.range(0, i + 2)) {
            let actual = (map.reverseEntriesFrom(j)).toArray();
            let expected = (Iter.dropWhile<(Nat, Text)>(map.reverseEntries(), func(k, v) = k > j)).toArray();
            Test.expect.array(actual, Tuple2.makeToText(Nat.toText, Text.toText), Tuple2.makeEqual(Nat.equal, Text.equal)).equal(expected)
          }
        }
      }
    )
  }
)
