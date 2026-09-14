# Core package style guide

## Source code

Unless otherwise mentioned, this repository should follow the official [Motoko code style guidelines](https://internetcomputer.org/docs/motoko/style).

## Interface design

Use the priorities below when choosing the name/parameters for public functions, classes, and modules:

1. Consistency with the rest of the `core` package.
2. Scalability for large canisters.
3. Performance to minimize cycles cost.

## Documentation code examples

* Each function should include a doc comment with a basic usage example:

```motoko
/// Returns whether `char` is an uppercase character.
///
/// Example:
/// ```motoko include=import
/// assert Char.isUpper('A');
/// assert not Char.isUpper('a');
/// ```
public func isUpper(char : Char) : Bool { ... };
```

* When relevant, examples should use the `assert` keyword without outer parentheses:

```motoko
assert Nat.toInt(1234) == +1234;
```

* Data structure modules (`Array`, `List`, `Map`, `Queue`, etc.) should use a `persistent actor` wrapper with transient keywords as needed:

```motoko
import Map "mo:core/Map";

persistent actor {
  let iter = Iter.fromArray([(0, "Zero"), (1, "One"), (2, "Two")]);
  let map = Map.fromIter<Nat, Text>(iter, Nat.compare);
}
```

* Other modules (`Bool`, `Int`, `Time`, etc.) should use either a minimal top-level code snippet (omitting the import) or a full actor example:

```motoko
assert Principal.fromText("2vxsx-fae") == Principal.anonymous();
```

...or...

```motoko
import IC "mo:core/InternetComputer";
import Principal "mo:core/Principal";

persistent actor {
  type OutputType = { decimals : Nat32 };

  public func example() : async ?OutputType {
    let ledger = Principal.fromText("ryjl3-tyaaa-aaaaa-aaaba-cai")
    let method = "decimals";
    let input = ();
    let rawReply = await IC.call(ledger, method, to_candid (input));
    let output : ?OutputType = from_candid (rawReply);
    assert output == ?{ decimals = 8 };
    output
  }
}
```

* For minimal code snippets with imports from other modules, include a space after the import. For a code example in the `Text`` module:

```motoko
import Char "mo:core/Char";

assert Text.compareWith("abc", "ABC", Char.compare) == #greater
```

## Types

### Naming

* Use `UpperCamelCase` for type and class names, including type parameters.

* Use `lowerCamelCase` for value parameter and field names, including variant cases.

* Where needed, use a `Var` prefix to distinguish mutable from immutable versions of a similar type or class name.

* Classes are encapsulated abstractions; name them after their conceptual _function_, not their _implementation_,
  except when having to distinguish multiple different implementations of the same concept (such as `Queue` vs. `RealTimeQueue`). The data structure with the least tradeoffs and simplest usage pattern should have a concise name, e.g. `Queue`.

* In contrast, other types are transparent and can be named after their function or structure where appropriate (e.g. `Tree`).

### Type aliases

* Type aliases should be defined for complex object or variant types or ones that are used more than once.

* Place shared types that are used across multiple modules in `Types.mo`. Module-local types may stay in their own module.


## Functions and methods

### General

* Use `lowerCamelCase` for functions and methods.

* The name of accessors or functions returning a value should describe that value (as a noun). Avoid redundant `get` prefixes, unless the function is named only `get` and is the generic getter for a container (see below).

* The name of mutators or functions performing side effects or complex operations should describe that operation (as a verb in imperative form).

* The name of predicate functions returning `Bool` should use an `is` or `has` prefix or a similar description of the tested property (as a verb in indicative form).

* Analogous functions should have the same name across different modules and classes.

* Avoid overly specialized functions. Every library module has a size and complexity budget. One use case is not a sufficient reason to add something to the library!


### Modules

* There should be a module corresponding to each primitive type.

* The following functions should be provided in all modules corresponding to a data structure or primitive type:

  - `equal`: compare two values
  
  - `compare`: compare two values (return `Types.Order`)
  
  - `toText`: convert to textual representation

### Data structures

* Data structures at the top level of the package should be mutable, while those in the `pure` directory should be immutable. 

* Each immutable data structure should have a corresponding mutable data structure. This can either be a separate implementation or a wrapper around the immutable API.

* The interface should be as consistent as possible between data structures.

* Here is a list of common data structure operations and suggested names that ought to be consistent across containers:

  - `empty`: return a new, empty instance

  - `contains`: test membership

  - `get`: read from container (usually returns option, except for arrays)

  - `add`: write to container (overwrites if entry already exists)

    Note: Choosing this instead of `set` since it works better for containers like sets and is visually easier to distinguish from `get`.

  - `swap`: write to container and return old value (as for `get`)

  - `remove`: remove and return old value (as for `get`)

  - `delete`: remove from collection (does nothing if not present)

  - `size`: query number of entries in collection (returns `Nat`)

  - `isEmpty`: check if collections is empty (may be faster than `size`)

  - `clear`: remove all entries from mutable collection

  - `clone`: copy mutable container

  - `keys`: iterator over keys of collection (same as `values` for sets)

  - `values`: iterator over values of collection

  - `entries`: iterator over (key, value) pairs

  - `equal`: compare collections (where polymorphic, takes equality predicate for values)

  - `compare`: compare collections over ordered values (where polymorphic, takes ordering function for values)

  - `forEach`: map unit function over container

  - `map`: map function over container (may change type for polymorphic containers)

  - `filter`: narrow collections

  - `filterMap`: map filtering function (returns option) over container (may change type for polymorphic containers)

  - `foldLeft`, `foldRight`: fold unordered or ordered collection (have the same argument order, but their callback type differs in its order of arguments)

  - `find`: search for element based on predicate (returns option)

  - `any`, `all`: check for existential or universal property

* All higher-order functions should put the function parameter last.
