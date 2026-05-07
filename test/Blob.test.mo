import Array "../src/Array";
import Blob "../src/Blob";
import Nat8 "../src/Nat8";
import VarArray "../src/VarArray";
import { suite; test; expect } "mo:test";

suite(
  "basic operations",
  func() {
    test(
      "empty creates an empty blob",
      func() {
        let emptyBlob = Blob.empty();
        expect.nat(emptyBlob.size()).equal(0)
      }
    );

    test(
      "isEmpty identifies empty blobs",
      func() {
        expect.bool(Blob.isEmpty(Blob.empty())).equal(true);
        expect.bool(Blob.isEmpty("\FF\00" : Blob)).equal(false)
      }
    );

    test(
      "size returns correct byte count",
      func() {
        expect.nat(Blob.size("\FF\00\AA" : Blob)).equal(3);
        expect.nat(Blob.size(Blob.empty())).equal(0)
      }
    )
  }
);

suite(
  "conversion",
  func() {
    test(
      "fromArray creates blob from byte array",
      func() {
        let bytes : [Nat8] = [0, 255, 170];
        let blob = Blob.fromArray(bytes);
        expect.nat(blob.size()).equal(3);
        expect.array(Blob.toArray(blob), Nat8.toText, Nat8.equal).equal(bytes)
      }
    );

    test(
      "fromVarArray creates blob from mutable byte array",
      func() {
        let bytes : [var Nat8] = [var 0, 255, 170];
        let blob = Blob.fromVarArray(bytes);
        expect.nat(blob.size()).equal(3);
        expect.array(Blob.toArray(blob), Nat8.toText, Nat8.equal).equal([0, 255, 170])
      }
    );

    test(
      "toArray converts blob to byte array",
      func() {
        let blob = "\00\FF\AA" : Blob;
        let bytes = Blob.toArray(blob);
        expect.array(bytes, Nat8.toText, Nat8.equal).equal([0, 255, 170])
      }
    );

    test(
      "toVarArray converts blob to mutable byte array",
      func() {
        let blob = "\00\FF\AA" : Blob;
        let bytes = Blob.toVarArray(blob);
        expect.array([bytes[0], bytes[1], bytes[2]], Nat8.toText, Nat8.equal).equal([0, 255, 170])
      }
    );

    test(
      "Array.toBlob converts byte array to blob",
      func() {
        let bytes : [Nat8] = [0, 255, 170];
        expect.blob(Array.toBlob(bytes)).equal("\00\FF\AA");
        expect.blob(bytes.toBlob()).equal("\00\FF\AA");
        expect.blob(([] : [Nat8]).toBlob()).equal("")
      }
    );

    test(
      "VarArray.toBlob converts mutable byte array to blob",
      func() {
        let bytes : [var Nat8] = [var 0, 255, 170];
        expect.blob(VarArray.toBlob(bytes)).equal("\00\FF\AA");
        expect.blob(bytes.toBlob()).equal("\00\FF\AA");
        expect.blob(([var] : [var Nat8]).toBlob()).equal("")
      }
    )
  }
);

suite(
  "hash",
  func() {
    test(
      "hash returns consistent values",
      func() {
        let blob1 = "\00\FF\00" : Blob;
        let blob2 = "\FF\00\FF" : Blob;
        expect.nat32(Blob.hash(blob1)).equal(1818567776);
        expect.nat32(Blob.hash(blob2)).equal(1826292338)
      }
    )
  }
);

suite(
  "comparison",
  func() {
    test(
      "equal",
      func() {
        let blob1 = "\00\FF\00" : Blob;
        let blob2 = "\00\FF\00" : Blob;
        let blob3 = "\FF\00\FF" : Blob;

        expect.bool(Blob.equal(blob1, blob2)).equal(true);
        expect.bool(Blob.equal(blob1, blob3)).equal(false)
      }
    );

    test(
      "notEqual",
      func() {
        let blob1 = "\00\FF\00" : Blob;
        let blob2 = "\00\FF\00" : Blob;
        let blob3 = "\FF\00\FF" : Blob;

        expect.bool(Blob.notEqual(blob1, blob2)).equal(false);
        expect.bool(Blob.notEqual(blob1, blob3)).equal(true)
      }
    );

    test(
      "less",
      func() {
        let blob1 = "\00\AA\00" : Blob;
        let blob2 = "\00\FF\00" : Blob;

        expect.bool(Blob.less(blob1, blob2)).equal(true);
        expect.bool(Blob.less(blob2, blob1)).equal(false);
        expect.bool(Blob.less(blob1, blob1)).equal(false)
      }
    );

    test(
      "lessOrEqual",
      func() {
        let blob1 = "\00\AA\00" : Blob;
        let blob2 = "\00\FF\00" : Blob;

        expect.bool(Blob.lessOrEqual(blob1, blob2)).equal(true);
        expect.bool(Blob.lessOrEqual(blob1, blob1)).equal(true);
        expect.bool(Blob.lessOrEqual(blob2, blob1)).equal(false)
      }
    );

    test(
      "greater",
      func() {
        let blob1 = "\00\FF\00" : Blob;
        let blob2 = "\00\AA\00" : Blob;

        expect.bool(Blob.greater(blob1, blob2)).equal(true);
        expect.bool(Blob.greater(blob2, blob1)).equal(false);
        expect.bool(Blob.greater(blob1, blob1)).equal(false)
      }
    );

    test(
      "greaterOrEqual",
      func() {
        let blob1 = "\00\FF\00" : Blob;
        let blob2 = "\00\AA\00" : Blob;

        expect.bool(Blob.greaterOrEqual(blob1, blob2)).equal(true);
        expect.bool(Blob.greaterOrEqual(blob1, blob1)).equal(true);
        expect.bool(Blob.greaterOrEqual(blob2, blob1)).equal(false)
      }
    );

    test(
      "compare",
      func() {
        let blob1 = "\00\AA\00" : Blob;
        let blob2 = "\00\FF\00" : Blob;

        expect.text(debug_show (Blob.compare(blob1, blob2))).equal("#less");
        expect.text(debug_show (Blob.compare(blob2, blob1))).equal("#greater");
        expect.text(debug_show (Blob.compare(blob1, blob1))).equal("#equal")
      }
    )
  }
)
