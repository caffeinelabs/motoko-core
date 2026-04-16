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
        assert Queue.size(Queue.empty<Nat>()) == 0
      }
    );

    test(
      "is empty",
      func() {
        assert Queue.isEmpty(Queue.empty<Nat>())
      }
    );

    test(
      "peek front",
      func() {
        assert Queue.peekFront(Queue.empty<Nat>()) == null
      }
    );

    test(
      "peek back",
      func() {
        assert Queue.peekBack(Queue.empty<Nat>()) == null
      }
    );

    test(
      "pop front",
      func() {
        assert Queue.popFront(Queue.empty<Nat>()) == null
      }
    );

    test(
      "pop back",
      func() {
        assert Queue.popBack(Queue.empty<Nat>()) == null
      }
    );

    test(
      "contains",
      func() {
        assert not Queue.contains(Queue.empty<Nat>(), Nat.equal, 0)
      }
    );

    test(
      "clone",
      func() {
        assert Queue.size(Queue.clone(Queue.empty<Nat>())) == 0
      }
    );

    test(
      "clear",
      func() {
        let queue = Queue.empty<Nat>();
        Queue.clear(queue);
        assert Queue.size(queue) == 0
      }
    );

    test(
      "from iter",
      func() {
        assert Queue.size(Queue.fromIter<Nat>(Iter.fromArray([]))) == 0
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
        assert Queue.equal(Queue.empty<Nat>(), Queue.empty<Nat>(), Nat.equal)
      }
    );

    test(
      "compare",
      func() {
        assert Queue.compare(Queue.empty<Nat>(), Queue.empty<Nat>(), Nat.compare) == #equal
      }
    );

    test(
      "to text",
      func() {
        assert Queue.toText(Queue.empty<Nat>(), Nat.toText) == "Queue[]"
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
        expect.nat(Queue.size(Queue.singleton<Nat>(0))).equal(1)
      }
    );

    test(
      "is empty",
      func() {
        assert not Queue.isEmpty(Queue.singleton<Nat>(0))
      }
    );

    test(
      "peek front",
      func() {
        assert Queue.peekFront(Queue.singleton<Nat>(0)) == ?0
      }
    );

    test(
      "peek back",
      func() {
        assert Queue.peekBack(Queue.singleton<Nat>(0)) == ?0
      }
    );

    test(
      "pop front",
      func() {
        let queue = Queue.singleton<Nat>(0);
        let front = Queue.popFront(queue);
        assert Queue.isEmpty(queue);
        assert front == ?0
      }
    );

    test(
      "pop back",
      func() {
        let queue = Queue.singleton<Nat>(0);
        let back = Queue.popBack(queue);
        assert Queue.isEmpty(queue);
        assert back == ?0
      }
    );

    test(
      "contains present",
      func() {
        assert Queue.contains(Queue.singleton<Nat>(0), Nat.equal, 0)
      }
    );

    test(
      "contains absent",
      func() {
        assert not Queue.contains(Queue.singleton<Nat>(0), Nat.equal, 1)
      }
    );

    test(
      "clone",
      func() {
        let original = Queue.singleton<Nat>(0);
        let clone = Queue.clone(original);
        assert Queue.popFront(original) == ?0;
        expect.nat(Queue.size(clone)).equal(1)
      }
    );

    test(
      "clear",
      func() {
        let queue = Queue.singleton<Nat>(0);
        Queue.clear(queue);
        expect.nat(Queue.size(queue)).equal(0)
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
        assert Queue.equal(Queue.singleton<Nat>(0), Queue.singleton<Nat>(0), Nat.equal)
      }
    );

    test(
      "equal different",
      func() {
        assert not Queue.equal(Queue.singleton<Nat>(0), Queue.singleton<Nat>(1), Nat.equal)
      }
    );

    test(
      "compare less",
      func() {
        assert Queue.compare(Queue.singleton<Nat>(0), Queue.singleton<Nat>(1), Nat.compare) == #less
      }
    );

    test(
      "compare equal",
      func() {
        assert Queue.compare(Queue.singleton<Nat>(1), Queue.singleton<Nat>(1), Nat.compare) == #equal
      }
    );

    test(
      "compare greater",
      func() {
        assert Queue.compare(Queue.singleton<Nat>(2), Queue.singleton<Nat>(1), Nat.compare) == #greater
      }
    );

    test(
      "to text",
      func() {
        assert Queue.toText(Queue.singleton<Nat>(123), Nat.toText) == "Queue[123]"
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
        Queue.pushFront(queue, 1);
        Queue.pushFront(queue, 2);
        Queue.pushFront(queue, 3);
        assert queue.values().toArray() == [3, 2, 1]
      }
    );

    test(
      "push back",
      func() {
        let queue = Queue.empty<Nat>();
        Queue.pushBack(queue, 1);
        Queue.pushBack(queue, 2);
        Queue.pushBack(queue, 3);
        assert queue.values().toArray() == [1, 2, 3]
      }
    );

    test(
      "mixed push",
      func() {
        let queue = Queue.empty<Nat>();
        Queue.pushFront(queue, 2);
        Queue.pushBack(queue, 3);
        Queue.pushFront(queue, 1);
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
          Queue.popFront(queue),
          Queue.popFront(queue),
          Queue.popFront(queue),
          Queue.popFront(queue)
        ];
        assert Queue.isEmpty(queue);
        assert results == [?1, ?2, ?3, null]
      }
    );

    test(
      "pop back",
      func() {
        let queue = Queue.fromIter<Nat>([1, 2, 3].values());
        let results = [
          Queue.popBack(queue),
          Queue.popBack(queue),
          Queue.popBack(queue),
          Queue.popBack(queue)
        ];
        assert Queue.isEmpty(queue);
        assert results == [?3, ?2, ?1, null]
      }
    );

    test(
      "mixed pop",
      func() {
        let queue = Queue.fromIter<Nat>([1, 2, 3, 4].values());
        let results = [
          Queue.popFront(queue),
          Queue.popBack(queue),
          Queue.popFront(queue),
          Queue.popBack(queue),
          Queue.popFront(queue)
        ];
        assert Queue.isEmpty(queue);
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
        let mapped = Queue.map<Nat, Text>(queue, Nat.toText);
        assert mapped.values().toArray() == ["1", "2", "3"]
      }
    );

    test(
      "filter",
      func() {
        let queue = Queue.fromIter<Nat>([1, 2, 3, 4].values());
        let filtered = Queue.filter<Nat>(queue, func n = n % 2 == 0);
        assert filtered.values().toArray() == [2, 4]
      }
    );

    test(
      "filter map",
      func() {
        let queue = Queue.fromIter<Nat>([1, 2, 3, 4].values());
        let result = Queue.filterMap<Nat, Text>(
          queue,
          func n = if (n % 2 == 0) ?Nat.toText(n) else null
        );
        assert result.values().toArray() == ["2", "4"]
      }
    );

    test(
      "for each",
      func() {
        let queue = Queue.fromIter<Nat>([1, 2, 3].values());
        var sum = 0;
        Queue.forEach<Nat>(queue, func n { sum += n });
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
        assert Queue.all<Nat>(queue, func n = n % 2 == 0)
      }
    );

    test(
      "all false",
      func() {
        let queue = Queue.fromIter<Nat>([2, 3, 4].values());
        assert not Queue.all<Nat>(queue, func n = n % 2 == 0)
      }
    );

    test(
      "any true",
      func() {
        let queue = Queue.fromIter<Nat>([1, 2, 3].values());
        assert Queue.any<Nat>(queue, func n = n % 2 == 0)
      }
    );

    test(
      "any false",
      func() {
        let queue = Queue.fromIter<Nat>([1, 3, 5].values());
        assert not Queue.any<Nat>(queue, func n = n % 2 == 0)
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
        let pureQueue = Queue.toPure(queue);
        assert PureQueue.isEmpty(pureQueue)
      }
    );

    test(
      "empty from pure",
      func() {
        let pureQueue = PureQueue.empty<Nat>();
        let queue = Queue.fromPure<Nat>(pureQueue);
        assert Queue.isEmpty(queue)
      }
    );

    test(
      "singleton to pure",
      func() {
        let queue = Queue.singleton<Nat>(1);
        let pureQueue = Queue.toPure(queue);
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
        let pureQueue = Queue.toPure(queue);
        assert pureQueue.values().toArray() == [1, 2, 3]
      }
    );

    test(
      "multiple elements from pure",
      func() {
        var pureQueue = PureQueue.empty<Nat>();
        pureQueue := PureQueue.pushBack(pureQueue, 1);
        pureQueue := PureQueue.pushBack(pureQueue, 2);
        pureQueue := PureQueue.pushBack(pureQueue, 3);
        let queue = Queue.fromPure<Nat>(pureQueue);
        assert queue.values().toArray() == [1, 2, 3]
      }
    );

    test(
      "round trip mutable to pure to mutable",
      func() {
        let original = Queue.fromIter<Nat>([1, 2, 3].values());
        let pureQueue = Queue.toPure(original);
        let roundTrip = Queue.fromPure<Nat>(pureQueue);
        assert roundTrip.values().toArray() == [1, 2, 3]
      }
    );

    test(
      "round trip pure to mutable to pure",
      func() {
        var original = PureQueue.empty<Nat>();
        original := PureQueue.pushBack(original, 1);
        original := PureQueue.pushBack(original, 2);
        original := PureQueue.pushBack(original, 3);
        let mutableQueue = Queue.fromPure<Nat>(original);
        let roundTrip = Queue.toPure(mutableQueue);
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
            Queue.pushBack(queue, nextInsert);
            nextInsert += 1
          } else {
            assert Queue.size(queue) == (nextInsert - nextRemove : Nat);
            switch (Queue.popFront(queue)) {
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
          switch (Queue.popFront(queue)) {
            case null Runtime.trap("Should not be empty");
            case (?number) {
              assert number == nextRemove;
              nextRemove += 1
            }
          }
        };
        switch (Queue.popFront(queue)) {
          case null {
            assert Queue.isEmpty(queue);
            assert nextInsert == nextRemove
          };
          case (?_) Runtime.trap("Should be empty")
        };
        assert Queue.size(queue) == 0
      }
    );

    test(
      "repeated grow shrink",
      func() {
        let queue = Queue.empty<Nat>();
        for (_ in Nat.range(0, 2)) {
          for (number in Nat.range(0, numberOfSteps)) {
            Queue.pushBack(queue, number)
          };
          for (number in Nat.range(0, numberOfSteps)) {
            assert Queue.popFront(queue) == ?number
          };
          assert Queue.isEmpty(queue)
        };
        expect.nat(Queue.size(queue)).equal(0)
      }
    );

    test(
      "iterate",
      func() {
        let queue = Queue.empty<Nat>();
        for (number in Nat.range(0, numberOfSteps)) {
          Queue.pushBack(queue, number)
        };
        var counter = 0;
        for (number in queue.values()) {
          assert number == counter;
          counter += 1
        };
        assert counter == numberOfSteps;
        for (number in Nat.range(0, numberOfSteps / 2)) {
          assert Queue.popFront(queue) == ?number
        };
        counter := numberOfSteps / 2;
        for (number in queue.values()) {
          assert number == counter;
          counter += 1
        };
        assert counter == numberOfSteps;
        expect.nat(Queue.size(queue)).equal((numberOfSteps + 1) / 2)
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
        assert Queue.isEmpty(queue);
        assert Queue.size(queue) == 0
      }
    );

    test(
      "single element",
      func() {
        let queue = Queue.fromArray<Nat>([42]);
        assert Queue.size(queue) == 1;
        assert Queue.peekFront(queue) == ?42;
        assert Queue.peekBack(queue) == ?42
      }
    );

    test(
      "multiple elements",
      func() {
        let queue = Queue.fromArray<Nat>([1, 2, 3]);
        assert Queue.size(queue) == 3;
        assert Queue.peekFront(queue) == ?1;
        assert Queue.peekBack(queue) == ?3;
        assert Queue.popFront(queue) == ?1;
        assert Queue.popFront(queue) == ?2;
        assert Queue.popFront(queue) == ?3;
        assert Queue.isEmpty(queue)
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
        let array = Queue.toArray(queue);
        assert array == []
      }
    );

    test(
      "single element",
      func() {
        let queue = Queue.singleton<Nat>(42);
        let array = Queue.toArray(queue);
        assert array == [42]
      }
    );

    test(
      "multiple elements",
      func() {
        let queue = Queue.fromArray<Nat>([1, 2, 3]);
        let array = Queue.toArray(queue);
        assert array == [1, 2, 3]
      }
    );

    test(
      "round trip",
      func() {
        let original = [1, 2, 3, 4, 5];
        let queue = Queue.fromArray<Nat>(original);
        let result = Queue.toArray(queue);
        assert result == original
      }
    )
  }
)
