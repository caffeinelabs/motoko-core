import * as assert from "node:assert/strict";
import fc from "fast-check";
import { OracleDeque } from "./references/arrayDequeOracle";

/** Logical queue state shared by model and oracle (front at index 0). */
export type QueueModel = { items: number[] };

class PushFrontCommand implements fc.Command<QueueModel, OracleDeque> {
  constructor(private readonly value: number) {}

  check(_m: Readonly<QueueModel>): boolean {
    return true;
  }

  run(m: QueueModel, r: OracleDeque): void {
    m.items = [this.value, ...m.items];
    r.pushFront(this.value);
    assert.deepEqual(r.toArray(), m.items);
  }

  toString(): string {
    return `pushFront(${this.value})`;
  }
}

class PushBackCommand implements fc.Command<QueueModel, OracleDeque> {
  constructor(private readonly value: number) {}

  check(_m: Readonly<QueueModel>): boolean {
    return true;
  }

  run(m: QueueModel, r: OracleDeque): void {
    m.items = [...m.items, this.value];
    r.pushBack(this.value);
    assert.deepEqual(r.toArray(), m.items);
  }

  toString(): string {
    return `pushBack(${this.value})`;
  }
}

class PopFrontCommand implements fc.Command<QueueModel, OracleDeque> {
  check(m: Readonly<QueueModel>): boolean {
    return m.items.length > 0;
  }

  run(m: QueueModel, r: OracleDeque): void {
    const expected = m.items[0]!;
    m.items = m.items.slice(1);
    const got = r.popFront();
    assert.equal(got, expected);
    assert.deepEqual(r.toArray(), m.items);
  }

  toString(): string {
    return "popFront";
  }
}

class PopBackCommand implements fc.Command<QueueModel, OracleDeque> {
  check(m: Readonly<QueueModel>): boolean {
    return m.items.length > 0;
  }

  run(m: QueueModel, r: OracleDeque): void {
    const expected = m.items[m.items.length - 1]!;
    m.items = m.items.slice(0, -1);
    const got = r.popBack();
    assert.equal(got, expected);
    assert.deepEqual(r.toArray(), m.items);
  }

  toString(): string {
    return "popBack";
  }
}

const pushFrontArb = fc.nat().map((n) => new PushFrontCommand(n));
const pushBackArb = fc.nat().map((n) => new PushBackCommand(n));
const popFrontArb = fc.constant(new PopFrontCommand());
const popBackArb = fc.constant(new PopBackCommand());

const allQueueCommands = [pushFrontArb, pushBackArb, popFrontArb, popBackArb];

export function queueCommandArbitrary(
  constraints?: fc.CommandsContraints,
): fc.Arbitrary<Iterable<fc.Command<QueueModel, OracleDeque>>> {
  return fc.commands(allQueueCommands, constraints);
}

export function runQueueModelPbt(params?: {
  readonly numRuns?: number;
  readonly maxCommands?: number;
  readonly seed?: number;
  readonly verbose?: boolean;
}): void {
  const maxCommands = params?.maxCommands ?? 400;
  fc.assert(
    fc.property(queueCommandArbitrary({ maxCommands }), (cmds) => {
      fc.modelRun(
        () => ({
          model: { items: [] },
          real: new OracleDeque(),
        }),
        cmds,
      );
    }),
    {
      numRuns: params?.numRuns ?? 100,
      seed: params?.seed,
      verbose: params?.verbose,
    },
  );
}
