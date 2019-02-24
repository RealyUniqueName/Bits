package bits;

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
		bits.forEach(pos -> actual.push(pos));

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

	function testFromPositions() {
		var bits = Bits.fromPositions([0, 2]);

		Assert.isTrue(bits.isSet(0));
		Assert.isFalse(bits.isSet(1));
		Assert.isTrue(bits.isSet(2));
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