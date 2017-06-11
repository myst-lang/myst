# Bytecode reference

Myst bytecode is a binary stream of instructions for the Myst Virtual Machine to read and execute. Instructions are self-delimited, meaning they know their own length, and can thus be put directly adjacent to each other with no extra padding bytes.


## Instructions

|  section   |   command    | opcode |  args |  pop  |   push  |
|------------|--------------|--------|-------|-------|---------|
| nop        | nop          | 0x00   |       |       |         |
| variables  | getlocal     | 0x01   | name  |       | value   |
|            | setlocal     | 0x02   | name  | value |         |
| stack      | push         | 0x10   | value |       | value   |
|            | pop          | 0x11   |       | value |         |
| math       | add          | 0x20   |       | b,a   | a+b     |
|            | subtract     | 0x21   |       | b,a   | a-b     |
|            | multiply     | 0x22   |       | b,a   | a*b     |
|            | divide       | 0x23   |       | b,a   | a/b     |
|            | power        | 0x24   |       | b,a   | a**b    |
|            | negate       | 0x25   |       | a     | -a      |
| comparison | equal        | 0x30   |       | b,a   | a==b    |
|            | notequal     | 0x31   |       | b,a   | !(a==b) |
|            | lessthan     | 0x32   |       | b,a   | a<b     |
|            | lessequal    | 0x33   |       | b,a   | a<=b    |
|            | greaterequal | 0x34   |       | b,a   | a>=b    |
|            | greaterthan  | 0x35   |       | b,a   | a>b     |
| logic      | and          | 0x40   |       | b,a   | a&&b    |
|            | or           | 0x41   |       | b,a   | a or b  |
|            | not          | 0x42   |       | val   | !val    |
| flow       | label        | 0x50   | name  |       |         |
|            | jump         | 0x51   | idx   |       |         |
|            | jumpto       | 0x52   | label |       |         |
|            | jumpif       | 0x53   | idx   | val   |         |
|            | jumpunless   | 0x54   | idx   | val   |         |
| transform  | buildmap     | 0x80   | size  | *size | map     |
|            | buildarray   | 0x81   | size  | *size | array   |
|            | splat        | 0x90   |       | array | a,b,... |
| io         | write        | 0xa0   |       | value |         |


## Instruction layout

The byte layout for an instruction is simple: a 1-byte opcode, then the arguments themselves. The opcode determines how many arguments are expected. For example a `push` instruction (`0x10`) will read 1 argument, while a `pop` instruction (`0x11`) will read 0 arguments.

Each argument represents a literal value, and may be either nil, an integer, a float, a string, or a symbol. To accommodate these various types, each value must start with a type identifier, according to the table below. This type sets an expectation for the size of the argument, and allows the VM to properly parse it.

|   type  | identifier |      length     |
| ------- | ---------- | --------------- |
| Nil     | 0x00       | 0               |
| Integer | 0x01       | 8               |
| Float   | 0x02       | 8               |
| String  | 0x04       | null-terminated |
| Symbol  | 0x08       | null-terminated |

String and Symbol literals can be of (essentially) arbitrary size, and are terminated using a null byte (`0x00`).

Below is an example of two bytecode instructions (one with an argument and one without) that shows the structure of an instruction:

```
00010000 00000001 00010000...0000
├─┬─────┼─┬──────┼─┬────────────┤
  │       │        └─ 8-byte value
  │       └─ 0x01 - Integer type
  └─ 0x10 - push

00010001
├─┬────┤
  └─ 0x11 - pop
```

