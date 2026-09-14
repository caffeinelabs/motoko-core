/// Double-ended queue of a generic element type `T`.
///
/// The interface is purely functional, not imperative, and queues are immutable values.
/// In particular, Queue operations such as push and pop do not update their input queue but, instead, return the
/// value of the modified Queue, alongside any other data.
/// The input queue is left unchanged.
///
/// Examples of use-cases:
/// Queue (FIFO) by using `pushBack()` and `popFront()`.
/// Stack (LIFO) by using `pushFront()` and `popFront()`.
///
/// A Queue is internally implemented as two lists, a head access list and a (reversed) tail access list,
/// that are dynamically size-balanced by splitting.
///
/// Construction: Create a new queue with the `empty<T>()` function.
///
/// Note on the costs of push and pop functions:
/// * Runtime: `O(1)` amortized costs, `O(size)` worst case cost per single call.
/// * Space: `O(1)` amortized costs, `O(size)` worst case cost per single call.
///
/// `n` denotes the number of elements stored in the queue.
///
/// Note that some operations that traverse the elements of the queue (e.g. `forEach`, `values`) preserve the order of the elements,
/// whereas others (e.g. `map`, `contains`) do NOT guarantee that the elements are visited in any order.
/// The order is undefined to avoid allocations, making these operations more efficient.
///
/// ```motoko name=import
/// import Queue "mo:core/pure/Queue";
/// ```

import Iter "../Iter";
import List "List";
import Order "../Order";
import Types "../Types";
import Array "../Array";
import Prim "mo:⛔";

