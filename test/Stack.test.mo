import Stack "../src/Stack";
import Nat "../src/Nat";
import Iter "../src/Iter";
import PureList "../src/pure/List";
import { suite; test; expect } = "mo:test";

suite(
  "empty",
  func() {
    test(
      "new stack is empty",
      func() {
        expect.bool(Stack.isEmpty(Stack.empty<Nat>())).isTrue()
      }
    );

    test(
      "new stack has size 0",
      func() {
        expect.nat(Stack.size(Stack.empty<Nat>())).equal(0)
      }
    );

    test(
      "peek empty returns null",
      func() {
        expect.option(Stack.peek(Stack.empty<Nat>()), Nat.toText, Nat.equal).isNull()
      }
    );

    test(
      "pop empty returns null",
      func() {
        expect.option(Stack.pop(Stack.empty<Nat>()), Nat.toText, Nat.equal).isNull()
      }
    )
  }
);

suite(
  "singleton",
  func() {
    test(
      "creates stack with one element",
      func() {
        let s = Stack.singleton<Nat>(123);
        expect.bool(Stack.size(s) == 1 and Stack.peek(s) == ?123).isTrue()
      }
    )
  }
);

suite(
  "push/pop operations",
  func() {
    test(
      "push increases size",
      func() {
        let s = Stack.empty<Nat>();
        Stack.push(s, 1);
        expect.nat(Stack.size(s)).equal(1)
      }
    );

    test(
      "push/pop maintains LIFO order",
      func() {
        let s = Stack.empty<Nat>();
        Stack.push(s, 1);
        Stack.push(s, 2);
        Stack.push(s, 3);
        expect.array(
          [Stack.pop(s), Stack.pop(s), Stack.pop(s)],
          func(x : ?Nat) : Text {
            switch (x) { case (null) "null"; case (?n) Nat.toText(n) }
          },
          func(a : ?Nat, b : ?Nat) : Bool {
            switch (a, b) {
              case (null, null) true;
              case (?x, ?y) x == y;
              case (_, _) false
            }
          }
        ).equal([?3, ?2, ?1]);
        expect.nat(Stack.size(s)).equal(0)
      }
    );

    test(
      "peek doesn't remove element",
      func() {
        let s = Stack.empty<Nat>();
        Stack.push(s, 42);
        let p1 = Stack.peek(s);
        let p2 = Stack.peek(s);
        expect.bool(p1 == p2 and p1 == ?42 and Stack.size(s) == 1).isTrue()
      }
    )
  }
);

suite(
  "clear and clone",
  func() {
    test(
      "clear empties stack",
      func() {
        let s = Stack.fromIter<Nat>([1, 2, 3].values());
        Stack.clear(s);
        expect.bool(Stack.isEmpty(s)).isTrue()
      }
    );

    test(
      "clone creates independent copy",
      func() {
        let original = Stack.fromIter<Nat>([1, 2, 3].values());
        let copy = Stack.clone(original);
        ignore Stack.pop(original);
        expect.bool(Stack.size(copy) == 3 and Stack.peek(copy) == ?3).isTrue()
      }
    )
  }
);

suite(
  "iteration and search",
  func() {
    test(
      "contains finds element",
      func() {
        let s = Stack.fromIter<Nat>([1, 2, 3].values());
        expect.bool(Stack.contains(s, Nat.equal, 2)).isTrue()
      }
    );

    test(
      "get retrieves correct element",
      func() {
        let s = Stack.fromIter<Nat>([1, 2, 3].values());
        expect.bool(Stack.get(s, 1) == ?2).isTrue()
      }
    );

    test(
      "values iterates in LIFO order",
      func() {
        let s = Stack.fromIter<Nat>([1, 2, 3].values());
        expect.array(s.values().toArray(), Nat.toText, Nat.equal).equal([3, 2, 1])
      }
    )
  }
);

