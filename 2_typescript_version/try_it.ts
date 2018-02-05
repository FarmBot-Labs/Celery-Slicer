import * as fs from "fs";
import { flatten } from "./index";
import { CeleryNode } from "farmbot";
const txt = fs.readFileSync("./unsliced_examples.json");

const sequence = JSON.parse(txt.toString())[4];
const wow: CeleryNode = {
  kind: "sequence",
  args: {
    locals: { kind: "scope_declaration", args: {}, body: [] },
    version: 6,
    label: "move_abs(1,2,3), move_rel(4,5,6), write_pin(13, off, digital)"
  },
  body: [{
    kind: "move_absolute",
    args: {
      location: {
        kind: "coordinate",
        args: { x: 0, y: 0, z: 0 }
      },
      offset: {
        kind: "coordinate",
        args: { x: 0, y: 0, z: 0 }
      },
      speed: 100
    }
  }, {
    kind: "move_relative",
    args: { x: 0, y: 0, z: 0, speed: 100 }
  }, {
    kind: "write_pin",
    args: { pin_number: 0, pin_value: 0, pin_mode: 0 }
  }]
};

// console.dir(JSON.parse(flatten(sequence)));
console.dir(flatten(wow));
