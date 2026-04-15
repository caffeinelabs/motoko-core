// @testmode wasi

/// Replays oracle traces from `test/ts/pbt/emitQueueOracleFixtures.ts` (written to
/// `test/generated/QueueOracleFixtures.mo` when you run `npm run generate:oracle-fixtures` or `npm test`).

import Queue "../../src/pure/Queue";
import Nat "../../src/Nat";
import Iter "../../src/Iter";
import Prim "mo:prim";
import Fixture "../generated/QueueOracleFixtures";
import { suite; test; expect } "mo:test";

func replay(q : Queue.Queue<Nat>, ops : [Fixture.Op]) : Queue.Queue<Nat> {
  var current = q;
  for (op in ops.vals()) {
    switch (op) {
      case (#pushFront(n)) {
        current := Queue.pushFront(current, n)
      };
      case (#pushBack(n)) {
        current := Queue.pushBack(current, n)
      };
      case (#popFront) {
        switch (Queue.popFront(current)) {
          case null Prim.trap("oracle trace: popFront on empty");
          case (?(_, q2)) current := q2
        }
      };
      case (#popBack) {
        switch (Queue.popBack(current)) {
          case null Prim.trap("oracle trace: popBack on empty");
          case (?(q2, _)) current := q2
        }
      };
    }
  };
  current
};

suite(
  "oracle replay (TS reference)",
  func() {
    test(
      "100 generated traces match OracleDeque final state",
      func() {
        assert Fixture.fixtures.size() == Fixture.fixtureCount;
        for (fx in Fixture.fixtures.vals()) {
          let finalQ = replay(Queue.empty<Nat>(), fx.trace);
          expect.array<Nat>(
            Iter.toArray(Queue.values(finalQ)),
            Nat.toText,
            Nat.equal,
          ).equal(fx.expectedFinal)
        }
      }
    )
  },
);
