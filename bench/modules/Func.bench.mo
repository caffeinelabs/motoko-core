import Bench "mo:bench";
import Func "../../src/Func";
import Nat "../../src/Nat";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Func");
    bench.description("Benchmarks for the Func module");
    bench.rows(["identity", "const", "compose"]);
    bench.cols(["1_000", "10_000", "100_000"]);

    let inc = func (x : Nat) : Nat { x + 1 };
    let double = func (x : Nat) : Nat { x * 2 };
    let composed = Func.compose(inc, double);

    bench.runner(func(row, col) {
      let n = switch col {
        case "1_000" 1_000;
        case "10_000" 10_000;
        case "100_000" 100_000;
        case _ Runtime.unreachable()
      };
      switch row {
        case "identity" for (_ in Nat.range(0, n)) { ignore Func.identity<Nat>(7) };
        case "const" for (_ in Nat.range(0, n)) { ignore Func.const<Nat, Nat>(5)(0) };
        case "compose" for (_ in Nat.range(0, n)) { ignore composed(3) };
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}