suite(
  "transformations",
  func() {
    test(
      "reverse changes order",
      func() {
        let s = Stack.fromIter<Nat>([1, 2, 3].values());
        Stack.reverse(s);
        expect.array(s.values().toArray(), Nat.toText, Nat.equal).equal([1, 2, 3])
      }
    );

    test(
      "map transforms elements",
      func() {
        let s = Stack.fromIter<Nat>([1, 2, 3].values());
        let mapped = Stack.map<Nat, Nat>(s, func(x) { x + 1 });
        expect.array(mapped.values().toArray(), Nat.toText, Nat.equal).equal([4, 3, 2])
      }
    );

    test(
      "filter keeps matching elements",
      func() {
        let s = Stack.fromIter<Nat>([1, 2, 3, 4].values());
        let evens = Stack.filter<Nat>(s, func(x) { x % 2 == 0 });
        expect.array(evens.values().toArray(), Nat.toText, Nat.equal).equal([4, 2])
      }
    );

    test(
      "filterMap combines map and filter",
      func() {
        let s = Stack.fromIter<Nat>([1, 2, 3, 4].values());
        let evenDoubled = Stack.filterMap<Nat, Nat>(
          s,
          func(x) {
            if (x % 2 == 0) { ?(x * 2) } else { null }
          }
        );
        expect.array(evenDoubled.values().toArray(), Nat.toText, Nat.equal).equal([8, 4])
      }
    )
  }
);

suite(
  "queries",
  func() {
    test(
      "all true when all match",
      func() {
        let s = Stack.fromIter<Nat>([2, 4, 6].values());
        expect.bool(Stack.all<Nat>(s, func(x) { x % 2 == 0 })).isTrue()
      }
    );

    test(
      "all false when any doesn't match",
      func() {
        let s = Stack.fromIter<Nat>([2, 3, 4].values());
        expect.bool(Stack.all<Nat>(s, func(x) { x % 2 == 0 })).isFalse()
      }
    );

    test(
      "any true when one matches",
      func() {
        let s = Stack.fromIter<Nat>([1, 2, 3].values());
        expect.bool(Stack.any<Nat>(s, func(x) { x % 2 == 0 })).isTrue()
      }
    );

    test(
      "any false when none match",
      func() {
        let s = Stack.fromIter<Nat>([1, 3, 5].values());
        expect.bool(Stack.any<Nat>(s, func(x) { x % 2 == 0 })).isFalse()
      }
    )
  }
);