module {
  /// @deprecated M0235
  type List<T> = Types.Pure.List<T>;

  /// Double-ended queue data type.
  public type Queue<T> = Types.Pure.Queue<T>;

  /// Create a new empty queue.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.empty<Nat>();
  ///   assert queue.isEmpty();
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func empty<T>() : Queue<T> = (null, 0, null);

  /// Determine whether a queue is empty.
  /// Returns true if `queue` is empty, otherwise `false`.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.empty<Nat>();
  ///   assert queue.isEmpty();
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func isEmpty<T>(self : Queue<T>) : Bool = self.1 == 0;

  /// Create a new queue comprising a single element.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.singleton(25);
  ///   assert queue.size() == 1;
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func singleton<T>(item : T) : Queue<T> = (null, 1, ?(item, null));

  /// Determine the number of elements contained in a queue.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.singleton(42);
  ///   assert queue.size() == 1;
  /// }
  /// ```
  ///
  /// Runtime: `O(1)` in Release profile (compiled with `--release` flag), `O(size)` otherwise.
  ///
  /// Space: `O(1)`.
  public func size<T>(self : Queue<T>) : Nat {
    debug assert self.1 == List.size(self.0) + List.size(self.2);
    self.1
  };

  /// Check if a queue contains a specific element.
  /// Returns true if the queue contains an element equal to `item` according to the `equal` function.
  ///
  /// Note: The order in which elements are visited is undefined, for performance reasons.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter([1, 2, 3].values());
  ///   assert queue.contains(Nat.equal, 2);
  ///   assert not queue.contains(Nat.equal, 4);
  /// }
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  public func contains<T>(self : Queue<T>, equal : (implicit : (T, T) -> Bool), item : T) : Bool = List.contains(self.0, equal, item) or List.contains(self.2, equal, item);

  /// Inspect the optional element on the front end of a queue.
  /// Returns `null` if `queue` is empty. Otherwise, the front element of `queue`.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.empty<Nat>().pushFront(2).pushFront(1);
  ///   assert queue.peekFront() == ?1;
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func peekFront<T>(self : Queue<T>) : ?T = switch self {
    case ((?(x, _), _, _) or (_, _, ?(x, null))) ?x;
    case _ { debug assert List.isEmpty(self.2); null }
  };

  /// Inspect the optional element on the back end of a queue.
  /// Returns `null` if `queue` is empty. Otherwise, the back element of `queue`.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.empty<Nat>().pushBack(1).pushBack(2);
  ///   assert queue.peekBack() == ?2;
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func peekBack<T>(self : Queue<T>) : ?T = switch self {
    case ((_, _, ?(x, _)) or (?(x, null), _, _)) ?x;
    case _ { debug assert List.isEmpty(self.0); null }
  };

  // helper to rebalance the queue after getting lopsided
  func check<T>(q : Queue<T>) : Queue<T> {
    switch q {
      case (null, n, r) {
        let (a, b) = List.split(r, n / 2);
        (List.reverse b, n, a)
      };
      case (f, n, null) {
        let (a, b) = List.split(f, n / 2);
        (a, n, List.reverse b)
      };
      case q q
    }
  };

  /// Insert a new element on the front end of a queue.
  /// Returns the new queue with `element` in the front followed by the elements of `queue`.
  ///
  /// This may involve dynamic rebalancing of the two, internally used lists.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.empty<Nat>().pushFront(2).pushFront(1);
  ///   assert queue.peekFront() == ?1;
  ///   assert queue.peekBack() == ?2;
  ///   assert queue.size() == 2;
  /// }
  /// ```
  ///
  /// Runtime: `O(size)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(size)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the queue.
  public func pushFront<T>(self : Queue<T>, element : T) : Queue<T> = check(?(element, self.0), self.1 + 1, self.2);

  /// Insert a new element on the back end of a queue.
  /// Returns the new queue with all the elements of `queue`, followed by `element` on the back.
  ///
  /// This may involve dynamic rebalancing of the two, internally used lists.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.empty<Nat>().pushBack(1).pushBack(2);
  ///   assert queue.peekBack() == ?2;
  ///   assert queue.size() == 2;
  /// }
  /// ```
  ///
  /// Runtime: `O(size)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(size)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the queue.
  public func pushBack<T>(self : Queue<T>, element : T) : Queue<T> = check(self.0, self.1 + 1, ?(element, self.2));

  /// Remove the element on the front end of a queue.
  /// Returns `null` if `queue` is empty. Otherwise, it returns a pair of
  /// the first element and a new queue that contains all the remaining elements of `queue`.
  ///
  /// This may involve dynamic rebalancing of the two, internally used lists.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Runtime "mo:core/Runtime";
  ///
  /// persistent actor {
  ///   let initial = Queue.empty<Nat>().pushBack(1).pushBack(2);
  ///   // initial queue with elements [1, 2]
  ///   switch (initial.popFront()) {
  ///     case null Runtime.trap "Empty queue impossible";
  ///     case (?(frontElement, remainingQueue)) {
  ///       assert frontElement == 1;
  ///       assert remainingQueue.size() == 1
  ///     }
  ///   }
  /// }
  /// ```
  ///
  /// Runtime: `O(size)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(size)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the queue.
  public func popFront<T>(self : Queue<T>) : ?(T, Queue<T>) = if (self.1 == 0) null else switch self {
    case (?(i, f), n, b) ?(i, check(f, n - 1 : Nat, b));
    case (null, _, ?(i, null)) ?(i, (null, 0, null));
    case _ popFront(check self)
  };

  /// Remove the element on the back end of a queue.
  /// Returns `null` if `queue` is empty. Otherwise, it returns a pair of
  /// a new queue that contains the remaining elements of `queue`
  /// and, as the second pair item, the removed back element.
  ///
  /// This may involve dynamic rebalancing of the two, internally used lists.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Runtime "mo:core/Runtime";
  ///
  /// persistent actor {
  ///   let initial = Queue.empty<Nat>().pushBack(1).pushBack(2);
  ///   // initial queue with elements [1, 2]
  ///   let reduced = initial.popBack();
  ///   switch reduced {
  ///     case null Runtime.trap("Empty queue impossible");
  ///     case (?result) {
  ///       let reducedQueue = result.0;
  ///       let removedElement = result.1;
  ///       assert removedElement == 2;
  ///       assert reducedQueue.size() == 1;
  ///     }
  ///   }
  /// }
  /// ```
  ///
  /// Runtime: `O(size)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(size)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the queue.
  public func popBack<T>(self : Queue<T>) : ?(Queue<T>, T) = if (self.1 == 0) null else switch self {
    case (f, n, ?(i, b)) ?((check(f, n - 1 : Nat, b), i));
    case (?(i, null), _, null) ?((null, 0, null), i);
    case _ popBack(check self)
  };

  /// Turn an iterator into a queue, consuming it.
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.fromIter([0, 1, 2, 3, 4].values());
  ///   assert queue.size() == 5;
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func fromIter<T>(iter : Iter.Iter<T>) : Queue<T> {
    let list = List.fromIter iter;
    check(list, List.size list, null)
  };

  /// Convert an iterator to a queue, consuming it.
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   transient let iter = [0, 1, 2, 3, 4].values();
  ///
  ///   let queue = iter.toQueue();
  ///   assert queue.size() == 5;
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func toQueue<T>(self : Iter.Iter<T>) : Queue<T> {
    // ignore-self-type-check
    fromIter(self)
  };

  /// Create a queue from an array.
  /// Elements appear in the same order as in the array.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.fromArray(["A", "B", "C"]);
  ///   assert queue.size() == 3;
  ///   assert queue.peekFront() == ?"A";
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func fromArray<T>(array : [T]) : Queue<T> {
    let list = List.fromArray array;
    check(list, array.size(), null)
  };

  /// Create an immutable array from a queue.
  /// Elements appear in the same order as in the queue (front to back).
  ///
  /// Example:
  /// ```motoko include=import
  /// import Array "mo:core/Array";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromArray(["A", "B", "C"]);
  ///   let array = queue.toArray();
  ///   assert array == ["A", "B", "C"];
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func toArray<T>(self : Queue<T>) : [T] {
    let iter = values(self);
    Array.tabulate(
      self.1,
      func(i) {
        switch (iter.next()) {
          case null {
            Prim.trap("pure/Queue.toArray: unexpected end of iterator")
          };
          case (?value) { value }
        }
      }
    )
  };

  /// Convert a queue to an iterator of its elements in front-to-back order.
  ///
  /// Performance note: Creating the iterator needs `O(size)` runtime and space!
  ///
  /// Example:
  /// ```motoko include=import
  /// import Iter "mo:core/Iter";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter([1, 2, 3].values());
  ///   assert queue.values().toArray() == [1, 2, 3];
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func values<T>(self : Queue<T>) : Iter.Iter<T> = Iter.concat(List.values(self.0), List.values(List.reverse(self.2)));

  /// Compare two queues for equality using the provided equality function.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// persistent actor {
  ///   let queue1 = Queue.fromIter([1, 2].values());
  ///   let queue2 = Queue.fromIter([1, 2].values());
  ///   let queue3 = Queue.fromIter([1, 3].values());
  ///   assert queue1.equal(queue2, Nat.equal);
  ///   assert not queue1.equal(queue3, Nat.equal);
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func equal<T>(self : Queue<T>, other : Queue<T>, equal : (implicit : (T, T) -> Bool)) : Bool {
    if (self.1 != other.1) {
      return false
    };
    let (iter1, iter2) = (values(self), values(other));
    loop {
      switch (iter1.next(), iter2.next()) {
        case (null, null) { return true };
        case (?v1, ?v2) {
          if (not equal(v1, v2)) { return false }
        };
        case (_, _) { return false }
      }
    }
  };

  /// Return true if the given predicate `f` is true for all queue
  /// elements.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.fromIter([1, 2, 3].values());
  ///   let allGreaterThanOne = queue.all(func n = n > 1);
  ///   assert not allGreaterThanOne; // false because 1 is not > 1
  /// }
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)` as the current implementation uses `values` to iterate over the queue.
  ///
  /// *Runtime and space assumes that the `predicate` runs in `O(1)` time and space.
  public func all<T>(self : Queue<T>, predicate : T -> Bool) : Bool {
    for (item in values self) if (not (predicate item)) return false;
    return true
  };

  /// Return true if there exists a queue element for which
  /// the given predicate `f` is true.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.fromIter([1, 2, 3].values());
  ///   let hasGreaterThanOne = queue.any(func n = n > 1);
  ///   assert hasGreaterThanOne; // true because 2 and 3 are > 1
  /// }
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)` as the current implementation uses `values` to iterate over the queue.
  ///
  /// *Runtime and space assumes that the `predicate` runs in `O(1)` time and space.
  public func any<T>(self : Queue<T>, predicate : T -> Bool) : Bool {
    for (item in values self) if (predicate item) return true;
    return false
  };

  /// Call the given function for its side effect, with each queue element in turn.
  /// The order of visiting elements is front-to-back.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   var text = "";
  ///   let queue = Queue.fromIter(["A", "B", "C"].values());
  ///   queue.forEach(func n = text #= n);
  ///   assert text == "ABC";
  /// }
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that `f` runs in `O(1)` time and space.
  public func forEach<T>(self : Queue<T>, f : T -> ()) = for (item in values self) f item;

  /// Call the given function `f` on each queue element and collect the results
  /// in a new queue.
  ///
  /// Note: The order of visiting elements is undefined with the current implementation.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Iter "mo:core/Iter";
  /// import Nat "mo:core/Nat";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter([0, 1, 2].values());
  ///   let textQueue = queue.map(Nat.toText);
  ///   assert textQueue.values().toArray() == ["0", "1", "2"];
  /// }
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that `f` runs in `O(1)` time and space.
  public func map<T1, T2>(self : Queue<T1>, f : T1 -> T2) : Queue<T2> {
    let (fr, n, b) = self;
    (List.map(fr, f), n, List.map(b, f))
  };

  /// Create a new queue with only those elements of the original queue for which
  /// the given function (often called the _predicate_) returns true.
  ///
  /// Note: The order of visiting elements is undefined with the current implementation.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.fromIter([0, 1, 2, 1].values());
  ///   let filtered = queue.filter(func n = n != 1);
  ///   assert filtered.size() == 2;
  /// }
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that `predicate` runs in `O(1)` time and space.
  public func filter<T>(self : Queue<T>, predicate : T -> Bool) : Queue<T> {
    let (fr, _, b) = self;
    let front = List.filter(fr, predicate);
    let back = List.filter(b, predicate);
    check(front, List.size front + List.size back, back)
  };

  /// Call the given function on each queue element, and collect the non-null results
  /// in a new queue.
  ///
  /// Note: The order of visiting elements is undefined with the current implementation.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.fromIter([1, 2, 3].values());
  ///   let doubled = queue.filterMap(
  ///     func n = if (n > 1) ?(n * 2) else null
  ///   );
  ///   assert doubled.size() == 2;
  /// }
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that `f` runs in `O(1)` time and space.
  public func filterMap<T, U>(self : Queue<T>, f : T -> ?U) : Queue<U> {
    let (fr, _n, b) = self;
    let front = List.filterMap(fr, f);
    let back = List.filterMap(b, f);
    check(front, List.size front + List.size back, back)
  };

  /// Convert a queue to its text representation using the provided conversion function.
  /// This function is meant to be used for debugging and testing purposes.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter([1, 2, 3].values());
  ///   assert queue.toText(Nat.toText) == "PureQueue[1, 2, 3]";
  /// }
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  public func toText<T>(self : Queue<T>, f : (implicit : (toText : T -> Text))) : Text {
    var text = "PureQueue[";
    func add(item : T) {
      if (text.size() > 10) text #= ", ";
      text #= f(item)
    };
    List.forEach(self.0, add);
    List.forEach(List.reverse(self.2), add);
    text # "]"
  };

  /// Compare two queues using lexicographic ordering specified by argument function `compareItem`.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// persistent actor {
  ///   let queue1 = Queue.fromIter([1, 2].values());
  ///   let queue2 = Queue.fromIter([1, 3].values());
  ///   assert queue1.compare(queue2, Nat.compare) == #less;
  /// }
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that argument `compareItem` runs in `O(1)` time and space.
  public func compare<T>(self : Queue<T>, other : Queue<T>, compareItem : (implicit : (compare : (T, T) -> Order.Order))) : Order.Order {
    let (i1, i2) = (values self, values other);
    loop switch (i1.next(), i2.next()) {
      case (?v1, ?v2) switch (compareItem(v1, v2)) {
        case (#equal) ();
        case c return c
      };
      case (null, null) return #equal;
      case (null, _) return #less;
      case (_, null) return #greater
    }
  };

  /// Reverse the order of elements in a queue.
  /// This operation is cheap, it does NOT require copying the elements.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.fromIter([1, 2, 3].values());
  ///   let reversed = queue.reverse();
  ///   assert reversed.peekFront() == ?3;
  ///   assert reversed.peekBack() == ?1;
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`
  ///
  /// Space: `O(1)`
  public func reverse<T>(self : Queue<T>) : Queue<T> = (self.2, self.1, self.0)
}
