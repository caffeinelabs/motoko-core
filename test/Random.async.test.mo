import Random "../src/Random";
import Nat8 "../src/Nat8";
import Nat "../src/Nat";
import Nat64 "../src/Nat64";
import Array "../src/Array";
import Blob "../src/Blob";
import { suite; test; expect } = "mo:test/async";

await suite(
  "Random.emptyState() and AsyncRandom state management",
  func() : async () {
    func mockAsyncGenerator(bytes : [Nat8]) : () -> async* Blob {
      func() : async* Blob {
        Blob.fromArray(bytes)
      }
    };

    await test(
      "emptyState() creates proper initial state",
      func() : async () {
        let state = Random.emptyState();

        expect.nat(state.bytes.size()).equal(0);
        expect.nat(state.index).equal(0);
        expect.nat8(state.bits).equal(0x00);
        expect.nat8(state.bitMask).equal(0x00)
      }
    );
    await test(
      "cryptoFromState() creates AsyncRandom with proper state reference",
      func() : async () {
        let state = Random.emptyState();
        let random = Random.cryptoFromState(state);

        expect.nat(state.bytes.size()).equal(0);
        expect.nat(state.index).equal(0);

        let _val1 = await* random.nat8();
        let _val2 = await* random.nat8();

        expect.nat(state.bytes.size()).greater(0);
        expect.nat(state.index).greater(0)
      }
    );
    await test(
      "Multiple AsyncRandom instances can share the same state",
      func() : async () {
        let state = Random.emptyState();
        let random1 = Random.cryptoFromState(state);
        let random2 = Random.cryptoFromState(state);

        expect.nat(state.bytes.size()).equal(0);
        expect.nat(state.index).equal(0);

        let _val1 = await* random1.nat8();
        let index1 = state.index;

        let _val2 = await* random2.nat8();
        let index2 = state.index;

        expect.nat(index2).greater(index1);
        expect.nat(state.bytes.size()).greater(0);

        let _bool1 = await* random1.bool();
        let _bool2 = await* random2.bool()
      }
    );
    await test(
      "AsyncRandom state independence with separate states",
      func() : async () {
        let state1 = Random.emptyState();
        let state2 = Random.emptyState();
        let random1 = Random.cryptoFromState(state1);
        let random2 = Random.cryptoFromState(state2);

        expect.nat(state1.index).equal(state2.index);
        expect.nat(state1.bytes.size()).equal(state2.bytes.size());

        state1.index := 5;
        expect.nat(state1.index).equal(5);
        expect.nat(state2.index).equal(0);

        let _val1 = await* random1.nat8();
        let _val2 = await* random2.nat8();

        expect.nat(state1.index).greater(0);
        expect.nat(state2.index).greater(0);
        expect.nat(state1.bytes.size()).greater(0);
        expect.nat(state2.bytes.size()).greater(0);

        let range1 = await* random1.natRange(10, 20);
        let range2 = await* random2.natRange(10, 20);

        expect.nat(range1).greaterOrEqual(10);
        expect.nat(range1).less(20);
        expect.nat(range2).greaterOrEqual(10);
        expect.nat(range2).less(20)
      }
    );
    await test(
      "AsyncRandom creation with mock generator",
      func() : async () {
        let state = Random.emptyState();
        let mockBytes : [Nat8] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];

        let random = Random.AsyncRandom(state, mockAsyncGenerator(mockBytes));

        expect.nat(state.bytes.size()).equal(0);
        expect.nat(state.index).equal(0);

        let val1 = await* random.nat8();
        let val2 = await* random.nat8();
        let val3 = await* random.nat8();

        expect.nat(state.bytes.size()).greater(0);
        expect.nat(state.index).greater(0);

        expect.nat8(val1).equal(1);
        expect.nat8(val2).equal(2);
        expect.nat8(val3).equal(3);

        let nat64Val = await* random.nat64();
        expect.nat64(nat64Val).greater(0)
      }
    );
    await test(
      "State reuse scenario simulation",
      func() : async () {
        let state = Random.emptyState();

        state.bytes := [10, 20, 30, 40, 50, 60, 70, 80];
        state.index := 3;
        state.bits := 0xAA;
        state.bitMask := 0x08;

        let random = Random.cryptoFromState(state);

        expect.nat(state.bytes.size()).equal(8);
        expect.nat(state.index).equal(3);
        expect.nat8(state.bits).equal(0xAA);
        expect.nat8(state.bitMask).equal(0x08);

        expect.nat8(state.bytes[state.index]).equal(40);

        let nextVal = await* random.nat8();
        expect.nat8(nextVal).equal(40);

        let afterVal = await* random.nat8();
        expect.nat8(afterVal).equal(50);

        let _boolVal = await* random.bool();

        expect.nat(state.index).greater(3);

        let rangeVal = await* random.intRange(-10, 10);
        expect.int(rangeVal).greaterOrEqual(-10);
        expect.int(rangeVal).less(10)
      }
    );
    await test(
      "Edge case: state with exhausted bytes",
      func() : async () {
        let state = Random.emptyState();

        state.bytes := [1, 2, 3, 4];
        state.index := 4;

        let random = Random.cryptoFromState(state);

        expect.nat(state.bytes.size()).equal(4);
        expect.nat(state.index).equal(4);
        expect.nat(state.index).equal(state.bytes.size());

        let _val1 = await* random.nat8();
        let _val2 = await* random.nat8();

        expect.nat(state.bytes.size()).greater(4);
        expect.nat(state.index).greater(0);

        let _boolVal = await* random.bool();
        let nat64Val = await* random.nat64();
        let rangeVal = await* random.natRange(100, 200);

        expect.nat64(nat64Val).greater(0);
        expect.nat(rangeVal).greaterOrEqual(100);
        expect.nat(rangeVal).less(200)
      }
    )
  }
);

