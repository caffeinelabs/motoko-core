/// Utilities for `Order` (comparison between two values).

import Types "Types";

module {

  /// A type to represent an order.
  public type Order = Types.Order;

  /// Check if an order is #less.
  public func isLess(self : Order) : Bool {
    switch self {
      case (#less) { true };
      case _ { false }
    }
  };

  /// Check if an order is #equal.
  public func isEqual(self : Order) : Bool {
    switch self {
      case (#equal) { true };
      case _ { false }
    }
  };

  /// Check if an order is #greater.
  public func isGreater(self : Order) : Bool {
    switch self {
      case (#greater) { true };
      case _ { false }
    }
  };

  /// Returns true if only if  `order1` and `order2` are the same.
  public func equal(self : Order, other : Order) : Bool {
    switch (self, other) {
      case (#less, #less) { true };
      case (#equal, #equal) { true };
      case (#greater, #greater) { true };
      case _ { false }
    }
  };

  /// Compares two orders: `#less` comes before `#equal`, which comes before `#greater`,
  /// matching the order in which `allValues` yields them.
  ///
  /// Example:
  /// ```motoko
  /// import Order "mo:core/Order";
  ///
  /// let less : Order.Order = #less;
  /// assert less.compare(#greater) == #less;
  /// assert less.compare(#less) == #equal;
  /// ```
  public func compare(self : Order, other : Order) : Order {
    let (selfRank, otherRank) = (rank(self), rank(other));
    if (selfRank < otherRank) #less else if (selfRank == otherRank) #equal else #greater
  };

  func rank(order : Order) : Nat {
    switch order {
      case (#less) { 0 };
      case (#equal) { 1 };
      case (#greater) { 2 }
    }
  };

  /// Returns the textual representation of an order: `"#less"`, `"#equal"`, or `"#greater"`.
  ///
  /// Example:
  /// ```motoko
  /// import Order "mo:core/Order";
  ///
  /// let order : Order.Order = #greater;
  /// assert order.toText() == "#greater";
  /// ```
  public func toText(self : Order) : Text {
    switch self {
      case (#less) { "#less" };
      case (#equal) { "#equal" };
      case (#greater) { "#greater" }
    }
  };

  /// Returns an iterator that yields all possible `Order` values:
  /// `#less`, `#equal`, `#greater`.
  public func allValues() : Types.Iter<Order> {
    var nextState : ?Order = ?#less;
    {
      next = func() : ?Order {
        let state = nextState;
        switch state {
          case (?#less) { nextState := ?#equal };
          case (?#equal) { nextState := ?#greater };
          case (?#greater) { nextState := null };
          case (null) {}
        };
        state
      }
    }
  }

}
