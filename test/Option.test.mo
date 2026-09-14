import Option "../src/Option";
import Int "../src/Int";
import { suite; test; expect } "mo:test";
import Nat "../src/Nat";

suite(
  "apply",
  func() {
    test(
      "null function, null value",
      func() {
        assert (Option.apply<Int, Bool>(null, null) == null)
      }
    );

    test(
      "null function, non-null value",
      func() {
        assert (Option.apply<Int, Bool>(?0, null) == null)
      }
    );

    test(
      "non-null function, null value",
      func() {
        let isEven = func(x : Int) : Bool {
          x % 2 == 0
        };

        assert (Option.apply<Int, Bool>(null, ?isEven) == null)
      }
    );

    test(
      "non-null function, non-null value",
      func() {
        let isEven = func(x : Int) : Bool {
          x % 2 == 0
        };

        assert (Option.apply<Int, Bool>(?0, ?isEven) == ?true)
      }
    )
  }
);

suite(
  "bind",
  func() {
    test(
      "null value to null value",
      func() {
        let safeInt = func(x : Int) : ?Int {
          if (x > 9007199254740991) {
            null
          } else {
            ?x
          }
        };

        assert (Option.chain<Int, Int>(null, safeInt) == null)
      }
    );

    test(
      "non-null value to null value",
      func() {
        let safeInt = func(x : Int) : ?Int {
          if (x > 9007199254740991) {
            null
          } else {
            ?x
          }
        };

        assert (Option.chain<Int, Int>(?9007199254740992, safeInt) == null)
      }
    );

    test(
      "non-null value to non-null value",
      func() {
        let safeInt = func(x : Int) : ?Int {
          if (x > 9007199254740991) {
            null
          } else {
            ?x
          }
        };

        assert (Option.chain<Int, Int>(?0, safeInt) == ?0)
      }
    )
  }
);

suite(
  "flatten",
  func() {
    test(
      "null value",
      func() {
        assert (Option.flatten<Int>(?null) == null)
      }
    );

    test(
      "non-null value",
      func() {
        assert (Option.flatten<Int>(??0) == ?0)
      }
    )
  }
);

suite(
  "map",
  func() {
    test(
      "null value",
      func() {
        let isEven = func(x : Int) : Bool {
          x % 2 == 0
        };

        assert (Option.map<Int, Bool>(null, isEven) == null)
      }
    );

    test(
      "non-null value",
      func() {
        let isEven = func(x : Int) : Bool {
          x % 2 == 0
        };

        assert (Option.map<Int, Bool>(?0, isEven) == ?true)
      }
    )
  }
);

test(
  "forEach",
  func() {
    var witness = 0;
    Option.forEach(?(1), func(x : Nat) { witness += 1 });
    assert (witness == 1);
    Option.forEach<Nat>(null, func(x : Nat) { witness += 1 });
    assert (witness == 1)
  }
);

test(
  "some",
  func() {
    assert (Option.some<Int>(0) == ?0)
  }
);

test(
  "equal",
  func() {
    assert (Option.equal<Int>(null, null, Int.equal));
    assert (Option.equal<Int>(?0, ?0, Int.equal));
    assert (not Option.equal<Int>(?0, ?1, Int.equal));
    assert (not Option.equal<Int>(?0, null, Int.equal));
    assert (not Option.equal<Int>(null, ?0, Int.equal))
  }
);

test(
  "compare",
  func() {
    expect.bool(Option.compare<Nat>(null, null, Nat.compare) == #equal).isTrue();
    expect.bool(Option.compare(null, ?0, Nat.compare) == #less).isTrue();
    expect.bool(Option.compare(?0, null, Nat.compare) == #greater).isTrue();
    expect.bool(Option.compare(?0, ?0, Nat.compare) == #equal).isTrue();
    expect.bool(Option.compare(?0, ?1, Nat.compare) == #less).isTrue();
    expect.bool(Option.compare(?1, ?0, Nat.compare) == #greater).isTrue()
  }
);

test(
  "toText",
  func() {
    expect.text(Option.toText<Nat>(null, Nat.toText)).equal("null");
    expect.text(Option.toText(?0, Nat.toText)).equal("?0")
  }
)
