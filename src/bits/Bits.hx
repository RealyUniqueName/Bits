package bits;

import haxe.io.BytesData;
/**
 * A sequence of bits of any size.
 */
abstract Bits(BitsData) from BitsData to BitsData {
	/**
	 * Create a `bits.Bits` instance using values of `positions` as positions of bits, which should be set to 1.
	 * E.g. `[0, 2, 7]` will produce `bits.Bits` instance of `10000101`.
	 * If there is a negative value in `positions` the result is unspecified.
	 */
	@:from
	static public function fromPositions(positions:Array<Int>):Bits {
		var bits = new Bits();
		for(pos in positions) {
			#if haxe4 inline #end bits.set(pos);
		}
		return bits;
	}

	/**
	 * Create a new instance.
	 *
	 * By default the new instance allocates a memory for 32 (on most platforms) bits.
	 * And then grows as necessary on setting bits at positions greater than 31.
	 *
	 * @param capacity makes `bits.Bits` to pre-allocate the amount of memory required to store `capacity` bits.
	 */
	public inline function new(capacity:Int = 0) {
		this = new BitsData();
		if(capacity > 0) {
			this.resize(Math.ceil(capacity / BitsData.CELL_SIZE));
		}
	}

	/**
	 * Set the bit at position `pos` (zero-based) in a binary representation of `bits.BitFlags` to 1.
	 * It's like `bits = bits | (1 << pos)`
	 * E.g. if `pos` is 2 the third bit is set to 1 (`0000100`).
	 * If `pos` is negative the result is unspecified.
	 */
	public function set(pos:Int) {
		if(pos < BitsData.CELL_SIZE) {
			this[0] |= (1 << pos);
		} else {
			var cell = Std.int(pos / BitsData.CELL_SIZE);
			if(this.length <= cell) {
				this.resize(cell + 1);
			}
			var bit = pos - cell * BitsData.CELL_SIZE;
			this[cell] |= (1 << bit);
		}
	}

	/**
	 * Set the bit at position `pos` (zero-based) in a binary representation of `bits.BitFlags` to 0.
	 * If `pos` is negative the result is unspecified.
	 */
	public function unset(pos:Int) {
		if(pos < BitsData.CELL_SIZE) {
			this[0] &= ~(1 << pos);
		} else {
			var cell = Std.int(pos / BitsData.CELL_SIZE);
			if(this.length <= cell) {
				this.resize(cell + 1);
			}
			var bit = pos - cell * BitsData.CELL_SIZE;
			this[cell] &= ~(1 << bit);
		}
	}

	/**
	 * Add all ones of `bits` to this instance.
	 * It's like `this = this | bits`.
	 */
	public function add(bits:Bits) {
		var data = (bits:BitsData);
		if(this.length < data.length) {
			this.resize(data.length);
		}
		for(cell in 0...data.length) {
			this[cell] |= data[cell];
		}
	}

	/**
	 * Remove all ones of `bits` from this instance.
	 * It's like `this = this & ~bits`.
	 */
	public function remove(bits:Bits) {
		var data = (bits:BitsData);
		for(cell in 0...data.length) {
			if(cell >= this.length) {
				break;
			}
			this[cell] &= ~data[cell];
		}
	}

	/**
	 * Check if a bit at position `pos` is set to 1.
	 * If `pos` is negative the result is unspecified.
	 */
	public function isSet(pos:Int):Bool {
		return if(pos < BitsData.CELL_SIZE) {
			0 != this[0] & (1 << pos);
		} else {
			var cell = Std.int(pos / BitsData.CELL_SIZE);
			var bit = pos - cell * BitsData.CELL_SIZE;
			cell < this.length && 0 != this[cell] & (1 << bit);
		}
	}

	/**
	 * Check if this instance has all the corresponding bits of `bits` set.
	 * It's like `this & bits != 0`.
	 * E.g. returns `true` if `this` is `10010010` and `bits` is `10000010`.
	 */
	public function areSet(bits:Bits):Bool {
		var data = (bits:BitsData);
		var has = true;
		for(cell in 0...data.length) {
			if(cell < this.length) {
				has = data[cell] == this[cell] & data[cell];
			} else {
				has = 0 == data[cell];
			}
			if(!has) break;
		}
		return has;
	}

	/**
	 * Invoke `callback` for each non-zero bit.
	 * Callback will receive a position (zero-based) of each non-zero bit.
	 */
	public inline function forEach(callback:Int->Void) {
		for(cell in 0...this.length) {
			var cellValue = this[cell];
			if(cellValue != 0) {
				for(i in 0...BitsData.CELL_SIZE) {
					if(0 != cellValue & (1 << i)) {
						callback(cell * BitsData.CELL_SIZE + i);
					}
				}
			}
		}
	}

	/**
	 * Create a copy of this instance
	 */
	public inline function copy():Bits {
		return this.copy();
	}

	/**
	 * Get string representation of this instance (without leading zeros).
	 * E.g. `100010010`.
	 */
	public function toString():String {
		var result = '';
		for(cell in 0...this.length) {
			var cellValue = this[cell];
			for(i in 0...BitsData.CELL_SIZE) {
				result = (0 != cellValue & (1 << i) ? '1' : '0') + result;
			}
		}
		return result.substr(result.indexOf('1'));
	}

	/**
	 * Check if all bits are zeros
	 */
	public function isEmpty():Bool {
		var empty = true;
		for(cellValue in this) {
			if(cellValue != 0) {
				empty = false;
				break;
			}
		}
		return empty;
	}

	/**
	 * Count the amount of non-zero bits.
	 */
	public function count():Int {
		return this.countOnes();
	}

	/**
	 * Set all bits to 0
	 */
	public function clear() {
		for(cell in 0...this.length) {
			this[cell] = 0;
		}
	}

	/**
	 * Merge this instance with `bits`.
	 * E.g. merging `10010` and `10001` produces `10011`.
	 * Creates a new `bits.Bits` instance.
	 */
	@:op(A | B)
	public function merge(bits:Bits):Bits {
		inline function mergeData(a:BitsData, b:BitsData):BitsData {
			var result = a.copy();
			for(cell in 0...b.length) {
				result[cell] |= b[cell];
			}
			return result;
		}

		if(this.length < (bits:BitsData).length) {
			return mergeData(bits, this);
		} else {
			return mergeData(this, bits);
		}
	}

	/**
	 * Returns an intersection of this instance with `bits`.
	 * E.g. intersecting `10010` and `01010` produces `00010`.
	 * Creates a new `bits.Bits` instance.
	 */
	@:op(A & B)
	public function intersect(bits:Bits):Bits {
		inline function intersectData(a:BitsData, b:BitsData):BitsData {
			var result = a.copy();
			for(cell in 0...a.length) {
				result[cell] &= b[cell];
			}
			return result;
		}

		if(this.length < (bits:BitsData).length) {
			return intersectData(this, bits);
		} else {
			return intersectData(bits, this);
		}
	}

	/**
	 * Iterator over the positions of non-zero bits
	 */
	public inline function iterator():BitsIterator {
		return new BitsIterator(this);
	}
}

