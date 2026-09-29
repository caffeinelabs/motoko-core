import Queue "../src/Queue";
import PureQueue "../src/pure/Queue";
import Iter "../src/Iter";
import Nat "../src/Nat";
import Runtime "../src/Runtime";
import { suite; test; expect } "mo:test";

suite(
  "empty",
  func() {
    test(
      "size",
      func() {
        assert Queue.empty<Nat>().size() == 0
      }
    );

    test(
      "is empty",
      func() {
        assert Queue.empty<Nat>().isEmpty()
      }
    );

    test(
      "peek front",
      func() {
        assert Queue.empty<Nat>().peekFront() == null
      }
    );

    test(
      "peek back",
      func() {
        assert Queue.empty<Nat>().peekBack() == null
      }
    );

    test(
      "pop front",
      func() {
        assert Queue.empty<Nat>().popFront() == null
      }
    );

    test(
      "pop back",
      func() {
        assert Queue.empty<Nat>().popBack() == null
      }
    );

    test(
      "contains",
      func() {
        assert not Queue.empty<Nat>().contains(Nat.equal, 0)
      }
    );

    test(
      "clone",
      func() {
        assert Queue.empty<Nat>().clone().size() == 0
      }
    );

    test(
      "clear",
      func() {
        let queue = Queue.empty<Nat>();
        queue.clear();
        assert queue.size() == 0
      }
    );

    test(
      "from iter",
      func() {
        assert Queue.fromIter<Nat>(Iter.empty<Nat>()).size() == 0
      }
    );

    test(
      "values",
      func() {
        assert Queue.empty<Nat>().values().toArray() == []
      }
    );

    test(
      "equal",
      func() {
        assert Queue.empty<Nat>().equal(Queue.empty<Nat>(), Nat.equal)
      }
    );

    test(
      "compare",
      func() {
        assert Queue.empty<Nat>().compare(Queue.empty<Nat>(), Nat.compare) == #equal
      }
    );

    test(
      "to text",
      func() {
        assert Queue.empty<Nat>().toText(Nat.toText) == "Queue[]"
      }
    )
  }
);

suite(
  "singleton",
  func() {
    test(
      "size",
      func() {
        expect.nat(Queue.singleton<Nat>(0).size()).equal(1)
      }
    );

    test(
      "is empty",
      func() {
        assert not Queue.singleton<Nat>(0).isEmpty()
      }
    );

    test(
      "peek front",
      func() {
        assert Queue.singleton<Nat>(0).peekFront() == ?0
      }
    );

    test(
      "peek back",
      func() {
        assert Queue.singleton<Nat>(0).peekBack() == ?0
      }
    );

    test(
      "pop front",
      func() {
        let queue = Queue.singleton<Nat>(0);
        let front = queue.popFront();
        assert queue.isEmpty();
        assert front == ?0
      }
    );

    test(
      "pop back",
      func() {
        let queue = Queue.singleton<Nat>(0);
        let back = queue.popBack();
        assert queue.isEmpty();
        assert back == ?0
      }
    );

    test(
      "contains present",
      func() {
        assert Queue.singleton<Nat>(0).contains(Nat.equal, 0)
      }
    );

    test(
      "contains absent",
      func() {
        assert not Queue.singleton<Nat>(0).contains(Nat.equal, 1)
      }
    );

    test(
      "clone",
      func() {
        let original = Queue.singleton<Nat>(0);
        let clone = original.clone();
        assert original.popFront() == ?0;
        expect.nat(clone.size()).equal(1)
      }
    );

    test(
      "clear",
      func() {
        let queue = Queue.singleton<Nat>(0);
        queue.clear();
        expect.nat(queue.size()).equal(0)
      }
    );

    test(
      "vals",
      func() {
        assert Queue.singleton<Nat>(0).values().toArray() == [0]
      }
    );

    test(
      "equal same",
      func() {
        assert Queue.singleton<Nat>(0).equal(Queue.singleton<Nat>(0), Nat.equal)
      }
    );

    test(
      "equal different",
      func() {
        assert not Queue.singleton<Nat>(0).equal(Queue.singleton<Nat>(1), Nat.equal)
      }
    );

    test(
      "compare less",
      func() {
        assert Queue.singleton<Nat>(0).compare(Queue.singleton<Nat>(1), Nat.compare) == #less
      }
    );

    test(
      "compare equal",
      func() {
        assert Queue.singleton<Nat>(1).compare(Queue.singleton<Nat>(1), Nat.compare) == #equal
      }
    );

    test(
      "compare greater",
      func() {
        assert Queue.singleton<Nat>(2).compare(Queue.singleton<Nat>(1), Nat.compare) == #greater
      }
    );

    test(
      "to text",
      func() {
        assert Queue.singleton<Nat>(123).toText(Nat.toText) == "Queue[123]"
      }
    )
  }
);

