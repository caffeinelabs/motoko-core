import Array "../src/Array";
import Order "../src/Order";
import { test } "mo:test";

test(
  "isLess",
  func() {
    assert (Order.isLess(#less));
    assert (not Order.isLess(#equal));
    assert (not Order.isLess(#greater))
  }
);

test(
  "isEqual",
  func() {
    assert (not Order.isEqual(#less));
    assert (Order.isEqual(#equal));
    assert (not Order.isEqual(#greater))
  }
);

test(
  "isGreater",
  func() {
    assert (not Order.isGreater(#less));
    assert (not Order.isGreater(#equal));
    assert (Order.isGreater(#greater))
  }
);

test(
  "allValues",
  func() {
    let iter = Order.allValues();
    assert (iter.next() == ?#less);
    assert (iter.next() == ?#equal);
    assert (iter.next() == ?#greater);
    assert (iter.next() == null);
    assert (iter.next() == null)
  }
);

test(
  "compare",
  func() {
    let lt : Order.Order = #less;
    let eq : Order.Order = #equal;
    let gt : Order.Order = #greater;
    assert lt.compare(eq) == #less;
    assert eq.compare(gt) == #less;
    assert gt.compare(lt) == #greater;
    assert eq.compare(eq) == #equal;
    assert [gt, lt, eq].sort() == [lt, eq, gt]
  }
);

test(
  "toText",
  func() {
    let orders : [Order.Order] = [#less, #equal, #greater];
    assert orders.toText() == "[#less, #equal, #greater]"
  }
)
