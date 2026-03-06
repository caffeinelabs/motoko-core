/// A mutable priority queue of elements.
/// Always returns the element with the highest priority first,
/// as determined by a user-provided comparison function.
///
/// Typical use cases include:
/// * Task scheduling (highest-priority task first)
/// * Event simulation
/// * Pathfinding algorithms (e.g. Dijkstra, A*)
///
/// Example:
/// ```motoko
/// import PriorityQueue "mo:core/PriorityQueue";
/// import Nat "mo:core/Nat";
///
/// persistent actor {
///   let pq = PriorityQueue.empty<Nat>();
///   PriorityQueue.push(pq, Nat.compare, 5);
///   PriorityQueue.push(pq, Nat.compare, 10);
///   PriorityQueue.push(pq, Nat.compare, 3);
///   assert PriorityQueue.pop(pq, Nat.compare) == ?10;
///   assert PriorityQueue.pop(pq, Nat.compare) == ?5;
///   assert PriorityQueue.pop(pq, Nat.compare) == ?3;
///   assert PriorityQueue.pop(pq, Nat.compare) == null;
/// }
/// ```
///
/// Internally implemented as a binary heap stored in a core library `List`.
///
/// Performance:
/// * Runtime: `O(log n)` for `push` and `pop` (amortized).
/// * Runtime: `O(1)` for `peek`, `clear`, `size`, and `isEmpty`.
/// * Space: `O(n)`, where `n` is the number of stored elements.
///
/// Implementation note (due to `List`):
/// * There is an additive memory overhead of `O(sqrt(n))`.
/// * For `push` and `pop`, the amortized time is `O(log n)`,
///   but the worst case can involve an extra `O(sqrt(n))` step.
import List "List";
import Types "Types";
import Order "Order";