await suite(
  "AsyncRandom",
  func() : async () {
    func deterministicMockGenerator(seed : Nat8) : () -> async* Blob {
      var counter = seed;
      func() : async* Blob {
        let bytes : [Nat8] = Array.tabulate<Nat8>(
          16,
          func(i) {
            counter := Nat8.fromNat((Nat8.toNat(counter) + 1) % 256);
            counter
          }
        );
        Blob.fromArray(bytes)
      }
    };

    await test(
      "bool() method produces boolean values",
      func() : async () {
        let state = Random.emptyState();
        let random = Random.AsyncRandom(state, deterministicMockGenerator(0));

        let results : [Bool] = [
          await* random.bool(),
          await* random.bool(),
          await* random.bool(),
          await* random.bool(),
          await* random.bool()
        ];

        expect.nat(results.size()).equal(5);

        let initialIndex = state.index;
        let initialBitMask = state.bitMask;
        let _ = await* random.bool();
        expect.bool(state.index > initialIndex or state.bitMask != initialBitMask).isTrue()
      }
    );

    await test(
      "nat8() method produces Nat8 values in correct range",
      func() : async () {
        let state = Random.emptyState();
        let random = Random.AsyncRandom(state, deterministicMockGenerator(10));

        let results : [Nat8] = [
          await* random.nat8(),
          await* random.nat8(),
          await* random.nat8(),
          await* random.nat8(),
          await* random.nat8()
        ];

        expect.nat(results.size()).equal(5);
        expect.nat(state.index).equal(5);
        expect.nat(state.bytes.size()).equal(16)
      }
    );

    await test(
      "nat8() with known deterministic sequence",
      func() : async () {
        let state = Random.emptyState();
        func predictableGenerator() : async* Blob {
          Blob.fromArray([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16])
        };
        let random = Random.AsyncRandom(state, predictableGenerator);

        expect.nat8(await* random.nat8()).equal(1);
        expect.nat8(await* random.nat8()).equal(2);
        expect.nat8(await* random.nat8()).equal(3);
        expect.nat8(await* random.nat8()).equal(4);
        expect.nat8(await* random.nat8()).equal(5)
      }
    );

    await test(
      "nat64() method produces Nat64 values",
      func() : async () {
        let state = Random.emptyState();
        let random = Random.AsyncRandom(state, deterministicMockGenerator(42));

        let results : [Nat64] = [
          await* random.nat64(),
          await* random.nat64(),
          await* random.nat64()
        ];

        expect.nat(results.size()).equal(3);
        expect.nat(state.index).equal(8)
      }
    );

    await test(
      "nat64() with predictable bytes produces expected values",
      func() : async () {
        let state = Random.emptyState();
        func sequentialGenerator() : async* Blob {
          let bytes = Array.tabulate(16, func(i) { Nat8.fromNat(i) });
          Blob.fromArray(bytes)
        };
        let random = Random.AsyncRandom(state, sequentialGenerator);

        let result = await* random.nat64();

        let expected : Nat64 = (0 << 56) | (1 << 48) | (2 << 40) | (3 << 32) | (4 << 24) | (5 << 16) | (6 << 8) | 7;
        expect.nat64(result).equal(expected)
      }
    );

    await test(
      "Range methods return values within specified range",
      func() : async () {
        let state = Random.emptyState();
        let random = Random.AsyncRandom(state, deterministicMockGenerator(123));

        for (_ in Nat.range(0, 10)) {
          let nat64Val = await* random.nat64Range(100, 200);
          expect.nat64(nat64Val).greaterOrEqual(100);
          expect.nat64(nat64Val).less(200);

          let natVal = await* random.natRange(50, 150);
          expect.nat(natVal).greaterOrEqual(50);
          expect.nat(natVal).less(150);

          let intVal = await* random.intRange(-100, 100);
          expect.int(intVal).greaterOrEqual(-100);
          expect.int(intVal).less(100)
        }
      }
    );

    await test(
      "Generator refill behavior when bytes exhausted",
      func() : async () {
        let state = Random.emptyState();

        var generatorCallCount = 0;
        func smallChunkGenerator() : async* Blob {
          generatorCallCount += 1;
          if (generatorCallCount == 1) {
            Blob.fromArray([100, 101])
          } else {
            Blob.fromArray([200, 201, 202, 203])
          }
        };

        let random = Random.AsyncRandom(state, smallChunkGenerator);

        expect.nat8(await* random.nat8()).equal(100);
        expect.nat8(await* random.nat8()).equal(101);
        expect.nat(generatorCallCount).equal(1);

        expect.nat8(await* random.nat8()).equal(200);
        expect.nat(generatorCallCount).equal(2);

        expect.nat8(await* random.nat8()).equal(201);
        expect.nat8(await* random.nat8()).equal(202);
        expect.nat8(await* random.nat8()).equal(203);
        expect.nat(generatorCallCount).equal(2)
      }
    );

    await test(
      "Mixed method calls maintain state consistency",
      func() : async () {
        let state = Random.emptyState();
        let random = Random.AsyncRandom(state, deterministicMockGenerator(128));

        let _bool1 = await* random.bool();
        let _nat8_1 = await* random.nat8();
        let _nat64_1 = await* random.nat64();
        let _natRange1 = await* random.natRange(0, 100);
        let _intRange1 = await* random.intRange(-50, 50);
        let _bool2 = await* random.bool();

        expect.nat(state.index).greater(0);
        expect.nat(state.bytes.size()).greater(0)
      }
    )
  }
);

await suite(
  "AsyncRandom cryptographic randomness integration",
  func() : async () {
    await test(
      "crypto() creates working AsyncRandom",
      func() : async () {
        let random = Random.crypto();

        let _bool = await* random.bool();
        let _nat8 = await* random.nat8();
        let _nat64 = await* random.nat64()
      }
    );

    await test(
      "cryptoFromState() with persistent state",
      func() : async () {
        let state = Random.emptyState();
        let random1 = Random.cryptoFromState(state);

        let _val1 = await* random1.nat8();
        let _val2 = await* random1.nat8();

        let random2 = Random.cryptoFromState(state);
        let _val3 = await* random2.nat8();

        expect.nat(state.index).greater(0);
        expect.nat(state.bytes.size()).greater(0)
      }
    );

    await test(
      "Multiple crypto instances with shared state",
      func() : async () {
        let state = Random.emptyState();
        let random1 = Random.cryptoFromState(state);
        let random2 = Random.cryptoFromState(state);

        let _val1 = await* random1.nat8();
        let index1 = state.index;

        let _val2 = await* random2.nat8();
        let index2 = state.index;

        expect.nat(index2).greater(index1)
      }
    )
  }
)
