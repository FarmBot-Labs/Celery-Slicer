"use strict";
exports.__esModule = true;
/** This will be a GenServer when ported to Elixir.
 * Represents an expanding (never contracting) storage unit for CeleryScript
 * nodes that are numerically addressable. */
var Heap = /** @class */ (function () {
    /** Start at Heap.NULL and put a `nothing` node in there. */
    function Heap() {
        this.here = Heap.NULL;
        this.entries = (_a = {}, _a[this.here] = { __KIND__: "nothing" }, _a);
        var _a;
    }
    /** Allocate a new object in the heap. At a minimum, it must have a __KIND__,
     * which is the same thing as node.kind in normal CeleryScript. */
    Heap.prototype.allot = function (__KIND__) {
        this.entries[++this.here] = { __KIND__: __KIND__ };
        return this.here;
    };
    /** Add a key/value pair to a particular address in the heap.
     * For simplicity, they must be stringified. This is how we "flatten"
     * node.args and also store references to `parent` and `body`. */
    Heap.prototype.put = function (address, key, value) {
        var block = this.entries[address];
        if (block) {
            block[key] = value;
            return;
        }
        throw new Error("Bad node address: " + address);
    };
    /** Dump the heap as JSON. */
    Heap.prototype.dump = function () {
        return JSON.stringify(this.entries);
    };
    /** Starting address */
    Heap.NULL = 0;
    return Heap;
}());
exports.Heap = Heap;
