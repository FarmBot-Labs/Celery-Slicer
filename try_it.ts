import * as fs from "fs";
import { flatten } from "./index";
const txt = fs.readFileSync("./unsliced_examples.json");

JSON
  .parse(txt.toString())
  .map(sequence => console.dir(JSON.parse(flatten(sequence))));