suite(
  "push operations",
  func() {
    test(
      "push front",
      func() {
        let queue = Queue.empty<Nat>();
        queue.pushFront(1);
        queue.pushFront(2);
        queue.pushFront(3);
        assert queue.values().toArray() == [3, 2, 1]
      }
    );

    test(
      "push back",
      func() {
        let queue = Queue.empty<Nat>();
        queue.pushBack(1);
        queue.pushBack(2);
        queue.pushBack(3);
        assert queue.values().toArray() == [1, 2, 3]
      }
    );

    test(
      "mixed push",
      func() {
        let queue = Queue.empty<Nat>();
        queue.pushFront(2);
        queue.pushBack(3);
        queue.pushFront(1);
        assert queue.values().toArray() == [1, 2, 3]
      }
    )
  }
);

suite(
  "pop operations",
  func() {
    test(
      "pop front",
      func() {
        let queue = Queue.fromIter<Nat>([1, 2, 3].values());
        let results = [
          queue.popFront(),
          queue.popFront(),
          queue.popFront(),
          queue.popFront()
        ];
        assert queue.isEmpty();
        assert results == [?1, ?2, ?3, null]
      }
    );

    test(
      "pop back",
      func() {
        let queue = Queue.fromIter<Nat>([1, 2, 3].values());
        let results = [
          queue.popBack(),
          queue.popBack(),
          queue.popBack(),
          queue.popBack()
        ];
        assert queue.isEmpty();
        assert results == [?3, ?2, ?1, null]
      }
    );

    test(
      "mixed pop",
      func() {
        let queue = Queue.fromIter<Nat>([1, 2, 3, 4].values());
        let results = [
          queue.popFront(),
          queue.popBack(),
          queue.popFront(),
          queue.popBack(),
          queue.popFront()
        ];
        assert queue.isEmpty();
        assert results == [?1, ?4, ?2, ?3, null]
      }
    )
  }
);

suite(
  "transformations",
  func() {
    test(
      "map",
      func() {
        let queue = Queue.fromIter<Nat>([1, 2, 3].values());
        let mapped = queue.map(Nat.toText);
        assert mapped.values().toArray() == ["1", "2", "3"]
      }
    );

    test(
      "filter",
      func() {
        let queue = Queue.fromIter<Nat>([1, 2, 3, 4].values());
        let filtered = queue.filter(func n = n % 2 == 0);
        assert filtered.values().toArray() == [2, 4]
      }
    );

    test(
      "filter map",
      func() {
        let queue = Queue.fromIter<Nat>([1, 2, 3, 4].values());
        let result = queue.filterMap(
          func n = if (n % 2 == 0) ?n.toText() else null
        );
        assert result.values().toArray() == ["2", "4"]
      }
    );

    test(
      "for each",
      func() {
        let queue = Queue.fromIter<Nat>([1, 2, 3].values());
        var sum = 0;
        queue.forEach(func n { sum += n });
        assert sum == 6
      }
    )
  }
);

suite(
  "queries",
  func() {
    test(
      "all true",
      func() {
        let queue = Queue.fromIter<Nat>([2, 4, 6].values());
        assert queue.all(func n = n % 2 == 0)
      }
    );

    test(
      "all false",
      func() {
        let queue = Queue.fromIter<Nat>([2, 3, 4].values());
        assert not queue.all(func n = n % 2 == 0)
      }
    );

    test(
      "any true",
      func() {
        let queue = Queue.fromIter<Nat>([1, 2, 3].values());
        assert queue.any(func n = n % 2 == 0)
      }
    );

    test(
      "any false",
      func() {
        let queue = Queue.fromIter<Nat>([1, 3, 5].values());
        assert not queue.any(func n = n % 2 == 0)
      }
    )
  }
);

