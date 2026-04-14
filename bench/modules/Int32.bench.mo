import Bench "mo:bench";
import Int32 "../../src/Int32";
import Nat "../../src/Nat";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Int32");
    bench.description("Benchmarks for the Int32 module");
    bench.rows(["add", "mul", "addWrap", "mulWrap", "bitand", "bitor", "bitxor", "bitshiftLeft", "compare", "toText", "toInt", "fromInt"]);
    bench.cols(["1_000", "10_000", "100_000"]);

    bench.runner(func(row, col) {
      let n = switch col {
        case "1_000" 1_000;
        case "10_000" 10_000;
        case "100_000" 100_000;
        case _ Runtime.unreachable()
      };
      let x : Int32 = 420_000;
      let y : Int32 = 130_000;
      switch row {
        case "add" for (_ in Nat.range(0, n)) { ignore Int32.add(x, y) };
        case "mul" for (_ in Nat.range(0, n)) { ignore Int32.mul(x, y) };
        case "addWrap" for (_ in Nat.range(0, n)) { ignore Int32.addWrap(x, y) };
        case "mulWrap" for (_ in Nat.range(0, n)) { ignore Int32.mulWrap(x, y) };
        case "bitand" for (_ in Nat.range(0, n)) { ignore Int32.bitand(x, y) };
        case "bitor" for (_ in Nat.range(0, n)) { ignore Int32.bitor(x, y) };
        case "bitxor" for (_ in Nat.range(0, n)) { ignore Int32.bitxor(x, y) };
        case "bitshiftLeft" for (_ in Nat.range(0, n)) { ignore Int32.bitshiftLeft(x, y) };
        case "compare" for (_ in Nat.range(0, n)) { ignore Int32.compare(x, y) };
        case "toText" for (_ in Nat.range(0, n)) { ignore Int32.toText(x) };
        case "toInt" for (_ in Nat.range(0, n)) { ignore Int32.toInt(x) };
        case "fromInt" for (_ in Nat.range(0, n)) { ignore Int32.fromInt(420_000) };
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}