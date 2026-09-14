import Result "../src/Result";
import Int "../src/Int";
import { suite; test } "mo:test";

func makeNatural(x : Int) : Result.Result<Nat, Text> = if (x >= 0) {
  #ok(Int.abs(x))
} else { #err(Int.toText(x) # " is not a natural number.") };

func largerThan10(x : Nat) : Result.Result<Nat, Text> = if (x > 10) { #ok(x) } else {
  #err(Int.toText(x) # " is not larger than 10.")
};

suite(
  "chain",
  func() {
    test(
      "ok -> ok",
      func() {
        assert Result.chain(makeNatural(11), largerThan10) == #ok(11)
      }
    );

    test(
      "ok -> err",
      func() {
        assert Result.chain(makeNatural(5), largerThan10) == #err("5 is not larger than 10.")
      }
    );

    test(
      "err",
      func() {
        assert Result.chain(makeNatural(-5), largerThan10) == #err("-5 is not a natural number.")
      }
    )
  }
);

suite(
  "flatten",
  func() {
    test(
      "ok -> ok",
      func() {
        assert Result.flatten<Nat, Text>(#ok(#ok(10))) == #ok(10)
      }
    );

    test(
      "err",
      func() {
        assert Result.flatten<Nat, Text>(#err("wrong")) == #err("wrong")
      }
    );

    test(
      "ok -> err",
      func() {
        assert Result.flatten<Nat, Text>(#ok(#err("wrong"))) == #err("wrong")
      }
    )
  }
);

suite(
  "forOk",
  func() {
    var counter : Nat = 0;

    test(
      "ok",
      func() {
        Result.forOk(makeNatural(5), func(x : Nat) { counter += x });
        assert counter == 5
      }
    );

    test(
      "err",
      func() {
        Result.forOk(makeNatural(-10), func(x : Nat) { counter += x });
        assert counter == 5
      }
    )
  }
);

suite(
  "forErr",
  func() {
    var counter : Nat = 0;

    test(
      "ok",
      func() {
        Result.forErr(#err 5, func(x : Nat) { counter += x });
        assert counter == 5
      }
    );

    test(
      "err",
      func() {
        Result.forErr(#ok 5, func(x : Nat) { counter += x });
        assert counter == 5
      }
    )
  }
)
