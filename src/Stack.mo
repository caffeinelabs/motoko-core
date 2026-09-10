/// A mutable stack data structure.
/// Elements can be pushed on top of the stack
/// and removed from top of the stack (LIFO).
///
/// Example:
/// ```motoko
/// import Stack "mo:core/Stack";
/// import Debug "mo:core/Debug";
///
/// persistent actor {
///   let levels = Stack.empty<Text>();
///   levels.push("Inner");
///   levels.push("Middle");
///   levels.push("Outer");
///   assert levels.pop() == ?"Outer";
///   assert levels.pop() == ?"Middle";
///   assert levels.pop() == ?"Inner";
///   assert levels.pop() == null;
/// }
/// ```
///
/// The internal implementation is a singly-linked list.
///
/// Performance:
/// * Runtime: `O(1)` for push, pop, and peek operation.
/// * Space: `O(n)`.
/// `n` denotes the number of elements stored on the stack.

// TODO: optimize or re-use pure/List operations (e.g. for `any` etc)

import Order "Order";
import Iter "Iter";
import Types "Types";
import PureList "pure/List";

module {
  type List<T> = Types.Pure.List<T>;
  public type Stack<T> = Types.Stack<T>;

  /// Convert a mutable stack to an immutable, purely functional list.
  /// Please note that functional lists are ordered like stacks (FIFO).
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  /// import PureList "mo:core/pure/List";
  /// import Iter "mo:core/Iter";
  ///
  /// persistent actor {
  ///   let mutableStack = Stack.empty<Nat>();
  ///   mutableStack.push(3);
  ///   mutableStack.push(2);
  ///   mutableStack.push(1);
  ///   let immutableList = mutableStack.toPure();
  ///   assert Iter.toArray(PureList.values(immutableList)) == [1, 2, 3];
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  /// Space: `O(1)`.
  /// where `n` denotes the number of elements stored in the stack.
  /// @deprecated M0235
  public func toPure<T>(self : Stack<T>) : PureList.List<T> {
    self.top
  };

  public func toArray<T>(self : Stack<T>) : [T] {
    Iter.toArray(values(self))
  };

  public func toVarArray<T>(self : Stack<T>) : [var T] {
    Iter.toVarArray(values(self))
  };

  /// Convert an immutable, purely functional list to a mutable stack.
  /// Please note that functional lists are ordered like stacks (FIFO).
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  /// import PureList "mo:core/pure/List";
  /// import Iter "mo:core/Iter";
  ///
  /// persistent actor {
  ///   let immutableList = PureList.fromIter([1, 2, 3].values());
  ///   let mutableStack = Stack.fromPure<Nat>(immutableList);
  ///   assert Iter.toArray(mutableStack.values()) == [1, 2, 3];
  /// }
  /// ```
  ///
  /// Runtime: `O(n)`.
  /// Space: `O(n)`.
  /// where `n` denotes the number of elements stored in the queue.
  /// @deprecated M0235
  public func fromPure<T>(list : PureList.List<T>) : Stack<T> {
    var size = 0;
    var cur = list;
    loop {
      switch cur {
        case (?(_, next)) {
          size += 1;
          cur := next
        };
        case null {
          return { var top = list; var size }
        }
      }
    }
  };

  public func fromVarArray<T>(array : [var T]) : Stack<T> {
    fromIter(array.values())
  };

  public func fromArray<T>(array : [T]) : Stack<T> {
    fromIter(array.values())
  };

  /// Create a new empty mutable stack.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  /// import Nat "mo:core/Nat";
  ///
  /// persistent actor {
  ///   let stack = Stack.empty<Text>();
  ///   assert stack.size() == 0;
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  /// Space: `O(1)`.
  public func empty<T>() : Stack<T> {
    {
      var top = null;
      var size = 0
    }
  };

  /// Creates a new stack with `size` elements by applying the `generator` function to indices `[0..size-1]`.
  /// Elements are pushed in ascending index order.
  /// Which means that the generated element with the index `0` will be at the bottom of the stack.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  /// import Iter "mo:core/Iter";
  ///
  /// persistent actor {
  ///   let stack = Stack.tabulate<Nat>(3, func(i) { 2 * i });
  ///   assert Iter.toArray(stack.values()) == [4, 2, 0];
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// where `n` denotes the number of elements stored on the stack and
  /// assuming that `generator` has O(1) costs.
  public func tabulate<T>(size : Nat, generator : Nat -> T) : Stack<T> {
    let stack = empty<T>();
    var index = 0;
    while (index < size) {
      let element = generator(index);
      push(stack, element);
      index += 1
    };
    stack
  };

  /// Creates a new stack containing a single element.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.singleton("motoko");
  ///   assert stack.peek() == ?"motoko";
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func singleton<T>(element : T) : Stack<T> {
    let stack = empty<T>();
    push(stack, element);
    stack
  };

  /// Removes all elements from the stack.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter<Nat>([3, 2, 1].values());
  ///   stack.clear();
  ///   assert stack.isEmpty();
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func clear<T>(self : Stack<T>) {
    self.top := null;
    self.size := 0
  };

  /// Creates a deep copy of the stack with the same elements in the same order.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  /// import Nat "mo:core/Nat";
  ///
  /// persistent actor {
  ///   let original = Stack.fromIter<Nat>([3, 2, 1].values());
  ///   let copy = original.clone();
  ///   assert copy.equal(original, Nat.equal);
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// where `n` denotes the number of elements stored on the stack.
  public func clone<T>(self : Stack<T>) : Stack<T> {
    let copy = empty<T>();
    for (element in values(self)) {
      push(copy, element)
    };
    reverse(copy);
    copy
  };

  /// Returns true if the stack contains no elements.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.empty<Nat>();
  ///   assert stack.isEmpty();
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func isEmpty<T>(self : Stack<T>) : Bool {
    self.size == 0
  };

  /// Returns the number of elements on the stack.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter<Nat>([3, 2, 1].values());
  ///   assert stack.size() == 3;
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func size<T>(self : Stack<T>) : Nat {
    self.size
  };

  /// Returns true if the stack contains the specified element.
  /// Uses the provided equality function to compare elements.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  /// import Nat "mo:core/Nat";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter<Nat>([3, 2, 1].values());
  ///   assert stack.contains(2);
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(1)
  /// where `n` denotes the number of elements stored on the stack and assuming
  /// that `equal` has O(1) costs.
  public func contains<T>(self : Stack<T>, equal : (implicit : (T, T) -> Bool), element : T) : Bool {
    for (existing in values(self)) {
      if (equal(existing, element)) {
        return true
      }
    };
    false
  };

  public func reverseValues<T>(self : Stack<T>) : Iter.Iter<T> {
    Iter.reverse(values(self))
  };

  /// Pushes a new element onto the top of the stack.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.empty<Nat>();
  ///   stack.push(42);
  ///   assert stack.peek() == ?42;
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func push<T>(self : Stack<T>, value : T) {
    self.top := ?(value, self.top);
    self.size += 1
  };

  /// Returns the top element of the stack without removing it.
  /// Returns null if the stack is empty.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.empty<Nat>();
  ///   stack.push(3);
  ///   stack.push(2);
  ///   stack.push(1);
  ///   assert stack.peek() == ?1;
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func peek<T>(self : Stack<T>) : ?T {
    switch (self.top) {
      case null null;
      case (?(value, _)) ?value
    }
  };

  /// Removes and returns the top element of the stack.
  /// Returns null if the stack is empty.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.empty<Nat>();
  ///   stack.push(3);
  ///   stack.push(2);
  ///   stack.push(1);
  ///   assert stack.pop() == ?1;
  ///   assert stack.pop() == ?2;
  ///   assert stack.pop() == ?3;
  ///   assert stack.pop() == null;
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func pop<T>(self : Stack<T>) : ?T {
    switch (self.top) {
      case null null;
      case (?(value, next)) {
        self.top := next;
        self.size -= 1;
        ?value
      }
    }
  };

  /// Returns the element at the specified position from the top of the stack.
  /// Returns null if position is out of bounds.
  /// Position 0 is the top of the stack.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.empty<Char>();
  ///   stack.push('c');
  ///   stack.push('b');
  ///   stack.push('a');
  ///   assert stack.get(0) == ?'a';
  ///   assert stack.get(1) == ?'b';
  ///   assert stack.get(2) == ?'c';
  ///   assert stack.get(3) == null;
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(1)
  /// where `n` denotes the number of elements stored on the stack.
  public func get<T>(self : Stack<T>, position : Nat) : ?T {
    var index = 0;
    var current = self.top;
    while (index < position) {
      switch (current) {
        case null return null;
        case (?(_, next)) {
          current := next
        }
      };
      index += 1
    };
    switch (current) {
      case null null;
      case (?(value, _)) ?value
    }
  };

  /// Reverses the order of elements in the stack.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.empty<Nat>();
  ///   stack.push(3);
  ///   stack.push(2);
  ///   stack.push(1);
  ///   stack.reverse();
  ///   assert stack.pop() == ?3;
  ///   assert stack.pop() == ?2;
  ///   assert stack.pop() == ?1;
  ///   assert stack.pop() == null;
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// where `n` denotes the number of elements stored on the stack.
  public func reverse<T>(self : Stack<T>) {
    var last : List<T> = null;
    for (element in values(self)) {
      last := ?(element, last)
    };
    self.top := last
  };

  /// Returns an iterator over the elements in the stack, from top to bottom.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  /// import Nat "mo:core/Nat";
  /// import Iter "mo:core/Iter";
  ///
  /// persistent actor {
  ///   let stack = Stack.empty<Nat>();
  ///   stack.push(3);
  ///   stack.push(2);
  ///   stack.push(1);
  ///   assert Iter.toArray(stack.values()) == [1, 2, 3];
  /// }
  /// ```
  ///
  /// Runtime: O(1) for iterator creation, O(n) for full traversal
  /// Space: O(1)
  /// where `n` denotes the number of elements stored on the stack.
  public func values<T>(self : Stack<T>) : Types.Iter<T> {
    object {
      var current = self.top;

      public func next() : ?T {
        switch (current) {
          case null null;
          case (?(value, next)) {
            current := next;
            ?value
          }
        }
      }
    }
  };

  /// Returns true if all elements in the stack satisfy the predicate.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter<Nat>([2, 4, 6].values());
  ///   assert stack.all<Nat>(func(n) = n % 2 == 0);
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(1)
  /// where `n` denotes the number of elements stored on the stack and
  /// assuming that `predicate` has O(1) costs.
  public func all<T>(self : Stack<T>, predicate : T -> Bool) : Bool {
    for (element in values(self)) {
      if (not predicate(element)) {
        return false
      }
    };
    true
  };

  /// Returns true if any element in the stack satisfies the predicate.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter<Nat>([3, 2, 1].values());
  ///   assert stack.any<Nat>(func(n) = n == 2);
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(1)
  /// where `n` denotes the number of elements stored on the stack and
  /// assuming `predicate` has O(1) costs.
  public func any<T>(self : Stack<T>, predicate : T -> Bool) : Bool {
    for (element in values(self)) {
      if (predicate(element)) {
        return true
      }
    };
    false
  };

  /// Applies the operation to each element in the stack, from top to bottom.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  /// import Nat "mo:core/Nat";
  /// import Debug "mo:core/Debug";
  ///
  /// persistent actor {
  ///   let stack = Stack.empty<Nat>();
  ///   stack.push(3);
  ///   stack.push(2);
  ///   stack.push(1);
  ///   var text = "";
  ///   stack.forEach<Nat>(func(n) = text #= Nat.toText(n));
  ///   assert text == "123";
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(1)
  /// where `n` denotes the number of elements stored on the stack and
  /// assuming that `operation` has O(1) costs.
  public func forEach<T>(self : Stack<T>, operation : T -> ()) {
    for (element in values(self)) {
      operation(element)
    }
  };

  /// Creates a new stack by applying the projection function to each element.
  /// Maintains the original order of elements.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  /// import Iter "mo:core/Iter";
  ///
  /// persistent actor {
  ///   let stack = Stack.empty<Nat>();
  ///   stack.push(3);
  ///   stack.push(2);
  ///   stack.push(1);
  ///   let doubled = stack.map<Nat, Nat>(func(n) { 2 * n });
  ///   assert doubled.get(0) == ?2;
  ///   assert doubled.get(1) == ?4;
  ///   assert doubled.get(2) == ?6;
  ///   assert doubled.get(3) == null;
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// where `n` denotes the number of elements stored on the stack and
  /// assuming that `project` has O(1) costs.
  public func map<T, U>(self : Stack<T>, project : T -> U) : Stack<U> {
    let result = empty<U>();
    for (element in values(self)) {
      push(result, project(element))
    };
    reverse(result);
    result
  };

  /// Creates a new stack containing only elements that satisfy the predicate.
  /// Maintains the relative order of elements.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.empty<Nat>();
  ///   stack.push(4);
  ///   stack.push(3);
  ///   stack.push(2);
  ///   stack.push(1);
  ///   let evens = stack.filter(func(n) { n % 2 == 0 });
  ///   assert evens.pop() == ?2;
  ///   assert evens.pop() == ?4;
  ///   assert evens.pop() == null;
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// where `n` denotes the number of elements stored on the stack and
  /// assuming `predicate` has O(1) costs.
  public func filter<T>(self : Stack<T>, predicate : T -> Bool) : Stack<T> {
    let result = empty<T>();
    for (element in values(self)) {
      if (predicate(element)) {
        push(result, element)
      }
    };
    reverse(result);
    result
  };

  /// Creates a new stack by applying the projection function to each element
  /// and keeping only the successful results (where project returns ?value).
  /// Maintains the relative order of elements.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.empty<Nat>();
  ///   stack.push(4);
  ///   stack.push(3);
  ///   stack.push(2);
  ///   stack.push(1);
  ///   let evenDoubled = Stack.filterMap<Nat, Nat>(stack, func(n) {
  ///     if (n % 2 == 0) {
  ///       ?(n * 2)
  ///     } else {
  ///       null
  ///     }
  ///   });
  ///   assert evenDoubled.pop() == ?4;
  ///   assert evenDoubled.pop() == ?8;
  ///   assert evenDoubled.pop() == null;
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// where `n` denotes the number of elements stored on the stack and
  /// assuming that `project` has O(1) costs.
  public func filterMap<T, U>(self : Stack<T>, project : T -> ?U) : Stack<U> {
    let result = empty<U>();
    for (element in values(self)) {
      switch (project(element)) {
        case null {};
        case (?newElement) {
          push(result, newElement)
        }
      }
    };
    reverse(result);
    result
  };

  /// Return the first element for which the given `predicate` is true,
  /// if such an element exists.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromPure<Nat>(?(1, ?(2, ?(3, null))));
  ///   assert stack.find<Nat>(func n = n > 1) == ?2;
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.

  public func find<T>(self : Stack<T>, predicate : T -> Bool) : ?T = PureList.find(self.top, predicate);

  /// Return the first index for which the given `predicate` is true.
  /// If no element satisfies the predicate, returns null.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromPure(?('A', ?('B', ?('C', ?('D', null)))));
  ///   let found = stack.findIndex(func x = x == 'C');
  ///   assert found == ?2;
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func findIndex<T>(self : Stack<T>, predicate : T -> Bool) : ?Nat = PureList.findIndex(self.top, predicate);

  /// Compares two stacks for equality using the provided equality function.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  /// import Nat "mo:core/Nat";
  ///
  /// persistent actor {
  ///   let stack1 = Stack.fromIter<Nat>([3, 2, 1].values());
  ///   let stack2 = Stack.fromIter<Nat>([3, 2, 1].values());
  ///   assert stack1.equal(stack2, Nat.equal);
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(1)
  /// where `n` denotes the number of elements stored on the stack and
  /// assuming that `equal` has O(1) costs.
  public func equal<T>(self : Stack<T>, other : Stack<T>, equal : (implicit : (T, T) -> Bool)) : Bool {
    if (size(self) != size(other)) {
      return false
    };
    let iterator1 = values(self);
    let iterator2 = values(other);
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

  /// Creates a new stack from an iterator.
  /// Elements are pushed in iteration order. Which means that the last element
  /// of the iterator will be the first element on top of the stack.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  /// import Iter "mo:core/Iter";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter<Nat>([3, 2, 1].values());
  ///   assert Iter.toArray(stack.values()) == [1, 2, 3];
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// where `n` denotes the number of iterated elements.
  public func fromIter<T>(iter : Types.Iter<T>) : Stack<T> {
    let stack = empty<T>();
    for (element in iter) {
      push(stack, element)
    };
    stack
  };

  /// Convert an iterator into a stack.
  /// Elements are pushed in iteration order. Which means that the last element
  /// of the iterator will be the first element on top of the stack.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  /// import Iter "mo:core/Iter";
  ///
  /// persistent actor {
  ///   transient let iter = [3, 2, 1].values();
  ///
  ///   let stack = iter.toStack<Nat>();
  ///
  ///   assert Iter.toArray(stack.values()) == [1, 2, 3];
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// where `n` denotes the number of iterated elements.
  public func toStack<T>(self : Types.Iter<T>) : Stack<T> {
    // ignore-self-type-check
    fromIter(self)
  };

  /// Converts the stack to its string representation using the provided
  /// element formatting function.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  /// import Nat "mo:core/Nat";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter<Nat>([3, 2, 1].values());
  ///   assert stack.toText(Nat.toText) == "Stack[1, 2, 3]";
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// where `n` denotes the number of elements stored on the stack and
  /// assuming that `format` has O(1) costs.
  public func toText<T>(self : Stack<T>, format : (implicit : (toText : T -> Text))) : Text {
    var text = "Stack[";
    var sep = "";
    for (element in values(self)) {
      text #= sep # format(element);
      sep := ", "
    };
    text #= "]";
    text
  };

  /// Compares two stacks lexicographically using the provided comparison function.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:core/Stack";
  /// import Nat "mo:core/Nat";
  ///
  /// persistent actor {
  ///   let stack1 = Stack.fromIter<Nat>([2, 1].values());
  ///   let stack2 = Stack.fromIter<Nat>([3, 2, 1].values());
  ///   assert stack1.compare(stack2, Nat.compare) == #less;
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(1)
  /// where `n` denotes the number of elements stored on the stack and
  /// assuming that `compare` has O(1) costs.
  public func compare<T>(self : Stack<T>, other : Stack<T>, compare : (implicit : (T, T) -> Order.Order)) : Order.Order {
    let iterator1 = values(self);
    let iterator2 = values(other);
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
