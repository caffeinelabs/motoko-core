import Bench "mo:bench";

import Array "../src/Array";
import Iter "../src/Iter";
import Nat "../src/Nat";
import Nat64 "../src/Nat64";
import List "../src/pure/List";
import Random "../src/Random";
import Runtime "../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Benchmarking the fromIter functions");
    bench.description("Columns describe the number of elements in the input iter.");

    bench.rows([
      "Iter.toArray",
      "List.fromIter",
      "List.fromIter . Iter.reverse"
    ]);
    bench.cols([
      "100",
      "10_000",
      "100_000"
    ]);

    let rng = Random.seed(27850937); // fix seed for reproducibility

    // 128-bit draws, so the inputs are boxed bignums rather than compact Nats
    func randomNat() : Nat = Nat64.toNat(rng.nat64()) * 2 ** 64 + Nat64.toNat(rng.nat64());

    func input(n : Nat) : [Nat] = Array.tabulate(n, func _ = randomNat());

    let array1 = input(100);
    let array2 = input(10_000);
    let array3 = input(100_000);

    bench.runner(
      func(row, col) {
        let array = switch col {
          case "100" array1;
          case "10_000" array2;
          case "100_000" array3;
          case _ Runtime.unreachable()
        };
        switch row {
          case "List.fromIter" ignore List.fromIter(array.values());
          case "List.fromIter . Iter.reverse" ignore List.fromIter(Iter.reverse(array.values()));
          case "Iter.toArray" ignore array.values().toArray();
          case _ Runtime.unreachable()
        }
      }
    );

    bench
  }
}
