import Bench "mo:bench";
import Bool "../../src/Bool";
import Nat "../../src/Nat";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Bool");
    bench.description("Benchmarks for the Bool module");
    bench.rows(["equal", "compare", "logicalAnd", "logicalOr", "logicalXor", "logicalNot", "toText"]);
    bench.cols(["1_000", "10_000", "100_000"]);

    bench.runner(func(row, col) {
      let n = switch col {
        case "1_000" 1_000;
        case "10_000" 10_000;
        case "100_000" 100_000;
        case _ Runtime.unreachable()
      };
      switch row {
        case "equal" for (_ in Nat.range(0, n)) { ignore Bool.equal(true, false) };
        case "compare" for (_ in Nat.range(0, n)) { ignore Bool.compare(true, false) };
        case "logicalAnd" for (_ in Nat.range(0, n)) { ignore Bool.logicalAnd(true, false) };
        case "logicalOr" for (_ in Nat.range(0, n)) { ignore Bool.logicalOr(true, false) };
        case "logicalXor" for (_ in Nat.range(0, n)) { ignore Bool.logicalXor(true, false) };
        case "logicalNot" for (_ in Nat.range(0, n)) { ignore Bool.logicalNot(true) };
        case "toText" for (_ in Nat.range(0, n)) { ignore Bool.toText(true) };
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}