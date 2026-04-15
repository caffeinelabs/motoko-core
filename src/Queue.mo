/// A mutable double-ended queue of elements.
/// The queue has two ends, front and back.
/// Elements can be added and removed at the two ends.
///
/// This can be used for different use cases, such as:
/// * Queue (FIFO) by using `pushBack()` and `popFront()`
/// * Stack (LIFO) by using `pushFront()` and `popFront()`.
///
/// Example:
/// ```motoko
/// import Queue "mo:core/Queue";
///
/// persistent actor {
///   let orders = Queue.empty<Text>();
///   Queue.pushBack(orders, "Motoko");
///   Queue.pushBack(orders, "Mops");
///   Queue.pushBack(orders, "IC");
///   assert Queue.popFront(orders) == ?"Motoko";
///   assert Queue.popFront(orders) == ?"Mops";
///   assert Queue.popFront(orders) == ?"IC";
///   assert Queue.popFront(orders) == null;
/// }
/// ```
///
/// The internal implementation is a doubly-linked list.
///
/// Performance:
/// * Runtime: `O(1)` for push, pop, and peek operations.
/// * Space: `O(n)`.
/// `n` denotes the number of elements stored in the queue.

import PureQueue "pure/Queue";
import Iter "Iter";
import Order "Order";
import Types "Types";
import Array "Array";
import Prim "mo:⛔";

