package odinium

import "core:fmt"
import "core:math"

bigfloat :: struct {
	mantissa: f64,
	exponent: i128,
}

print :: proc(buffer: ^[$T]u8, x: bigfloat) -> string {
	suffix := [?]cstring{"", "K", "M", "B", "T", "Qa", "Qd", "Sx", "Sp"}
	suffix_type := f64(x.exponent / 3)
	if i32(suffix_type) > len(suffix) {
		temp_string := fmt.bprintf(buffer^[:], "%fee%d", x.mantissa, x.exponent)
		return temp_string
	} else {
		temp_string := fmt.bprintf(
			buffer^[:],
			"%f %s",
			x.mantissa * math.pow10_f64(f64(i32(suffix_type) % 3)),
			suffix[i32(suffix_type)],
		)
		return temp_string
	}
}

normalize :: proc(number: bigfloat) -> bigfloat {
	mantissa := number.mantissa
	exponent := number.exponent
	if mantissa != 0 {
		e_plus := math.floor(math.log10_f64(abs(mantissa)))
		// normalize exponents upward if mantissa > 10
		if i128(e_plus) != 0 {
			mantissa = mantissa * math.pow(10, -e_plus)
			exponent = exponent + i128(e_plus)
		}
	} else {
		exponent = 0
	}
	return bigfloat{mantissa = mantissa, exponent = exponent}
}

negate :: proc(x: bigfloat) -> bigfloat {
	y := x
	y.mantissa = 0 - x.mantissa
	return y
}

add :: proc(x, y: bigfloat) -> bigfloat {
	exp_difference := f64(x.exponent - y.exponent)
	new_mantissa: f64
	switch {
	case exp_difference > 0:
		//ex: runs if _e5 > _e3
		new_mantissa = x.mantissa + y.mantissa * math.pow(10, -exp_difference)
		// this part is to shift it down by exp_difference placees ^^^^^^^^^^^
		break
	case exp_difference < 0:
		//ex: runs if _e3 < _e5
		new_mantissa = y.mantissa + x.mantissa * math.pow(10, -exp_difference) // same here 
		break
	case exp_difference == 0:
		//ex: runs if _e3 == _e3
		new_mantissa = x.mantissa + y.mantissa
		break
	}
	new_exponent := x.exponent
	if y.exponent > x.exponent {
		new_exponent = y.exponent
	}
	new_bignum := normalize(bigfloat{mantissa = new_mantissa, exponent = new_exponent})

	return new_bignum
}


sub :: proc(x, y: bigfloat) -> bigfloat {
	y_negated := negate(y)
	return add(x, y_negated)
}

mul :: proc(x, y: bigfloat) -> bigfloat {
	new_mantissa := x.mantissa * y.mantissa
	new_exponent := x.exponent + y.exponent

	new_bignum := normalize(bigfloat{mantissa = new_mantissa, exponent = new_exponent})

	return new_bignum
}

div :: proc(x, y: bigfloat) -> bigfloat {
	assert(y.mantissa != 0, "y should not be zero!")
	new_mantissa := x.mantissa / y.mantissa
	new_exponent := x.exponent - y.exponent

	new_bignum := normalize(bigfloat{mantissa = new_mantissa, exponent = new_exponent})

	return new_bignum
}

root :: proc {
	root_bff64,
	root_bfbf,
}

root_bfbf :: proc(x, y: bigfloat) -> bigfloat {
	root := y.mantissa * math.pow10_f64(f64(y.exponent))
	new_exponent := x.exponent / i128(root)
	new_mantissa := math.log10_f64(x.mantissa) / root + math.floor_f64(f64(x.exponent) / root)
	new_mantissa = math.pow10_f64(new_mantissa)
	new_bignum := normalize(bigfloat{mantissa = new_mantissa, exponent = new_exponent})
	return new_bignum
}

root_bff64 :: proc(x: bigfloat, y: f64) -> bigfloat {
	new_exponent := x.exponent / i128(y)
	new_mantissa := math.log10_f64(x.mantissa) / y + math.floor_f64(f64(x.exponent) / y)
	new_mantissa = math.pow10_f64(new_mantissa)
	new_bignum := normalize(bigfloat{mantissa = new_mantissa, exponent = new_exponent})
	return new_bignum
}

