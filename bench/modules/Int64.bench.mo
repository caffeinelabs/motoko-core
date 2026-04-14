import Bench "mo:bench";
import Int64 "../../src/Int64";
import Nat "../../src/Nat";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Int64");
    bench.description("Benchmarks for the Int64 module");
    bench.rows(["add", "mul", "addWrap", "mulWrap", "bitand", "bitor", "bitxor", "bitshiftLeft", "compare", "toText", "toInt", "fromInt"]);
    bench.cols(["1_000", "10_000", "100_000"]);

    bench.runner(func(row, col) {
      let n = switch col {
        case "1_000" 1_000;
        case "10_000" 10_000;
        case "100_000" 100_000;
        case _ Runtime.unreachable()
      };
      let x : Int64 = 42_000_000;
      let y : Int64 = 13_000_000;
      switch row {
        case "add" for (_ in Nat.range(0, n)) { ignore Int64.add(x, y) };
        case "mul" for (_ in Nat.range(0, n)) { ignore Int64.mul(x, y) };
        case "addWrap" for (_ in Nat.range(0, n)) { ignore Int64.addWrap(x, y) };
        case "mulWrap" for (_ in Nat.range(0, n)) { ignore Int64.mulWrap(x, y) };
        case "bitand" for (_ in Nat.range(0, n)) { ignore Int64.bitand(x, y) };
        case "bitor" for (_ in Nat.range(0, n)) { ignore Int64.bitor(x, y) };
        case "bitxor" for (_ in Nat.range(0, n)) { ignore Int64.bitxor(x, y) };
        case "bitshiftLeft" for (_ in Nat.range(0, n)) { ignore Int64.bitshiftLeft(x, y) };
        case "compare" for (_ in Nat.range(0, n)) { ignore Int64.compare(x, y) };
        case "toText" for (_ in Nat.range(0, n)) { ignore Int64.toText(x) };
        case "toInt" for (_ in Nat.range(0, n)) { ignore Int64.toInt(x) };
        case "fromInt" for (_ in Nat.range(0, n)) { ignore Int64.fromInt(42_000_000) };
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}