module {
  public type Queue<T> = Types.Queue.Queue<T>;

  type Node<T> = Types.Queue.Node<T>;

  /// Converts a mutable queue to an immutable, purely functional queue.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter<Nat>([1, 2, 3].vals());
  ///   let pureQueue = Queue.toPure<Nat>(queue);
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// `n` denotes the number of elements stored in the queue.
  /// @deprecated M0235
  public func toPure<T>(self : Queue<T>) : PureQueue.Queue<T> {
    let pureQueue = PureQueue.empty<T>();
    let iter = self.values();
    var current = pureQueue;
    loop {
      switch (iter.next()) {
        case null { return current };
        case (?val) { current := PureQueue.pushBack(current, val) }
      }
    }
  };

  /// Converts an immutable, purely functional queue to a mutable queue.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  /// import PureQueue "mo:core/pure/Queue";
  ///
  /// persistent actor {
  ///   let pureQueue = PureQueue.fromIter<Nat>([1, 2, 3].vals());
  ///   let queue = Queue.fromPure<Nat>(pureQueue);
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// `n` denotes the number of elements stored in the queue.
  /// @deprecated M0235
  public func fromPure<T>(pureQueue : PureQueue.Queue<T>) : Queue<T> {
    let queue = empty<T>();
    let iter = pureQueue.values();
    loop {
      switch (iter.next()) {
        case null { return queue };
        case (?val) { pushBack(queue, val) }
      }
    }
  };

  /// Create a new empty mutable double-ended queue.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.empty<Text>();
  ///   assert Queue.size(queue) == 0;
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  /// Space: `O(1)`.
  public func empty<T>() : Queue<T> {
    { var front = null; var back = null; var size = 0 }
  };

  /// Creates a new queue with a single element.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.singleton<Nat>(123);
  ///   assert Queue.size(queue) == 1;
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func singleton<T>(element : T) : Queue<T> {
    let queue = empty<T>();
    pushBack(queue, element);
    queue
  };

  /// Removes all elements from the queue.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter<Nat>([1, 2, 3].vals());
  ///   Queue.clear(queue);
  ///   assert Queue.isEmpty(queue);
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func clear<T>(self : Queue<T>) {
    self.front := null;
    self.back := null;
    self.size := 0
  };

  /// Creates a deep copy of the queue.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   let original = Queue.fromIter<Nat>([1, 2, 3].vals());
  ///   let copy = Queue.clone(original);
  ///   Queue.clear(original);
  ///   assert Queue.size(original) == 0;
  ///   assert Queue.size(copy) == 3;
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// `n` denotes the number of elements stored in the queue.
  public func clone<T>(self : Queue<T>) : Queue<T> {
    let copy = empty<T>();
    for (element in self.values()) {
      pushBack(copy, element)
    };
    copy
  };

  /// Returns the number of elements in the queue.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter<Text>(["A", "B", "C"].vals());
  ///   assert Queue.size(queue) == 3;
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func size<T>(self : Queue<T>) : Nat {
    self.size
  };

  /// Returns `true` if the queue contains no elements.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.empty<Nat>();
  ///   assert Queue.isEmpty(queue);
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func isEmpty<T>(self : Queue<T>) : Bool {
    self.size == 0
  };

  /// Checks if an element exists in the queue using the provided equality function.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  /// import Nat "mo:core/Nat";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter<Nat>([1, 2, 3].vals());
  ///   assert Queue.contains(queue, Nat.equal, 2);
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(1)
  /// `n` denotes the number of elements stored in the queue.
  public func contains<T>(self : Queue<T>, equal : (implicit : (T, T) -> Bool), element : T) : Bool {
    for (existing in self.values()) {
      if (equal(existing, element)) {
        return true
      }
    };
    false
  };

  /// Returns the first element in the queue without removing it.
  /// Returns null if the queue is empty.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter<Nat>([1, 2, 3].vals());
  ///   assert Queue.peekFront(queue) == ?1;
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func peekFront<T>(self : Queue<T>) : ?T {
    switch (self.front) {
      case null null;
      case (?node) ?node.value
    }
  };

  /// Returns the last element in the queue without removing it.
  /// Returns null if the queue is empty.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter<Nat>([1, 2, 3].vals());
  ///   assert Queue.peekBack(queue) == ?3;
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func peekBack<T>(self : Queue<T>) : ?T {
    switch (self.back) {
      case null null;
      case (?node) ?node.value
    }
  };

  /// Adds an element to the front of the queue.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.empty<Nat>();
  ///   Queue.pushFront(queue, 1);
  ///   assert Queue.peekFront(queue) == ?1;
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func pushFront<T>(self : Queue<T>, element : T) {
    let node : Node<T> = {
      value = element;
      var next = self.front;
      var previous = null
    };
    switch (self.front) {
      case null {};
      case (?first) first.previous := ?node
    };
    self.front := ?node;
    switch (self.back) {
      case null self.back := ?node;
      case (?_) {}
    };
    self.size += 1
  };

  /// Adds an element to the back of the queue.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.empty<Nat>();
  ///   Queue.pushBack(queue, 1);
  ///   assert Queue.peekBack(queue) == ?1;
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func pushBack<T>(self : Queue<T>, element : T) {
    let node : Node<T> = {
      value = element;
      var next = null;
      var previous = self.back
    };
    switch (self.back) {
      case null {};
      case (?last) last.next := ?node
    };
    self.back := ?node;
    switch (self.front) {
      case null self.front := ?node;
      case (?_) {}
    };
    self.size += 1
  };

  /// Removes and returns the first element in the queue.
  /// Returns null if the queue is empty.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter<Nat>([1, 2, 3].vals());
  ///   assert Queue.popFront(queue) == ?1;
  ///   assert Queue.size(queue) == 2;
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func popFront<T>(self : Queue<T>) : ?T {
    switch (self.front) {
      case null null;
      case (?first) {
        self.front := first.next;
        switch (self.front) {
          case null { self.back := null };
          case (?newFirst) { newFirst.previous := null }
        };
        self.size -= 1;
        ?first.value
      }
    }
  };

  /// Removes and returns the last element in the queue.
  /// Returns null if the queue is empty.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter<Nat>([1, 2, 3].vals());
  ///   assert Queue.popBack(queue) == ?3;
  ///   assert Queue.size(queue) == 2;
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func popBack<T>(self : Queue<T>) : ?T {
    switch (self.back) {
      case null null;
      case (?last) {
        self.back := last.previous;
        switch (self.back) {
          case null { self.front := null };
          case (?newLast) { newLast.next := null }
        };
        self.size -= 1;
        ?last.value
      }
    }
  };

  /// Creates a new queue from an iterator.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter<Text>(["A", "B", "C"].vals());
  ///   assert Queue.size(queue) == 3;
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// `n` denotes the number of elements stored in the queue.
  public func fromIter<T>(iter : Iter.Iter<T>) : Queue<T> {
    let queue = empty<T>();
    for (element in iter) {
      pushBack(queue, element)
    };
    queue
  };

  /// Converts an iterator to a queue.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   transient let iter = ["A", "B", "C"].vals();
  ///
  ///   let queue = iter.toQueue<Text>();
  ///
  ///   assert Queue.size(queue) == 3;
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// `n` denotes the number of elements stored in the queue.
  public func toQueue<T>(self : Iter.Iter<T>) : Queue<T> {
    fromIter(self)
  };

  /// Creates a new queue from an array.
  /// Elements appear in the same order as in the array.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromArray<Text>(["A", "B", "C"]);
  ///   assert Queue.size(queue) == 3;
  ///   assert Queue.peekFront(queue) == ?"A";
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// `n` denotes the number of elements stored in the array.
  public func fromArray<T>(array : [T]) : Queue<T> {
    let queue = empty<T>();
    for (element in array.vals()) {
      pushBack(queue, element)
    };
    queue
  };

  public func fromVarArray<T>(array : [var T]) : Queue<T> {
    fromIter(array.values())
  };

  /// Creates a new immutable array containing all elements from the queue.
  /// Elements appear in the same order as in the queue (front to back).
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  /// import Array "mo:core/Array";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromArray<Text>(["A", "B", "C"]);
  ///   let array = Queue.toArray(queue);
  ///   assert array == ["A", "B", "C"];
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// `n` denotes the number of elements stored in the queue.
  public func toArray<T>(self : Queue<T>) : [T] {
    let iter = self.values();
    Array.tabulate<T>(
      self.size,
      func(i) {
        switch (iter.next()) {
          case null { Prim.trap("Queue.toArray(): unexpected end of iterator") };
          case (?value) { value }
        }
      }
    )
  };

  public func toVarArray<T>(self : Queue<T>) : [var T] {
    Array.toVarArray(toArray(self))
  };

  /// Returns an iterator over the elements in the queue.
  /// Iterates from front to back.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  /// persistent actor {
  ///   let queue = Queue.fromIter<Text>(["A", "B", "C"].vals());
  ///   transient let iter = queue.values();
  ///   assert iter.next() == ?"A";
  ///   assert iter.next() == ?"B";
  ///   assert iter.next() == ?"C";
  ///   assert iter.next() == null;
  /// }
  /// ```
  ///
  /// Runtime: O(1) for iterator creation, O(n) for full iteration
  /// Space: O(1)
  public func values<T>(self : Queue<T>) : Iter.Iter<T> {
    object {
      var current = self.front;

      public func next() : ?T {
        switch (current) {
          case null null;
          case (?node) {
            current := node.next;
            ?node.value
          }
        }
      }
    }
  };

  public func reverseValues<T>(self : Queue<T>) : Iter.Iter<T> {
    Iter.reverse(self.values())
  };

  /// Tests whether all elements in the queue satisfy the given predicate.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter<Nat>([2, 4, 6].vals());
  ///   assert Queue.all<Nat>(queue, func(x) { x % 2 == 0 });
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(1)
  public func all<T>(self : Queue<T>, predicate : T -> Bool) : Bool {
    for (element in self.values()) {
      if (not predicate(element)) {
        return false
      }
    };
    true
  };

  /// Tests whether any element in the queue satisfies the given predicate.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter<Nat>([1, 2, 3].vals());
  ///   assert Queue.any<Nat>(queue, func (x) { x > 2 });
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(1)
  /// `n` denotes the number of elements stored in the queue.
  public func any<T>(self : Queue<T>, predicate : T -> Bool) : Bool {
    for (element in self.values()) {
      if (predicate(element)) {
        return true
      }
    };
    false
  };

  /// Applies the given operation to all elements in the queue.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   var sum = 0;
  ///   let queue = Queue.fromIter<Nat>([1, 2, 3].vals());
  ///   Queue.forEach<Nat>(queue, func(x) { sum += x });
  ///   assert sum == 6;
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(1)
  /// `n` denotes the number of elements stored in the queue.
  public func forEach<T>(self : Queue<T>, operation : T -> ()) {
    for (element in self.values()) {
      operation(element)
    }
  };

  /// Creates a new queue by applying the given function to all elements.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter<Nat>([1, 2, 3].vals());
  ///   let doubled = Queue.map<Nat, Nat>(queue, func(x) { x * 2 });
  ///   assert Queue.peekFront(doubled) == ?2;
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// `n` denotes the number of elements stored in the queue.
  public func map<T, U>(self : Queue<T>, project : T -> U) : Queue<U> {
    let result = empty<U>();
    for (element in self.values()) {
      pushBack(result, project(element))
    };
    result
  };

  /// Creates a new queue containing only elements that satisfy the given predicate.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter<Nat>([1, 2, 3, 4].vals());
  ///   let evens = Queue.filter<Nat>(queue, func(x) { x % 2 == 0 });
  ///   assert Queue.size(evens) == 2;
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// `n` denotes the number of elements stored in the queue.
  public func filter<T>(self : Queue<T>, criterion : T -> Bool) : Queue<T> {
    let result = empty<T>();
    for (element in self.values()) {
      if (criterion(element)) {
        pushBack(result, element)
      }
    };
    result
  };

  /// Creates a new queue by applying the given function to all elements
  /// and keeping only the non-null results.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter<Nat>([1, 2, 3, 4].vals());
  ///   let evenDoubled = Queue.filterMap<Nat, Nat>(
  ///     queue,
  ///     func(x) {
  ///       if (x % 2 == 0) { ?(x * 2) } else  { null }
  ///     }
  ///   );
  ///   assert Queue.size(evenDoubled) == 2;
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// `n` denotes the number of elements stored in the queue.
  public func filterMap<T, U>(self : Queue<T>, project : T -> ?U) : Queue<U> {
    let result = empty<U>();
    for (element in self.values()) {
      switch (project(element)) {
        case null {};
        case (?newElement) pushBack(result, newElement)
      }
    };
    result
  };

  /// Compares two queues for equality using the provided equality function.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  /// import Nat "mo:core/Nat";
  ///
  /// persistent actor {
  ///   let queue1 = Queue.fromIter<Nat>([1, 2, 3].vals());
  ///   let queue2 = Queue.fromIter<Nat>([1, 2, 3].vals());
  ///   assert Queue.equal(queue1, queue2, Nat.equal);
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(1)
  /// `n` denotes the number of elements stored in the queue.
  public func equal<T>(self : Queue<T>, other : Queue<T>, equal : (implicit : (T, T) -> Bool)) : Bool {
    if (size(self) != size(other)) {
      return false
    };
    let iterator1 = self.values();
    let iterator2 = other.values();
    loop {
      let element1 = iterator1.next();
      let element2 = iterator2.next();
      switch (element1, element2) {
        case (null, null) {
          return true
        };
        case (?element1, ?element2) {
          if (not equal(element1, element2)) {
            return false
          }
        };
        case _ { return false }
      }
    }
  };

  /// Converts a queue to its string representation using the provided element formatter.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  /// import Nat "mo:core/Nat";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter<Nat>([1, 2, 3].vals());
  ///   assert Queue.toText(queue, Nat.toText) == "Queue[1, 2, 3]";
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// `n` denotes the number of elements stored in the queue.
  public func toText<T>(self : Queue<T>, format : (implicit : (toText : T -> Text))) : Text {
    var text = "Queue[";
    var sep = "";
    for (element in self.values()) {
      text #= sep # format(element);
      sep := ", "
    };
    text #= "]";
    text
  };

  /// Compares two queues using the provided comparison function.
  /// Returns #less, #equal, or #greater.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:core/Queue";
  /// import Nat "mo:core/Nat";
  ///
  /// persistent actor {
  ///   let queue1 = Queue.fromIter<Nat>([1, 2].vals());
  ///   let queue2 = Queue.fromIter<Nat>([1, 2, 3].vals());
  ///   assert Queue.compare(queue1, queue2, Nat.compare) == #less;
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(1)
  /// `n` denotes the number of elements stored in the queue.
  public func compare<T>(self : Queue<T>, other : Queue<T>, compare : (implicit : (T, T) -> Order.Order)) : Order.Order {
    let iterator1 = self.values();
    let iterator2 = other.values();
    loop {
      switch (iterator1.next(), iterator2.next()) {
        case (null, null) return #equal;
        case (null, _) return #less;
        case (_, null) return #greater;
        case (?element1, ?element2) {
          let comparison = compare(element1, element2);
          if (comparison != #equal) {
            return comparison
          }
        }
      }
    }
  }
}