suite(
  "comparison",
  func() {
    test(
      "equal returns true for identical stacks",
      func() {
        let s1 = Stack.fromIter<Nat>([1, 2, 3].values());
        let s2 = Stack.fromIter<Nat>([1, 2, 3].values());
        expect.bool(Stack.equal(s1, s2, Nat.equal)).isTrue()
      }
    );

    test(
      "equal returns false for different stacks",
      func() {
        let s1 = Stack.fromIter<Nat>([1, 2, 3].values());
        let s2 = Stack.fromIter<Nat>([1, 2, 4].values());
        expect.bool(Stack.equal(s1, s2, Nat.equal)).isFalse()
      }
    );

    test(
      "compare orders correctly",
      func() {
        let s1 = Stack.fromIter<Nat>([1, 2].values());
        let s2 = Stack.fromIter<Nat>([1, 2, 3].values());
        expect.bool(Stack.compare(s1, s2, Nat.compare) == #less).isTrue()
      }
    )
  }
);

suite(
  "text representation",
  func() {
    test(
      "toText formats correctly",
      func() {
        let s = Stack.fromIter<Nat>([1, 2, 3].values());
        expect.text(Stack.toText(s, Nat.toText)).equal("Stack[3, 2, 1]")
      }
    )
  }
);

// TODO: Replace by PRNG in `Random`.
class Random(seed : Nat) {
  var current = seed;

  public func next() : Nat {
    current := (123138118391 * current + 133489131) % 9999;
    current
  };

  public func reset() {
    current := seed
  }
};

let randomSeed = 4711;
let largeSize = 1_000;

suite(
  "large scale operations",
  func() {
    test(
      "many push/pop operations",
      func() {
        let s = Stack.empty<Nat>();
        let random = Random(randomSeed);
        var expectedSum = 0;
        var actualSum = 0;

        for (i in Nat.range(0, largeSize)) {
          let value = random.next();
          Stack.push(s, value);
          expectedSum += value
        };

        expect.nat(Stack.size(s)).equal(largeSize);

        while (not Stack.isEmpty(s)) {
          switch (Stack.pop(s)) {
            case (?value) { actualSum += value };
            case null { expect.bool(false).isTrue() }; // Should never happen
          }
        };

        expect.bool(Stack.isEmpty(s) and expectedSum == actualSum).isTrue()
      }
    );

    test(
      "alternating push/pop operations",
      func() {
        let s = Stack.empty<Nat>();
        let random = Random(randomSeed);
        var count = 0;

        for (i in Nat.range(0, largeSize)) {
          if (random.next() % 2 == 0) {
            Stack.push(s, i);
            count += 1
          } else {
            switch (Stack.pop(s)) {
              case (?_) { count -= 1 };
              case null {}; // Stack can be empty
            }
          };
          expect.nat(Stack.size(s)).equal(count)
        };

        expect.bool(true).isTrue()
      }
    );

    test(
      "large scale transformations",
      func() {
        let original = Stack.tabulate<Nat>(largeSize, func(i) { i });
        let doubled = Stack.map<Nat, Nat>(original, func(x) { x * 2 });
        let filtered = Stack.filter<Nat>(doubled, func(x) { x % 4 == 0 });
        let mapped = Stack.filterMap<Nat, Nat>(
          filtered,
          func(x) {
            if (x % 8 == 0) ?x else null
          }
        );

        expect.nat(Stack.size(original)).equal(largeSize);
        expect.nat(Stack.size(doubled)).equal(largeSize);
        expect.nat(Stack.size(filtered)).equal(largeSize / 2);
        expect.nat(Stack.size(mapped)).equal(largeSize / 4)
      }
    );

    test(
      "large scale iteration",
      func() {
        let s = Stack.tabulate<Nat>(largeSize, func(i) = i);
        var sum = 0;
        var count = 0;

        for (value in s.values()) {
          sum += value;
          count += 1
        };

        expect.nat(count).equal(largeSize);
        let expectedSum = (largeSize - 1 : Nat) * largeSize / 2;
        expect.nat(sum).equal(expectedSum)
      }
    );

    test(
      "large scale clone and compare",
      func() {
        let original = Stack.tabulate<Nat>(largeSize, func(i) = i);
        let clone = Stack.clone(original);

        expect.bool(Stack.equal(original, clone, Nat.equal)).isTrue();

        Stack.push(original, largeSize);
        expect.bool(Stack.equal(original, clone, Nat.equal)).isFalse();
        expect.bool(Stack.compare(clone, original, Nat.compare) == #less).isTrue()
      }
    )
  }
);

suite(
  "stack conversion",
  func() {
    test(
      "toPure",
      func() {
        let stack = Stack.empty<Nat>();
        for (index in Nat.range(0, largeSize)) {
          Stack.push(stack, index)
        };

        let pureList = Stack.toPure(stack);
        var index = largeSize;

        for (element in PureList.values(pureList)) {
          index -= 1;
          expect.nat(element).equal(index)
        };

        expect.nat(PureList.size(pureList)).equal(largeSize)
      }
    );

    test(
      "fromPure",
      func() {
        var pureList = PureList.empty<Nat>();
        for (index in Nat.range(0, largeSize)) {
          pureList := PureList.pushFront(pureList, index)
        };

        let stack = Stack.fromPure<Nat>(pureList);
        var index = largeSize;

        for (element in PureList.values(pureList)) {
          index -= 1;
          expect.nat(element).equal(index)
        };

        expect.nat(Stack.size(stack)).equal(largeSize)
      }
    )
  }
)
