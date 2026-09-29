// @testmode wasi

import Queue "../../src/pure/Queue";
import Array "../../src/Array";
import Nat "../../src/Nat";
import Iter "../../src/Iter";
import Prim "mo:prim";
import { suite; test; expect } "mo:test";

func iterateForward<T>(queue : Queue.Queue<T>) : Iter.Iter<T> = queue.values();

func iterateBackward<T>(queue : Queue.Queue<T>) : Iter.Iter<T> = queue.reverse().values();

func frontToText(t : (Nat, Queue.Queue<Nat>)) : Text {
  "(" # t.0.toText() # ", " # t.1.toText(Nat.toText) # ")"
};

func frontEqual(t1 : (Nat, Queue.Queue<Nat>), t2 : (Nat, Queue.Queue<Nat>)) : Bool {
  t1.0 == t2.0 and t1.1.equal(t2.1, Nat.equal)
};

func backToText(t : (Queue.Queue<Nat>, Nat)) : Text {
  "(" # t.0.toText(Nat.toText) # ", " # t.1.toText() # ")"
};

func backEqual(t1 : (Queue.Queue<Nat>, Nat), t2 : (Queue.Queue<Nat>, Nat)) : Bool {
  t1.1 == t2.1 and t1.0.equal(t2.0, Nat.equal)
};

func reduceFront<T>(queue : Queue.Queue<T>, amount : Nat) : Queue.Queue<T> {
  var current = queue;
  for (_ in Nat.range(0, amount)) {
    switch (current.popFront()) {
      case null Prim.trap("should not be null");
      case (?result) current := result.1
    }
  };
  current
};

func reduceBack<T>(queue : Queue.Queue<T>, amount : Nat) : Queue.Queue<T> {
  var current = queue;
  for (_ in Nat.range(0, amount)) {
    switch (current.popBack()) {
      case null Prim.trap("should not be null");
      case (?result) current := result.0
    }
  };
  current
};

var queue = Queue.empty<Nat>();

suite(
  "construct",
  func() {
    test(
      "empty",
      func() {
        expect.bool(queue.isEmpty()).isTrue()
      }
    );

    test(
      "iterate forward",
      func() {
        expect.array(iterateForward(queue).toArray(), Nat.toText, Nat.equal).size(0)
      }
    );

    test(
      "iterate backward",
      func() {
        expect.array(iterateBackward(queue).toArray(), Nat.toText, Nat.equal).size(0)
      }
    );

    test(
      "peek front",
      func() {
        expect.option(queue.peekFront(), Nat.toText, Nat.equal).isNull()
      }
    );

    test(
      "peek back",
      func() {
        expect.option(queue.peekBack(), Nat.toText, Nat.equal).isNull()
      }
    );

    test(
      "pop front",
      func() {
        expect.option(
          queue.popFront(),
          frontToText,
          frontEqual
        ).isNull()
      }
    );

    test(
      "pop back",
      func() {
        expect.option(
          queue.popBack(),
          backToText,
          backEqual
        ).isNull()
      }
    )
  }
);

queue := Queue.empty<Nat>().pushFront(1);

suite(
  "single item",
  func() {
    test(
      "not empty",
      func() {
        expect.bool(queue.isEmpty()).isFalse()
      }
    );

    test(
      "iterate forward",
      func() {
        expect.array(iterateForward(queue).toArray(), Nat.toText, Nat.equal).equal([1])
      }
    );

    test(
      "iterate backward",
      func() {
        expect.array(iterateBackward(queue).toArray(), Nat.toText, Nat.equal).equal([1])
      }
    );

    test(
      "peek front",
      func() {
        expect.option(queue.peekFront(), Nat.toText, Nat.equal).equal(?1)
      }
    );

    test(
      "peek back",
      func() {
        expect.option(queue.peekBack(), Nat.toText, Nat.equal).equal(?1)
      }
    );

    test(
      "pop front",
      func() {
        expect.option(
          queue.popFront(),
          frontToText,
          frontEqual
        ).equal(?(1, Queue.empty()))
      }
    );

    test(
      "pop back",
      func() {
        expect.option(
          queue.popBack(),
          backToText,
          backEqual
        ).equal(?(Queue.empty(), 1))
      }
    )
  }
);

let testSize = 100;

func populateForward(from : Nat, to : Nat) : Queue.Queue<Nat> {
  var queue = Queue.empty<Nat>();
  for (number in Nat.range(from, to)) {
    queue := queue.pushFront(number)
  };
  queue
};

queue := populateForward(1, testSize + 1);

