import { randomInt } from "node:crypto";

/** Env var: base seed for generating `QueueOracleFixtures.mo` / `MapOracleFixtures.mo`. */
export const ORACLE_FIXTURE_SEED_ENV = "ORACLE_FIXTURE_SEED";

/** Env var: optional seed for fast-check in `runQueuePbt` / `runMapPbt` (TS only). */
export const ORACLE_PBT_SEED_ENV = "ORACLE_PBT_SEED";

function parseSeedFromArgv(): number | undefined {
  const argv = process.argv.slice(2);
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === undefined) {
      continue;
    }
    if (arg.startsWith("--seed=")) {
      return Number(arg.slice("--seed=".length));
    }
    if (arg === "--seed") {
      const next = argv[i + 1];
      if (next !== undefined) {
        return Number(next);
      }
    }
  }
  return undefined;
}

function toUInt32(n: number): number {
  if (!Number.isFinite(n)) {
    throw new Error(`Invalid seed (not a finite number): ${n}`);
  }
  return n >>> 0;
}

/**
 * Base seed for one `generate:oracle-fixtures` run (shared by Queue + Map emitters).
 *
 * Resolution order: `--seed` / `--seed=` CLI args, then `ORACLE_FIXTURE_SEED`, else random.
 * When the seed is chosen at random, the value and reproduce command are printed to stderr.
 */
export function resolveOracleFixtureBaseSeed(): number {
  const fromArgv = parseSeedFromArgv();
  if (fromArgv !== undefined) {
    const s = toUInt32(fromArgv);
    console.error(
      `Oracle fixture generation: using CLI seed (${ORACLE_FIXTURE_SEED_ENV}=${s}).`,
    );
    return s;
  }

  const raw = process.env[ORACLE_FIXTURE_SEED_ENV];
  if (raw !== undefined && raw !== "") {
    const s = toUInt32(Number(raw));
    console.error(
      `Oracle fixture generation: using ${ORACLE_FIXTURE_SEED_ENV}=${s}.`,
    );
    return s;
  }

  const s = randomInt(0, 2 ** 32);
  console.error(
    `Oracle fixture generation: random base seed ${s}.\n` +
      `To reproduce: ${ORACLE_FIXTURE_SEED_ENV}=${s} npm run generate:oracle-fixtures`,
  );
  return s;
}

/** Optional uint32 from env (for fast-check); undefined if unset or invalid. */
export function readOptionalPbtSeed(): number | undefined {
  const raw = process.env[ORACLE_PBT_SEED_ENV];
  if (raw === undefined || raw === "") {
    return undefined;
  }
  const n = Number(raw);
  if (!Number.isFinite(n)) {
    console.error(
      `Warning: ${ORACLE_PBT_SEED_ENV} is not a finite number; ignoring.`,
    );
    return undefined;
  }
  return toUInt32(n);
}
