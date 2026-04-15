// @testmode wasi

/// Replays oracle traces from `test/ts/pbt/emitMapOracleFixtures.ts` (output in
/// `test/generated/MapOracleFixtures.mo` via `npm run generate:oracle-fixtures`).

import Map "../../src/pure/Map";
import Nat "../../src/Nat";
import Iter "../../src/Iter";
import Fixture "../generated/MapOracleFixtures";
import { suite; test; expect } "mo:test";

let c = Nat.compare;

func replay(m : Map.Map<Nat, Text>, ops : [Fixture.MutationOp]) : Map.Map<Nat, Text> {
  var cur = m;
  for (op in ops.vals()) {
    switch (op) {
      case (#add(k, v)) {
        cur := Map.add(cur, c, k, v)
      };
      case (#remove(k)) {
        cur := Map.remove(cur, c, k)
      }
    }
  };
  cur
};

suite(
  "Map oracle replay (TS reference)",
  func() {
    test(
      "100 generated maps match OracleNatTextMap",
      func() {
        assert Fixture.fixtures.size() == Fixture.fixtureCount;
        for (fx in Fixture.fixtures.vals()) {
          let finalM = replay(Map.empty<Nat, Text>(), fx.mutations);
          expect.bool(
            Iter.toArray(Map.entries(finalM)) == fx.expectedEntries
          ).isTrue()
        }
      }
    )
  }
)