suite(
  "forward insertion",
  func() {
    test(
      "not empty",
      func() {
        expect.bool(queue.isEmpty()).isFalse()
      }
    );

    test(
      "iterate forward",
      func() {
        expect.array(
          iterateForward(queue).toArray(),
          Nat.toText,
          Nat.equal
        ).equal(
          Array.tabulate(
            testSize,
            func(index : Nat) : Nat {
              testSize - index
            }
          )
        )
      }
    );

    test(
      "iterate backward",
      func() {
        expect.array(
          iterateBackward(queue).toArray(),
          Nat.toText,
          Nat.equal
        ).equal(
          Array.tabulate(
            testSize,
            func(index : Nat) : Nat {
              index + 1
            }
          )
        )
      }
    );

    test(
      "peek front",
      func() {
        expect.option(queue.peekFront(), Nat.toText, Nat.equal).equal(?testSize)
      }
    );

    test(
      "peek back",
      func() {
        expect.option(queue.peekBack(), Nat.toText, Nat.equal).equal(?1)
      }
    );

    test(
      "pop front",
      func() {
        expect.option(
          queue.popFront(),
          frontToText,
          frontEqual
        ).equal(?(testSize, populateForward(1, testSize)))
      }
    );

    test(
      "empty after front removal",
      func() {
        expect.bool(reduceFront(queue, testSize).isEmpty()).isTrue()
      }
    );

    test(
      "empty after back removal",
      func() {
        expect.bool(reduceBack(queue, testSize).isEmpty()).isTrue()
      }
    )
  }
);

func populateBackward(from : Nat, to : Nat) : Queue.Queue<Nat> {
  var queue = Queue.empty<Nat>();
  for (number in Nat.range(from, to)) {
    queue := queue.pushBack(number)
  };
  queue
};

queue := populateBackward(1, testSize + 1);

suite(
  "backward insertion",
  func() {
    test(
      "not empty",
      func() {
        expect.bool(queue.isEmpty()).isFalse()
      }
    );

    test(
      "iterate forward",
      func() {
        expect.array(
          iterateForward(queue).toArray(),
          Nat.toText,
          Nat.equal
        ).equal(
          Array.tabulate(
            testSize,
            func(index : Nat) : Nat {
              index + 1
            }
          )
        )
      }
    );

    test(
      "iterate backward",
      func() {
        expect.array(
          iterateBackward(queue).toArray(),
          Nat.toText,
          Nat.equal
        ).equal(
          Array.tabulate(
            testSize,
            func(index : Nat) : Nat {
              testSize - index
            }
          )
        )
      }
    );

    test(
      "peek front",
      func() {
        expect.option(queue.peekFront(), Nat.toText, Nat.equal).equal(?1)
      }
    );

    test(
      "peek back",
      func() {
        expect.option(queue.peekBack(), Nat.toText, Nat.equal).equal(?testSize)
      }
    );

    test(
      "pop front",
      func() {
        expect.option(
          queue.popFront(),
          frontToText,
          frontEqual
        ).equal(?(1, populateBackward(2, testSize + 1)))
      }
    );

    test(
      "pop back",
      func() {
        expect.option(
          queue.popBack(),
          backToText,
          backEqual
        ).equal(?(populateBackward(1, testSize), testSize))
      }
    );

    test(
      "empty after front removal",
      func() {
        expect.bool(reduceFront(queue, testSize).isEmpty()).isTrue()
      }
    );

    test(
      "empty after back removal",
      func() {
        expect.bool(reduceBack(queue, testSize).isEmpty()).isTrue()
      }
    )
  }
);

queue := Queue.fromIter([1, 2, 3, 4, 5].values()).filter(func n = n < 3);

suite(
  "filter invariants",
  func() {
    test(
      "not empty",
      func() {
        expect.bool(queue.isEmpty()).isFalse()
      }
    );

    test(
      "peek front",
      func() {
        expect.option(queue.peekFront(), Nat.toText, Nat.equal).equal(?1)
      }
    );

    test(
      "peek back",
      func() {
        expect.option(queue.peekBack(), Nat.toText, Nat.equal).equal(?2)
      }
    )
  }
);

object Random {
  var number = 4711;
  public func next() : Int {
    number := (123138118391 * number + 133489131) % 9999;
    number
  }
};

func randomPopulate(amount : Nat) : Queue.Queue<Nat> {
  var current = Queue.empty<Nat>();
  for (number in Nat.range(0, amount)) {
    current := if (Random.next() % 2 == 0) {
      current.pushFront(Nat.sub(amount, number))
    } else {
      current.pushBack(amount + number)
    }
  };
  current
};

func isSorted(queue : Queue.Queue<Nat>) : Bool {
  let array = iterateForward(queue).toArray();
  let sorted = array.sort(Nat.compare);
  array.equal(sorted, Nat.equal)
};

func randomRemoval(queue : Queue.Queue<Nat>, amount : Nat) : Queue.Queue<Nat> {
  var current = queue;
  for (number in Nat.range(0, amount)) {
    current := if (Random.next() % 2 == 0) {
      let pair = current.popFront();
      switch pair {
        case null Prim.trap("should not be null");
        case (?result) result.1
      }
    } else {
      let pair = current.popBack();
      switch pair {
        case null Prim.trap("should not be null");
        case (?result) result.0
      }
    }
  };
  current
};

queue := randomPopulate(testSize);