class BitsIterator {
	var data:BitsData;
	var cell:Int = 0;
	var i:Int = 0;

	public inline function new(data:BitsData) {
		this.data = data;
	}

	public inline function hasNext():Bool {
		var has = false;

		while(cell < data.length) {
			var cellValue = data[cell];

			if(cellValue != 0) {
				while(i < BitsData.CELL_SIZE) {
					if(cellValue & (1 << i) != 0) {
						has = true;
						break;
					}
					++i;
				}
				if(has) break;
			}

			i = 0;
			++cell;
		}

		return has;
	}

	public inline function next():Int {
		++i;
		return cell * BitsData.CELL_SIZE + i - 1;
	}
}

//TODO change to the most effective data structure for each target platform
@:noCompletion
abstract BitsData(Array<Int>) {
	static public inline var CELL_SIZE = 32;

	public var length(get,never):Int;

	public inline function new() this = [0];

	public inline function resize(newLength:Int) {
		#if (!haxe4 || !static)
			for(i in this.length...newLength) {
				this[i] = 0;
			}
		#else
			this.resize(newLength);
		#end
	}

	public inline function copy():BitsData {
		return cast this.copy();
	}

	/**
	 * Count 1-bits
	 */
	public inline function countOnes():Int {
		var result = 0;
		#if (neko || js || java || cs || cpp || flash)
			for(v in this) {
				if(v != 0) {
					v = v - ((v >>> 1) & 0x55555555);
					v = (v & 0x33333333) + ((v >>> 2) & 0x33333333);
					result += (((v + (v >>> 4)) & 0x0F0F0F0F) * 0x01010101) >>> 24;
				}
			}
		#else
			for(cellValue in this) {
				if(cellValue != 0) {
					for(i in 0...CELL_SIZE) {
						if(cellValue & (1 << i) != 0) {
							++result;
						}
					}
				}
			}
		#end
		return result;
	}

	@:op([])
	inline function get(index:Int):Int {
		return this[index];
	}

	@:op([])
	inline function set(index:Int, value:Int):Int {
		return this[index] = value;
	}

	inline function get_length() return this.length;
}