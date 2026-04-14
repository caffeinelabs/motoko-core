import Bench "mo:bench";
import Nat "../../src/Nat";
import Option "../../src/Option";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Option");
    bench.description("Benchmarks for the Option module");
    bench.rows([
      "map",
      "chain",
      "get",
      "flatten",
      "equal",
      "compare",
      "isSome",
      "isNull",
      "toText",
      "apply",
      "forEach",
      "unwrap"
    ]);
    bench.cols(["1_000", "10_000", "100_000"]);

    let someVal : ?Nat = ?42;
    let noneVal : ?Nat = null;

    bench.runner(func(row, col) {
      let n = switch col {
        case "1_000" 1_000;
        case "10_000" 10_000;
        case "100_000" 100_000;
        case _ Runtime.unreachable()
      };
      switch row {
        case "map" for (_ in Nat.range(0, n)) { ignore Option.map<Nat, Nat>(someVal, func(x) = x + 1) };
        case "chain" for (_ in Nat.range(0, n)) { ignore Option.chain<Nat, Nat>(someVal, func(x) = ?(x + 1)) };
        case "get" for (_ in Nat.range(0, n)) { ignore Option.get<Nat>(someVal, 0) };
        case "flatten" for (_ in Nat.range(0, n)) { ignore Option.flatten<Nat>(?(?42)) };
        case "equal" for (_ in Nat.range(0, n)) { ignore Option.equal<Nat>(someVal, someVal, Nat.equal) };
        case "compare" for (_ in Nat.range(0, n)) { ignore Option.compare<Nat>(someVal, someVal, Nat.compare) };
        case "isSome" for (_ in Nat.range(0, n)) { ignore Option.isSome(someVal) };
        case "isNull" for (_ in Nat.range(0, n)) { ignore Option.isNull(noneVal) };
        case "toText" for (_ in Nat.range(0, n)) { ignore Option.toText<Nat>(someVal, Nat.toText) };
        case "apply" for (_ in Nat.range(0, n)) { ignore Option.apply<Nat, Nat>(someVal, ?(func(x : Nat) = x + 1)) };
        case "forEach" for (_ in Nat.range(0, n)) { Option.forEach<Nat>(someVal, func(_) {}) };
        case "unwrap" for (_ in Nat.range(0, n)) { ignore Option.unwrap<Nat>(someVal) };
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}