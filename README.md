# Bits

This lib aims to implement binary bit flags in Haxe with unlimited amount of bits per instance.

```haxe
var flags = new bits.Bits();

flags.set(2); // set a bit at position 2 (zero-based)
flags.set(5);

flags.toString(); // "10010"

flags.isSet(2); // true
flags.areSet([2, 5]); // true;

flags.set(9999);
flags.isSet(9999); // true
```

`bits.Bits` is implemented as an abstract over `Array<Int>`. Each item of that array is used to store 32 flags.