pow_bfbf :: proc(x, y: bigfloat) -> bigfloat {
	power := y.mantissa * math.pow10_f64(f64(y.exponent))
	sum := math.log10_f64(x.mantissa) + f64(x.exponent)
	sum = sum * power
	new_exponent := math.floor_f64(sum)
	new_mantissa := math.pow10_f64((sum - new_exponent))

	return bigfloat{mantissa = new_mantissa, exponent = i128(new_exponent + 0.01)}
}

gt_than :: proc(x, y: bigfloat) -> bool {
	selfSign: bool = x.mantissa > 0
	anotherSign: bool = y.mantissa > 0

	if (selfSign == anotherSign) {
		if !selfSign {
			if (x.exponent < y.exponent) {
				return true
			} else if (x.exponent > y.exponent) {
				return false
			} else {
				if (x.mantissa < y.mantissa) {
					return true
				} else if (x.mantissa > y.mantissa) {
					return false
				} else {return false}
			}
		} else {
			if (x.exponent < y.exponent) {
				return false
			} else if (x.exponent > y.exponent) {
				return true
			} else {
				if (x.mantissa < y.mantissa) {
					return false
				} else if (x.mantissa > y.mantissa) {
					return true
				} else {return false}
			}
		}
	} else {
		if (selfSign) {return true} else {return false}
	}
}

ls_than :: proc(x, y: bigfloat) -> bool {
	selfSign: bool = x.mantissa > 0
	anotherSign: bool = y.mantissa > 0

	if (selfSign == anotherSign) {
		if !selfSign {
			if (x.exponent < y.exponent) {
				return false
			} else if (x.exponent > y.exponent) {
				return true
			} else {
				if (x.mantissa < y.mantissa) {
					return false
				} else if (x.mantissa > y.mantissa) {
					return true
				} else {return false}
			}
		} else {
			if (x.exponent < y.exponent) {
				return true
			} else if (x.exponent > y.exponent) {
				return false
			} else {
				if (x.mantissa < y.mantissa) {
					return true
				} else if (x.mantissa > y.mantissa) {
					return false
				} else {return false}
			}
		}
	} else {
		if (selfSign) {return false} else {return true}
	}
}

gt__eq :: proc(x, y: bigfloat) -> bool {
	selfSign: bool = x.mantissa > 0
	anotherSign: bool = y.mantissa > 0

	if (selfSign == anotherSign) {
		if !selfSign {
			if (x.exponent < y.exponent) {
				return true
			} else if (x.exponent > y.exponent) {
				return false
			} else {
				if (x.mantissa < y.mantissa) {
					return true
				} else if (x.mantissa > y.mantissa) {
					return false
				} else {return true}
			}
		} else {
			if (x.exponent < y.exponent) {
				return false
			} else if (x.exponent > y.exponent) {
				return true
			} else {
				if (x.mantissa < y.mantissa) {
					return false
				} else if (x.mantissa > y.mantissa) {
					return true
				} else {return true}
			}
		}
	} else {
		if (selfSign) {return true} else {return false}
	}
}

ls__eq :: proc(x, y: bigfloat) -> bool {
	selfSign: bool = x.mantissa > 0
	anotherSign: bool = y.mantissa > 0

	if (selfSign == anotherSign) {
		if !selfSign {
			if (x.exponent < y.exponent) {
				return false
			} else if (x.exponent > y.exponent) {
				return true
			} else {
				if (x.mantissa < y.mantissa) {
					return false
				} else if (x.mantissa > y.mantissa) {
					return true
				} else {return true}
			}
		} else {
			if (x.exponent < y.exponent) {
				return true
			} else if (x.exponent > y.exponent) {
				return false
			} else {
				if (x.mantissa < y.mantissa) {
					return true
				} else if (x.mantissa > y.mantissa) {
					return true
				} else {return false}
			}
		}
	} else {
		if (selfSign) {return false} else {return true}
	}
}


equals :: proc(x, y: bigfloat) -> bool {
	if x.exponent == y.exponent && x.mantissa == y.mantissa {return true} else {return false}
}

noteql :: proc(x, y: bigfloat) -> bool {
	if x.exponent == y.exponent && x.mantissa == y.mantissa {return false} else {return true}
}
