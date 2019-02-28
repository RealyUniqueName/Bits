package bits;

import bits.Bits;
import utest.Assert;

class TestBits extends utest.Test {
	function testSetIsSetUnset_lessThan32() {
		for(pos in [0, 3, 8, 16, 25, 31]) {
			var bits = new Bits();
			Assert.isFalse(bits.isSet(pos), 'isSet($pos) on empty bits failed');
			bits.set(pos);
			Assert.isTrue(bits.isSet(pos), 'set($pos) failed');
			bits.unset(pos);
			Assert.isFalse(bits.isSet(pos), 'unset($pos) failed');
		}
	}

	function testSetIsSetUnset_32AndGreater() {
		for(pos in [32, 48, 63, 64, 512]) {
			var bits = new Bits();
			Assert.isFalse(bits.isSet(pos), 'isSet($pos) on empty bits failed');
			bits.set(pos);
			Assert.isTrue(bits.isSet(pos), 'set($pos) failed');
			bits.unset(pos);
			Assert.isFalse(bits.isSet(pos), 'unset($pos) failed');
		}
	}

	function testAreSet() {
		var a = new Bits();
		a.set(0);
		a.set(16);
		a.set(31);
		a.set(50);

		Assert.isTrue(a.areSet([0, 16, 31, 50]));

		var b = new Bits();
		b.set(0);
		b.set(31);
		b.set(50);

		Assert.isTrue(a.areSet(b));

		b.set(512);
		Assert.isFalse(a.areSet(b));

		b.unset(512);
		Assert.isTrue(a.areSet(b));

	}

	function testForEach() {
		var bits = new Bits();
		var expected = [1, 20, 32, 500];
		for(pos in expected) {
			bits.set(pos);
		}

		var actual = [];
		bits.forEach(function(pos) actual.push(pos));

		Assert.same(expected, actual);
	}

	function testIterator() {
		var bits = new Bits();
		var expected = [1, 20, 32, 500];
		for(pos in expected) {
			bits.set(pos);
		}

		var actual = [for(pos in bits) pos];
		Assert.same(expected, actual);

		expected.remove(500);
		bits.unset(500);

		var actual = [for(pos in bits) pos];
		Assert.same(expected, actual);
	}

	function testToString() {
		var bits = new Bits();
		bits.set(1);
		bits.set(8);
		bits.set(32);
		bits.set(66);

		var expected = '1000000000000000000000000000000000100000000000000000000000100000010';
		var actual = bits.toString();

		Assert.equals(expected, actual);
	}

	function testClear() {
		var bits = new Bits();
		bits.set(10);
		bits.set(100);
		bits.set(1000);

		bits.clear();

		bits.forEach(function(_) Assert.fail());
		Assert.pass();
	}

	function testIsEmpty() {
		var bits = new Bits();

		Assert.isTrue(bits.isEmpty());

		bits.set(999999);
		Assert.isFalse(bits.isEmpty());

		bits.unset(999999);
		Assert.isTrue(bits.isEmpty());
	}

	function testCount() {
		var bits = new Bits();

		Assert.equals(0, bits.count());

		bits.set(1);
		bits.set(32);
		bits.set(131);
		bits.set(875696);
		Assert.equals(4, bits.count());

		bits.unset(131);
		Assert.equals(3, bits.count());

		bits.clear();
		for(i in 0...BitsData.CELL_SIZE * 10) {
			bits.set(i);
		}
		Assert.equals(BitsData.CELL_SIZE * 10, bits.count());
	}

	function testFromPositions() {
		var bits = Bits.fromPositions([0, 2]);

		Assert.isTrue(bits.isSet(0));
		Assert.isFalse(bits.isSet(1));
		Assert.isTrue(bits.isSet(2));
	}

	function testAdd() {
		var a = new Bits();
		a.set(1);
		a.set(4);
		var b = new Bits();
		b.set(3);
		b.set(100);

		a.add(b);

		Assert.isTrue(a.isSet(1));
		Assert.isTrue(a.isSet(3));
		Assert.isTrue(a.isSet(4));
		Assert.isTrue(a.isSet(100));
	}

	function testRemove() {
		var a = new Bits();
		a.set(1);
		a.set(60);
		var b = new Bits();
		b.set(3);
		b.set(60);
		b.set(100);

		a.remove(b);

		Assert.isTrue(a.isSet(1));
		Assert.isFalse(a.isSet(3));
		Assert.isFalse(a.isSet(60));
		Assert.isFalse(a.isSet(100));
	}

	function testOpOr() {
		var a = new Bits();
		a.set(1);
		a.set(4);
		var b = new Bits();
		b.set(3);
		b.set(100);

		var c = a | b;

		Assert.isTrue(c.isSet(1));
		Assert.isTrue(c.isSet(3));
		Assert.isTrue(c.isSet(4));
		Assert.isTrue(c.isSet(100));

		Assert.isTrue(a.isSet(1));
		Assert.isFalse(a.isSet(3));
		Assert.isTrue(a.isSet(4));
		Assert.isFalse(a.isSet(100));

		Assert.isFalse(b.isSet(1));
		Assert.isTrue(b.isSet(3));
		Assert.isFalse(b.isSet(4));
		Assert.isTrue(b.isSet(100));
	}

	function testOpAnd() {
		var a = new Bits();
		a.set(1);
		a.set(4);
		a.set(70);
		var b = new Bits();
		b.set(3);
		b.set(70);
		b.set(100);

		var c = a & b;

		Assert.isFalse(c.isSet(1));
		Assert.isFalse(c.isSet(3));
		Assert.isFalse(c.isSet(4));
		Assert.isTrue(c.isSet(70));
		Assert.isFalse(c.isSet(100));

		Assert.isTrue(a.isSet(1));
		Assert.isFalse(a.isSet(3));
		Assert.isTrue(a.isSet(4));
		Assert.isTrue(a.isSet(70));
		Assert.isFalse(a.isSet(100));

		Assert.isFalse(b.isSet(1));
		Assert.isTrue(b.isSet(3));
		Assert.isFalse(b.isSet(4));
		Assert.isTrue(a.isSet(70));
		Assert.isTrue(b.isSet(100));
	}

	// var t:Bool = false;
	// function testZ(async:utest.Async) {
	// 	var b = new Bits();
	// 	b.set(1024);
	// 	haxe.Timer.delay(() -> {
	// 		haxe.Timer.measure(() -> {
	// 			for(i in 0...0xFFFFF)
	// 				t = b.isSet(512);
	// 		});
	// 		async.done();
	// 	}, 0);
	// }
}