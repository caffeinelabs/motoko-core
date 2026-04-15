import Array "../src/Array";
import Base64 "../src/Base64";
import Blob "../src/Blob";
import Nat8 "../src/Nat8";
import Text "../src/Text";
import { suite; test; expect } "mo:test";

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
        expect.text(Base64.encode(Blob.fromArray(b3))).equal("AP+q");

        // 2 bytes — one '=' padding
        let b2 : [Nat8] = [1, 2]; // 0x01 0x02
        expect.text(Base64.encode(Blob.fromArray(b2))).equal("AQI=");

        // 1 byte — two '=' padding
        let b1 : [Nat8] = [255]; // 0xFF
        expect.text(Base64.encode(Blob.fromArray(b1))).equal("/w==")
      }
    );

    // Long input: 256 sequential bytes
    test(
      "encodes 256 sequential bytes (0..255)",
      func() {
        let bytes : [Nat8] = Array.tabulate<Nat8>(256, func i = Nat8.fromNat(i));
        let encoded = Base64.encode(Blob.fromArray(bytes));

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
)
