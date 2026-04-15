/// Module for Base64 encoding of byte sequences.
///
/// Base64 encoding converts binary data to an ASCII string using 64 printable
/// characters, as specified in [RFC 4648](https://www.rfc-editor.org/rfc/rfc4648).
/// It is widely used for HTTP Basic Authentication, encoding binary data in
/// JSON payloads, and data URIs.
///
/// This module uses the standard Base64 alphabet (`A–Z`, `a–z`, `0–9`, `+`, `/`)
/// and pads output to a multiple of 4 characters using `=`.
///
/// Original version authored by Claude Sonnet (claude-sonnet-4-6) for use in generated
/// Motoko API clients. The module received subsequent manual performance improvements.
///
/// Import from the core package to use this module.
/// ```motoko name=import
/// import Base64 "mo:core/Base64";
/// ```

import Blob "Blob";
import Nat8 "Nat8";
import Nat16 "Nat16";
import Nat32 "Nat32";
import Nat64 "Nat64";
import Text "Text";
import Prim "mo:prim";

module {

  // Standard Base64 alphabet (RFC 4648 §4) in UTF8 values.
  // Equivalent to Text form:
  /*
  private let alphabet : [Text] = [
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
    "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
    "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "/"
  ];
  */
  // prettier-ignore
  private let alphabet : [Nat8] = [
    65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77,
    78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90,
    97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109,
    110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122,
    48, 49, 50, 51, 52, 53, 54, 55, 56, 57,
    43, 47
  ];

  /// Encodes a `Blob` as a Base64 `Text` string (RFC 4648 §4).
  ///
  /// Output length is always a multiple of 4, padded with `=` as needed.
  /// An empty `Blob` encodes to an empty `Text`.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert Base64.encode("" : Blob) == "";
  /// assert Base64.encode("f" : Blob) == "Zg==";
  /// assert Base64.encode("fo" : Blob) == "Zm8=";
  /// assert Base64.encode("foo" : Blob) == "Zm9v";
  /// assert Base64.encode("foobar" : Blob) == "Zm9vYmFy";
  /// ```
  ///
  /// Typical use — embedding text in a data URI:
  /// ```motoko include=import
  /// let payload = "Hello" : Blob;
  /// let uri = "data:text/plain;base64," # Base64.encode(payload);
  /// assert uri == "data:text/plain;base64,SGVsbG8=";
  /// ```
  public func encode(data : Blob) : Text {
    let sz = Nat64.fromIntWrap(data.size());
    var result = "";
    var i = 0 : Nat64;
    var next_i = 6 : Nat64;

    // Process chunks of 6 input bytes at a time (8 output characters)
    while (next_i <= sz) {
      let b1 = data[i.toNat()];
      let b2 : Nat8 = data[(i +% 1).toNat()];
      let b3 : Nat8 = data[(i +% 2).toNat()];
      let b4 : Nat8 = data[(i +% 3).toNat()];
      let b5 : Nat8 = data[(i +% 4).toNat()];
      let b6 : Nat8 = data[(i +% 5).toNat()];

      let n = (b1.toNat16().toNat32() << 16) | (b2.toNat16().toNat32() << 8) | b3.toNat16().toNat32();
      let m = (b4.toNat16().toNat32() << 16) | (b5.toNat16().toNat32() << 8) | b6.toNat16().toNat32();

      let bytes = Blob.fromArray([
        alphabet[((n >> 18) & 0x3F).toNat()],
        alphabet[((n >> 12) & 0x3F).toNat()],
        alphabet[((n >> 6) & 0x3F).toNat()],
        alphabet[(n & 0x3F).toNat()],
        alphabet[((m >> 18) & 0x3F).toNat()],
        alphabet[((m >> 12) & 0x3F).toNat()],
        alphabet[((m >> 6) & 0x3F).toNat()],
        alphabet[(m & 0x3F).toNat()]
      ]);

      switch (Text.decodeUtf8(bytes)) {
        case (?t) result := result # t;
        case (_) {
          Prim.trap("Cannot happen: Utf8 decode error in Base64.encode().")
        }
      };

      i := next_i;
      next_i +%= 6
    };

    // Process remaining 0-5 input bytes in chunks of 3
    while (i < sz) {
      let b1 = data[i.toNat()];
      let b2 : Nat8 = if (i +% 1 < sz) data[(i +% 1).toNat()] else 0;
      let b3 : Nat8 = if (i +% 2 < sz) data[(i +% 2).toNat()] else 0;

      let n = (b1.toNat16().toNat32() << 16) | (b2.toNat16().toNat32() << 8) | b3.toNat16().toNat32();

      //  Note: Value 61 is the UTF8 encoding of the `=` character
      let bytes = Blob.fromArray([
        alphabet[((n >> 18) & 0x3F).toNat()],
        alphabet[((n >> 12) & 0x3F).toNat()],
        if (i +% 1 < sz) alphabet[((n >> 6) & 0x3F).toNat()] else 61,
        if (i +% 2 < sz) alphabet[(n & 0x3F).toNat()] else 61
      ]);

      switch (Text.decodeUtf8(bytes)) {
        case (?t) result := result # t;
        case (_) {
          Prim.trap("Cannot happen: Utf8 decode error in Base64.encode().")
        }
      };

      i +%= 3
    };
    result
  };

}
