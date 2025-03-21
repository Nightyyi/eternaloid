package odiniumrsc

import od "../odinium"
import "core:fmt"
import "core:math"

bigfloat :: od.bigfloat

linear_growth :: proc(level, base, step: bigfloat) -> (cost: bigfloat) {
	cost = od.add(base, od.mul(level, step))
	return
}