suite(
  "pure queue conversions",
  func() {
    test(
      "empty to pure",
      func() {
        let queue = Queue.empty<Nat>();
        let pureQueue = queue.toPure();
        assert pureQueue.isEmpty()
      }
    );

    test(
      "empty from pure",
      func() {
        let pureQueue = PureQueue.empty<Nat>();
        let queue = Queue.fromPure<Nat>(pureQueue);
        assert queue.isEmpty()
      }
    );

    test(
      "singleton to pure",
      func() {
        let queue = Queue.singleton<Nat>(1);
        let pureQueue = queue.toPure();
        assert pureQueue.values().toArray() == [1]
      }
    );

    test(
      "singleton from pure",
      func() {
        let pureQueue = PureQueue.pushBack(PureQueue.empty(), 1);
        let queue = Queue.fromPure<Nat>(pureQueue);
        assert queue.values().toArray() == [1]
      }
    );

    test(
      "multiple elements to pure",
      func() {
        let queue = Queue.fromIter<Nat>([1, 2, 3].values());
        let pureQueue = queue.toPure();
        assert pureQueue.values().toArray() == [1, 2, 3]
      }
    );

    test(
      "multiple elements from pure",
      func() {
        var pureQueue = PureQueue.empty<Nat>();
        pureQueue := pureQueue.pushBack(1);
        pureQueue := pureQueue.pushBack(2);
        pureQueue := pureQueue.pushBack(3);
        let queue = Queue.fromPure<Nat>(pureQueue);
        assert queue.values().toArray() == [1, 2, 3]
      }
    );

    test(
      "round trip mutable to pure to mutable",
      func() {
        let original = Queue.fromIter<Nat>([1, 2, 3].values());
        let pureQueue = original.toPure();
        let roundTrip = Queue.fromPure<Nat>(pureQueue);
        assert roundTrip.values().toArray() == [1, 2, 3]
      }
    );

    test(
      "round trip pure to mutable to pure",
      func() {
        var original = PureQueue.empty<Nat>();
        original := original.pushBack(1);
        original := original.pushBack(2);
        original := original.pushBack(3);
        let mutableQueue = Queue.fromPure<Nat>(original);
        let roundTrip = mutableQueue.toPure();
        assert roundTrip.values().toArray() == [1, 2, 3]
      }
    )
  }
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
let numberOfSteps = 10_000;

suite(
  "large queue",
  func() {
    test(
      "randomized FIFO",
      func() {
        let queue = Queue.empty<Nat>();
        var nextInsert = 0;
        var nextRemove = 0;
        let random = Random(randomSeed);
        for (_ in Nat.range(0, numberOfSteps)) {
          if (random.next() % 2 == 0) {
            queue.pushBack(nextInsert);
            nextInsert += 1
          } else {
            assert queue.size() == (nextInsert - nextRemove : Nat);
            switch (queue.popFront()) {
              case null {
                assert nextInsert == nextRemove
              };
              case (?number) {
                assert number == nextRemove;
                nextRemove += 1
              }
            }
          }
        };
        while (nextRemove < nextInsert) {
          switch (queue.popFront()) {
            case null Runtime.trap("Should not be empty");
            case (?number) {
              assert number == nextRemove;
              nextRemove += 1
            }
          }
        };
        switch (queue.popFront()) {
          case null {
            assert queue.isEmpty();
            assert nextInsert == nextRemove
          };
          case (?_) Runtime.trap("Should be empty")
        };
        assert queue.size() == 0
      }
    );

    test(
      "repeated grow shrink",
      func() {
        let queue = Queue.empty<Nat>();
        for (_ in Nat.range(0, 2)) {
          for (number in Nat.range(0, numberOfSteps)) {
            queue.pushBack(number)
          };
          for (number in Nat.range(0, numberOfSteps)) {
            assert queue.popFront() == ?number
          };
          assert queue.isEmpty()
        };
        expect.nat(queue.size()).equal(0)
      }
    );

    test(
      "iterate",
      func() {
        let queue = Queue.empty<Nat>();
        for (number in Nat.range(0, numberOfSteps)) {
          queue.pushBack(number)
        };
        var counter = 0;
        for (number in queue.values()) {
          assert number == counter;
          counter += 1
        };
        assert counter == numberOfSteps;
        for (number in Nat.range(0, numberOfSteps / 2)) {
          assert queue.popFront() == ?number
        };
        counter := numberOfSteps / 2;
        for (number in queue.values()) {
          assert number == counter;
          counter += 1
        };
        assert counter == numberOfSteps;
        expect.nat(queue.size()).equal((numberOfSteps + 1) / 2)
      }
    )
  }
);

suite(
  "fromArray",
  func() {
    test(
      "empty array",
      func() {
        let queue = Queue.fromArray<Nat>([]);
        assert queue.isEmpty();
        assert queue.size() == 0
      }
    );

    test(
      "single element",
      func() {
        let queue = Queue.fromArray<Nat>([42]);
        assert queue.size() == 1;
        assert queue.peekFront() == ?42;
        assert queue.peekBack() == ?42
      }
    );

    test(
      "multiple elements",
      func() {
        let queue = Queue.fromArray<Nat>([1, 2, 3]);
        assert queue.size() == 3;
        assert queue.peekFront() == ?1;
        assert queue.peekBack() == ?3;
        assert queue.popFront() == ?1;
        assert queue.popFront() == ?2;
        assert queue.popFront() == ?3;
        assert queue.isEmpty()
      }
    )
  }
);

suite(
  "toArray",
  func() {
    test(
      "empty queue",
      func() {
        let queue = Queue.empty<Nat>();
        let array = queue.toArray();
        assert array == []
      }
    );

    test(
      "single element",
      func() {
        let queue = Queue.singleton<Nat>(42);
        let array = queue.toArray();
        assert array == [42]
      }
    );

    test(
      "multiple elements",
      func() {
        let queue = Queue.fromArray<Nat>([1, 2, 3]);
        let array = queue.toArray();
        assert array == [1, 2, 3]
      }
    );

    test(
      "round trip",
      func() {
        let original = [1, 2, 3, 4, 5];
        let queue = Queue.fromArray<Nat>(original);
        let result = queue.toArray();
        assert result == original
      }
    )
  }
)
