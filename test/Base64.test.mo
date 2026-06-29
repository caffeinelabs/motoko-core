import Array "../src/Array";
import Base64 "../src/Base64";
import Blob "../src/Blob";
import Nat8 "../src/Nat8";
import Text "../src/Text";
import { suite; test; expect } "mo:test";
import Nat "../src/Nat";
import Prim "mo:prim";

suite(
  "Base64.encode",
  func() {
    // Examples from the module docs
    test(
      "encodes empty and short ASCII inputs",
      func() {
        expect.text(Base64.encode("" : Blob)).equal("");
        expect.text(Base64.encode("f" : Blob)).equal("Zg==");
        expect.text(Base64.encode("fo" : Blob)).equal("Zm8=");
        expect.text(Base64.encode("foo" : Blob)).equal("Zm9v");
        expect.text(Base64.encode("foob" : Blob)).equal("Zm9vYg==");
        expect.text(Base64.encode("fooba" : Blob)).equal("Zm9vYmE=");
        expect.text(Base64.encode("foobar" : Blob)).equal("Zm9vYmFy")
      }
    );

    // Typical use case from docs: data URIs
    test(
      "encodes for data URI example",
      func() {
        let payload = "Hello" : Blob;
        let uri = "data:text/plain;base64," # Base64.encode(payload);
        expect.text(uri).equal("data:text/plain;base64,SGVsbG8=")
      }
    );

    // Raw byte cases to verify padding and non-ASCII bytes
    test(
      "encodes raw bytes with and without padding",
      func() {
        // 3 bytes — no padding
        let b3 : [Nat8] = [0, 255, 170]; // 0x00 0xFF 0xAA
        expect.text(Base64.encode(Array.toBlob(b3))).equal("AP+q");

        // 2 bytes — one '=' padding
        let b2 : [Nat8] = [1, 2]; // 0x01 0x02
        expect.text(Base64.encode(Array.toBlob(b2))).equal("AQI=");

        // 1 byte — two '=' padding
        let b1 : [Nat8] = [255]; // 0xFF
        expect.text(Base64.encode(Array.toBlob(b1))).equal("/w==")
      }
    );

    // Long input: 256 sequential bytes
    test(
      "encodes 256 sequential bytes (0..255)",
      func() {
        let bytes : [Nat8] = Array.tabulate<Nat8>(256, func i = Nat.toNat8(i));
        let encoded = Base64.encode(Array.toBlob(bytes));

        // Output length should be ceil(256/3)*4 = 344
        expect.nat(Text.size(encoded)).equal(344);

        // Known prefix: Base64 of bytes 0..15 is AAECAwQFBgcICQoLDA0ODxAREhMUFRYX
        expect.bool(Text.startsWith(encoded, #text "AAECAwQFBgcICQoLDA0ODxAREhMUFRYX")).equal(true);

        // Trailing single byte 0xFF encodes as '/w=='
        expect.bool(Text.endsWith(encoded, #text "/w==")).equal(true);

        // All characters must be in the Base64 alphabet or '='
        var ok = true;
        label scan for (c in Text.toIter(encoded)) {
          if (
            not (
              ('A' <= c and c <= 'Z') or
              ('a' <= c and c <= 'z') or
              ('0' <= c and c <= '9') or
              (c == '+') or
              (c == '/') or
              (c == '=')
            )
          ) {
            ok := false;
            break scan
          }
        };
        expect.bool(ok).equal(true)
      }
    );

    // Human-readable multi-sentence text, easy to verify with third-party Base64 tools
    test(
      "encodes multi-sentence ASCII text",
      func() {
        let txt = "The quick brown fox jumps over the lazy dog. Pack my box with five dozen liquor jugs." : Blob;
        let expected = "VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZy4gUGFjayBteSBib3ggd2l0aCBmaXZlIGRvemVuIGxpcXVvciBqdWdzLg==";
        expect.text(Base64.encode(txt)).equal(expected)
      }
    )
  }
);

// Helper: display a ?Blob value for test failure messages
let blobToText : Blob -> Text = func b = debug_show (Prim.blobToArray(b));

suite(
  "Base64.decode",
  func() {
    // Examples from the module docs
    test(
      "decodes empty and short ASCII inputs",
      func() {
        expect.option<Blob>(Base64.decode(""), blobToText, Blob.equal).equal(?("" : Blob));
        expect.option<Blob>(Base64.decode("Zg=="), blobToText, Blob.equal).equal(?("f" : Blob));
        expect.option<Blob>(Base64.decode("Zm8="), blobToText, Blob.equal).equal(?("fo" : Blob));
        expect.option<Blob>(Base64.decode("Zm9v"), blobToText, Blob.equal).equal(?("foo" : Blob));
        expect.option<Blob>(Base64.decode("Zm9vYg=="), blobToText, Blob.equal).equal(?("foob" : Blob));
        expect.option<Blob>(Base64.decode("Zm9vYmE="), blobToText, Blob.equal).equal(?("fooba" : Blob));
        expect.option<Blob>(Base64.decode("Zm9vYmFy"), blobToText, Blob.equal).equal(?("foobar" : Blob))
      }
    );

    // Padding lengths: 0, 1, and 2 '=' characters
    test(
      "decodes all padding lengths correctly",
      func() {
        // 3-byte group → no padding
        let b3 : [Nat8] = [0, 255, 170];
        expect.option<Blob>(Base64.decode("AP+q"), blobToText, Blob.equal).equal(?Array.toBlob(b3));

        // 2-byte group → one '=' padding
        let b2 : [Nat8] = [1, 2];
        expect.option<Blob>(Base64.decode("AQI="), blobToText, Blob.equal).equal(?Array.toBlob(b2));

        // 1-byte group → two '=' paddings
        let b1 : [Nat8] = [255];
        expect.option<Blob>(Base64.decode("/w=="), blobToText, Blob.equal).equal(?Array.toBlob(b1))
      }
    );

    // Invalid input returns null
    test(
      "returns null for invalid characters",
      func() {
        expect.option<Blob>(Base64.decode("not!base64"), blobToText, Blob.equal).equal(null);
        expect.option<Blob>(Base64.decode("Zm9v Ym Fy"), blobToText, Blob.equal).equal(null); // spaces
        expect.option<Blob>(Base64.decode("Zm9v\nYmFy"), blobToText, Blob.equal).equal(null); // newline
        expect.option<Blob>(Base64.decode("Zm9\FF"), blobToText, Blob.equal).equal(null); // non-ASCII
        expect.option<Blob>(Base64.decode("===="), blobToText, Blob.equal).equal(?("" : Blob)) // only padding is valid (empty)
      }
    );

    // Round-trip property: decode(encode(b)) == ?b
    test(
      "round-trips through encode",
      func() {
        let cases : [Blob] = [
          "" : Blob,
          "f" : Blob,
          "fo" : Blob,
          "foo" : Blob,
          "foobar" : Blob,
          "Hello, World!" : Blob,
          Array.toBlob([0, 1, 2, 3, 127, 128, 254, 255])
        ];
        for (b in cases.vals()) {
          expect.option<Blob>(Base64.decode(Base64.encode(b)), blobToText, Blob.equal).equal(?b)
        }
      }
    );

    // Round-trip over 256 sequential bytes
    test(
      "round-trips 256 sequential bytes",
      func() {
        let bytes : [Nat8] = Array.tabulate<Nat8>(256, func i = Nat.toNat8(i));
        let b = Array.toBlob(bytes);
        expect.option<Blob>(Base64.decode(Base64.encode(b)), blobToText, Blob.equal).equal(?b)
      }
    );

    // Long known-value check
    test(
      "decodes multi-sentence ASCII text",
      func() {
        let encoded = "VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZy4gUGFjayBteSBib3ggd2l0aCBmaXZlIGRvemVuIGxpcXVvciBqdWdzLg==";
        let expected = "The quick brown fox jumps over the lazy dog. Pack my box with five dozen liquor jugs." : Blob;
        expect.option<Blob>(Base64.decode(encoded), blobToText, Blob.equal).equal(?expected)
      }
    )
  }
)
