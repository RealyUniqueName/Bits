package bits;

/**
 * A sequence of bits of any size.
 * Unlike ordinary `Int` which is 32 or 64 bits depending on a target platform architecture.
 */
abstract Bits(Data) {
	public inline function new() {
		this = new Data();
	}

	/**
	 * Set the bit at position `pos` (zero-based) in a binary representation of `bits.BitFlags` to 1.
	 * It's like `bits = bits | (1 << pos)`
	 * E.g. if `pos` is 2 the third bit is set to 1 (`0000100`).
	 * If `pos` is negative the result is unspecified.
	 */
	public function set(pos:Int) {
		if(pos < Data.CELL_SIZE) {
			this[0] = this[0] | (1 << pos);
		} else {
			var cell = Std.int(pos / Data.CELL_SIZE);
			if(this.length <= cell) {
				this.resize(cell + 1);
			}
			var bit = pos - cell * Data.CELL_SIZE;
			this[cell] = this[cell] | (1 << bit);
		}
	}

	/**
	 * Set the bit at position `pos` (zero-based) in a binary representation of `bits.BitFlags` to 0.
	 * If `pos` is negative the result is unspecified.
	 */
	public function unset(pos:Int) {
		if(pos < Data.CELL_SIZE) {
			this[0] = this[0] & ~(1 << pos);
		} else {
			var cell = Std.int(pos / Data.CELL_SIZE);
			if(this.length <= cell) {
				this.resize(cell + 1);
			}
			var bit = pos - cell * Data.CELL_SIZE;
			this[cell] = this[cell] & ~(1 << bit);
		}
	}

	/**
	 * Check if a bit at position `pos` is set to 1.
	 * If `pos` is negative the result is unspecified.
	 */
	public function isSet(pos:Int):Bool {
		return if(pos < Data.CELL_SIZE) {
			0 != this[0] & (1 << pos);
		} else {
			var cell = Std.int(pos / Data.CELL_SIZE);
			var bit = pos - cell * Data.CELL_SIZE;
			cell < this.length && 0 != this[cell] & (1 << bit);
		}
	}

	/**
	 * Check if this instance has all the corresponding bits of `bits` set.
	 * It's like `this & bits != 0`.
	 * E.g. returns `true` if `this` is `10010010` and `bits` is `10000010`.
	 */
	public function areSet(bits:Bits):Bool {
		var data:Data = bits.getData();
		var has = true;
		for(i in 0...data.length) {
			if(i < this.length) {
				has = data[i] == this[i] & data[i];
			} else {
				has = 0 == data[i] | 0; // `| 0` is required to cast `null` to zero on dynamic platforms
			}
			if(!has) break;
		}
		return has;
	}

	/**
	 * Invoke `callback` for each non-zero bit.
	 */
	public inline function forEach(callback:(pos:Int)->Void) {
		for(cell in 0...this.length) {
			if(this[cell] == 0) {
				continue;
			}
			for(i in 0...Data.CELL_SIZE) {
				var bit = this[cell] & (1 << i);
				if(bit != 0) {
					callback(cell * Data.CELL_SIZE + i);
				}
			}
		}
	}

	// inline function iterator():BitsIterator {
	// 	return new BitsIterator(this);
	// }

	inline function getData():Data {
		return this;
	}
}

// class BitsIterator {
// 	var data:Data;
// 	var cell:Int = 0;
// 	var i:Int = 0;

// 	@:allow(bits.Bits)
// 	inline function new(data:Data) {
// 		this.data = data;
// 	}

// 	public inline function hasNext():Bool {

// 	}
// }

//TODO change to the most effective data structure for each target platform
private abstract Data(Array<Int>) {
	static public inline var CELL_SIZE = 32;

	public var length(get,never):Int;

	public inline function new() this = [0];

	public inline function resize(newLength:Int) {
		#if (eval || js)
			for(i in this.length...newLength) {
				this[i] = 0;
			}
		#else
			this.resize(newLength);
		#end
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