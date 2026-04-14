import Bench "mo:bench";
import Tuples "../../src/Tuples";
import Nat "../../src/Nat";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Tuples");
    bench.description("Benchmarks for the Tuples module");
    bench.rows([
      "Tuple2.equal",
      "Tuple2.compare",
      "Tuple2.toText",
      "Tuple2.swap",
      "Tuple3.equal",
      "Tuple3.compare",
      "Tuple3.toText",
      "Tuple4.equal",
      "Tuple4.compare",
      "Tuple4.toText"
    ]);
    bench.cols(["1_000", "10_000", "100_000"]);

    let t2 : (Nat, Nat) = (42, 99);
    let t3 : (Nat, Nat, Nat) = (42, 99, 7);
    let t4 : (Nat, Nat, Nat, Nat) = (42, 99, 7, 13);

    bench.runner(func(row, col) {
      let n = switch col {
        case "1_000" 1_000;
        case "10_000" 10_000;
        case "100_000" 100_000;
        case _ Runtime.unreachable()
      };
      switch row {
        case "Tuple2.equal" for (_ in Nat.range(0, n)) { ignore Tuples.Tuple2.equal<Nat, Nat>(t2, t2, Nat.equal, Nat.equal) };
        case "Tuple2.compare" for (_ in Nat.range(0, n)) { ignore Tuples.Tuple2.compare<Nat, Nat>(t2, t2, Nat.compare, Nat.compare) };
        case "Tuple2.toText" for (_ in Nat.range(0, n)) { ignore Tuples.Tuple2.toText<Nat, Nat>(t2, Nat.toText, Nat.toText) };
        case "Tuple2.swap" for (_ in Nat.range(0, n)) { ignore Tuples.Tuple2.swap<Nat, Nat>(t2) };
        case "Tuple3.equal" for (_ in Nat.range(0, n)) { ignore Tuples.Tuple3.equal<Nat, Nat, Nat>(t3, t3, Nat.equal, Nat.equal, Nat.equal) };
        case "Tuple3.compare" for (_ in Nat.range(0, n)) { ignore Tuples.Tuple3.compare<Nat, Nat, Nat>(t3, t3, Nat.compare, Nat.compare, Nat.compare) };
        case "Tuple3.toText" for (_ in Nat.range(0, n)) { ignore Tuples.Tuple3.toText<Nat, Nat, Nat>(t3, Nat.toText, Nat.toText, Nat.toText) };
        case "Tuple4.equal" for (_ in Nat.range(0, n)) { ignore Tuples.Tuple4.equal<Nat, Nat, Nat, Nat>(t4, t4, Nat.equal, Nat.equal, Nat.equal, Nat.equal) };
        case "Tuple4.compare" for (_ in Nat.range(0, n)) { ignore Tuples.Tuple4.compare<Nat, Nat, Nat, Nat>(t4, t4, Nat.compare, Nat.compare, Nat.compare, Nat.compare) };
        case "Tuple4.toText" for (_ in Nat.range(0, n)) { ignore Tuples.Tuple4.toText<Nat, Nat, Nat, Nat>(t4, Nat.toText, Nat.toText, Nat.toText, Nat.toText) };
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}
