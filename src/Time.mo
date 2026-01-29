/// System time utilities and timers.
///
/// The following example illustrates using the system time:
///
/// ```motoko
/// import Int = "mo:core/Int";
/// import Time = "mo:core/Time";
///
/// persistent actor {
///   var lastTime = Time.now();
///
///   public func greet(name : Text) : async Text {
///     let now = Time.now();
///     let elapsedSeconds = (now - lastTime) / 1000_000_000;
///     lastTime := now;
///     return "Hello, " # name # "!" #
///       " I was last called " # Int.toText(elapsedSeconds) # " seconds ago";
///    };
/// };
/// ```
///
/// Note: If `moc` is invoked with `-no-timer`, the importing will fail.
/// Note: The resolution of the timers is in the order of the block rate,
///       so durations should be chosen well above that. For frequent
///       canister wake-ups the heartbeat mechanism should be considered.

import Types "Types";
import Nat "Nat";
import Order "Order";
import Prim "mo:⛔";

module {

  /// System time is represent as nanoseconds since 1970-01-01.
  public type Time = Types.Time;

  /// Quantity of time expressed in `#days`, `#hours`, `#minutes`, `#seconds`, `#milliseconds`, or `#nanoseconds`.
  public type Duration = Types.Duration;

  /// Current system time given as nanoseconds since 1970-01-01. The system guarantees that:
  ///
  /// * the time, as observed by the canister smart contract, is monotonically increasing, even across canister upgrades.
  /// * within an invocation of one entry point, the time is constant.
  ///
  /// The system times of different canisters are unrelated, and calls from one canister to another may appear to travel "backwards in time"
  ///
  /// Note: While an implementation will likely try to keep the system time close to the real time, this is not formally guaranteed.
  public func now() : Time = Prim.nat64ToNat(Prim.time());

  /// Compares two `Time` values by their order.
  ///
  /// Returns `#less` if `x < y`, `#equal` if `x == y`, and `#greater` if `x > y`.
  ///
  /// This function can be used as value for a high order function, such as a sort function.
  ///
  /// Example:
  /// ```motoko
  /// import Time "mo:core/Time";
  /// import Array "mo:core/Array";
  /// 
  /// let times = [1704067200000000000, 1672531200000000000, 1688169600000000000];
  /// assert Array.sort(times, Time.compare) == [1672531200000000000, 1688169600000000000, 1704067200000000000];
  /// ```
  public func compare(x : Time, y : Time) : Order.Order {
    if (x < y) { #less } else if (x == y) { #equal } else {
      #greater
    }
  };

  public type TimerId = Nat;

  public func toNanoseconds(duration : Duration) : Nat {
    switch duration {
      case (#days n) n * 86_400_000_000_000;
      case (#hours n) n * 3_600_000_000_000;
      case (#minutes n) n * 60_000_000_000;
      case (#seconds n) n * 1_000_000_000;
      case (#milliseconds n) n * 1_000_000;
      case (#nanoseconds n) n
    }
  };

}
