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
///   pq.push(5);
///   pq.push(10);
///   pq.push(3);
///   assert pq.pop() == ?10;
///   assert pq.pop() == ?5;
///   assert pq.pop() == ?3;
///   assert pq.pop() == null;
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
  /// assert pq.isEmpty();
  /// ```
  ///
  /// Runtime: `O(1)`. Space: `O(1)`.
  public func empty<T>() : PriorityQueue<T> = {
    heap = List.empty()
  };

  /// Returns a priority queue containing a single element.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/PriorityQueue";
  ///
  /// let pq = PriorityQueue.singleton<Nat>(42);
  /// assert pq.peek() == ?42;
  /// ```
  ///
  /// Runtime: `O(1)`. Space: `O(1)`.
  public func singleton<T>(element : T) : PriorityQueue<T> = {
    heap = List.singleton(element)
  };

  /// Returns the number of elements in the priority queue.
  ///
  /// Runtime: `O(1)`.
  public func size<T>(self : PriorityQueue<T>) : Nat = self.heap.size();

  /// Returns `true` iff the priority queue is empty.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/PriorityQueue";
  /// import Nat "mo:core/Nat";
  ///
  /// let pq = PriorityQueue.empty<Nat>();
  /// assert pq.isEmpty();
  /// pq.push(5);
  /// assert not pq.isEmpty();
  /// ```
  ///
  /// Runtime: `O(1)`. Space: `O(1)`.
  public func isEmpty<T>(self : PriorityQueue<T>) : Bool = self.heap.isEmpty();

  /// Removes all elements from the priority queue.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/PriorityQueue";
  /// import Nat "mo:core/Nat";
  ///
  /// let pq = PriorityQueue.empty<Nat>();
  /// pq.push(5);
  /// pq.push(10);
  /// assert not pq.isEmpty();
  /// pq.clear();
  /// assert pq.isEmpty();
  /// ```
  ///
  /// Runtime: `O(1)`. Space: `O(1)`.
  public func clear<T>(self : PriorityQueue<T>) = self.heap.clear();

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
  /// pq.push(5);
  /// pq.push(10);
  /// assert pq.peek() == ?10;
  /// ```
  ///
  /// Runtime: `O(log n)`. Space: `O(1)`.
  public func push<T>(
    self : PriorityQueue<T>,
    compare : (implicit : (T, T) -> Order.Order),
    element : T
  ) {
    let heap = self.heap;
    heap.add(element);
    var index : Nat = heap.size() - 1;
    while (index > 0) {
      let parentId = (index - 1) : Nat / 2;
      let parentVal = heap.at(parentId);
      if (compare(element, parentVal) == #greater) {
        heap.put(index, parentVal);
        index := parentId
      } else {
        heap.put(index, element);
        return
      }
    };
    heap.put(0, element)
  };

  /// Returns the element with the highest priority, without removing it.
  /// Returns `null` if the queue is empty.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/PriorityQueue";
  ///
  /// let pq = PriorityQueue.singleton<Nat>(42);
  /// assert pq.peek() == ?42;
  /// ```
  ///
  /// Runtime: `O(1)`. Space: `O(1)`.
  public func peek<T>(self : PriorityQueue<T>) : ?T = self.heap.get(0);

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
  /// pq.push(5);
  /// pq.push(10);
  /// assert pq.pop() == ?10;
  /// ```
  ///
  /// Runtime: `O(log n)`. Space: `O(1)`.
  public func pop<T>(
    self : PriorityQueue<T>,
    compare : (implicit : (T, T) -> Order.Order)
  ) : ?T {
    let heap = self.heap;
    if (heap.isEmpty()) {
      return null
    };
    let top = heap.get(0);
    let lastIndex : Nat = heap.size() - 1;
    let lastElem = heap.at(lastIndex);

    var index = 0;
    loop {
      var best = lastIndex;
      let left = 2 * index + 1;
      var bestElem = lastElem;
      if (left < lastIndex) {
        let leftElem = heap.at(left);
        if (compare(leftElem, lastElem) == #greater) {
          best := left;
          bestElem := leftElem
        }
      };
      let right = left + 1;
      if (right < lastIndex) {
        let rightElem = heap.at(right);
        if (compare(rightElem, bestElem) == #greater) {
          best := right;
          bestElem := rightElem
        }
      };
      if (best == lastIndex) {
        heap.put(index, lastElem);
        ignore heap.removeLast();
        return top
      };
      heap.put(index, bestElem);
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
  /// let pq = PriorityQueue.fromIter([5, 10, 3].values(), Nat.compare);
  /// assert pq.size() == 3;
  /// assert pq.peek() == ?10;
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

  /// Creates a copy of the priority queue.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/PriorityQueue";
  /// import Nat "mo:core/Nat";
  ///
  /// let original = PriorityQueue.fromIter([5, 10, 3].values(), Nat.compare);
  /// let copy = original.clone();
  /// assert copy.pop() == ?10;
  /// assert original.size() == 3;
  /// ```
  ///
  /// Runtime: `O(n)`. Space: `O(n)`.
  /// `n` denotes the number of elements in the priority queue.
  public func clone<T>(self : PriorityQueue<T>) : PriorityQueue<T> = {
    heap = self.heap.clone()
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
  /// let pq = PriorityQueue.fromIter([5, 10, 3].values(), Nat.compare);
  /// assert pq.values().toArray() == [10, 5, 3];
  /// ```
  ///
  /// Runtime: `O(n)` to create the iterator, `O(log n)` per `next()` call.
  /// Space: `O(n)` for the internal clone.
  /// `n` denotes the number of elements in the priority queue.
  public func values<T>(self : PriorityQueue<T>, compare : (implicit : (T, T) -> Order.Order)) : Types.Iter<T> {
    let copy : PriorityQueue<T> = clone(self);
    object {
      public func next() : ?T {
        pop(copy)
      }
    }
  }
}
