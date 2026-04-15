import { OracleDeque } from "../references/arrayDequeOracle";

/** Mirrors the Motoko `Op` variant in `test/oracleReplay/QueueReplayFixture.mo`. */
export type OracleOp =
  | { readonly kind: "pushFront"; readonly value: number }
  | { readonly kind: "pushBack"; readonly value: number }
  | { readonly kind: "popFront" }
  | { readonly kind: "popBack" };

/**
 * Fixed trace shared with the Motoko replay test. Keep in sync with the emitter output.
 * Pops are only used when the oracle queue is non-empty.
 */
export const TRACE: readonly OracleOp[] = [
  { kind: "pushBack", value: 10 },
  { kind: "pushFront", value: 5 },
  { kind: "pushBack", value: 7 },
  { kind: "popFront" },
  { kind: "popBack" },
  { kind: "pushFront", value: 1 },
  { kind: "popFront" },
];

export function expectedFinalFromTrace(): number[] {
  const d = new OracleDeque();
  for (const op of TRACE) {
    switch (op.kind) {
      case "pushFront":
        d.pushFront(op.value);
        break;
      case "pushBack":
        d.pushBack(op.value);
        break;
      case "popFront":
        d.popFront();
        break;
      case "popBack":
        d.popBack();
        break;
    }
  }
  return d.toArray();
}
