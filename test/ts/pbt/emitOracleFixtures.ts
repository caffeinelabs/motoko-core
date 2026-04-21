import { writeMapOracleFixtures } from "./emitMapOracleFixtures";
import { writeQueueOracleFixtures } from "./emitQueueOracleFixtures";
import { resolveOracleFixtureBaseSeed } from "./oracleFixtureSeed";

const baseSeed = resolveOracleFixtureBaseSeed();
writeQueueOracleFixtures(baseSeed);
writeMapOracleFixtures(baseSeed);
