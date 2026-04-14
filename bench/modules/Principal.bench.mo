import Bench "mo:bench";
import Principal "../../src/Principal";
import Nat "../../src/Nat";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();
    bench.name("Principal");
    bench.description("Benchmarks for the Principal module");
    bench.rows(["compare", "equal", "hash", "toBlob", "fromBlob", "toText", "fromText", "isAnonymous", "toLedgerAccount"]);
    bench.cols(["1_000", "10_000", "100_000"]);

    let p1 = Principal.anonymous();
    let p1Text = Principal.toText(p1);
    let p1Blob = Principal.toBlob(p1);

    bench.runner(func(row, col) {
      let n = switch col {
        case "1_000" 1_000;
        case "10_000" 10_000;
        case "100_000" 100_000;
        case _ Runtime.unreachable()
      };
      switch row {
        case "compare" for (_ in Nat.range(0, n)) { ignore Principal.compare(p1, p1) };
        case "equal" for (_ in Nat.range(0, n)) { ignore Principal.equal(p1, p1) };
        case "hash" for (_ in Nat.range(0, n)) { ignore Principal.hash(p1) };
        case "toBlob" for (_ in Nat.range(0, n)) { ignore Principal.toBlob(p1) };
        case "fromBlob" for (_ in Nat.range(0, n)) { ignore Principal.fromBlob(p1Blob) };
        case "toText" for (_ in Nat.range(0, n)) { ignore Principal.toText(p1) };
        case "fromText" for (_ in Nat.range(0, n)) { ignore Principal.fromText(p1Text) };
        case "isAnonymous" for (_ in Nat.range(0, n)) { ignore Principal.isAnonymous(p1) };
        case "toLedgerAccount" for (_ in Nat.range(0, n)) { ignore Principal.toLedgerAccount(p1, null) };
        case _ Runtime.unreachable()
      }
    });
    bench
  }
}
