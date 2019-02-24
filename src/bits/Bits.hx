package bits;

/**
 * A sequence of bits of any size.
 */
abstract Bits(Data) from Data to Data {
	/**
	 * Create a `bits.Bits` instance using values of `positions` as positions of bits, which should be set to 1.
	 * E.g. `[0, 2, 7]` will produce `bits.Bits` instance of `10000101`.
	 * If there is a negative value in `positions` the result is unspecified.
	 */
	@:from
	static public function fromPositions(positions:Array<Int>):Bits {
		var bits = new Bits();
		for(pos in positions) {
			inline bits.set(pos);
		}
		return bits;
	}

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
			this[0] |= (1 << pos);
		} else {
			var cell = Std.int(pos / Data.CELL_SIZE);
			if(this.length <= cell) {
				this.resize(cell + 1);
			}
			var bit = pos - cell * Data.CELL_SIZE;
			this[cell] |= (1 << bit);
		}
	}

	/**
	 * Set the bit at position `pos` (zero-based) in a binary representation of `bits.BitFlags` to 0.
	 * If `pos` is negative the result is unspecified.
	 */
	public function unset(pos:Int) {
		if(pos < Data.CELL_SIZE) {
			this[0] &= ~(1 << pos);
		} else {
			var cell = Std.int(pos / Data.CELL_SIZE);
			if(this.length <= cell) {
				this.resize(cell + 1);
			}
			var bit = pos - cell * Data.CELL_SIZE;
			this[cell] &= ~(1 << bit);
		}
	}

	/**
	 * Add all ones of `bits` to this instance.
	 * It's like `this = this | bits`.
	 */
	public function add(bits:Bits) {
		var data = (bits:Data);
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
		var data = (bits:Data);
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
		var data = (bits:Data);
		var has = true;
		for(cell in 0...data.length) {
			if(cell < this.length) {
				has = data[cell] == this[cell] & data[cell];
			} else {
				// `| 0` is required to cast `null` to zero on dynamic platforms
				has = 0 == data[cell] | 0;
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
			// `| 0` is required to cast `null` to zero on dynamic platforms
			var cellValue = this[cell] | 0;
			if(cellValue == 0) {
				continue;
			}
			for(i in 0...Data.CELL_SIZE) {
				if(0 != cellValue & (1 << i)) {
					callback(cell * Data.CELL_SIZE + i);
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
			// `| 0` is required to cast `null` to zero on dynamic platforms
			var cellValue = this[cell] | 0;
			for(i in 0...Data.CELL_SIZE) {
				result = (0 != cellValue & (1 << i) ? '1' : '0') + result;
			}
		}
		return result.substr(result.indexOf('1'));
	}

	/**
	 * Merge this instance with `bits`.
	 * Creates a new `bits.Bits` instance.
	 */
	@:op(A | B)
	public function merge(bits:Bits):Bits {
		inline function mergeData(a:Data, b:Data):Data {
			var result = a.copy();
			for(cell in 0...b.length) {
				result[cell] |= b[cell];
			}
			return result;
		}

		if(this.length < (bits:Data).length) {
			return mergeData(bits, this);
		} else {
			return mergeData(this, bits);
		}
	}

	/**
	 * Returns an intersection of this instance with `bits`.
	 * Creates a new `bits.Bits` instance.
	 */
	@:op(A & B)
	public function intersect(bits:Bits):Bits {
		inline function intersectData(a:Data, b:Data):Data {
			var result = a.copy();
			for(cell in 0...a.length) {
				result[cell] &= b[cell];
			}
			return result;
		}

		if(this.length < (bits:Data).length) {
			return intersectData(this, bits);
		} else {
			return intersectData(bits, this);
		}
	}
}

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

	public inline function copy():Data {
		return cast this.copy();
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