module {
  public type PriorityQueue<T> = Types.PriorityQueue<T>;

  /// Returns an empty priority queue.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/PriorityQueue";
  ///
  /// let pq = PriorityQueue.empty<Nat>();
  /// assert PriorityQueue.isEmpty(pq);
  /// ```
  ///
  /// Runtime: `O(1)`. Space: `O(1)`.
  public func empty<T>() : PriorityQueue<T> = {
    heap = List.empty<T>()
  };

  /// Returns a priority queue containing a single element.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/PriorityQueue";
  ///
  /// let pq = PriorityQueue.singleton<Nat>(42);
  /// assert PriorityQueue.peek(pq) == ?42;
  /// ```
  ///
  /// Runtime: `O(1)`. Space: `O(1)`.
  public func singleton<T>(element : T) : PriorityQueue<T> = {
    heap = List.singleton(element)
  };

  /// Returns the number of elements in the priority queue.
  ///
  /// Runtime: `O(1)`.
  public func size<T>(self : PriorityQueue<T>) : Nat = List.size(self.heap);

  /// Returns `true` iff the priority queue is empty.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/PriorityQueue";
  /// import Nat "mo:core/Nat";
  ///
  /// let pq = PriorityQueue.empty<Nat>();
  /// assert PriorityQueue.isEmpty(pq);
  /// PriorityQueue.push(pq, Nat.compare, 5);
  /// assert not PriorityQueue.isEmpty(pq);
  /// ```
  ///
  /// Runtime: `O(1)`. Space: `O(1)`.
  public func isEmpty<T>(self : PriorityQueue<T>) : Bool = List.isEmpty(self.heap);

  /// Removes all elements from the priority queue.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/PriorityQueue";
  /// import Nat "mo:core/Nat";
  ///
  ///
  /// let pq = PriorityQueue.empty<Nat>();
  /// PriorityQueue.push(pq, Nat.compare, 5);
  /// PriorityQueue.push(pq, Nat.compare, 10);
  /// assert not PriorityQueue.isEmpty(pq);
  /// PriorityQueue.clear(pq);
  /// assert PriorityQueue.isEmpty(pq);
  /// ```
  ///
  /// Runtime: `O(1)`. Space: `O(1)`.
  public func clear<T>(self : PriorityQueue<T>) = List.clear(self.heap);

  /// Inserts a new element into the priority queue.
  ///
  /// `compare` – comparison function that defines priority ordering.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/PriorityQueue";
  /// import Nat "mo:core/Nat";
  ///
  /// let pq = PriorityQueue.empty<Nat>();
  /// PriorityQueue.push(pq, Nat.compare, 5);
  /// PriorityQueue.push(pq, Nat.compare, 10);
  /// assert PriorityQueue.peek(pq) == ?10;
  /// ```
  ///
  /// Runtime: `O(log n)`. Space: `O(1)`.
  public func push<T>(
    self : PriorityQueue<T>,
    compare : (implicit : (T, T) -> Order.Order),
    element : T
  ) {
    let heap = self.heap;
    List.add(heap, element);
    var index : Nat = List.size(heap) - 1;
    while (index > 0) {
      let parentId = (index - 1) : Nat / 2;
      let parentVal = List.at(heap, parentId);
      if (compare(element, parentVal) == #greater) {
        List.put(heap, index, parentVal);
        index := parentId
      } else {
        List.put(heap, index, element);
        return
      }
    };
    List.put(heap, 0, element)
  };

  /// Returns the element with the highest priority, without removing it.
  /// Returns `null` if the queue is empty.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/PriorityQueue";
  ///
  /// let pq = PriorityQueue.singleton<Nat>(42);
  /// assert PriorityQueue.peek(pq) == ?42;
  /// ```
  ///
  /// Runtime: `O(1)`. Space: `O(1)`.
  public func peek<T>(self : PriorityQueue<T>) : ?T = List.get(self.heap, 0);

  /// Removes and returns the element with the highest priority.
  /// Returns `null` if the queue is empty.
  ///
  /// `compare` – comparison function that defines priority ordering.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/PriorityQueue";
  /// import Nat "mo:core/Nat";
  ///
  /// let pq = PriorityQueue.empty<Nat>();
  /// PriorityQueue.push(pq, Nat.compare, 5);
  /// PriorityQueue.push(pq, Nat.compare, 10);
  /// assert PriorityQueue.pop(pq, Nat.compare) == ?10;
  /// ```
  ///
  /// Runtime: `O(log n)`. Space: `O(1)`.
  public func pop<T>(
    self : PriorityQueue<T>,
    compare : (implicit : (T, T) -> Order.Order)
  ) : ?T {
    let heap = self.heap;
    if (List.isEmpty(heap)) {
      return null
    };
    let top = List.get(heap, 0);
    let lastIndex : Nat = List.size(heap) - 1;
    let lastElem = List.at(heap, lastIndex);

    var index = 0;
    loop {
      var best = lastIndex;
      let left = 2 * index + 1;
      var bestElem = lastElem;
      if (left < lastIndex) {
        let leftElem = List.at(heap, left);
        if (compare(leftElem, lastElem) == #greater) {
          best := left;
          bestElem := leftElem
        }
      };
      let right = left + 1;
      if (right < lastIndex) {
        let rightElem = List.at(heap, right);
        if (compare(rightElem, bestElem) == #greater) {
          best := right;
          bestElem := rightElem
        }
      };
      if (best == lastIndex) {
        List.put(heap, index, lastElem);
        ignore List.removeLast(heap);
        return top
      };
      List.put(heap, index, bestElem);
      index := best
    }
  };

  /// Creates a new priority queue from an iterator.
  ///
  /// `compare` – comparison function that defines priority ordering.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/PriorityQueue";
  /// import Nat "mo:core/Nat";
  ///
  /// let pq = PriorityQueue.fromIter<Nat>([5, 10, 3].values(), Nat.compare);
  /// assert PriorityQueue.size(pq) == 3;
  /// assert PriorityQueue.peek(pq) == ?10;
  /// ```
  ///
  /// Runtime: `O(n * log(n))`.
  /// Space: `O(n)`.
  /// `n` denotes the number of elements in the iterator.
  public func fromIter<T>(iter : Types.Iter<T>, compare : (implicit : (T, T) -> Order.Order)) : PriorityQueue<T> {
    let pq = empty<T>();
    for (element in iter) {
      push(pq, element)
    };
    pq
  };

  /// Returns an iterator that yields elements in descending priority order
  /// (highest priority first, matching `pop` semantics).
  ///
  /// The original queue is not modified. Internally clones the heap
  /// and pops from the clone on each `next()` call.
  ///
  /// `compare` – comparison function that defines priority ordering.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/PriorityQueue";
  /// import Nat "mo:core/Nat";
  /// import Iter "mo:core/Iter";
  ///
  /// let pq = PriorityQueue.fromIter<Nat>([5, 10, 3].values(), Nat.compare);
  /// assert Iter.toArray(PriorityQueue.values(pq, Nat.compare)) == [10, 5, 3];
  /// ```
  ///
  /// Runtime: `O(n)` to create the iterator, `O(log n)` per `next()` call.
  /// Space: `O(n)` for the internal clone.
  /// `n` denotes the number of elements in the priority queue.
  public func values<T>(self : PriorityQueue<T>, compare : (implicit : (T, T) -> Order.Order)) : Types.Iter<T> {
    let clone : PriorityQueue<T> = { heap = self.heap.clone() };
    object {
      public func next() : ?T {
        pop(clone)
      }
    }
  };

  /// Returns a new priority queue containing only elements that satisfy the given predicate.
  ///
  /// `compare` – comparison function that defines priority ordering.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/PriorityQueue";
  /// import Nat "mo:core/Nat";
  ///
  /// let pq = PriorityQueue.fromIter<Nat>([1, 5, 10, 3].values(), Nat.compare);
  /// let filtered = PriorityQueue.filter(pq, Nat.compare, func(x : Nat) : Bool { x > 4 });
  /// assert PriorityQueue.size(filtered) == 2;
  /// assert PriorityQueue.peek(filtered) == ?10;
  /// ```
  ///
  /// Runtime: `O(n * log(n))`.
  /// Space: `O(n)`.
  /// `n` denotes the number of elements in the priority queue.
  public func filter<T>(self : PriorityQueue<T>, compare : (implicit : (T, T) -> Order.Order), predicate : T -> Bool) : PriorityQueue<T> {
    let result = empty<T>();
    for (element in self.heap.values()) {
      if (predicate(element)) {
        push(result, element)
      }
    };
    result
  }
}
