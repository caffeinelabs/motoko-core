import Bench "mo:bench";

import Array "../../src/Array";
import Blob "../../src/Blob";
import Nat "../../src/Nat";
import Runtime "../../src/Runtime";
import VarArray "../../src/VarArray";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Blob");
    bench.description("Blob operations across byte lengths.");
    bench.rows([
      "fromArray",
      "toArray",
      "compare",
      "equal",
      "hash",
      "size",
      "fromVarArray",
      "toVarArray"
    ]);
    bench.cols([
      "100",
      "1_000",
      "10_000"
    ]);

    let bytes100 = Array.tabulate<Nat8>(100, func(i) = Nat.toNat8(i % 256));
    let bytes1k = Array.tabulate<Nat8>(1_000, func(i) = Nat.toNat8(i % 256));
    let bytes10k = Array.tabulate<Nat8>(10_000, func(i) = Nat.toNat8(i % 256));
    let varBytes100 = VarArray.fromArray<Nat8>(bytes100);
    let varBytes1k = VarArray.fromArray<Nat8>(bytes1k);
    let varBytes10k = VarArray.fromArray<Nat8>(bytes10k);
    let blob100 = Blob.fromArray(bytes100);
    let blob1k = Blob.fromArray(bytes1k);
    let blob10k = Blob.fromArray(bytes10k);
    let byteses = [bytes100, bytes1k, bytes10k];
    let varByteses = [varBytes100, varBytes1k, varBytes10k];
    let blobs = [blob100, blob1k, blob10k];

    func colIdx(col : Text) : Nat {
      switch col {
        case "100" { 0 };
        case "1_000" { 1 };
        case "10_000" { 2 };
        case _ { Runtime.unreachable() }
      }
    };

    bench.runner(
      func(row, col) {
        let i = colIdx(col);
        let bytes = byteses[i];
        let varBytes = varByteses[i];
        let blob = blobs[i];
        switch row {
          case "fromArray" { ignore Blob.fromArray(bytes) };
          case "toArray" { ignore Blob.toArray(blob) };
          case "compare" { ignore Blob.compare(blob, blob) };
          case "equal" { ignore Blob.equal(blob, blob) };
          case "hash" { ignore Blob.hash(blob) };
          case "size" { ignore Blob.size(blob) };
          case "fromVarArray" { ignore Blob.fromVarArray(varBytes) };
          case "toVarArray" { ignore Blob.toVarArray(blob) };
          case _ { Runtime.unreachable() }
        }
      }
    );

    bench
  }
}