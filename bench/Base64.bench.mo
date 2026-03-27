import Array "../src/Array";
import Blob "../src/Blob";
import Base64 "../src/Base64";
import _Nat "../src/Nat";
import Bench "mo:bench-helper";

module {

  // Generate a Blob of zero bytes of given length
  func zeros(len : Nat) : Blob {
    Array.tabulate<Nat8>(len, func _ = 0)
    |> Blob.fromArray(_)
  };
  // Generate a Blob of mixed bytes of given length
  func mixed(len : Nat) : Blob {
    Array.tabulate<Nat8>(len, func i = (i % 256).toNat8())
    |> Blob.fromArray(_)
  };

  public func init() : Bench.V1 {
    let nRows = 5;

    let schema : Bench.Schema = {
      name = "Base64";
      description = "Compare zero bytes vs mixed bytes encoding to Base64";
      rows = Array.tabulate(nRows, func(i) = (10 ** i).toText());
      cols = ["zero bytes", "mixed bytes"]
    };

    let routines : [[() -> ()]] = Array.tabulate(
      nRows,
      func(ri) {
        let z = zeros(10 ** ri);
        let m = mixed(10 ** ri);
        [
          func() { ignore Base64.encode(z) },
          func() { ignore Base64.encode(m) }
        ]
      }
    );

    Bench.V1(schema, func(ri, ci) = routines[ri][ci]())
  }
}
