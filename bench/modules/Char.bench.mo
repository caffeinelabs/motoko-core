import Bench "mo:bench";
import Char "../../src/Char";
import Nat "../../src/Nat";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Char");
    bench.description("Benchmarks for the Char module");
    bench.rows(["equal", "compare", "fromNat32", "toNat32", "toText", "isAlphabetic", "isDigit", "isLower", "isUpper", "isWhitespace"]);
    bench.cols(["1_000", "10_000", "100_000"]);

    bench.runner(func(row, col) {
      let n = switch col {
        case "1_000" 1_000;
        case "10_000" 10_000;
        case "100_000" 100_000;
        case _ Runtime.unreachable()
      };
      let a = 'A';
      let z = 'z';
      switch row {
        case "equal" for (_ in Nat.range(0, n)) { ignore Char.equal(a, z) };
        case "compare" for (_ in Nat.range(0, n)) { ignore Char.compare(a, z) };
        case "fromNat32" for (_ in Nat.range(0, n)) { ignore Char.fromNat32(65) };
        case "toNat32" for (_ in Nat.range(0, n)) { ignore Char.toNat32(a) };
        case "toText" for (_ in Nat.range(0, n)) { ignore Char.toText(a) };
        case "isAlphabetic" for (_ in Nat.range(0, n)) { ignore Char.isAlphabetic(a) };
        case "isDigit" for (_ in Nat.range(0, n)) { ignore Char.isDigit(a) };
        case "isLower" for (_ in Nat.range(0, n)) { ignore Char.isLower(z) };
        case "isUpper" for (_ in Nat.range(0, n)) { ignore Char.isUpper(a) };
        case "isWhitespace" for (_ in Nat.range(0, n)) { ignore Char.isWhitespace(' ') };
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}