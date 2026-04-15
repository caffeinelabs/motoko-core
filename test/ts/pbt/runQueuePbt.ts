import { readOptionalPbtSeed } from "./oracleFixtureSeed";
import { runQueueModelPbt } from "./pureQueueCommands";

const pbtSeed = readOptionalPbtSeed();
runQueueModelPbt(pbtSeed !== undefined ? { seed: pbtSeed } : {});
