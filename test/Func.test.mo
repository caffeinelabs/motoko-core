import Function "../src/Func";
import Text "../src/Text";
import { suite; test; expect } "mo:test";

func isEven(x : Int) : Bool { x % 2 == 0 };
func not_(x : Bool) : Bool { not x };
let isOdd = Function.compose(not_, isEven);

suite(
  "compose",
  func() {
    test(
      "not even is odd",
      func() {
        expect.bool(isOdd(0)).equal(false)
      }
    );

    test(
      "one is odd",
      func() {
        expect.bool(isOdd(1)).equal(true)
      }
    )
  }
);

suite(
  "const",
  func() {
    test(
      "abc is ignored",
      func() {
        expect.bool(Function.const<Bool, Text>(true)("abc")).equal(true)
      }
    );

    test(
      "same for flipped const",
      func() {
        expect.bool(Function.const<Bool, Text>(false)("abc")).equal(false)
      }
    );

    test(
      "same for structured ignoree",
      func() {
        expect.bool(Function.const<Bool, (Text, Text)>(false)("abc", "abc")).equal(false)
      }
    )
  }
)
