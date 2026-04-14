import Bench "mo:bench";
import Random "../../src/Random";
import Nat "../../src/Nat";
import Nat64 "../../src/Nat64";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Random");
    bench.description("Benchmarks for seeded Random");
    bench.rows(["seed", "nat64", "natRange", "bool"]);
    bench.cols(["1_000", "10_000", "100_000"]);

    bench.runner(func(row, col) {
      let n = switch col {
        case "1_000" 1_000;
        case "10_000" 10_000;
        case "100_000" 100_000;
        case _ Runtime.unreachable()
      };
      switch row {
        case "seed" for (i in Nat.range(0, n)) { ignore Random.seed(Nat64.fromNat(i)) };
        case "nat64" {
          let rng = Random.seed(0x42);
          for (_ in Nat.range(0, n)) { ignore rng.nat64() }
        };
        case "natRange" {
          let rng = Random.seed(0x42);
          for (_ in Nat.range(0, n)) { ignore rng.natRange(0, 1_000_000) }
        };
        case "bool" {
          let rng = Random.seed(0x42);
          for (_ in Nat.range(0, n)) { ignore rng.bool() }
        };
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}
