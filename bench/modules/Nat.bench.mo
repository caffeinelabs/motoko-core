import Bench "mo:bench";
import Nat "../../src/Nat";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Nat");
    bench.description("Benchmarks for the Nat module");
    bench.rows(["add", "sub", "mul", "div", "pow", "compare", "toText", "fromText", "bitshiftLeft", "min", "max"]);
    bench.cols(["1_000", "10_000", "100_000"]);

    bench.runner(func(row, col) {
      let n = switch col {
        case "1_000" 1_000;
        case "10_000" 10_000;
        case "100_000" 100_000;
        case _ Runtime.unreachable()
      };
      let x : Nat = 12345;
      let y : Nat = 6789;
      switch row {
        case "add" for (_ in Nat.range(0, n)) { ignore Nat.add(x, y) };
        case "sub" for (_ in Nat.range(0, n)) { ignore Nat.sub(x, y) };
        case "mul" for (_ in Nat.range(0, n)) { ignore Nat.mul(x, y) };
        case "div" for (_ in Nat.range(0, n)) { ignore Nat.div(x, y) };
        case "pow" for (_ in Nat.range(0, n)) { ignore Nat.pow(x, 2) };
        case "compare" for (_ in Nat.range(0, n)) { ignore Nat.compare(x, y) };
        case "toText" for (_ in Nat.range(0, n)) { ignore Nat.toText(x) };
        case "fromText" for (_ in Nat.range(0, n)) { ignore Nat.fromText("12345") };
        case "bitshiftLeft" for (_ in Nat.range(0, n)) { ignore Nat.bitshiftLeft(x, (3 : Nat32)) };
        case "min" for (_ in Nat.range(0, n)) { ignore Nat.min(x, y) };
        case "max" for (_ in Nat.range(0, n)) { ignore Nat.max(x, y) };
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}