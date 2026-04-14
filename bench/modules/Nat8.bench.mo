import Bench "mo:bench";
import Nat8 "../../src/Nat8";
import Nat "../../src/Nat";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Nat8");
    bench.description("Benchmarks for the Nat8 module");
    bench.rows(["add", "mul", "addWrap", "mulWrap", "bitand", "bitor", "bitxor", "bitshiftLeft", "compare", "toText", "toNat", "fromNat"]);
    bench.cols(["1_000", "10_000", "100_000"]);

    bench.runner(func(row, col) {
      let n = switch col {
        case "1_000" 1_000;
        case "10_000" 10_000;
        case "100_000" 100_000;
        case _ Runtime.unreachable()
      };
      let x : Nat8 = 42;
      let y : Nat8 = 13;
      switch row {
        case "add" for (_ in Nat.range(0, n)) { ignore Nat8.add(x, y) };
        case "mul" for (_ in Nat.range(0, n)) { ignore Nat8.mul(x, y) };
        case "addWrap" for (_ in Nat.range(0, n)) { ignore Nat8.addWrap(x, y) };
        case "mulWrap" for (_ in Nat.range(0, n)) { ignore Nat8.mulWrap(x, y) };
        case "bitand" for (_ in Nat.range(0, n)) { ignore Nat8.bitand(x, y) };
        case "bitor" for (_ in Nat.range(0, n)) { ignore Nat8.bitor(x, y) };
        case "bitxor" for (_ in Nat.range(0, n)) { ignore Nat8.bitxor(x, y) };
        case "bitshiftLeft" for (_ in Nat.range(0, n)) { ignore Nat8.bitshiftLeft(x, y) };
        case "compare" for (_ in Nat.range(0, n)) { ignore Nat8.compare(x, y) };
        case "toText" for (_ in Nat.range(0, n)) { ignore Nat8.toText(x) };
        case "toNat" for (_ in Nat.range(0, n)) { ignore Nat8.toNat(x) };
        case "fromNat" for (_ in Nat.range(0, n)) { ignore Nat8.fromNat(42) };
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}