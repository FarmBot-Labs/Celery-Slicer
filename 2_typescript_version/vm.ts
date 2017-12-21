import { Block } from "./heap";

type WrappedValue =
  | { kind: "string", val: string }
  | { kind: "number", val: number };

interface VM {
  /** Program counter. Next node to execute */
  PC: number;
  /** Return stack. EG: Where do we go back to when finished? */
  RS: number[];
  /** Audit trail. List of every address we've been to. TODO: Limit to last 100
   * addresses and add an `overflow` flag, maybe? */
  AUDIT: number[];
  /** Data stack. Flexible array for general purpose data storage. */
  DS: WrappedValue[];
  MEM: { [addr: number]: (Block | undefined) };
}

interface InstructionSet {
  [name: string]: (vm: VM) => VM;
}

const instructions: InstructionSet = {
  sequence(vm) {
    // This logic may be wrong. Consider it pseudocode.
    const isReturning = vm.RS[vm.RS.length - 1] == vm.PC;
    if (isReturning) {
      vm.RS.pop();
      vm.PC = parseInt(vm.MEM[vm.PC]["🔗parent"]);
    } else {
      vm.RS.push(vm.PC); // We will be back...
      vm.PC = parseInt(vm.MEM[vm.PC]["🔗body"]);
    }
    return vm;
  },
  wait(vm) {
    const me = vm.MEM[vm.PC];
    sleep(me["milliseconds"]);
    const next = me["🔗next"];
    if (next === "0") {
      // We're done here; return to the node that owns this "body".
      vm.PC = vm.RS[vm.RS.length - 1];
    } else {
      vm.PC = parseInt(next);
    }
    return vm;
  }
}

function tick(vm: VM): VM {
  // Track previous call.
  vm.AUDIT.push(vm.PC);
  // Execute current PC location.
  return instructions["" + vm.PC](vm);
}

function run(vm: VM) {
  while (vm.PC !== 0) {
    tick(vm);
  }
  return "done!";
}

function sleep(x: any) {
  // Pretend that this is a real IO operation or something.
}
