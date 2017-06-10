# Bytecode reference

Myst bytecode is normally represented as a binary sequence starting with a 1-byte opcode, followed by the arguments for the opcode, which can take a variable number of bytes. String arguments to opcodes are delimited using a null byte (`0x00`).


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

