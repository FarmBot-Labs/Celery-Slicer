import * as fs from "fs";
import { flatten } from "./index";
const txt = fs.readFileSync("./unsliced_examples.json");

const sequence = JSON.parse(txt.toString())[4];

console.dir(JSON.parse(flatten(sequence)));