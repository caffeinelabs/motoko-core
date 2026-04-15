import { OracleDeque } from "./references/arrayDequeOracle";

/** Serialized queue operation; mirrors Motoko `Op` in generated fixtures. */
export type OracleOp =
  | { readonly kind: "pushFront"; readonly value: number }
  | { readonly kind: "pushBack"; readonly value: number }
  | { readonly kind: "popFront" }
  | { readonly kind: "popBack" };

export function applyOracleOps(ops: readonly OracleOp[]): number[] {
  const d = new OracleDeque();
  for (const op of ops) {
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
