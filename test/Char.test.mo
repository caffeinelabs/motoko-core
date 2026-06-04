import Char "../src/Char";
import Nat32 "../src/Nat32";
import Prim "mo:⛔";
import { suite; test; expect } "mo:test";

// suite(
//   "toUpper",
//   func() {
//     test(
//       "converts lowercase special chars to uppercase",
//       func() {
//         expect.char(Char.toUpper('ö')).equal('Ö');
//         expect.char(Char.toUpper('σ')).equal('Σ');
//       }
//     );

//     test(
//       "preserves non-letter chars",
//       func() {
//         expect.char(Char.toUpper('💩')).equal('💩');
//       }
//     )
//   }
// );

// suite(
//   "toLower",
//   func() {
//     test(
//       "converts uppercase special chars to lowercase",
//       func() {
//         expect.char(Char.toLower('Ö')).equal('ö');
//         expect.char(Char.toLower('Σ')).equal('σ');
//       }
//     );

//     test(
//       "preserves non-letter chars",
//       func() {
//         expect.char(Char.toLower('💩')).equal('💩');
//       }
//     )
//   }
// );

suite(
  "conversion",
  func() {
    test(
      "toNat32 converts characters to their Unicode values",
      func() {
        expect.nat32(Char.toNat32('A')).equal(65);
        expect.nat32(Char.toNat32('京')).equal(20140)
      }
    );

    test(
      "fromNat32 converts valid Unicode values to characters",
      func() {
        expect.char(Nat32.toChar(65)).equal('A');
        expect.char(Nat32.toChar(20140)).equal('京')
      }
    );

    test(
      "toText converts character to single character text",
      func() {
        expect.text(Char.toText('A')).equal("A");
        expect.text(Char.toText('京')).equal("京");
        expect.text(Char.toText('💩')).equal("💩")
      }
    )
  }
);

suite(
  "isWhitespace",
  func() {
    test(
      "identifies standard whitespace",
      func() {
        expect.bool(Char.isWhitespace(' ')).equal(true);
        expect.bool(Char.isWhitespace('\t')).equal(true);
        expect.bool(Char.isWhitespace('\r')).equal(true)
      }
    );

    test(
      "identifies special whitespace characters",
      func() {
        // 12288 (U+3000) = ideographic space
        expect.bool(Char.isWhitespace(Prim.nat32ToChar(12288))).equal(true);
        // Vertical tab
        expect.bool(Char.isWhitespace(Prim.nat32ToChar(0x0B))).equal(true);
        // Form feed
        expect.bool(Char.isWhitespace(Prim.nat32ToChar(0x0C))).equal(true)
      }
    );

    test(
      "returns false for non-whitespace",
      func() {
        expect.bool(Char.isWhitespace('x')).equal(false)
      }
    )
  }
);

suite(
  "isLower",
  func() {
    test(
      "identifies lowercase letters",
      func() {
        expect.bool(Char.isLower('x')).equal(true)
      }
    );

    test(
      "returns false for uppercase letters",
      func() {
        expect.bool(Char.isLower('X')).equal(false)
      }
    )
  }
);

suite(
  "isUpper",
  func() {
    test(
      "identifies uppercase letters",
      func() {
        expect.bool(Char.isUpper('X')).equal(true)
      }
    );

    test(
      "returns false for lowercase letters",
      func() {
        expect.bool(Char.isUpper('x')).equal(false)
      }
    )
  }
);

suite(
  "isAlphabetic",
  func() {
    test(
      "identifies alphabetic characters",
      func() {
        expect.bool(Char.isAlphabetic('a')).equal(true);
        expect.bool(Char.isAlphabetic('京')).equal(true)
      }
    );

    test(
      "returns false for non-alphabetic characters",
      func() {
        expect.bool(Char.isAlphabetic('㋡')).equal(false)
      }
    )
  }
);

suite(
  "isDigit",
  func() {
    test(
      "identifies decimal digits",
      func() {
        expect.bool(Char.isDigit('0')).equal(true);
        expect.bool(Char.isDigit('5')).equal(true);
        expect.bool(Char.isDigit('9')).equal(true)
      }
    );

    test(
      "returns false for non-digits",
      func() {
        expect.bool(Char.isDigit('a')).equal(false);
        expect.bool(Char.isDigit('$')).equal(false)
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
        expect.bool(Char.equal('a', 'a')).equal(true);
        expect.bool(Char.equal('a', 'b')).equal(false)
      }
    );

    test(
      "notEqual",
      func() {
        expect.bool(Char.notEqual('a', 'b')).equal(true);
        expect.bool(Char.notEqual('a', 'a')).equal(false)
      }
    );

    test(
      "less",
      func() {
        expect.bool(Char.less('a', 'b')).equal(true);
        expect.bool(Char.less('b', 'a')).equal(false);
        expect.bool(Char.less('a', 'a')).equal(false)
      }
    );

    test(
      "lessOrEqual",
      func() {
        expect.bool(Char.lessOrEqual('a', 'b')).equal(true);
        expect.bool(Char.lessOrEqual('a', 'a')).equal(true);
        expect.bool(Char.lessOrEqual('b', 'a')).equal(false)
      }
    );

    test(
      "greater",
      func() {
        expect.bool(Char.greater('b', 'a')).equal(true);
        expect.bool(Char.greater('a', 'b')).equal(false);
        expect.bool(Char.greater('a', 'a')).equal(false)
      }
    );

    test(
      "greaterOrEqual",
      func() {
        expect.bool(Char.greaterOrEqual('b', 'a')).equal(true);
        expect.bool(Char.greaterOrEqual('a', 'a')).equal(true);
        expect.bool(Char.greaterOrEqual('a', 'b')).equal(false)
      }
    );

    test(
      "compare",
      func() {
        expect.text(debug_show (Char.compare('a', 'b'))).equal("#less");
        expect.text(debug_show (Char.compare('b', 'a'))).equal("#greater");
        expect.text(debug_show (Char.compare('a', 'a'))).equal("#equal")
      }
    )
  }
)