suite(
  "random insertion",
  func() {
    test(
      "not empty",
      func() {
        expect.bool(queue.isEmpty()).isFalse()
      }
    );

    test(
      "correct order",
      func() {
        expect.bool(isSorted(queue)).isTrue()
      }
    );

    test(
      "consistent iteration",
      func() {
        expect.array(
          iterateForward(queue).toArray(),
          Nat.toText,
          Nat.equal
        ).equal(iterateBackward(queue).toArray().reverse())
      }
    );

    test(
      "random quarter removal",
      func() {
        expect.bool(isSorted(randomRemoval(queue, testSize / 4))).isTrue()
      }
    );

    test(
      "random half removal",
      func() {
        expect.bool(isSorted(randomRemoval(queue, testSize / 2))).isTrue()
      }
    );

    test(
      "random three quarter removal",
      func() {
        expect.bool(isSorted(randomRemoval(queue, testSize * 3 / 4))).isTrue()
      }
    );

    test(
      "random total removal",
      func() {
        expect.bool(randomRemoval(queue, testSize).isEmpty()).isTrue()
      }
    )
  }
);

func randomInsertionDeletion(steps : Nat) : Queue.Queue<Nat> {
  var current = Queue.empty<Nat>();
  var size = 0;
  for (number in Nat.range(0, steps - 1)) {
    let random = Random.next();
    current := switch (random % 4) {
      case 0 {
        size += 1;
        current.pushFront(Nat.sub(steps, number))
      };
      case 1 {
        size += 1;
        current.pushBack(steps + number)
      };
      case 2 {
        switch (current.popFront()) {
          case null {
            assert (size == 0);
            current
          };
          case (?result) {
            size -= 1;
            result.1
          }
        }
      };
      case 3 {
        switch (current.popBack()) {
          case null {
            assert (size == 0);
            current
          };
          case (?result) {
            size -= 1;
            result.0
          }
        }
      };
      case _ Prim.trap("Impossible case")
    };
    assert (isSorted(current))
  };
  current
};

suite(
  "completely random",
  func() {
    test(
      "random insertion and deletion",
      func() {
        expect.bool(isSorted(randomInsertionDeletion(1000))).isTrue()
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
        let queue = Queue.fromArray([42]);
        assert queue.size() == 1;
        assert queue.peekFront() == ?42;
        assert queue.peekBack() == ?42
      }
    );

    test(
      "multiple elements",
      func() {
        let queue = Queue.fromArray([1, 2, 3]);
        assert queue.size() == 3;
        assert queue.peekFront() == ?1;
        assert queue.peekBack() == ?3;

        switch (queue.popFront()) {
          case null assert false;
          case (?(1, rest1)) {
            switch (rest1.popFront()) {
              case null assert false;
              case (?(2, rest2)) {
                switch (rest2.popFront()) {
                  case null assert false;
                  case (?(3, rest3)) {
                    assert rest3.isEmpty()
                  };
                  case _ assert false
                }
              };
              case _ assert false
            }
          };
          case _ assert false
        }
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
        let queue = Queue.singleton(42);
        let array = queue.toArray();
        assert array == [42]
      }
    );

    test(
      "multiple elements",
      func() {
        let queue = Queue.fromArray([1, 2, 3]);
        let array = queue.toArray();
        assert array == [1, 2, 3]
      }
    );

    test(
      "round trip",
      func() {
        let original = [1, 2, 3, 4, 5];
        let queue = Queue.fromArray(original);
        let result = queue.toArray();
        assert result == original
      }
    )
  }
);

suite(
  "pop restores the queue invariant",
  func() {
    test(
      "popFront that empties the front list keeps accessors correct",
      func() {
        // Build a back-loaded queue: the front list stays a singleton while
        // the back list grows, so the following popFront empties the front.
        var queue = Queue.empty<Nat>();
        for (n in Nat.range(1, 5)) queue := queue.pushBack(n);
        // logical queue: [1, 2, 3, 4]
        let ?(x, rest) = queue.popFront() else Prim.trap("unexpected empty");
        expect.nat(x).equal(1);
        expect.nat(rest.size()).equal(3);
        expect.option(rest.peekFront(), Nat.toText, Nat.equal).equal(?2);
        expect.option(rest.peekBack(), Nat.toText, Nat.equal).equal(?4);
        expect.bool(rest.contains(Nat.equal, 2)).isTrue();
        expect.array(rest.toArray(), Nat.toText, Nat.equal).equal([2, 3, 4])
      }
    );

    test(
      "popBack that empties the back list keeps accessors correct",
      func() {
        // Front-loaded queue: the back list stays a singleton while the front
        // list grows, so the following popBack empties the back.
        var queue = Queue.empty<Nat>();
        for (n in Nat.rangeBy(4, 0, -1)) queue := queue.pushFront(n);
        // logical queue: [1, 2, 3, 4]
        let ?(rest, x) = queue.popBack() else Prim.trap("unexpected empty");
        expect.nat(x).equal(4);
        expect.nat(rest.size()).equal(3);
        expect.option(rest.peekBack(), Nat.toText, Nat.equal).equal(?3);
        expect.option(rest.peekFront(), Nat.toText, Nat.equal).equal(?1);
        expect.bool(rest.contains(Nat.equal, 3)).isTrue();
        expect.array(rest.toArray(), Nat.toText, Nat.equal).equal([1, 2, 3])
      }
    )
  }
)
