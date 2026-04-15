import * as assert from "node:assert/strict";
import fc from "fast-check";
import type { MapMutationOp } from "./mapOracleOps";
import { OracleNatTextMap } from "./references/oracleNatTextMap";

export type MapModel = { map: Map<number, string> };

function sortedSnapshot(m: Map<number, string>): [number, string][] {
  return [...m.entries()].sort((a, b) => a[0] - b[0]);
}

function assertMapMatchesOracle(
  model: Map<number, string>,
  oracle: OracleNatTextMap,
): void {
  assert.deepEqual(sortedSnapshot(model), oracle.sortedEntries());
}

class AddCommand implements fc.Command<MapModel, OracleNatTextMap> {
  constructor(
    readonly key: number,
    readonly value: string,
  ) {}

  check(_m: Readonly<MapModel>): boolean {
    return true;
  }

  run(m: MapModel, r: OracleNatTextMap): void {
    m.map.set(this.key, this.value);
    r.add(this.key, this.value);
    assertMapMatchesOracle(m.map, r);
  }

  toString(): string {
    return `add key=${this.key} value=${JSON.stringify(this.value)}`;
  }
}

class RemoveCommand implements fc.Command<MapModel, OracleNatTextMap> {
  constructor(readonly key: number) {}

  check(_m: Readonly<MapModel>): boolean {
    return true;
  }

  run(m: MapModel, r: OracleNatTextMap): void {
    m.map.delete(this.key);
    r.remove(this.key);
    assertMapMatchesOracle(m.map, r);
  }

  toString(): string {
    return `remove key=${this.key}`;
  }
}

class GetCommand implements fc.Command<MapModel, OracleNatTextMap> {
  constructor(readonly key: number) {}

  check(_m: Readonly<MapModel>): boolean {
    return true;
  }

  run(m: MapModel, r: OracleNatTextMap): void {
    assert.equal(m.map.get(this.key), r.get(this.key));
    assertMapMatchesOracle(m.map, r);
  }

  toString(): string {
    return `get key=${this.key}`;
  }
}

const addArb = fc
  .tuple(
    fc.nat({ max: 500_000 }),
    fc.nat({ max: 500_000 }),
  )
  .map(([k, v]) => new AddCommand(k, String(v)));

const removeArb = fc.nat({ max: 500_000 }).map((k) => new RemoveCommand(k));

const getArb = fc.nat({ max: 500_000 }).map((k) => new GetCommand(k));

const allMapCommands = [addArb, removeArb, getArb];

export function mapCommandArbitrary(
  constraints?: fc.CommandsContraints,
): fc.Arbitrary<Iterable<fc.Command<MapModel, OracleNatTextMap>>> {
  return fc.commands(allMapCommands, constraints);
}

export function commandToMapMutationOp(
  cmd: fc.Command<MapModel, OracleNatTextMap>,
): MapMutationOp | null {
  const s = cmd.toString();
  const addM = /^add key=(\d+) value=(.+)$/.exec(s);
  if (addM) {
    const value = JSON.parse(addM[2]!) as string;
    return { kind: "add", key: Number(addM[1]), value };
  }
  const rmM = /^remove key=(\d+)$/.exec(s);
  if (rmM) {
    return { kind: "remove", key: Number(rmM[1]) };
  }
  return null;
}

export function runMapModelPbt(params?: {
  readonly numRuns?: number;
  readonly maxCommands?: number;
  readonly seed?: number;
  readonly verbose?: boolean;
}): void {
  const maxCommands = params?.maxCommands ?? 400;
  fc.assert(
    fc.property(mapCommandArbitrary({ maxCommands }), (cmds) => {
      fc.modelRun(
        () => ({
          model: { map: new Map() },
          real: new OracleNatTextMap(),
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
