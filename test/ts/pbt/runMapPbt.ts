import { readOptionalPbtSeed } from "./oracleFixtureSeed";
import { runMapModelPbt } from "./pureMapCommands";

const pbtSeed = readOptionalPbtSeed();
runMapModelPbt(pbtSeed !== undefined ? { seed: pbtSeed } : {});
