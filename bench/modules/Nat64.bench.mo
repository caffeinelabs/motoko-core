import Bench "mo:bench";
import Nat64 "../../src/Nat64";
import Nat "../../src/Nat";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Nat64");
    bench.description("Benchmarks for the Nat64 module");
    bench.rows(["add", "mul", "addWrap", "mulWrap", "bitand", "bitor", "bitxor", "bitshiftLeft", "compare", "toText", "toNat", "fromNat"]);
    bench.cols(["1_000", "10_000", "100_000"]);

    bench.runner(func(row, col) {
      let n = switch col {
        case "1_000" 1_000;
        case "10_000" 10_000;
        case "100_000" 100_000;
        case _ Runtime.unreachable()
      };
      let x : Nat64 = 42_000_000;
      let y : Nat64 = 13_000_000;
      switch row {
        case "add" for (_ in Nat.range(0, n)) { ignore Nat64.add(x, y) };
        case "mul" for (_ in Nat.range(0, n)) { ignore Nat64.mul(x, y) };
        case "addWrap" for (_ in Nat.range(0, n)) { ignore Nat64.addWrap(x, y) };
        case "mulWrap" for (_ in Nat.range(0, n)) { ignore Nat64.mulWrap(x, y) };
        case "bitand" for (_ in Nat.range(0, n)) { ignore Nat64.bitand(x, y) };
        case "bitor" for (_ in Nat.range(0, n)) { ignore Nat64.bitor(x, y) };
        case "bitxor" for (_ in Nat.range(0, n)) { ignore Nat64.bitxor(x, y) };
        case "bitshiftLeft" for (_ in Nat.range(0, n)) { ignore Nat64.bitshiftLeft(x, y) };
        case "compare" for (_ in Nat.range(0, n)) { ignore Nat64.compare(x, y) };
        case "toText" for (_ in Nat.range(0, n)) { ignore Nat64.toText(x) };
        case "toNat" for (_ in Nat.range(0, n)) { ignore Nat64.toNat(x) };
        case "fromNat" for (_ in Nat.range(0, n)) { ignore Nat64.fromNat(42_000_000) };
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}