import Bench "mo:bench";
import PureQueue "../../../src/pure/Queue";
import Array "../../../src/Array";
import Nat "../../../src/Nat";
import Random "../../../src/Random";
import Runtime "../../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("pure/Queue");
    bench.description("Benchmarks for the pure Queue module");
    bench.rows([
      "fromArray",
      "pushBack",
      "pushFront",
      "popFront",
      "popBack",
      "map",
      "filter",
      "forEach",
      "contains",
      "equal",
      "toArray",
      "reverse"
    ]);
    bench.cols(["100", "1_000", "10_000"]);

    let rng = Random.seed(0xabcdef01);
    let a100 = Array.tabulate<Nat>(100, func(_) = rng.natRange(0, 1_000_000));
    let a1000 = Array.tabulate<Nat>(1_000, func(_) = rng.natRange(0, 1_000_000));
    let a10000 = Array.tabulate<Nat>(10_000, func(_) = rng.natRange(0, 1_000_000));

    let a100copy = Array.tabulate<Nat>(100, func(i) = a100[i]);
    let a1000copy = Array.tabulate<Nat>(1_000, func(i) = a1000[i]);
    let a10000copy = Array.tabulate<Nat>(10_000, func(i) = a10000[i]);

    let q100 = PureQueue.fromArray<Nat>(a100);
    let q1000 = PureQueue.fromArray<Nat>(a1000);
    let q10000 = PureQueue.fromArray<Nat>(a10000);

    let q100copy = PureQueue.fromArray<Nat>(a100copy);
    let q1000copy = PureQueue.fromArray<Nat>(a1000copy);
    let q10000copy = PureQueue.fromArray<Nat>(a10000copy);

    bench.runner(func(row, col) {
      let arr = switch col {
        case "100" a100;
        case "1_000" a1000;
        case "10_000" a10000;
        case _ Runtime.unreachable()
      };
      let theQueue = switch col {
        case "100" q100;
        case "1_000" q1000;
        case "10_000" q10000;
        case _ Runtime.unreachable()
      };
      let theQueueEq = switch col {
        case "100" q100copy;
        case "1_000" q1000copy;
        case "10_000" q10000copy;
        case _ Runtime.unreachable()
      };
      let key = arr[arr.size() / 2];
      switch row {
        case "fromArray" ignore PureQueue.fromArray<Nat>(arr);
        case "pushBack" {
          var q = PureQueue.empty<Nat>();
          for (x in arr.vals()) { q := PureQueue.pushBack<Nat>(q, x) }
        };
        case "pushFront" {
          var q = PureQueue.empty<Nat>();
          for (x in arr.vals()) { q := PureQueue.pushFront<Nat>(q, x) }
        };
        case "popFront" {
          var q = theQueue;
          label l loop {
            switch (PureQueue.popFront<Nat>(q)) {
              case null break l;
              case (?(_, rest)) q := rest
            }
          }
        };
        case "popBack" {
          var q = theQueue;
          label l loop {
            switch (PureQueue.popBack<Nat>(q)) {
              case null break l;
              case (?result) q := result.0
            }
          }
        };
        case "map" ignore PureQueue.map<Nat, Nat>(theQueue, func x = x + 1);
        case "filter" ignore PureQueue.filter<Nat>(theQueue, func x = x % 2 == 0);
        case "forEach" PureQueue.forEach<Nat>(theQueue, func x = ignore x);
        case "contains" ignore PureQueue.contains<Nat>(theQueue, Nat.equal, key);
        case "equal" ignore PureQueue.equal<Nat>(theQueue, theQueueEq, Nat.equal);
        case "toArray" ignore PureQueue.toArray<Nat>(theQueue);
        case "reverse" ignore PureQueue.reverse<Nat>(theQueue);
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}