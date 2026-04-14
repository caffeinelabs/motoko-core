import Bench "mo:bench";
import PriorityQueue "../../src/PriorityQueue";
import Array "../../src/Array";
import Nat "../../src/Nat";
import Random "../../src/Random";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("PriorityQueue");
    bench.description("Benchmarks for the PriorityQueue module");
    bench.rows(["fromIter", "push", "pop", "push+pop mixed", "peek", "clone", "values"]);
    bench.cols(["100", "1_000", "10_000"]);

    let rng = Random.seed(0xfeedface);
    let a100 = Array.tabulate<Nat>(100, func(_) = rng.natRange(0, 1_000_000));
    let a1000 = Array.tabulate<Nat>(1_000, func(_) = rng.natRange(0, 1_000_000));
    let a10000 = Array.tabulate<Nat>(10_000, func(_) = rng.natRange(0, 1_000_000));

    let pq100 = PriorityQueue.fromIter<Nat>(a100.vals(), Nat.compare);
    let pq1000 = PriorityQueue.fromIter<Nat>(a1000.vals(), Nat.compare);
    let pq10000 = PriorityQueue.fromIter<Nat>(a10000.vals(), Nat.compare);

    bench.runner(func(row, col) {
      let (arr, thePQ, n) = switch col {
        case "100" (a100, pq100, 100);
        case "1_000" (a1000, pq1000, 1_000);
        case "10_000" (a10000, pq10000, 10_000);
        case _ Runtime.unreachable()
      };
      switch row {
        case "fromIter" ignore PriorityQueue.fromIter<Nat>(arr.vals(), Nat.compare);
        case "push" {
          let pq = PriorityQueue.empty<Nat>();
          for (x in arr.vals()) { PriorityQueue.push<Nat>(pq, Nat.compare, x) }
        };
        case "pop" {
          let pq = PriorityQueue.clone<Nat>(thePQ);
          label l loop { switch (PriorityQueue.pop<Nat>(pq, Nat.compare)) { case null break l; case _ () } }
        };
        case "push+pop mixed" {
          let pq = PriorityQueue.empty<Nat>();
          for (x in arr.vals()) {
            PriorityQueue.push<Nat>(pq, Nat.compare, x);
            if (x % 2 == 0) { ignore PriorityQueue.pop<Nat>(pq, Nat.compare) }
          }
        };
        case "peek" for (_ in Nat.range(0, n)) { ignore PriorityQueue.peek<Nat>(thePQ) };
        case "clone" ignore PriorityQueue.clone<Nat>(thePQ);
        case "values" for (x in PriorityQueue.values<Nat>(thePQ, Nat.compare)) { ignore x };
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}