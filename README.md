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

### API

```haxe
/**
 * Create a `bits.Bits` instance using values of `positions` as positions of bits, which should be set to 1.
 * E.g. `[0, 2, 7]` will produce `bits.Bits` instance of `10000101`.
 * If there is a negative value in `positions` the result is unspecified.
 */
@:from static public function fromPositions(positions:Array<Int>):Bits;

/**
 * Create a new instance.
 *
 * By default the new instance allocates a memory for 32 (on most platforms) bits.
 * And then grows as necessary on setting bits at positions greater than 31.
 *
 * @param capacity makes `bits.Bits` to pre-allocate the amount of memory required to store `capacity` bits.
 */
public inline function new(capacity:Int = 0);

/**
 * Set the bit at position `pos` (zero-based) in a binary representation of `bits.BitFlags` to 1.
 * It's like `bits = bits | (1 << pos)`
 * E.g. if `pos` is 2 the third bit is set to 1 (`0000100`).
 * If `pos` is negative the result is unspecified.
 */
public function set(pos:Int):Void;

/**
 * Set the bit at position `pos` (zero-based) in a binary representation of `bits.BitFlags` to 0.
 * If `pos` is negative the result is unspecified.
 */
public function unset(pos:Int):Void;

/**
 * Add all ones of `bits` to this instance.
 * It's like `this = this | bits`.
 */
public function add(bits:Bits):Void;

/**
 * Remove all ones of `bits` from this instance.
 * It's like `this = this & ~bits`.
 */
public function remove(bits:Bits):Void;

/**
 * Check if a bit at position `pos` is set to 1.
 * If `pos` is negative the result is unspecified.
 */
public function isSet(pos:Int):Bool;

/**
 * Check if this instance has all the corresponding bits of `bits` set.
 * It's like `this & bits != 0`.
 * E.g. returns `true` if `this` is `10010010` and `bits` is `10000010`.
 */
public function areSet(bits:Bits):Bool;

/**
 * Invoke `callback` for each non-zero bit.
 * Callback will receive a position (zero-based) of each non-zero bit.
 */
public inline function forEach(callback:Int->Void):Void;

/**
 * Create a copy of this instance
 */
public inline function copy():Bits;

/**
 * Get string representation of this instance (without leading zeros).
 * E.g. `100010010`.
 */
public function toString():String;

/**
 * Count the amount of non-zero bits.
 */
public function count():Int;

/**
 * Check if all bits are zeros
 */
public function isEmpty():Bool;

/**
 * Set all bits to 0
 */
public function clear():Void;

/**
 * Merge this instance with `bits`.
 * E.g. merging `10010` and `10001` produces `10011`.
 * Creates a new `bits.Bits` instance.
 */
@:op(A | B) public function merge(bits:Bits):Bits;

/**
 * Returns an intersection of this instance with `bits`.
 * E.g. intersecting `10010` and `01010` produces `00010`.
 * Creates a new `bits.Bits` instance.
 */
@:op(A & B) public function intersect(bits:Bits):Bits;

/**
 * Iterator over the positions of non-zero bits
 */
public inline function iterator():BitsIterator;
```
