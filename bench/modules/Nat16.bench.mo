import Bench "mo:bench";
import Nat16 "../../src/Nat16";
import Nat "../../src/Nat";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Nat16");
    bench.description("Benchmarks for the Nat16 module");
    bench.rows(["add", "mul", "addWrap", "mulWrap", "bitand", "bitor", "bitxor", "bitshiftLeft", "compare", "toText", "toNat", "fromNat"]);
    bench.cols(["1_000", "10_000", "100_000"]);

    bench.runner(func(row, col) {
      let n = switch col {
        case "1_000" 1_000;
        case "10_000" 10_000;
        case "100_000" 100_000;
        case _ Runtime.unreachable()
      };
      let x : Nat16 = 4200;
      let y : Nat16 = 1300;
      switch row {
        case "add" for (_ in Nat.range(0, n)) { ignore Nat16.add(x, y) };
        case "mul" for (_ in Nat.range(0, n)) { ignore Nat16.mul(x, y) };
        case "addWrap" for (_ in Nat.range(0, n)) { ignore Nat16.addWrap(x, y) };
        case "mulWrap" for (_ in Nat.range(0, n)) { ignore Nat16.mulWrap(x, y) };
        case "bitand" for (_ in Nat.range(0, n)) { ignore Nat16.bitand(x, y) };
        case "bitor" for (_ in Nat.range(0, n)) { ignore Nat16.bitor(x, y) };
        case "bitxor" for (_ in Nat.range(0, n)) { ignore Nat16.bitxor(x, y) };
        case "bitshiftLeft" for (_ in Nat.range(0, n)) { ignore Nat16.bitshiftLeft(x, y) };
        case "compare" for (_ in Nat.range(0, n)) { ignore Nat16.compare(x, y) };
        case "toText" for (_ in Nat.range(0, n)) { ignore Nat16.toText(x) };
        case "toNat" for (_ in Nat.range(0, n)) { ignore Nat16.toNat(x) };
        case "fromNat" for (_ in Nat.range(0, n)) { ignore Nat16.fromNat(4200) };
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}