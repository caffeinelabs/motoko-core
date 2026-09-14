/// A mutable priority queue of elements.
/// !!! In contrast to the implementation in `src/PriorityQueue.mo`, this one
/// is a wrapper over `Set`. !!!
///
/// Always returns the element with the highest priority first,
/// as determined by a user-provided comparison function.
///
/// Internally implemented as a wrapper over a core library `Set<(T, Nat)>`.
/// The `Nat` values serve as unique tags to distinguish elements
/// with equal priority, since a `Set` cannot store duplicates.
///
/// Performance:
/// * Runtime: `O(log n)` for `push`, `pop` and `peek`.
/// * Runtime: `O(1)` for `clear`, `size`, and `isEmpty`.
/// * Space: `O(n)`, where `n` is the number of stored elements.
import Set "../../src/Set";
import Order "../../src/Order";
import Nat "../../src/Nat";
import { Tuple2 } "../../src/Tuples";

module {
  public type PriorityQueue<T> = {
    set : Set.Set<(T, Nat)>;
    var counter : Nat
  };

  /// Returns an empty priority queue.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/internal/PriorityQueueSet";
  ///
  /// let pq = PriorityQueue.empty<Nat>();
  /// assert PriorityQueue.isEmpty(pq);
  /// ```
  ///
  /// Runtime: `O(1)`. Space: `O(1)`.
  public func empty<T>() : PriorityQueue<T> = {
    set = Set.empty();
    var counter = 0
  };

  /// Returns a priority queue containing a single element.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/internal/PriorityQueueSet";
  ///
  /// let pq = PriorityQueue.singleton<Nat>(42);
  /// assert PriorityQueue.peek(pq) == ?42;
  /// ```
  ///
  /// Runtime: `O(1)`. Space: `O(1)`.
  public func singleton<T>(element : T) : PriorityQueue<T> = {
    set = Set.singleton((element, 0));
    var counter = 1
  };

  /// Returns the number of elements in the priority queue.
  ///
  /// Runtime: `O(1)`.
  public func size<T>(priorityQueue : PriorityQueue<T>) : Nat = Set.size(priorityQueue.set);

  /// Returns `true` iff the priority queue is empty.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/internal/PriorityQueueSet";
  /// import Nat "mo:core/Nat";
  ///
  /// let pq = PriorityQueue.empty<Nat>();
  /// assert PriorityQueue.isEmpty(pq);
  /// PriorityQueue.push(pq, Nat.compare, 5);
  /// assert not PriorityQueue.isEmpty(pq);
  /// ```
  ///
  /// Runtime: `O(1)`. Space: `O(1)`.
  public func isEmpty<T>(priorityQueue : PriorityQueue<T>) : Bool = Set.isEmpty(priorityQueue.set);

  /// Removes all elements from the priority queue.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/internal/PriorityQueueSet";
  /// import Nat "mo:core/Nat";
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
  public func clear<T>(priorityQueue : PriorityQueue<T>) = Set.clear(priorityQueue.set);

  /// Inserts a new element into the priority queue.
  ///
  /// `compare` – comparison function that defines priority ordering.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/internal/PriorityQueueSet";
  /// import Nat "mo:core/Nat";
  ///
  /// let pq = PriorityQueue.empty<Nat>();
  /// PriorityQueue.push(pq, Nat.compare, 5);
  /// PriorityQueue.push(pq, Nat.compare, 10);
  /// assert PriorityQueue.peek(pq) == ?10;
  /// ```
  ///
  /// Runtime: `O(log n)`. Space: `O(log n)`.
  public func push<T>(priorityQueue : PriorityQueue<T>, compare : (T, T) -> Order.Order, element : T) {
    Set.add(priorityQueue.set, Tuple2.makeCompare(compare, Nat.compare), (element, priorityQueue.counter));
    priorityQueue.counter += 1
  };

  /// Returns the element with the highest priority, without removing it.
  /// Returns `null` if the queue is empty.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/internal/PriorityQueueSet";
  /// import Nat "mo:core/Nat";
  ///
  /// let pq = PriorityQueue.singleton<Nat>(42);
  /// assert PriorityQueue.peek(pq) == ?42;
  /// ```
  ///
  /// Runtime: `O(log n)`. Space: `O(1)`.
  public func peek<T>(priorityQueue : PriorityQueue<T>) : ?T = do ? {
    let (element, _) = Set.max(priorityQueue.set)!;
    element
  };

  /// Removes and returns the element with the highest priority.
  /// Returns `null` if the queue is empty.
  ///
  /// `compare` – comparison function that defines priority ordering.
  ///
  /// Example:
  /// ```motoko
  /// import PriorityQueue "mo:core/internal/PriorityQueueSet";
  /// import Nat "mo:core/Nat";
  ///
  /// let pq = PriorityQueue.empty<Nat>();
  /// PriorityQueue.push(pq, Nat.compare, 5);
  /// PriorityQueue.push(pq, Nat.compare, 10);
  /// assert PriorityQueue.pop(pq, Nat.compare) == ?10;
  /// ```
  ///
  /// Runtime: `O(log n)`. Space: `O(log n)`.
  public func pop<T>(priorityQueue : PriorityQueue<T>, compare : (T, T) -> Order.Order) : ?T = do ? {
    let (element, nonce) = Set.max(priorityQueue.set)!;
    Set.remove(priorityQueue.set, Tuple2.makeCompare(compare, Nat.compare), (element, nonce));
    element
  }
}
