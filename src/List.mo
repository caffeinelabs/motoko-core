/// A mutable growable array data structure with efficient random access and dynamic resizing.
/// `List` provides O(1) access time and O(sqrt(n)) memory overhead. In contrast, `pure/List` is a purely functional linked list.
/// Can be declared `stable` for orthogonal persistence.
///
/// This implementation is adapted with permission from the `vector` Mops package created by Research AG.
///
/// Copyright: 2023 MR Research AG
/// Main author: Andrii Stepanov (AStepanov25)
/// Contributors: Timo Hanke (timohanke), Andy Gura (andygura), react0r-com
///
/// ```motoko name=import
/// import List "mo:core/List";
/// ```

import PureList "pure/List";
import Prim "mo:⛔";
import Nat32 "Nat32";
import Array "Array";
import Nat "Nat";
import Option "Option";
import VarArray "VarArray";
import Types "Types";

module {
  /// `List<T>` provides a mutable list of elements of type `T`.
  /// Based on the paper "Resizable Arrays in Optimal Time and Space" by Brodnik, Carlsson, Demaine, Munro and Sedgewick (1999).
  /// Since this is internally a two-dimensional array the access times for put and get operations
  /// will naturally be 2x slower than Buffer and Array. However, Array is not resizable and Buffer
  /// has `O(size)` memory waste.
  ///
  /// The maximum number of elements in a `List` is 2^32.
  public type List<T> = Types.List<T>;

  let INTERNAL_ERROR = "List: internal error";

  /// Creates a new empty List for elements of type T.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.empty<Nat>(); // Creates a new List
  /// ```
  public func empty<T>() : List<T> = {
    // the first block is always empty and is present in each List
    // this is done to optimize locate, at, get, etc
    var blocks = [var [var]];
    // can't be 0 in any List
    var blockIndex = 1;
    var elementIndex = 0
  };

  /// Returns a new list with capacity and size 1, containing `element`.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// let list = List.singleton<Nat>(1);
  /// assert List.toText<Nat>(list, Nat.toText) == "List[1]";
  /// ```
  ///
  /// Runtime: `O(1)`
  ///
  /// Space: `O(1)`
  public func singleton<T>(element : T) : List<T> = {
    var blockIndex = 2;
    var blocks = [var [var], [var ?element]];
    var elementIndex = 0
  };

  func repeatInternal<T>(initValue : ?T, size : Nat) : List<T> {
    let (blockIndex, elementIndex) = locate(size);

    let blocks = newIndexBlockLength(Nat32.fromNat(if (elementIndex == 0) { blockIndex - 1 } else blockIndex));
    let dataBlocks = VarArray.repeat<[var ?T]>([var], blocks);
    var i = 1;
    while (i < blockIndex) {
      dataBlocks[i] := VarArray.repeat<?T>(initValue, dataBlockSize(i));
      i += 1
    };
    if (elementIndex != 0) {
      dataBlocks[blockIndex] := if (Option.isNull(initValue)) VarArray.repeat<?T>(
        null,
        dataBlockSize(blockIndex)
      ) else VarArray.tabulate<?T>(
        dataBlockSize(blockIndex),
        func i = if (i < elementIndex) initValue else null
      )
    };

    {
      var blocks = dataBlocks;
      var blockIndex = blockIndex;
      var elementIndex = elementIndex
    }
  };

  /// Creates a new List with `size` copies of the initial value.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.repeat<Nat>(2, 4);
  /// assert List.toArray(list) == [2, 2, 2, 2];
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  public func repeat<T>(initValue : T, size : Nat) : List<T> = repeatInternal<T>(?initValue, size);

  /// Fills all elements in the list with the given value.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.fromArray<Nat>([1, 2, 3]);
  /// List.fill(list, 0); // fills the list with 0
  /// assert List.toArray(list) == [0, 0, 0];
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  public func fill<T>(self : List<T>, value : T) {
    let blocks = self.blocks;
    let blockCount = blocks.size();
    let blockIndex = self.blockIndex;
    let elementIndex = self.elementIndex;

    var i = 1;
    while (i < blockCount) {
      let db = blocks[i];
      let sz = if (i == blockIndex) elementIndex else db.size();
      if (sz == 0) return;

      var j = 0;
      while (j < sz) {
        db[j] := ?value;
        j += 1
      };
      i += 1
    }
  };

  /// Converts a mutable `List` to a purely functional `PureList`.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.fromArray<Nat>([1, 2, 3]);
  /// let pureList = List.toPure<Nat>(list); // converts to immutable PureList
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  /// @deprecated M0235
  public func toPure<T>(self : List<T>) : PureList.List<T> {
    var result : PureList.List<T> = null;

    let blocks = self.blocks;
    let blockIndex = self.blockIndex;
    let elementIndex = self.elementIndex;

    var i = blockIndex;
    if (elementIndex == 0) i -= 1;

    while (i > 0) {
      let db = blocks[i];
      let sz = db.size();
      var j = if (i == blockIndex) elementIndex else sz;
      while (j > 0) {
        j -= 1;
        switch (db[j]) {
          case (?x) result := ?(x, result);
          case null Prim.trap INTERNAL_ERROR
        }
      };
      i -= 1
    };

    result
  };

  /// Converts a purely functional `PureList` to a `List`.
  ///
  /// Example:
  /// ```motoko include=import
  /// import PureList "mo:core/pure/List";
  ///
  /// let pureList = PureList.fromArray<Nat>([1, 2, 3]);
  /// let list = List.fromPure<Nat>(pureList); // converts to List
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  /// @deprecated M0235
  public func fromPure<T>(pure : PureList.List<T>) : List<T> {
    var p = pure;
    var list = empty<T>();
    loop {
      switch (p) {
        case (?(x, xs)) {
          add(list, x);
          p := xs
        };
        case null return list
      }
    }
  };

  func addRepeatInternal<T>(list : List<T>, initValue : ?T, count : Nat) {
    let (b, e) = locate(size(list) + count);
    let blocksCount = newIndexBlockLength(Nat32.fromNat(if (e == 0) b - 1 else b));

    let oldBlocksCount = list.blocks.size();
    if (oldBlocksCount < blocksCount) {
      let oldBlocks = list.blocks;
      let blocks = VarArray.repeat<[var ?T]>([var], blocksCount);
      var i = 0;
      while (i < oldBlocksCount) {
        blocks[i] := oldBlocks[i];
        i += 1
      };
      list.blocks := blocks
    };

    let blocks = list.blocks;
    var blockIndex = list.blockIndex;
    var elementIndex = list.elementIndex;

    var cnt = count;
    label L while (cnt > 0) {
      if (blocks[blockIndex].size() == 0) {
        let dbSize = dataBlockSize(blockIndex);
        if (cnt >= dbSize) {
          blocks[blockIndex] := VarArray.repeat<?T>(initValue, dbSize);
          blockIndex += 1;
          cnt -= dbSize;
          continue L
        };
        blocks[blockIndex] := VarArray.repeat<?T>(null, dbSize)
      };

      let block = blocks[blockIndex];
      let dbSize = block.size();
      let to = Nat.min(elementIndex + cnt, dbSize);
      cnt -= to - elementIndex;

      while (elementIndex < to) {
        block[elementIndex] := initValue;
        elementIndex += 1
      };

      if (elementIndex == dbSize) {
        elementIndex := 0;
        blockIndex += 1
      }
    };

    list.blockIndex := blockIndex;
    list.elementIndex := elementIndex
  };

  private func reserve<T>(list : List<T>, size : Nat) {
    let blockIndex = list.blockIndex;
    let elementIndex = list.elementIndex;

    addRepeatInternal<T>(list, null, size);

    list.blockIndex := blockIndex;
    list.elementIndex := elementIndex
  };

  /// Add to list `count` copies of the initial value.
  ///
  /// ```motoko include=import
  /// let list = List.repeat<Nat>(2, 4); // [2, 2, 2, 2]
  /// List.addRepeat(list, 2, 1); // [2, 2, 2, 2, 1, 1]
  /// ```
  ///
  /// The maximum number of elements in a `List` is 2^32.
  ///
  /// Runtime: `O(count)`
  public func addRepeat<T>(self : List<T>, initValue : T, count : Nat) = addRepeatInternal<T>(self, ?initValue, count);

  /// Truncates the list to the specified size.
  /// If the new size is larger than the current size, it will do nothing.
  /// If the new size is equal to the current list size, after the operation list will be equal to cloned version of itself.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.fromArray<Nat>([1, 2, 3, 4, 5]);
  /// List.truncate(list, 3); // list is now [1, 2, 3]
  /// assert List.toArray(list) == [1, 2, 3];
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  public func truncate<T>(self : List<T>, newSize : Nat) {
    if (newSize > size(self)) return;

    // if newSize == size(self) then after the operation self will be equal to List.clone(self)
    let (blockIndex, elementIndex) = locate(newSize);
    self.blockIndex := blockIndex;
    self.elementIndex := elementIndex;
    let newBlocksCount = newIndexBlockLength(Nat32.fromNat(if (elementIndex == 0) blockIndex - 1 else blockIndex));

    let newBlocks = if (newBlocksCount < self.blocks.size()) {
      let oldDataBlocks = self.blocks;
      self.blocks := VarArray.tabulate<[var ?T]>(newBlocksCount, func(i) = oldDataBlocks[i]);
      self.blocks
    } else self.blocks;

    var i = if (elementIndex == 0) blockIndex else blockIndex + 1;
    while (i < newBlocksCount) {
      newBlocks[i] := [var];
      i += 1
    };
    if (elementIndex != 0) {
      let block = newBlocks[blockIndex];
      var i = elementIndex;
      var to = block.size();
      while (i < to) {
        block[i] := null;
        i += 1
      }
    }
  };

  /// Resets the list to size 0, de-referencing all elements.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.empty<Nat>();
  /// List.add(list, 10);
  /// List.add(list, 11);
  /// List.add(list, 12);
  /// List.clear(list); // list is now empty
  /// assert List.toArray(list) == [];
  /// ```
  ///
  /// Runtime: `O(1)`
  public func clear<T>(self : List<T>) {
    self.blocks := [var [var]];
    self.blockIndex := 1;
    self.elementIndex := 0
  };

  /// Creates a list of size `size`. Each element at index i
  /// is created by applying `generator` to i.
  ///
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// let list = List.tabulate<Nat>(4, func i = i * 2);
  /// assert List.toArray(list) == [0, 2, 4, 6];
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `generator` runs in O(1) time and space.
  public func tabulate<T>(size : Nat, generator : Nat -> T) : List<T> {
    let (blockIndex, elementIndex) = locate(size);

    let blocks = newIndexBlockLength(Nat32.fromNat(if (elementIndex == 0) { blockIndex - 1 } else blockIndex));
    let dataBlocks = VarArray.repeat<[var ?T]>([var], blocks);

    var i = 1;
    var pos = 0;

    while (i < blockIndex) {
      let len = dataBlockSize(i);
      dataBlocks[i] := VarArray.tabulate<?T>(len, func i = ?generator(pos + i));
      pos += len;
      i += 1
    };
    if (elementIndex != 0 and blockIndex < blocks) {
      dataBlocks[i] := VarArray.tabulate<?T>(
        dataBlockSize(blockIndex),
        func i = if (i < elementIndex) ?generator(pos + i) else null
      )
    };

    {
      var blocks = dataBlocks;
      var blockIndex = blockIndex;
      var elementIndex = elementIndex
    }
  };

  /// Combines a list of lists into a single list. Retains the original
  /// ordering of the elements.
  ///
  /// This has better performance compared to `List.join()`.
  ///
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// let lists = List.fromArray<List.List<Nat>>([
  ///   List.fromArray<Nat>([0, 1, 2]), List.fromArray<Nat>([2, 3]), List.fromArray<Nat>([]), List.fromArray<Nat>([4])
  /// ]);
  /// let flatList = List.flatten<Nat>(lists);
  /// assert List.equal<Nat>(flatList, List.fromArray<Nat>([0, 1, 2, 2, 3, 4]), Nat.equal);
  /// ```
  ///
  /// Runtime: O(number of elements in list)
  ///
  /// Space: O(number of elements in list)
  public func flatten<T>(self : List<List<T>>) : List<T> {
    var sz = 0;
    forEach<List<T>>(self, func(sublist) = sz += size(sublist));

    let result = repeatInternal<T>(null, sz);
    result.blockIndex := 1;
    result.elementIndex := 0;

    forEach<List<T>>(
      self,
      func(sublist) {
        forEach<T>(
          sublist,
          func(item) {
            add(result, item)
          }
        )
      }
    );
    result
  };

  /// Combines an iterator of lists into a single list.
  /// Retains the original ordering of the elements.
  ///
  /// Consider using `List.flatten()` for better performance.
  ///
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// let lists = [List.fromArray<Nat>([0, 1, 2]), List.fromArray<Nat>([2, 3]), List.fromArray<Nat>([]), List.fromArray<Nat>([4])];
  /// let joinedList = List.join<Nat>(lists.vals());
  /// assert List.equal<Nat>(joinedList, List.fromArray<Nat>([0, 1, 2, 2, 3, 4]), Nat.equal);
  /// ```
  ///
  /// Runtime: O(number of elements in list)
  ///
  /// Space: O(number of elements in list)
  public func join<T>(self : Types.Iter<List<T>>) : List<T> {
    var result = empty<T>();
    for (list in self) {
      reserve(result, size(list));
      forEach<T>(list, func item = addUnsafe(result, item))
    };
    result
  };

  /// Returns a copy of a List, with the same size.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.empty<Nat>();
  /// List.add(list, 1);
  ///
  /// let clone = List.clone(list);
  /// assert List.toArray(clone) == [1];
  /// ```
  ///
  /// Runtime: `O(size)`
  public func clone<T>(self : List<T>) : List<T> = {
    var blocks = VarArray.tabulate<[var ?T]>(
      Nat.min(
        newIndexBlockLength(Nat32.fromNat(if (self.elementIndex == 0) self.blockIndex - 1 else self.blockIndex)),
        self.blocks.size()
      ),
      func(i) = VarArray.clone<?T>(self.blocks[i])
    );
    var blockIndex = self.blockIndex;
    var elementIndex = self.elementIndex
  };

  /// Creates a new list by applying the provided function to each element in the input list.
  /// The resulting list has the same size as the input list.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// let list = List.singleton<Nat>(123);
  /// let textList = List.map<Nat, Text>(list, Nat.toText);
  /// assert List.toArray(textList) == ["123"];
  /// ```
  ///
  /// Runtime: `O(size)`
  public func map<T, R>(self : List<T>, f : T -> R) : List<R> {
    let blocksCount = Nat.min(
      newIndexBlockLength(Nat32.fromNat(if (self.elementIndex == 0) self.blockIndex - 1 else self.blockIndex)),
      self.blocks.size()
    );
    let blocks = VarArray.repeat<[var ?R]>([var], blocksCount);

    var i = 1;
    label l while (i < blocksCount) {
      let oldBlock = self.blocks[i];
      let blockSize = oldBlock.size();
      let newBlock = VarArray.repeat<?R>(null, blockSize);
      blocks[i] := newBlock;
      var j = 0;

      while (j < blockSize) {
        switch (oldBlock[j]) {
          case (?item) newBlock[j] := ?f(item);
          case null break l
        };
        j += 1
      };
      i += 1
    };

    {
      var blocks = blocks;
      var blockIndex = self.blockIndex;
      var elementIndex = self.elementIndex
    }
  };

  /// Applies `f` to each element of `list` in place,
  /// retaining the original ordering of elements.
  /// This modifies the original list.
  ///
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// let list = List.fromArray<Nat>([0, 1, 2, 3]);
  /// List.mapInPlace<Nat>(list, func x = x * 3);
  /// assert List.equal(list, List.fromArray<Nat>([0, 3, 6, 9]), Nat.equal);
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func mapInPlace<T>(self : List<T>, f : T -> T) {
    let blocks = self.blocks;
    let blockCount = blocks.size();

    var i = 1;
    while (i < blockCount) {
      let db = blocks[i];
      let sz = db.size();
      if (sz == 0) return;

      var j = 0;
      while (j < sz) {
        switch (db[j]) {
          case (?x) db[j] := ?f(x);
          case null return
        };
        j += 1
      };
      i += 1
    }
  };

  /// Creates a new list by applying `f` to each element in `list` and its index.
  /// Retains original ordering of elements.
  ///
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// let list = List.fromArray<Nat>([10, 10, 10, 10]);
  /// let newList = List.mapEntries<Nat, Nat>(list, func (x, i) = i * x);
  /// assert List.equal(newList, List.fromArray<Nat>([0, 10, 20, 30]), Nat.equal);
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func mapEntries<T, R>(self : List<T>, f : (T, Nat) -> R) : List<R> {
    let blocks = VarArray.repeat<[var ?R]>([var], self.blocks.size());
    let blocksCount = self.blocks.size();

    var index = 0;

    var i = 1;
    label l while (i < blocksCount) {
      let oldBlock = self.blocks[i];
      let blockSize = oldBlock.size();
      let newBlock = VarArray.repeat<?R>(null, blockSize);
      blocks[i] := newBlock;
      var j = 0;

      while (j < blockSize) {
        switch (oldBlock[j]) {
          case (?item) newBlock[j] := ?f(item, index);
          case null break l
        };
        j += 1;
        index += 1
      };
      i += 1
    };

    {
      var blocks = blocks;
      var blockIndex = self.blockIndex;
      var elementIndex = self.elementIndex
    }
  };

  /// Creates a new list by applying `f` to each element in `list`.
  /// If any invocation of `f` produces an `#err`, returns an `#err`. Otherwise
  /// returns an `#ok` containing the new list.
  ///
  /// ```motoko include=import
  /// import Result "mo:core/Result";
  ///
  /// let list = List.fromArray<Nat>([4, 3, 2, 1, 0]);
  /// // divide 100 by every element in the list
  /// let result = List.mapResult<Nat, Nat, Text>(list, func x {
  ///   if (x > 0) {
  ///     #ok(100 / x)
  ///   } else {
  ///     #err "Cannot divide by zero"
  ///   }
  /// });
  /// assert Result.isErr(result);
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func mapResult<T, R, E>(self : List<T>, f : T -> Types.Result<R, E>) : Types.Result<List<R>, E> {
    var error : ?E = null;

    let blocks = VarArray.repeat<[var ?R]>([var], self.blocks.size());
    let blocksCount = self.blocks.size();

    var i = 1;
    while (i < blocksCount) {
      let oldBlock = self.blocks[i];
      let blockSize = oldBlock.size();
      let newBlock = VarArray.repeat<?R>(null, blockSize);
      blocks[i] := newBlock;
      var j = 0;

      while (j < blockSize) {
        switch (oldBlock[j]) {
          case (?item) newBlock[j] := switch (f(item)) {
            case (#ok x) ?x;
            case (#err e) switch (error) {
              case (null) {
                error := ?e;
                null
              };
              case (?_) null
            }
          };
          case null return switch (error) {
            case (null) return #ok {
              var blocks = blocks;
              var blockIndex = self.blockIndex;
              var elementIndex = self.elementIndex
            };
            case (?e) return #err e
          }
        };
        j += 1
      };
      i += 1
    };

    switch (error) {
      case (null) return #ok {
        var blocks = blocks;
        var blockIndex = self.blockIndex;
        var elementIndex = self.elementIndex
      };
      case (?e) return #err e
    }
  };

  /// Returns a new list containing only the elements from `list` for which the predicate returns true.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.fromArray<Nat>([1, 2, 3, 4]);
  /// let evenNumbers = List.filter<Nat>(list, func x = x % 2 == 0);
  /// assert List.toArray(evenNumbers) == [2, 4];
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that `predicate` runs in `O(1)` time and space.
  public func filter<T>(self : List<T>, predicate : T -> Bool) : List<T> {
    let filtered = empty<T>();

    let blocks = self.blocks;
    let blockCount = blocks.size();

    var i = 1;
    while (i < blockCount) {
      let db = blocks[i];
      let sz = db.size();
      if (sz == 0) return filtered;

      var j = 0;
      while (j < sz) {
        switch (db[j]) {
          case (?x) if (predicate(x)) add(filtered, x);
          case null return filtered
        };
        j += 1
      };
      i += 1
    };

    filtered
  };

  /// Retains only the elements in `list` for which the predicate returns true.
  /// Modifies the original list in place.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.fromArray<Nat>([1, 2, 3, 4]);
  /// List.retain<Nat>(list, func x = x % 2 == 0);
  /// assert List.toArray(list) == [2, 4];
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(sqrt(size))` if `list` was truncated otherwise `O(1)`
  public func retain<T>(self : List<T>, predicate : T -> Bool) {
    self.blockIndex := 1;
    self.elementIndex := 0;

    let blocks = self.blocks;
    let blockCount = blocks.size();

    var i = 1;
    label l while (i < blockCount) {
      let db = blocks[i];
      let sz = db.size();
      if (sz == 0) break l;

      var j = 0;
      while (j < sz) {
        switch (db[j]) {
          case (?x) if (predicate(x)) addUnsafe(self, x);
          case null break l
        };
        j += 1
      };
      i += 1
    };

    truncate(self, size(self))
  };

  /// Returns a new list containing all elements from `list` for which the function returns ?element.
  /// Discards all elements for which the function returns null.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.fromArray<Nat>([1, 2, 3, 4]);
  /// let doubled = List.filterMap<Nat, Nat>(list, func x = if (x % 2 == 0) ?(x * 2) else null);
  /// assert List.toArray(doubled) == [4, 8];
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that `f` runs in `O(1)` time and space.
  public func filterMap<T, R>(self : List<T>, f : T -> ?R) : List<R> {
    let filtered = empty<R>();

    let blocks = self.blocks;
    let blockCount = blocks.size();

    var i = 1;
    while (i < blockCount) {
      let db = blocks[i];
      let sz = db.size();
      if (sz == 0) return filtered;

      var j = 0;
      while (j < sz) {
        switch (db[j]) {
          case (?x) switch (f(x)) {
            case (?y) add(filtered, y);
            case null {}
          };
          case null return filtered
        };
        j += 1
      };
      i += 1
    };

    filtered
  };

  /// Creates a new list by applying `k` to each element in `list`,
  /// and concatenating the resulting iterators in order.
  ///
  /// ```motoko include=import
  /// import Int "mo:core/Int"
  ///
  /// let list = List.fromArray<Nat>([1, 2, 3, 4]);
  /// let newList = List.flatMap<Nat, Int>(list, func x = [x, -x].vals());
  /// assert List.equal(newList, List.fromArray<Int>([1, -1, 2, -2, 3, -3, 4, -4]), Int.equal);
  /// ```
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  /// *Runtime and space assumes that `k` runs in O(1) time and space.
  public func flatMap<T, R>(self : List<T>, k : T -> Types.Iter<R>) : List<R> {
    let result = empty<R>();

    let blocks = self.blocks;
    let blockCount = blocks.size();

    var i = 1;
    while (i < blockCount) {
      let db = blocks[i];
      let sz = db.size();
      if (sz == 0) return result;

      var j = 0;
      while (j < sz) {
        switch (db[j]) {
          case (?x) for (y in k(x)) add(result, y);
          case _ return result
        };
        j += 1
      };
      i += 1
    };

    result
  };

  func indexByBlockElement<T>(blockIndex : Nat, elementIndex : Nat) : Nat {
    let d = Nat32.fromNat(blockIndex);

    // We call all data blocks of the same capacity an "epoch". We number the epochs 0,1,2,...
    // A data block is in epoch e iff the data block has capacity 2 ** e.
    // Each epoch starting with epoch 1 spans exactly two super blocks.
    // Super block s falls in epoch ceil(s/2).

    // epoch of last data block
    // e = 32 - lz
    let lz = Nat32.bitcountLeadingZero(d / 3);

    // capacity of all prior epochs combined
    // capacity_before_e = 2 * 4 ** (e - 1) - 1

    // data blocks in all prior epochs combined
    // blocks_before_e = 3 * 2 ** (e - 1) - 2

    // then size = d * 2 ** e + i - c
    // where c = blocks_before_e * 2 ** e - capacity_before_e

    // there can be overflows, but the result is without overflows, so use addWrap and subWrap
    // we don't erase bits by >>, so to use <>> is ok
    Nat32.toNat((d -% (1 <>> lz)) <>> lz +% Nat32.fromNat(elementIndex))
  };

  /// Returns the current number of elements in the list.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.empty<Nat>();
  /// assert List.size(list) == 0
  /// ```
  ///
  /// Runtime: `O(1)` (with some internal calculations)
  public func size<T>(self : List<T>) : Nat {
    // due to the design of List (blockIndex, elementIndex) pair points
    // exactly to the place where size-th element should be added
    // so, it's the inlined version of indexByBlockElement
    let d = Nat32.fromNat(self.blockIndex);
    let lz = Nat32.bitcountLeadingZero(d / 3);
    Nat32.toNat((d -% (1 <>> lz)) <>> lz +% Nat32.fromNat(self.elementIndex))
  };

  func dataBlockSize(blockIndex : Nat) : Nat {
    // formula for the size of given blockIndex
    // don't call it for blockIndex == 0
    Nat32.toNat(1 <>> Nat32.bitcountLeadingZero(Nat32.fromNat(blockIndex) / 3))
  };

  func newIndexBlockLength(blockIndex : Nat32) : Nat {
    if (blockIndex <= 1) 2 else {
      let s = 30 - Nat32.bitcountLeadingZero(blockIndex);
      Nat32.toNat(((blockIndex >> s) +% 1) << s)
    }
  };

  func growIndexBlockIfNeeded<T>(list : List<T>) {
    if (list.blocks.size() == list.blockIndex) {
      let newBlocks = VarArray.repeat<[var ?T]>([var], newIndexBlockLength(Nat32.fromNat(list.blockIndex)));
      var i = 0;
      while (i < list.blockIndex) {
        newBlocks[i] := list.blocks[i];
        i += 1
      };
      list.blocks := newBlocks
    }
  };

  func shrinkIndexBlockIfNeeded<T>(list : List<T>) {
    let blockIndex = Nat32.fromNat(list.blockIndex);
    // kind of index of the first block in the super block
    if ((blockIndex << Nat32.bitcountLeadingZero(blockIndex)) << 2 == 0) {
      let newLength = newIndexBlockLength(blockIndex);
      if (newLength < list.blocks.size()) {
        let newBlocks = VarArray.repeat<[var ?T]>([var], newLength);
        var i = 0;
        while (i < newLength) {
          newBlocks[i] := list.blocks[i];
          i += 1
        };
        list.blocks := newBlocks
      }
    }
  };

  /// Adds a single element to the end of a List,
  /// allocating a new internal data block if needed,
  /// and resizing the internal index block if needed.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.empty<Nat>();
  /// List.add(list, 0); // add 0 to list
  /// List.add(list, 1);
  /// List.add(list, 2);
  /// List.add(list, 3);
  /// assert List.toArray(list) == [0, 1, 2, 3];
  /// ```
  ///
  /// The maximum number of elements in a `List` is 2^32.
  ///
  /// Amortized Runtime: `O(1)`, Worst Case Runtime: `O(sqrt(n))`
  public func add<T>(self : List<T>, element : T) {
    var elementIndex = self.elementIndex;
    if (elementIndex == 0) {
      growIndexBlockIfNeeded(self);
      let blockIndex = self.blockIndex;

      // When removing last we keep one more data block, so can be not empty
      if (self.blocks[blockIndex].size() == 0) {
        self.blocks[blockIndex] := VarArray.repeat<?T>(
          null,
          dataBlockSize(blockIndex)
        )
      }
    };

    let lastDataBlock = self.blocks[self.blockIndex];

    lastDataBlock[elementIndex] := ?element;

    elementIndex += 1;
    if (elementIndex == lastDataBlock.size()) {
      elementIndex := 0;
      self.blockIndex += 1
    };
    self.elementIndex := elementIndex
  };

  // Add an element without checking and resizing the List
  private func addUnsafe<T>(list : List<T>, element : T) {
    var elementIndex = list.elementIndex;
    let lastDataBlock = list.blocks[list.blockIndex];
    lastDataBlock[elementIndex] := ?element;

    elementIndex += 1;
    if (elementIndex == lastDataBlock.size()) {
      elementIndex := 0;
      list.blockIndex += 1
    };
    list.elementIndex := elementIndex
  };

  /// Removes and returns the last item in the list or `null` if
  /// the list is empty.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.empty<Nat>();
  /// List.add(list, 10);
  /// List.add(list, 11);
  /// assert List.removeLast(list) == ?11;
  /// assert List.removeLast(list) == ?10;
  /// assert List.removeLast(list) == null;
  /// ```
  ///
  /// Amortized Runtime: `O(1)`, Worst Case Runtime: `O(sqrt(n))`
  ///
  /// Amortized Space: `O(1)`, Worst Case Space: `O(sqrt(n))`
  public func removeLast<T>(self : List<T>) : ?T {
    var elementIndex = self.elementIndex;
    if (elementIndex == 0) {
      var blockIndex = self.blockIndex;
      if (blockIndex == 1) {
        return null
      };

      shrinkIndexBlockIfNeeded(self);

      blockIndex -= 1;
      elementIndex := self.blocks[blockIndex].size();

      // Keep one totally empty block when removing
      if (blockIndex + 2 < self.blocks.size()) self.blocks[blockIndex + 2] := [var];

      self.blockIndex := blockIndex
    };
    elementIndex -= 1;

    let lastDataBlock = self.blocks[self.blockIndex];

    let element = lastDataBlock[elementIndex];
    lastDataBlock[elementIndex] := null;

    self.elementIndex := elementIndex;
    return element
  };

  func locate(index : Nat) : (Nat, Nat) {
    // see comments in tests
    let i = Nat32.fromNat(index);
    let lz = Nat32.bitcountLeadingZero(i);
    let lz2 = lz >> 1;
    if (lz & 1 == 0) {
      (Nat32.toNat(((i << lz2) >> 16) ^ (0x10000 >> lz2)), Nat32.toNat(i & (0xFFFF >> lz2)))
    } else {
      (Nat32.toNat(((i << lz2) >> 15) ^ (0x18000 >> lz2)), Nat32.toNat(i & (0x7FFF >> lz2)))
    }
  };

  /// Returns the element at index `index`. Indexing is zero-based.
  /// Traps if `index >= size`, error message may not be descriptive.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.empty<Nat>();
  /// List.add(list, 10);
  /// List.add(list, 11);
  /// assert List.at(list, 0) == 10;
  /// ```
  ///
  /// Runtime: `O(1)`
  public func at<T>(self : List<T>, index : Nat) : T {
    // inlined version of:
    //   let (a,b) = locate(index);
    //   switch(self.blocks[a][b]) {
    //     case (?element) element;
    //     case (null) Prim.trap "";
    //   };
    let i = Nat32.fromNat(index);
    let lz = Nat32.bitcountLeadingZero(i);
    let lz2 = lz >> 1;
    switch (
      if (lz & 1 == 0) {
        self.blocks[Nat32.toNat(((i << lz2) >> 16) ^ (0x10000 >> lz2))][Nat32.toNat(i & (0xFFFF >> lz2))]
      } else {
        self.blocks[Nat32.toNat(((i << lz2) >> 15) ^ (0x18000 >> lz2))][Nat32.toNat(i & (0x7FFF >> lz2))]
      }
    ) {
      case (?result) return result;
      case (_) Prim.trap "List index out of bounds in get"
    }
  };

  /// Returns the element at index `index` as an option.
  /// Returns `null` when `index >= size`. Indexing is zero-based.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.empty<Nat>();
  /// List.add(list, 10);
  /// List.add(list, 11);
  /// assert List.get(list, 0) == ?10;
  /// assert List.get(list, 2) == null;
  /// ```
  ///
  /// Runtime: `O(1)`
  ///
  /// Space: `O(1)`
  /// @deprecated M0235
  public func get<T>(self : List<T>, index : Nat) : ?T {
    // inlined version of locate
    let (a, b) = do {
      let i = Nat32.fromNat(index);
      let lz = Nat32.bitcountLeadingZero(i);
      let lz2 = lz >> 1;
      if (lz & 1 == 0) {
        (Nat32.toNat(((i << lz2) >> 16) ^ (0x10000 >> lz2)), Nat32.toNat(i & (0xFFFF >> lz2)))
      } else {
        (Nat32.toNat(((i << lz2) >> 15) ^ (0x18000 >> lz2)), Nat32.toNat(i & (0x7FFF >> lz2)))
      }
    };
    if (a < self.blockIndex or self.elementIndex != 0 and a == self.blockIndex) {
      self.blocks[a][b]
    } else null
  };

  /// Overwrites the current element at `index` with `element`.
  /// Traps if `index` >= size, error message may not be descriptive. Indexing is zero-based.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.empty<Nat>();
  /// List.add(list, 10);
  /// List.put(list, 0, 20); // overwrites 10 at index 0 with 20
  /// assert List.toArray(list) == [20];
  /// ```
  ///
  /// Runtime: `O(1)`
  public func put<T>(self : List<T>, index : Nat, value : T) {
    let i = Nat32.fromNat(index);
    let lz = Nat32.bitcountLeadingZero(i);
    let lz2 = lz >> 1;
    let (block, element) = if (lz & 1 == 0) {
      (self.blocks[Nat32.toNat(((i << lz2) >> 16) ^ (0x10000 >> lz2))], Nat32.toNat(i & (0xFFFF >> lz2)))
    } else {
      (self.blocks[Nat32.toNat(((i << lz2) >> 15) ^ (0x18000 >> lz2))], Nat32.toNat(i & (0x7FFF >> lz2)))
    };

    switch (block[element]) {
      case (?_) block[element] := ?value;
      case _ Prim.trap "List index out of bounds in put"
    }
  };

  /// Sorts the elements in the list according to `compare`.
  /// Sort is deterministic, stable, and in-place.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// let list = List.empty<Nat>();
  /// List.add(list, 3);
  /// List.add(list, 1);
  /// List.add(list, 2);
  /// List.sortInPlace(list, Nat.compare);
  /// assert List.toArray(list) == [1, 2, 3];
  /// ```
  ///
  /// Runtime: O(size * log(size))
  ///
  /// Space: O(size)
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func sortInPlace<T>(self : List<T>, compare : (implicit : (T, T) -> Types.Order)) {
    if (size(self) < 2) return;
    let array = toVarArray(self);

    VarArray.sortInPlace(array, compare);

    var index = 0;

    let blocks = self.blocks;
    let blockCount = blocks.size();

    var i = 1;
    while (i < blockCount) {
      let db = blocks[i];
      let sz = db.size();
      if (sz == 0) return;

      var j = 0;
      while (j < sz) {
        switch (db[j]) {
          case (?_) db[j] := ?array[index];
          case _ return
        };
        index += 1;
        j += 1
      };
      i += 1
    }
  };

  /// Sorts the elements in the list according to `compare`.
  /// Sort is deterministic, stable, and in-place.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// let list = List.empty<Nat>();
  /// List.add(list, 3);
  /// List.add(list, 1);
  /// List.add(list, 2);
  /// let sorted = List.sort(list, Nat.compare);
  /// assert List.toArray(sorted) == [1, 2, 3];
  /// ```
  ///
  /// Runtime: O(size * log(size))
  ///
  /// Space: O(size)
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func sort<T>(self : List<T>, compare : (implicit : (T, T) -> Types.Order)) : List<T> {
    let array = toVarArray(self);
    VarArray.sortInPlace(array, compare);
    fromVarArray(array)
  };

  /// Checks whether the `list` is sorted.
  ///
  /// Example:
  /// ```
  /// import Nat "mo:core/Nat";
  ///
  /// let list = List.fromArray<Nat>([1, 2, 3]);
  /// assert List.isSorted(list, Nat.compare);
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  public func isSorted<T>(self : List<T>, compare : (implicit : (T, T) -> Types.Order)) : Bool {
    var prev = switch (first(self)) {
      case (?x) x;
      case _ return true
    };

    let blocks = self.blocks;
    let blockCount = blocks.size();

    var i = 2;
    while (i < blockCount) {
      let db = blocks[i];
      let sz = db.size();
      if (sz == 0) return true;

      var j = 0;
      while (j < sz) {
        switch (db[j]) {
          case (?x) switch (compare(x, prev)) {
            case (#greater or #equal) prev := x;
            case (#less) return false
          };
          case null return true
        };
        j += 1
      };
      i += 1
    };

    true
  };

  /// Remove adjacent duplicates from the `list`, if the `list` is sorted all elements will be unique.
  ///
  /// Example:
  /// ```
  /// import Nat "mo:core/Nat";
  ///
  /// let list = List.fromArray<Nat>([1, 1, 2, 2, 3]);
  /// List.deduplicate(list, Nat.equal);
  /// assert List.equal(list, List.fromArray<Nat>([1, 2, 3]), Nat.equal);
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  public func deduplicate<T>(self : List<T>, equal : (implicit : (T, T) -> Bool)) {
    var prev = switch (first(self)) {
      case (?x) x;
      case _ return
    };

    self.blockIndex := 1;
    self.elementIndex := 0;

    addUnsafe(self, prev);

    let blocks = self.blocks;
    let blockCount = blocks.size();

    var i = 2;
    label l while (i < blockCount) {
      let db = blocks[i];
      let sz = db.size();
      if (sz == 0) return break l;

      var j = 0;
      while (j < sz) {
        switch (db[j]) {
          case (?x) {
            if (not equal(x, prev)) addUnsafe(self, x);
            prev := x
          };
          case null break l
        };
        j += 1
      };
      i += 1
    };

    truncate(self, size(self))
  };

  /// Finds the first index of `element` in `list` using equality of elements defined
  /// by `equal`. Returns `null` if `element` is not found.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// let list = List.empty<Nat>();
  /// List.add(list, 1);
  /// List.add(list, 2);
  /// List.add(list, 3);
  /// List.add(list, 4);
  ///
  /// assert List.indexOf<Nat>(list, Nat.equal, 3) == ?2;
  /// assert List.indexOf<Nat>(list, Nat.equal, 5) == null;
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// *Runtime and space assumes that `equal` runs in `O(1)` time and space.
  public func indexOf<T>(self : List<T>, equal : (implicit : (T, T) -> Bool), element : T) : ?Nat {
    if (isEmpty(self)) return null;
    nextIndexOf<T>(self, equal, element, 0)
  };

  /// Returns the index of the next occurence of `element` in the `list` starting from the `from` index (inclusive).
  ///
  /// ```motoko include=import
  /// import Char "mo:core/Char";
  /// let list = List.fromArray<Char>(['c', 'o', 'f', 'f', 'e', 'e']);
  /// assert List.nextIndexOf<Char>(list, Char.equal, 'c', 0) == ?0;
  /// assert List.nextIndexOf<Char>(list, Char.equal, 'f', 0) == ?2;
  /// assert List.nextIndexOf<Char>(list, Char.equal, 'f', 2) == ?2;
  /// assert List.nextIndexOf<Char>(list, Char.equal, 'f', 3) == ?3;
  /// assert List.nextIndexOf<Char>(list, Char.equal, 'f', 4) == null;
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func nextIndexOf<T>(self : List<T>, equal : (implicit : (T, T) -> Bool), element : T, fromInclusive : Nat) : ?Nat {
    if (fromInclusive >= size(self)) Prim.trap "List index out of bounds in nextIndexOf";

    let (blockIndex, elementIndex) = locate(fromInclusive);

    let blocks = self.blocks;
    let blockCount = blocks.size();

    var i = blockIndex;
    while (i < blockCount) {
      let db = blocks[i];
      let sz = db.size();
      if (sz == 0) return null;

      var j = if (i == blockIndex) elementIndex else 0;
      while (j < sz) {
        switch (db[j]) {
          case (?x) if (equal(x, element)) return ?indexByBlockElement(i, j);
          case null return null
        };
        j += 1
      };
      i += 1
    };
    null
  };

  /// Finds the last index of `element` in `list` using equality of elements defined
  /// by `equal`. Returns `null` if `element` is not found.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// let list = List.fromArray<Nat>([1, 2, 3, 4, 2, 2]);
  ///
  /// assert List.lastIndexOf<Nat>(list, Nat.equal, 2) == ?5;
  /// assert List.lastIndexOf<Nat>(list, Nat.equal, 5) == null;
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// *Runtime and space assumes that `equal` runs in `O(1)` time and space.
  public func lastIndexOf<T>(self : List<T>, equal : (implicit : (T, T) -> Bool), element : T) : ?Nat = prevIndexOf<T>(
    self,
    equal,
    element,
    size(self)
  );

  /// Returns the index of the previous occurence of `element` in the `list` starting from the `from` index (exclusive).
  ///
  /// ```motoko include=import
  /// import Char "mo:core/Char";
  /// let list = List.fromArray<Char>(['c', 'o', 'f', 'f', 'e', 'e']);
  /// assert List.prevIndexOf<Char>(list, Char.equal, 'c', List.size(list)) == ?0;
  /// assert List.prevIndexOf<Char>(list, Char.equal, 'e', List.size(list)) == ?5;
  /// assert List.prevIndexOf<Char>(list, Char.equal, 'e', 5) == ?4;
  /// assert List.prevIndexOf<Char>(list, Char.equal, 'e', 4) == null;
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  public func prevIndexOf<T>(self : List<T>, equal : (implicit : (T, T) -> Bool), element : T, fromExclusive : Nat) : ?Nat {
    if (fromExclusive > size(self)) Prim.trap "List index out of bounds in prevIndexOf";

    let blocks = self.blocks;
    let (blockIndex, elementIndex) = locate(fromExclusive);

    var i = blockIndex;
    if (elementIndex == 0) i -= 1;

    while (i > 0) {
      let db = blocks[i];
      let sz = db.size();
      var j = if (i == blockIndex) elementIndex else sz;
      while (j > 0) {
        j -= 1;
        switch (db[j]) {
          case (?x) if (equal(x, element)) return ?indexByBlockElement(i, j);
          case null Prim.trap INTERNAL_ERROR
        }
      };
      i -= 1
    };

    null
  };

  /// Returns the first value in `list` for which `predicate` returns true.
  /// If no element satisfies the predicate, returns null.
  ///
  /// ```motoko include=import
  /// let list = List.fromArray<Nat>([1, 9, 4, 8]);
  /// let found = List.find<Nat>(list, func(x) { x > 8 });
  /// assert found == ?9;
  /// ```
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func find<T>(self : List<T>, predicate : T -> Bool) : ?T {
    Option.map<Nat, T>(findIndex<T>(self, predicate), func(i) = at(self, i))
  };

  /// Finds the index of the first element in `list` for which `predicate` is true.
  /// Returns `null` if no such element is found.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.empty<Nat>();
  /// List.add(list, 1);
  /// List.add(list, 2);
  /// List.add(list, 3);
  /// List.add(list, 4);
  ///
  /// assert List.findIndex<Nat>(list, func(i) { i % 2 == 0 }) == ?1;
  /// assert List.findIndex<Nat>(list, func(i) { i > 5 }) == null;
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// *Runtime and space assumes that `predicate` runs in `O(1)` time and space.
  public func findIndex<T>(self : List<T>, predicate : T -> Bool) : ?Nat {
    let blocks = self.blocks;
    let blockCount = blocks.size();

    var i = 1;
    while (i < blockCount) {
      let db = blocks[i];
      let sz = db.size();
      if (sz == 0) return null;

      var j = 0;
      while (j < sz) {
        switch (db[j]) {
          case (?x) if (predicate(x)) return ?indexByBlockElement(i, j);
          case null return null
        };
        j += 1
      };
      i += 1
    };
    null
  };

  /// Finds the index of the last element in `list` for which `predicate` is true.
  /// Returns `null` if no such element is found.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.empty<Nat>();
  /// List.add(list, 1);
  /// List.add(list, 2);
  /// List.add(list, 3);
  /// List.add(list, 4);
  ///
  /// assert List.findLastIndex<Nat>(list, func(i) { i % 2 == 0 }) == ?3;
  /// assert List.findLastIndex<Nat>(list, func(i) { i > 5 }) == null;
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// *Runtime and space assumes that `predicate` runs in `O(1)` time and space.
  public func findLastIndex<T>(self : List<T>, predicate : T -> Bool) : ?Nat {
    let blocks = self.blocks;
    let blockIndex = self.blockIndex;
    let elementIndex = self.elementIndex;

    var i = blockIndex;
    if (elementIndex == 0) i -= 1;

    while (i > 0) {
      let db = blocks[i];
      let sz = db.size();
      var j = if (i == blockIndex) elementIndex else sz;
      while (j > 0) {
        j -= 1;
        switch (db[j]) {
          case (?x) if (predicate(x)) return ?indexByBlockElement(i, j);
          case null Prim.trap INTERNAL_ERROR
        }
      };
      i -= 1
    };

    null
  };

  /// Performs binary search on a sorted list to find the index of the `element`.
  /// Returns `#found(index)` if the element is found, or `#insertionIndex(index)` with the index
  /// where the element would be inserted according to the ordering if not found.
  ///
  /// If there are multiple equal elements, no guarantee is made about which index is returned.
  /// The list must be sorted in ascending order according to the `compare` function.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// let list = List.fromArray<Nat>([1, 3, 5, 7, 9, 11]);
  /// assert List.binarySearch<Nat>(list, Nat.compare, 5) == #found(2);
  /// assert List.binarySearch<Nat>(list, Nat.compare, 6) == #insertionIndex(3);
  /// ```
  ///
  /// Runtime: `O(log(size))`
  ///
  /// Space: `O(1)`
  ///
  /// *Runtime and space assumes that `compare` runs in `O(1)` time and space.
  public func binarySearch<T>(self : List<T>, compare : (implicit : (T, T) -> Types.Order), element : T) : {
    #found : Nat;
    #insertionIndex : Nat
  } {
    // We call all data blocks of the same capacity an "epoch". We number the epochs 0,1,2,...
    // A data block is in epoch e iff the data block has capacity 2 ** e.
    // Each epoch starting with epoch 1 spans exactly two super blocks.
    // Super block s falls in epoch ceil(s/2).
    // Each epoch except e=0 contains 3 * 2 ** (e - 1) data blocks

    let blocks = self.blocks;
    let b = self.blockIndex - (if (self.elementIndex == 0) 1 else 0) : Nat;

    // block index x such that blocks[x][0] <= element
    let lessOrEqual = do {
      // epoch of the last data block
      let epoch = 32 - Nat32.bitcountLeadingZero(Nat32.fromNat(b) / 3);
      // initially block index is the first in the epoch
      var lessOrEqual = Nat32.toNat((1 << epoch) / 2);

      // lessOrEqual * 3 is always the first data block in an epoch
      // while the first element of the first data block in an epoch is actually grater then element go to the previous epoch
      // as the last epoch is half of the array we each iteration of the search divides the interval in four
      while (lessOrEqual != 0 and compare(Option.unwrap(blocks[lessOrEqual * 3][0]), element) == #greater) {
        lessOrEqual /= 2
      };

      lessOrEqual * 3
    };

    // Linear search in e=0, there are just two elements
    if (lessOrEqual == 0) {
      let to = Nat.min(size(self), 2);
      for (i in Nat.range(0, to)) {
        let x = at(self, i);
        switch (compare(x, element)) {
          case (#less) {};
          case (#equal) return #found(i);
          case (#greater) return #insertionIndex(i)
        }
      };
      return #insertionIndex(to)
    };

    // binary search the blockIndex in [left, right)
    let blockIndex = do {
      // guarateed less or equal to element
      var left = lessOrEqual;
      // right is either outside of the array or greater than element
      var right = Nat.min(b + 1, lessOrEqual * 2);
      while (right - left : Nat > 1) {
        let mid = (left + right) / 2;
        switch (compare(Option.unwrap(blocks[mid][0]), element)) {
          case (#less) left := mid;
          case (#greater) right := mid;
          case (#equal) return #found(indexByBlockElement(mid, 0))
        }
      };
      left
    };

    // binary search the elementIndex
    let elementIndex = do {
      let block = blocks[blockIndex];
      var left = 0;
      var right = if (blockIndex == self.blockIndex) self.elementIndex else block.size();
      while (left != right) {
        let mid = (left + right) / 2;
        switch (compare(Option.unwrap(block[mid]), element)) {
          case (#less) left := mid + 1;
          case (#greater) right := mid;
          case (#equal) return #found(indexByBlockElement(blockIndex, mid))
        }
      };
      left
    };

    #insertionIndex(indexByBlockElement(blockIndex, elementIndex))
  };

  /// Returns true iff every element in `list` satisfies `predicate`.
  /// In particular, if `list` is empty the function returns `true`.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.empty<Nat>();
  /// List.add(list, 2);
  /// List.add(list, 3);
  /// List.add(list, 4);
  ///
  /// assert List.all<Nat>(list, func x { x > 1 });
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  ///
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func all<T>(self : List<T>, predicate : T -> Bool) : Bool {
    let blocks = self.blocks;
    let blockCount = blocks.size();

    var i = 1;
    while (i < blockCount) {
      let db = blocks[i];
      let sz = db.size();
      if (sz == 0) return true;

      var j = 0;
      while (j < sz) {
        switch (db[j]) {
          case (?x) if (not predicate(x)) return false;
          case null return true
        };
        j += 1
      };
      i += 1
    };
    true
  };

  /// Returns true iff some element in `list` satisfies `predicate`.
  /// In particular, if `list` is empty the function returns `false`.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.empty<Nat>();
  /// List.add(list, 2);
  /// List.add(list, 3);
  /// List.add(list, 4);
  ///
  /// assert List.any<Nat>(list, func x { x > 3 });
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  ///
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func any<T>(self : List<T>, predicate : T -> Bool) : Bool = findIndex<T>(self, predicate) != null;

  /// Returns an Iterator (`Iter`) over the elements of a List.
  /// Iterator provides a single method `next()`, which returns
  /// elements in order, or `null` when out of elements to iterate over.
  ///
  /// ```motoko include=import
  /// let list = List.empty<Nat>();
  /// List.add(list, 10);
  /// List.add(list, 11);
  /// List.add(list, 12);
  ///
  /// var sum = 0;
  /// for (element in List.values(list)) {
  ///   sum += element;
  /// };
  /// assert sum == 33;
  /// ```
  ///
  /// Note: This does not create a snapshot. If the returned iterator is not consumed at once,
  /// and instead the consumption of the iterator is interleaved with other operations on the
  /// List, then this may lead to unexpected results.
  ///
  /// Runtime: `O(1)`
  public func values<T>(self : List<T>) : Types.Iter<T> = object {
    let blocks = self.blocks.size();
    var blockIndex = 0;
    var elementIndex = 0;
    var db : [var ?T] = self.blocks[blockIndex];
    var dbSize = db.size();

    public func next() : ?T {
      if (elementIndex == dbSize) {
        blockIndex += 1;
        if (blockIndex >= blocks) return null;
        db := self.blocks[blockIndex];
        dbSize := db.size();
        if (dbSize == 0) return null;
        elementIndex := 0
      };
      switch (db[elementIndex]) {
        case (?x) {
          elementIndex += 1;
          return ?x
        };
        case (_) return null
      }
    }
  };

  /// Returns an Iterator (`Iter`) over the items (index-value pairs) in the list.
  /// Each item is a tuple of `(index, value)`. The iterator provides a single method
  /// `next()` which returns elements in order, or `null` when out of elements.
  ///
  /// ```motoko include=import
  /// import Iter "mo:core/Iter";
  ///
  /// let list = List.empty<Nat>();
  /// List.add(list, 10);
  /// List.add(list, 11);
  /// List.add(list, 12);
  /// assert Iter.toArray(List.enumerate(list)) == [(0, 10), (1, 11), (2, 12)];
  /// ```
  ///
  /// Note: This does not create a snapshot. If the returned iterator is not consumed at once,
  /// and instead the consumption of the iterator is interleaved with other operations on the
  /// List, then this may lead to unexpected results.
  ///
  /// Runtime: `O(1)`
  ///
  /// Warning: Allocates memory on the heap to store ?(Nat, T).
  public func enumerate<T>(self : List<T>) : Types.Iter<(Nat, T)> = object {
    let blocks = self.blocks.size();
    var blockIndex = 0;
    var elementIndex = 0;
    var size = 0;
    var db : [var ?T] = [var];
    var i = 0;

    public func next() : ?(Nat, T) {
      if (elementIndex == size) {
        blockIndex += 1;
        if (blockIndex >= blocks) return null;
        db := self.blocks[blockIndex];
        size := db.size();
        if (size == 0) return null;
        elementIndex := 0
      };
      switch (db[elementIndex]) {
        case (?x) {
          let ret = ?(i, x);
          elementIndex += 1;
          i += 1;
          return ret
        };
        case (_) return null
      }
    }
  };

  /// Returns an Iterator (`Iter`) over the elements of the list in reverse order.
  /// The iterator provides a single method `next()` which returns elements from
  /// last to first, or `null` when out of elements.
  ///
  /// ```motoko include=import
  /// let list = List.empty<Nat>();
  /// List.add(list, 10);
  /// List.add(list, 11);
  /// List.add(list, 12);
  ///
  /// var sum = 0;
  /// for (element in List.reverseValues(list)) {
  ///   sum += element;
  /// };
  /// assert sum == 33;
  /// ```
  ///
  /// Note: This does not create a snapshot. If the returned iterator is not consumed at once,
  /// and instead the consumption of the iterator is interleaved with other operations on the
  /// List, then this may lead to unexpected results.
  ///
  /// Runtime: `O(1)`
  public func reverseValues<T>(self : List<T>) : Types.Iter<T> = object {
    var blockIndex = self.blockIndex;
    var elementIndex = self.elementIndex;
    var db : [var ?T] = if (blockIndex < self.blocks.size()) {
      self.blocks[blockIndex]
    } else { [var] };

    public func next() : ?T {
      if (elementIndex != 0) {
        elementIndex -= 1
      } else {
        blockIndex -= 1;
        if (blockIndex == 0) return null;
        db := self.blocks[blockIndex];
        elementIndex := db.size() - 1
      };

      db[elementIndex]
    }
  };

  /// Returns an Iterator (`Iter`) over the items in reverse order, i.e. pairs of index and value.
  /// Iterator provides a single method `next()`, which returns
  /// elements in reverse order, or `null` when out of elements to iterate over.
  ///
  /// ```motoko include=import
  /// import Iter "mo:core/Iter";
  ///
  /// let list = List.empty<Nat>();
  /// List.add(list, 10);
  /// List.add(list, 11);
  /// List.add(list, 12);
  /// assert Iter.toArray(List.reverseEnumerate(list)) == [(2, 12), (1, 11), (0, 10)];
  /// ```
  ///
  /// Note: This does not create a snapshot. If the returned iterator is not consumed at once,
  /// and instead the consumption of the iterator is interleaved with other operations on the
  /// List, then this may lead to unexpected results.
  ///
  /// Runtime: `O(1)`
  ///
  /// Warning: Allocates memory on the heap to store ?(T, Nat).
  public func reverseEnumerate<T>(self : List<T>) : Types.Iter<(Nat, T)> = object {
    var i = size(self);
    var blockIndex = self.blockIndex;
    var elementIndex = self.elementIndex;
    var db : [var ?T] = if (blockIndex < self.blocks.size()) {
      self.blocks[blockIndex]
    } else { [var] };

    public func next() : ?(Nat, T) {
      if (elementIndex != 0) {
        elementIndex -= 1
      } else {
        blockIndex -= 1;
        if (blockIndex == 0) return null;
        db := self.blocks[blockIndex];
        elementIndex := db.size() - 1
      };
      switch (db[elementIndex]) {
        case (?x) {
          i -= 1;
          return ?(i, x)
        };
        case (_) Prim.trap INTERNAL_ERROR
      }
    }
  };

  /// Returns an Iterator (`Iter`) over the indices (keys) of the list.
  /// The iterator provides a single method `next()` which returns indices
  /// from 0 to size-1, or `null` when out of elements.
  ///
  /// ```motoko include=import
  /// import Iter "mo:core/Iter";
  ///
  /// let list = List.empty<Text>();
  /// List.add(list, "A");
  /// List.add(list, "B");
  /// List.add(list, "C");
  /// Iter.toArray(List.keys(list)) // [0, 1, 2]
  /// ```
  ///
  /// Note: This does not create a snapshot. If the returned iterator is not consumed at once,
  /// and instead the consumption of the iterator is interleaved with other operations on the
  /// List, then this may lead to unexpected results.
  ///
  /// Runtime: `O(1)`
  public func keys<T>(self : List<T>) : Types.Iter<Nat> = Nat.range(0, size(self));

  /// Creates a new List containing all elements from the provided iterator.
  /// Elements are added in the order they are returned by the iterator.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  /// import Iter "mo:core/Iter";
  ///
  /// let array = [1, 1, 1];
  /// let iter = array.vals();
  ///
  /// let list = List.fromIter<Nat>(iter);
  /// assert Iter.toArray(List.values(list)) == [1, 1, 1];
  /// ```
  ///
  /// Runtime: `O(size)`
  public func fromIter<T>(iter : Types.Iter<T>) : List<T> {
    let list = empty<T>();
    for (element in iter) add(list, element);
    list
  };

  /// Convert an iterator to a new mutable List.
  /// Elements are added in the order they are returned by the iterator.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  /// import Iter "mo:core/Iter";
  ///
  /// let array = [1, 1, 1];
  /// let iter = array.vals();
  ///
  /// let list = iter.toList<Nat>();
  /// assert Iter.toArray(List.values(list)) == [1, 1, 1];
  /// ```
  ///
  /// Runtime: `O(size)`
  public func toList<T>(self : Types.Iter<T>) : List<T> {
    fromIter(self)
  };

  /// Appends all elements from `added` to the end of `list`.
  /// Example:
  /// ```motoko include=import
  /// let list = List.fromArray<Nat>([1, 2]);
  /// let added = List.fromArray<Nat>([3, 4]);
  /// List.append<Nat>(list, added);
  /// assert List.toArray(list) == [1, 2, 3, 4];
  /// ```
  ///
  /// Runtime: `O(size(added))`
  ///
  /// Space: `O(size(added))`
  public func append<T>(self : List<T>, added : List<T>) {
    reserve(self, size(added));

    let blocks = added.blocks;
    let blockCount = blocks.size();

    var i = 1;
    while (i < blockCount) {
      let db = blocks[i];
      let sz = db.size();
      if (sz == 0) return;

      var j = 0;
      while (j < sz) {
        switch (db[j]) {
          case (?x) addUnsafe(self, x);
          case null return
        };
        j += 1
      };
      i += 1
    }
  };

  /// Adds all elements from the provided iterator to the end of the list.
  /// Elements are added in the order they are returned by the iterator.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  /// import Iter "mo:core/Iter";
  ///
  /// let array = [1, 1, 1];
  /// let iter = array.vals();
  /// let list = List.repeat<Nat>(2, 1);
  ///
  /// List.addAll<Nat>(list, iter);
  /// assert Iter.toArray(List.values(list)) == [2, 1, 1, 1];
  /// ```
  ///
  /// The maximum number of elements in a `List` is 2^32.
  ///
  /// Runtime: `O(size)`, where n is the size of iter.
  public func addAll<T>(self : List<T>, iter : Types.Iter<T>) {
    for (element in iter) add(self, element)
  };

  /// Creates a new immutable array containing all elements from the list.
  /// Elements appear in the same order as in the list.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.fromArray<Nat>([1, 2, 3]);
  ///
  /// assert List.toArray<Nat>(list) == [1, 2, 3];
  /// ```
  ///
  /// Runtime: `O(size)`
  public func toArray<T>(self : List<T>) : [T] {
    var blockIndex = 0;
    var elementIndex = 0;
    var sz = 0;
    var db : [var ?T] = [var];

    func generator(_ : Nat) : T {
      if (elementIndex == sz) {
        blockIndex += 1;
        db := self.blocks[blockIndex];
        sz := db.size();
        elementIndex := 0
      };
      switch (db[elementIndex]) {
        case (?x) {
          elementIndex += 1;
          return x
        };
        case (_) Prim.trap INTERNAL_ERROR
      }
    };

    Array.tabulate<T>(size(self), generator)
  };

  /// Creates a List containing elements from an Array.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  /// import Iter "mo:core/Iter";
  ///
  /// let array = [2, 3];
  /// let list = List.fromArray<Nat>(array);
  /// assert Iter.toArray(List.values(list)) == [2, 3];
  /// ```
  ///
  /// Runtime: `O(size)`
  public func fromArray<T>(array : [T]) : List<T> {
    let (blockIndex, elementIndex) = locate(array.size());

    let blocks = newIndexBlockLength(Nat32.fromNat(if (elementIndex == 0) { blockIndex - 1 } else blockIndex));
    let dataBlocks = VarArray.repeat<[var ?T]>([var], blocks);

    var i = 1;
    var pos = 0;

    while (i < blockIndex) {
      let len = dataBlockSize(i);
      dataBlocks[i] := VarArray.tabulate<?T>(len, func i = ?array[pos + i]);
      pos += len;
      i += 1
    };
    if (elementIndex != 0 and blockIndex < blocks) {
      dataBlocks[i] := VarArray.tabulate<?T>(
        dataBlockSize(i),
        func i = if (i < elementIndex) ?array[pos + i] else null
      )
    };

    {
      var blocks = dataBlocks;
      var blockIndex = blockIndex;
      var elementIndex = elementIndex
    }
  };

  /// Creates a new mutable array containing all elements from the list.
  /// Elements appear in the same order as in the list.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Array "mo:core/Array";
  ///
  /// let list = List.fromArray<Nat>([1, 2, 3]);
  ///
  /// let varArray = List.toVarArray<Nat>(list);
  /// assert Array.fromVarArray(varArray) == [1, 2, 3];
  /// ```
  ///
  /// Runtime: `O(size)`
  public func toVarArray<T>(self : List<T>) : [var T] {
    let ?fs = first(self) else return [var];

    let array = VarArray.repeat<T>(fs, size(self));

    var index = 0;

    let blocks = self.blocks;
    let blockCount = blocks.size();

    var i = 1;
    while (i < blockCount) {
      let db = blocks[i];
      let sz = db.size();
      if (sz == 0) return array;

      var j = 0;
      while (j < sz) {
        switch (db[j]) {
          case (?x) array[index] := x;
          case null return array
        };
        j += 1;
        index += 1
      };
      i += 1
    };
    array
  };

  /// Creates a new List containing all elements from the mutable array.
  /// Elements appear in the same order as in the array.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  /// import Iter "mo:core/Iter";
  ///
  /// let array = [var 2, 3];
  /// let list = List.fromVarArray<Nat>(array);
  /// assert Iter.toArray(List.values(list)) == [2, 3];
  /// ```
  ///
  /// Runtime: `O(size)`
  public func fromVarArray<T>(array : [var T]) : List<T> {
    let (blockIndex, elementIndex) = locate(array.size());

    let blocks = newIndexBlockLength(Nat32.fromNat(if (elementIndex == 0) { blockIndex - 1 } else blockIndex));
    let dataBlocks = VarArray.repeat<[var ?T]>([var], blocks);

    func makeBlock(array : [var T], p : Nat, len : Nat, fill : Nat) : [var ?T] {
      let block = VarArray.repeat<?T>(null, len);
      var j = 0;
      var pos = p;
      while (j < fill) {
        block[j] := ?array[pos];
        j += 1;
        pos += 1
      };
      block
    };

    var i = 1;
    var pos = 0;

    while (i < blockIndex) {
      let len = dataBlockSize(i);
      dataBlocks[i] := makeBlock(array, pos, len, len);
      pos += len;
      i += 1
    };
    if (elementIndex != 0) {
      dataBlocks[i] := makeBlock(array, pos, dataBlockSize(i), elementIndex)
    };

    {
      var blocks = dataBlocks;
      var blockIndex = blockIndex;
      var elementIndex = elementIndex
    }
  };

  /// Returns the first element of `list`, or `null` if the list is empty.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert List.first(List.fromArray<Nat>([1, 2, 3])) == ?1;
  /// assert List.first(List.empty<Nat>()) == null;
  /// ```
  ///
  /// Runtime: `O(1)`
  ///
  /// Space: `O(1)`
  public func first<T>(self : List<T>) : ?T {
    if (self.blockIndex == 1) null else self.blocks[1][0]
  };

  /// Returns the last element of `list`, or `null` if the list is empty.
  ///
  /// Example:
  /// ```motoko include=import
  /// assert List.last(List.fromArray<Nat>([1, 2, 3])) == ?3;
  /// assert List.last(List.empty<Nat>()) == null;
  /// ```
  ///
  /// Runtime: `O(1)`
  ///
  /// Space: `O(1)`
  public func last<T>(self : List<T>) : ?T {
    let e = self.elementIndex;
    if (e > 0) return self.blocks[self.blockIndex][e - 1];

    let b = self.blockIndex - 1 : Nat;
    if (b == 0) null else {
      let block = self.blocks[b];
      block[block.size() - 1]
    }
  };

  /// Applies `f` to each element in `list`.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  /// import Debug "mo:core/Debug";
  ///
  /// let list = List.fromArray<Nat>([1, 2, 3]);
  ///
  /// List.forEach<Nat>(list, func(x) {
  ///   Debug.print(Nat.toText(x)); // prints each element in list
  /// });
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func forEach<T>(self : List<T>, f : T -> ()) {
    let blocks = self.blocks;
    let blockCount = blocks.size();

    var i = 1;
    while (i < blockCount) {
      let db = blocks[i];
      let sz = db.size();
      if (sz == 0) return;

      var j = 0;
      while (j < sz) {
        switch (db[j]) {
          case (?x) f(x);
          case null return
        };
        j += 1
      };
      i += 1
    }
  };

  /// Applies `f` to each item `(i, x)` in `list` where `i` is the key
  /// and `x` is the value.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  /// import Debug "mo:core/Debug";
  ///
  /// let list = List.fromArray<Nat>([1, 2, 3]);
  ///
  /// List.forEachEntry<Nat>(list, func (i,x) {
  ///   // prints each item (i,x) in list
  ///   Debug.print(Nat.toText(i) # Nat.toText(x));
  /// });
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func forEachEntry<T>(self : List<T>, f : (Nat, T) -> ()) {
    var index = 0;
    let blocks = self.blocks;
    let blockCount = blocks.size();

    var i = 1;
    while (i < blockCount) {
      let db = blocks[i];
      let sz = db.size();
      if (sz == 0) return;

      var j = 0;
      while (j < sz) {
        switch (db[j]) {
          case (?x) f(index, x);
          case null return
        };
        j += 1;
        index += 1
      };
      i += 1
    }
  };

  func actualInterval(fromInclusive : Int, toExclusive : Int, size : Nat) : (Nat, Nat) {
    let startInt = if (fromInclusive < 0) {
      let s = size + fromInclusive;
      if (s < 0) { 0 } else { s }
    } else {
      if (fromInclusive > size) { size } else { fromInclusive }
    };
    let endInt = if (toExclusive < 0) {
      let e = size + toExclusive;
      if (e < 0) { 0 } else { e }
    } else {
      if (toExclusive > size) { size } else { toExclusive }
    };
    (Prim.abs(startInt), Prim.abs(endInt))
  };

  /// Returns an iterator over a slice of `list` starting at `fromInclusive` up to (but not including) `toExclusive`.
  ///
  /// Negative indices are relative to the end of the list. For example, `-1` corresponds to the last element in the list.
  ///
  /// If the indices are out of bounds, they are clamped to the list bounds.
  /// If the first index is greater than the second, the function returns an empty iterator.
  ///
  /// ```motoko include=import
  /// let list = List.fromArray<Nat>([1, 2, 3, 4, 5]);
  /// let iter1 = List.range<Nat>(list, 3, List.size(list));
  /// assert iter1.next() == ?4;
  /// assert iter1.next() == ?5;
  /// assert iter1.next() == null;
  ///
  /// let iter2 = List.range<Nat>(list, 3, -1);
  /// assert iter2.next() == ?4;
  /// assert iter2.next() == null;
  ///
  /// let iter3 = List.range<Nat>(list, 0, 0);
  /// assert iter3.next() == null;
  /// ```
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func range<T>(self : List<T>, fromInclusive : Int, toExclusive : Int) : Types.Iter<T> = object {
    let (start, end) = actualInterval(fromInclusive, toExclusive, size(self));
    let blocks = self.blocks.size();
    var blockIndex = 0;
    var elementIndex = 0;
    if (start != 0) {
      let (block, element) = locate(start - 1);
      blockIndex := block;
      elementIndex := element + 1
    };
    var db : [var ?T] = self.blocks[blockIndex];
    var dbSize = db.size();
    var index = fromInclusive;

    public func next() : ?T {
      if (index >= end) return null;
      index += 1;

      if (elementIndex == dbSize) {
        blockIndex += 1;
        if (blockIndex >= blocks) return null;
        db := self.blocks[blockIndex];
        dbSize := db.size();
        if (dbSize == 0) return null;
        elementIndex := 0
      };
      let ret = db[elementIndex];
      elementIndex += 1;
      ret
    }
  };

  func sliceToArrayBase<T>(self : List<T>, start : Nat) : {
    next(i : Nat) : T
  } = object {
    var blockIndex = 0;
    var elementIndex = 0;
    if (start != 0) {
      let (block, element) = locate(start - 1);
      blockIndex := block;
      elementIndex := element + 1
    };
    var db : [var ?T] = self.blocks[blockIndex];
    var dbSize = db.size();

    public func next(i : Nat) : T {
      if (elementIndex == dbSize) {
        blockIndex += 1;
        db := self.blocks[blockIndex];
        dbSize := db.size();
        elementIndex := 0
      };
      switch (db[elementIndex]) {
        case (?x) {
          elementIndex += 1;
          return x
        };
        case null Prim.trap INTERNAL_ERROR
      }
    }
  };

  /// Returns a new array containing elements from `list` starting at index `fromInclusive` up to (but not including) index `toExclusive`.
  /// If the indices are out of bounds, they are clamped to the array bounds.
  ///
  /// ```motoko include=import
  /// let array = List.fromArray<Nat>([1, 2, 3, 4, 5]);
  ///
  /// let slice1 = List.sliceToArray<Nat>(array, 1, 4);
  /// assert slice1 == [2, 3, 4];
  ///
  /// let slice2 = List.sliceToArray<Nat>(array, 1, -1);
  /// assert slice2 == [2, 3, 4];
  /// ```
  ///
  /// Runtime: O(toExclusive - fromInclusive)
  ///
  /// Space: O(toExclusive - fromInclusive)
  public func sliceToArray<T>(self : List<T>, fromInclusive : Int, toExclusive : Int) : [T] {
    let (start, end) = actualInterval(fromInclusive, toExclusive, size(self));
    Array.tabulate<T>(end - start, sliceToArrayBase(self, start).next)
  };

  /// Returns a new var array containing elements from `list` starting at index `fromInclusive` up to (but not including) index `toExclusive`.
  /// If the indices are out of bounds, they are clamped to the array bounds.
  ///
  /// ```motoko include=import
  /// import VarArray "mo:core/VarArray";
  /// import Nat "mo:core/Nat";
  ///
  /// let array = List.fromArray<Nat>([1, 2, 3, 4, 5]);
  ///
  /// let slice1 = List.sliceToVarArray<Nat>(array, 1, 4);
  /// assert VarArray.equal(slice1, [var 2, 3, 4], Nat.equal);
  ///
  /// let slice2 = List.sliceToVarArray<Nat>(array, 1, -1);
  /// assert VarArray.equal(slice2, [var 2, 3, 4], Nat.equal);
  /// ```
  ///
  /// Runtime: O(toExclusive - fromInclusive)
  ///
  /// Space: O(toExclusive - fromInclusive)
  public func sliceToVarArray<T>(self : List<T>, fromInclusive : Int, toExclusive : Int) : [var T] {
    let (start, end) = actualInterval(fromInclusive, toExclusive, size(self));
    VarArray.tabulate<T>(end - start, sliceToArrayBase(self, start).next)
  };

  /// Like `forEachEntryRev` but iterates through the list in reverse order,
  /// from end to beginning.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  /// import Debug "mo:core/Debug";
  ///
  /// let list = List.fromArray<Nat>([1, 2, 3]);
  ///
  /// List.reverseForEachEntry<Nat>(list, func (i,x) {
  ///   // prints each item (i,x) in list
  ///   Debug.print(Nat.toText(i) # Nat.toText(x));
  /// });
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func reverseForEachEntry<T>(self : List<T>, f : (Nat, T) -> ()) {
    var index = 0;

    let blocks = self.blocks;
    let blockIndex = self.blockIndex;
    let elementIndex = self.elementIndex;

    var i = blockIndex;
    if (elementIndex == 0) i -= 1;

    while (i > 0) {
      let db = blocks[i];
      let sz = db.size();
      var j = if (i == blockIndex) elementIndex else sz;
      while (j > 0) {
        j -= 1;
        switch (db[j]) {
          case (?x) f(index, x);
          case null Prim.trap INTERNAL_ERROR
        };
        index += 1
      };
      i -= 1
    }
  };

  /// Applies `f` to each element in `list` in reverse order.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  /// import Debug "mo:core/Debug";
  ///
  /// let list = List.fromArray<Nat>([1, 2, 3]);
  ///
  /// List.reverseForEach<Nat>(list, func (x) {
  ///   Debug.print(Nat.toText(x)); // prints each element in list in reverse order
  /// });
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func reverseForEach<T>(self : List<T>, f : T -> ()) {
    let blocks = self.blocks;
    let blockIndex = self.blockIndex;
    let elementIndex = self.elementIndex;

    var i = blockIndex;
    if (elementIndex == 0) i -= 1;

    while (i > 0) {
      let db = blocks[i];
      let sz = db.size();
      var j = if (i == blockIndex) elementIndex else sz;
      while (j > 0) {
        j -= 1;
        switch (db[j]) {
          case (?x) f(x);
          case null Prim.trap INTERNAL_ERROR
        }
      };
      i -= 1
    }
  };

  /// Executes the closure over a slice of `list` starting at `fromInclusive` up to (but not including) `toExclusive`.
  ///
  /// ```motoko include=import
  /// import Debug "mo:core/Debug";
  /// import Nat "mo:core/Nat";
  ///
  /// let list = List.fromArray<Nat>([1, 2, 3, 4, 5]);
  /// List.forEachInRange<Nat>(list, func x = Debug.print(Nat.toText(x)), 1, 2); // prints 2 and 3
  /// ```
  ///
  /// Runtime: `O(toExclusive - fromExclusive)`
  ///
  /// Space: `O(1)`
  public func forEachInRange<T>(self : List<T>, f : T -> (), fromInclusive : Nat, toExclusive : Nat) {
    if (not (fromInclusive <= toExclusive and toExclusive <= size(self))) Prim.trap("Invalid range");

    func traverseBlock(block : [var ?T], f : T -> (), from : Nat, to : Nat) {
      var i = from;
      while (i < to) {
        switch (block[i]) {
          case (?value) f(value);
          case null Prim.trap(INTERNAL_ERROR)
        };
        i += 1
      }
    };

    let (fromBlock, fromElement) = locate(fromInclusive);
    let (toBlock, toElement) = locate(toExclusive);

    let blocks = self.blocks;
    let sz = blocks.size();

    if (fromBlock == toBlock) {
      if (fromBlock < sz) traverseBlock(blocks[fromBlock], f, fromElement, toElement);
      return
    };

    traverseBlock(blocks[fromBlock], f, fromElement, blocks[fromBlock].size());

    var i = fromBlock + 1;
    let to = Nat.min(toBlock, sz);
    while (i < to) {
      traverseBlock(blocks[i], f, 0, blocks[i].size());
      i += 1
    };

    if (toBlock < sz) traverseBlock(blocks[toBlock], f, 0, toElement)
  };

  /// Returns true if the list contains the specified element according to the provided
  /// equality function. Uses the provided `equal` function to compare elements.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// let list = List.empty<Nat>();
  /// List.add(list, 2);
  /// List.add(list, 0);
  /// List.add(list, 3);
  ///
  /// assert List.contains<Nat>(list, Nat.equal, 2);
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func contains<T>(self : List<T>, equal : (implicit : (T, T) -> Bool), element : T) : Bool {
    Option.isSome(indexOf(self, equal, element))
  };

  /// Returns the greatest element in the list according to the ordering defined by `compare`.
  /// Returns `null` if the list is empty.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// let list = List.empty<Nat>();
  /// List.add(list, 1);
  /// List.add(list, 2);
  ///
  /// assert List.max<Nat>(list, Nat.compare) == ?2;
  /// assert List.max<Nat>(List.empty<Nat>(), Nat.compare) == null;
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  ///
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func max<T>(self : List<T>, compare : (implicit : (T, T) -> Types.Order)) : ?T {
    var maxSoFar : T = switch (first(self)) {
      case (?x) x;
      case null return null
    };

    let blocks = self.blocks;
    let blockCount = blocks.size();

    var i = 2;
    while (i < blockCount) {
      let db = blocks[i];
      let sz = db.size();
      if (sz == 0) return ?maxSoFar;

      var j = 0;
      while (j < sz) {
        switch (db[j]) {
          case (?x) switch (compare(x, maxSoFar)) {
            case (#greater) maxSoFar := x;
            case _ {}
          };
          case null return ?maxSoFar
        };
        j += 1
      };
      i += 1
    };

    ?maxSoFar
  };

  /// Returns the least element in the list according to the ordering defined by `compare`.
  /// Returns `null` if the list is empty.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// let list = List.empty<Nat>();
  /// List.add(list, 1);
  /// List.add(list, 2);
  ///
  /// assert List.min<Nat>(list, Nat.compare) == ?1;
  /// assert List.min<Nat>(List.empty<Nat>(), Nat.compare) == null;
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  ///
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func min<T>(self : List<T>, compare : (implicit : (T, T) -> Types.Order)) : ?T {
    var minSoFar : T = switch (first(self)) {
      case (?x) x;
      case null return null
    };

    let blocks = self.blocks;
    let blockCount = blocks.size();

    var i = 2;
    while (i < blockCount) {
      let db = blocks[i];
      let sz = db.size();
      if (sz == 0) return ?minSoFar;

      var j = 0;
      while (j < sz) {
        switch (db[j]) {
          case (?x) switch (compare(x, minSoFar)) {
            case (#less) minSoFar := x;
            case _ {}
          };
          case null return ?minSoFar
        };
        j += 1
      };
      i += 1
    };

    ?minSoFar
  };

  /// Tests if two lists are equal by comparing their elements using the provided `equal` function.
  /// Returns true if and only if both lists have the same size and all corresponding elements
  /// are equal according to the provided function.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// let list1 = List.fromArray<Nat>([1,2]);
  /// let list2 = List.empty<Nat>();
  /// List.add(list2, 1);
  /// List.add(list2, 2);
  ///
  /// assert List.equal<Nat>(list1, list2, Nat.equal);
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func equal<T>(self : List<T>, other : List<T>, equal : (implicit : (T, T) -> Bool)) : Bool {
    if (size(self) != size(other)) return false;

    let blocks1 = self.blocks;
    let blocks2 = other.blocks;
    let blockCount = Nat.min(blocks1.size(), blocks2.size());

    var i = 1;
    while (i < blockCount) {
      let db1 = blocks1[i];
      let db2 = blocks2[i];
      let sz = Nat.min(db1.size(), db2.size());
      if (sz == 0) return true;

      var j = 0;
      while (j < sz) {
        switch (db1[j], db2[j]) {
          case (?x, ?y) if (not equal(x, y)) return false;
          case (_, _) return true
        };
        j += 1
      };
      i += 1
    };
    return true
  };

  /// Compares two lists lexicographically using the provided `compare` function.
  /// Elements are compared pairwise until a difference is found or one list ends.
  /// If all elements compare equal, the shorter list is considered less than the longer list.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// let list1 = List.fromArray<Nat>([0, 1]);
  /// let list2 = List.fromArray<Nat>([2]);
  /// let list3 = List.fromArray<Nat>([0, 1, 2]);
  ///
  /// assert List.compare<Nat>(list1, list2, Nat.compare) == #less;
  /// assert List.compare<Nat>(list1, list3, Nat.compare) == #less;
  /// assert List.compare<Nat>(list2, list3, Nat.compare) == #greater;
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  ///
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func compare<T>(self : List<T>, other : List<T>, compare : (implicit : (T, T) -> Types.Order)) : Types.Order {
    let blocks1 = self.blocks;
    let blocks2 = other.blocks;
    let blockCount = Nat.min(blocks1.size(), blocks2.size());

    var i = 1;
    label l while (i < blockCount) {
      let db1 = blocks1[i];
      let db2 = blocks2[i];
      let sz = Nat.min(db1.size(), db2.size());
      if (sz == 0) break l;

      var j = 0;
      while (j < sz) {
        switch (db1[j], db2[j]) {
          case (?x, ?y) switch (compare(x, y)) {
            case (#less) return #less;
            case (#greater) return #greater;
            case _ {}
          };
          case (_, _) break l
        };
        j += 1
      };
      i += 1
    };
    return Nat.compare(size(self), size(other))
  };

  /// Creates a textual representation of `list`, using `toText` to recursively
  /// convert the elements into Text.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// let list = List.fromArray<Nat>([1,2,3,4]);
  ///
  /// assert List.toText<Nat>(list, Nat.toText) == "List[1, 2, 3, 4]";
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that `toText` runs in O(1) time and space.
  public func toText<T>(self : List<T>, toText : (implicit : T -> Text)) : Text {
    var text = switch (first(self)) {
      case (?x) toText(x);
      case null ""
    };

    let blocks = self.blocks;
    let blockCount = blocks.size();

    var i = 2;
    label l while (i < blockCount) {
      let db = blocks[i];
      let sz = db.size();
      if (sz == 0) break l;

      var j = 0;
      while (j < sz) {
        switch (db[j]) {
          case (?x) text #= ", " # toText(x);
          case null break l
        };
        j += 1
      };
      i += 1
    };

    "List[" # text # "]"
  };

  /// Collapses the elements in `list` into a single value by starting with `base`
  /// and progessively combining elements into `base` with `combine`. Iteration runs
  /// left to right.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// let list = List.fromArray<Nat>([1,2,3]);
  ///
  /// assert List.foldLeft<Text, Nat>(list, "", func (acc, x) { acc # Nat.toText(x)}) == "123";
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  ///
  /// *Runtime and space assumes that `combine` runs in O(1)` time and space.
  public func foldLeft<A, T>(self : List<T>, base : A, combine : (A, T) -> A) : A {
    var accumulation = base;

    let blocks = self.blocks;
    let blockCount = blocks.size();

    var i = 1;
    while (i < blockCount) {
      let db = blocks[i];
      let sz = db.size();
      if (sz == 0) return accumulation;

      var j = 0;
      while (j < sz) {
        switch (db[j]) {
          case (?x) accumulation := combine(accumulation, x);
          case null return accumulation
        };
        j += 1
      };
      i += 1
    };
    accumulation
  };

  /// Collapses the elements in `list` into a single value by starting with `base`
  /// and progessively combining elements into `base` with `combine`. Iteration runs
  /// right to left.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  ///
  /// let list = List.fromArray<Nat>([1,2,3]);
  ///
  /// assert List.foldRight<Nat, Text>(list, "", func (x, acc) { Nat.toText(x) # acc }) == "123";
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  ///
  /// *Runtime and space assumes that `combine` runs in O(1)` time and space.
  public func foldRight<T, A>(self : List<T>, base : A, combine : (T, A) -> A) : A {
    var accumulation = base;

    let blocks = self.blocks;
    let blockIndex = self.blockIndex;
    let elementIndex = self.elementIndex;

    var i = blockIndex;
    if (elementIndex == 0) i -= 1;

    while (i > 0) {
      let db = blocks[i];
      let sz = db.size();
      var j = if (i == blockIndex) elementIndex else sz;
      while (j > 0) {
        j -= 1;
        switch (db[j]) {
          case (?x) accumulation := combine(x, accumulation);
          case null Prim.trap INTERNAL_ERROR
        }
      };
      i -= 1
    };

    accumulation
  };

  /// Reverses the order of elements in `list` by overwriting in place.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  /// import Iter "mo:core/Iter";
  ///
  /// let list = List.fromArray<Nat>([1,2,3]);
  ///
  /// List.reverseInPlace<Nat>(list);
  /// assert Iter.toArray(List.values(list)) == [3, 2, 1];
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  public func reverseInPlace<T>(self : List<T>) {
    let vsize = size(self);
    if (vsize <= 1) return;

    let (finalBlock, finalElement) = locate(vsize / 2);

    let blocks = self.blocks;

    var blockIndexBack = self.blockIndex;
    var elementIndexBack = self.elementIndex;
    var dbBack : [var ?T] = if (blockIndexBack < self.blocks.size()) {
      self.blocks[blockIndexBack]
    } else { [var] };

    var i = 1;
    var index = 0;
    while (i <= finalBlock) {
      let db = blocks[i];
      let sz = if (i == finalBlock) finalElement else db.size();

      var j = 0;
      while (j < sz) {
        if (elementIndexBack == 0) {
          blockIndexBack -= 1;
          dbBack := self.blocks[blockIndexBack];
          elementIndexBack := dbBack.size() - 1
        } else {
          elementIndexBack -= 1
        };

        let temp = db[j];
        db[j] := dbBack[elementIndexBack];
        dbBack[elementIndexBack] := temp;

        j += 1;
        index += 1
      };
      i += 1
    }
  };

  /// Returns a new List with the elements from `list` in reverse order.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:core/Nat";
  /// import Iter "mo:core/Iter";
  ///
  /// let list = List.fromArray<Nat>([1,2,3]);
  ///
  /// let rlist = List.reverse<Nat>(list);
  /// assert Iter.toArray(List.values(rlist)) == [3, 2, 1];
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  public func reverse<T>(self : List<T>) : List<T> {
    let rlist = repeatInternal<T>(null, size(self));

    let blocks = self.blocks;
    let blockCount = blocks.size();

    var blockIndexBack = rlist.blockIndex;
    var elementIndexBack = rlist.elementIndex;
    var dbBack : [var ?T] = if (blockIndexBack < rlist.blocks.size()) {
      rlist.blocks[blockIndexBack]
    } else { [var] };

    var i = 1;
    while (i < blockCount) {
      let db = blocks[i];
      let sz = db.size();
      if (sz == 0) return rlist;

      var j = 0;
      while (j < sz) {
        if (elementIndexBack == 0) {
          blockIndexBack -= 1;
          if (blockIndexBack == 0) return rlist;
          dbBack := rlist.blocks[blockIndexBack];
          elementIndexBack := dbBack.size() - 1
        } else {
          elementIndexBack -= 1
        };

        dbBack[elementIndexBack] := db[j];
        j += 1
      };
      i += 1
    };
    rlist
  };

  /// Returns true if and only if the list is empty.
  ///
  /// Example:
  /// ```motoko include=import
  /// let list = List.fromArray<Nat>([2,0,3]);
  /// assert not List.isEmpty<Nat>(list);
  /// assert List.isEmpty<Nat>(List.empty<Nat>());
  /// ```
  ///
  /// Runtime: `O(1)`
  ///
  /// Space: `O(1)`
  public func isEmpty<T>(self : List<T>) : Bool {
    self.blockIndex == 1
  };

  /// Unsafe iterator starting from `start`.
  ///
  /// Example:
  /// ```
  /// let list = List.fromArray<Nat>([1, 2, 3, 4, 5]);
  /// let reader = List.reader<Nat>(list, 2);
  /// assert reader() == 3;
  /// assert reader() == 4;
  /// assert reader() == 5;
  /// ```
  ///
  /// Runtime: `O(1)`
  ///
  /// Space: `O(1)`
  public let defaultReaderStart : Nat = 0;
  public func reader<T>(self : List<T>, start : (implicit : (defaultReaderStart : Nat))) : () -> T {
    var blockIndex = 0;
    var elementIndex = 0;
    if (start != 0) {
      let (block, element) = locate(start - 1);
      blockIndex := block;
      elementIndex := element + 1
    };
    var db : [var ?T] = self.blocks[blockIndex];
    var dbSize = db.size();
    func next() : T {
      // Note: next() traps when reading beyond end of list
      if (elementIndex == dbSize) {
        blockIndex += 1;
        db := self.blocks[blockIndex];
        dbSize := db.size();
        elementIndex := 0
      };
      switch (db[elementIndex]) {
        case (?ret) {
          elementIndex += 1;
          return ret
        };
        case (_) Prim.trap("List.reader(): out of bounds")
      }
    };
    next
  };

}
