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
/// Authored by Claude Sonnet (claude-sonnet-4-6) for use in generated
/// Motoko API clients.
///
/// Import from the core package to use this module.
/// ```motoko name=import
/// import Base64 "mo:core/Base64";
/// ```

import Nat8 "Nat8";
import Nat32 "Nat32";
import Text "Text";
import Blob "Blob";

module {

  // Standard Base64 alphabet (RFC 4648 §4).
  private let alphabet : [Char] = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
    'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
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
  /// Typical use — encoding HTTP Basic Auth credentials:
  /// ```motoko include=import
  /// // Encodes "user:pass" → "dXNlcjpwYXNz"
  /// let credentials = "user:pass" : Blob;
  /// let header = "Basic " # Base64.encode(credentials);
  /// assert header == "Basic dXNlcjpwYXNz";
  /// ```
  public func encode(data : Blob) : Text {
    let bytes = Blob.toArray(data);
    var result = "";
    var i = 0;
    while (i < bytes.size()) {
      let b1 = bytes[i];
      let b2 : Nat8 = if (i + 1 < bytes.size()) bytes[i + 1] else 0;
      let b3 : Nat8 = if (i + 2 < bytes.size()) bytes[i + 2] else 0;

      let n = (Nat32.fromNat(Nat8.toNat(b1)) << 16)
            | (Nat32.fromNat(Nat8.toNat(b2)) << 8)
            |  Nat32.fromNat(Nat8.toNat(b3));

      let c1 = Text.fromChar(alphabet[Nat32.toNat((n >> 18) & 0x3F)]);
      let c2 = Text.fromChar(alphabet[Nat32.toNat((n >> 12) & 0x3F)]);
      let c3 = if (i + 1 < bytes.size()) Text.fromChar(alphabet[Nat32.toNat((n >> 6) & 0x3F)]) else "=";
      let c4 = if (i + 2 < bytes.size()) Text.fromChar(alphabet[Nat32.toNat(n & 0x3F)]) else "=";

      result #= c1 # c2 # c3 # c4;
      i += 3
    };
    result
  };

}
