# Problems

 * There is no way to climb up the scope tree to resolve variables.
 * There is no way to generate full "stack traces".

# What We Need

 * a means of addressing individual nodes (but not via pointers, use immutable numbers or strings)
 * a `parent` property.
 * a `previousSibling` property.
 * Maybe a `nextSibling` and `child` property. Not sure.

# Ideas

 * Use Elixir processes instead of pointers?
 * Make a stateful Elixir process that acts as a push down stack ("memory") and maintains state for "compilation".

```
BEGIN_SESSION       <===== init   things =====\
  START_COMPILATION <===============\ Add new  | Lock out everyone
    COMPILE_ENTRY                   | item to  | else to prevent
    COMPILE_ENTRY   <== Add k/v's   | array    | weird mutations.
    COMPILE_ENTRY      to last entry|          |
  END_COMPILATION   <===============/          |
END_SESSION         <===serialize and re-init==/
```

Other idea:

```
INITIALIZE(): Heap                                     <== Make a fresh stack
ALLOT(label: string): number;                          <== Create an addressable unit
PUT(address: number, key: string, value: string): void <== Add
DUMP(): string                                         <== Output a flat array ready for traversal
```
