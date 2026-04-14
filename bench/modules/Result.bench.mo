import Bench "mo:bench";
import Nat "../../src/Nat";
import Result "../../src/Result";
import Text "../../src/Text";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Result");
    bench.description("Benchmarks for the Result module");
    bench.rows([
      "mapOk",
      "mapErr",
      "chain",
      "flatten",
      "isOk",
      "isErr",
      "equal",
      "compare",
      "toOption",
      "fromOption",
      "toUpper",
      "fromUpper"
    ]);
    bench.cols(["1_000", "10_000", "100_000"]);

    let okVal : Result.Result<Nat, Text> = #ok(42);
    let errVal : Result.Result<Nat, Text> = #err("error");

    bench.runner(func(row, col) {
      let n = switch col {
        case "1_000" 1_000;
        case "10_000" 10_000;
        case "100_000" 100_000;
        case _ Runtime.unreachable()
      };
      switch row {
        case "mapOk" for (_ in Nat.range(0, n)) { ignore Result.mapOk<Nat, Nat, Text>(okVal, func(x) = x + 1) };
        case "mapErr" for (_ in Nat.range(0, n)) { ignore Result.mapErr<Nat, Text, Text>(errVal, func(x) = x # "!") };
        case "chain" for (_ in Nat.range(0, n)) { ignore Result.chain<Nat, Nat, Text>(okVal, func(x) = #ok(x + 1)) };
        case "flatten" for (_ in Nat.range(0, n)) { ignore Result.flatten<Nat, Text>(#ok(#ok(42))) };
        case "isOk" for (_ in Nat.range(0, n)) { ignore Result.isOk(okVal) };
        case "isErr" for (_ in Nat.range(0, n)) { ignore Result.isErr(errVal) };
        case "equal" for (_ in Nat.range(0, n)) { ignore Result.equal<Nat, Text>(okVal, okVal, Nat.equal, Text.equal) };
        case "compare" for (_ in Nat.range(0, n)) { ignore Result.compare<Nat, Text>(okVal, okVal, Nat.compare, Text.compare) };
        case "toOption" for (_ in Nat.range(0, n)) { ignore Result.toOption<Nat, Text>(okVal) };
        case "fromOption" for (_ in Nat.range(0, n)) { ignore Result.fromOption<Nat, Text>(?42, "err") };
        case "toUpper" for (_ in Nat.range(0, n)) { ignore Result.toUpper<Nat, Text>(okVal) };
        case "fromUpper" for (_ in Nat.range(0, n)) { ignore Result.fromUpper<Nat, Text>(#Ok(42)) };
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}