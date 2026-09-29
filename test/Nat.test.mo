import Nat "../src/Nat";
import Iter "../src/Iter";
import { test } "mo:test";

test(
  "add",
  func() {
    assert Nat.add(1, Nat.add(2, 3)) == Nat.add(1, Nat.add(2, 3));
    assert Nat.add(0, 1) == 1;
    assert 1 == Nat.add(1, 0);
    assert Nat.add(0, 1) == Nat.add(1, 0);
    assert Nat.add(1, 2) == Nat.add(2, 1)
  }
);

test(
  "shift",
  func() {
    assert Nat.bitshiftLeft(1234567890, 3) == 1234567890 * 8;
    assert Nat.bitshiftRight(1234567892, 2) == 1234567892 / 4
  }
);

test(
  "toText",
  func() {
    assert Nat.toText(0) == "0";
    assert Nat.toText(1234) == "1234"
  }
);

test(
  "range",
  func() {
    assert Nat.range(0, 3).toArray() == [0, 1, 2];
    assert Nat.range(1, 3).toArray() == [1, 2];
    assert Nat.range(1, 2).toArray() == [1];
    assert Nat.range(3, 0).toArray() == [];
    assert Nat.range(1, 0).toArray() == [];
    assert Nat.range(0, 0).toArray() == []
  }
);

test(
  "rangeBy",
  func() {
    assert Nat.rangeBy(0, 3, 1).toArray() == [0, 1, 2];
    assert Nat.rangeBy(0, 3, 2).toArray() == [0, 2];
    assert Nat.rangeBy(0, 3, 3).toArray() == [0];
    assert Nat.rangeBy(1, 4, 2).toArray() == [1, 3];
    assert Nat.rangeBy(1, 3, 2).toArray() == [1];
    assert Nat.rangeBy(3, 0, -1).toArray() == [3, 2, 1];
    assert Nat.rangeBy(3, 1, -1).toArray() == [3, 2];
    assert Nat.rangeBy(3, 0, -2).toArray() == [3, 1];
    assert Nat.rangeBy(3, 1, -2).toArray() == [3];
    assert Nat.rangeBy(1, 3, -1).toArray() == [];
    assert Nat.rangeBy(0, 1, 0).toArray() == [];
    assert Nat.rangeBy(1, 0, 0).toArray() == [];

    assert Nat.rangeBy(4, 4, 1).toArray() == [];
    assert Nat.rangeBy(3, 4, 1).toArray() == [3];
    assert Nat.rangeBy(4, 3, -1).toArray() == [4]
  }
);

test(
  "rangeInclusive",
  func() {
    assert Nat.rangeInclusive(0, 2).toArray() == [0, 1, 2];
    assert Nat.rangeInclusive(1, 2).toArray() == [1, 2];
    assert Nat.rangeInclusive(1, 1).toArray() == [1];
    assert Nat.rangeInclusive(1, 0).toArray() == [];
    assert Nat.rangeInclusive(0, 0).toArray() == [0];
    assert Nat.rangeInclusive(0, 1).toArray() == [0, 1]
  }
);

test(
  "rangeByInclusive",
  func() {
    assert Nat.rangeByInclusive(1, 7, 2).toArray() == [1, 3, 5, 7];
    assert Nat.rangeByInclusive(1, 6, 2).toArray() == [1, 3, 5];
    assert Nat.rangeByInclusive(1, 3, 1).toArray() == [1, 2, 3];

    assert Nat.rangeByInclusive(7, 1, -2).toArray() == [7, 5, 3, 1];
    assert Nat.rangeByInclusive(6, 1, -2).toArray() == [6, 4, 2];
    assert Nat.rangeByInclusive(3, 1, -1).toArray() == [3, 2, 1];

    assert Nat.rangeByInclusive(1, 1, 1).toArray() == [1];
    assert Nat.rangeByInclusive(1, 1, -1).toArray() == [1];
    assert Nat.rangeByInclusive(1, 2, 0).toArray() == [];
    assert Nat.rangeByInclusive(2, 1, 1).toArray() == [];
    assert Nat.rangeByInclusive(1, 2, -1).toArray() == [];

    assert Nat.rangeByInclusive(3, 0, -1).toArray() == [3, 2, 1, 0];
    assert Nat.rangeByInclusive(3, 0, 0).toArray() == [];
    assert Nat.rangeByInclusive(3, 3, 0).toArray() == [3]
  }
)
