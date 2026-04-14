import Bench "mo:bench";
import Int "../../src/Int";
import Nat "../../src/Nat";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Int");
    bench.description("Benchmarks for the Int module");
    bench.rows(["add", "sub", "mul", "div", "pow", "abs", "compare", "toText", "fromText", "fromNat"]);
    bench.cols(["1_000", "10_000", "100_000"]);

    bench.runner(func(row, col) {
      let n = switch col {
        case "1_000" 1_000;
        case "10_000" 10_000;
        case "100_000" 100_000;
        case _ Runtime.unreachable()
      };
      let x : Int = 12345;
      let y : Int = 6789;
      switch row {
        case "add" for (_ in Nat.range(0, n)) { ignore Int.add(x, y) };
        case "sub" for (_ in Nat.range(0, n)) { ignore Int.sub(x, y) };
        case "mul" for (_ in Nat.range(0, n)) { ignore Int.mul(x, y) };
        case "div" for (_ in Nat.range(0, n)) { ignore Int.div(x, y) };
        case "pow" for (_ in Nat.range(0, n)) { ignore Int.pow(x, 2) };
        case "abs" for (_ in Nat.range(0, n)) { ignore Int.abs(x) };
        case "compare" for (_ in Nat.range(0, n)) { ignore Int.compare(x, y) };
        case "toText" for (_ in Nat.range(0, n)) { ignore Int.toText(x) };
        case "fromText" for (_ in Nat.range(0, n)) { ignore Int.fromText("12345") };
        case "fromNat" for (_ in Nat.range(0, n)) { ignore Int.fromNat(12345) };
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}