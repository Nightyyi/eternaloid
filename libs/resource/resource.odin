package resource

import od "../odinium"
import "core:fmt"

Boost_Type :: enum {
	base,
	multiplier,
	exponent,
}

Resource_Manager :: struct {
	output:              ^od.bigfloat,
	base:                []od.bigfloat,
	multiplier:          []od.bigfloat,
	exponent:            []od.bigfloat,
	cached_income:       od.bigfloat,
	external_multiplier: ^od.bigfloat,
	update:              bool,
	indexes:             [3]i32,
	static:              bool,
}

create_resource_manager :: proc(
	resource_pointer: ^od.bigfloat,
	length: [3]int,
) -> Resource_Manager {
	base := make_slice([]od.bigfloat, length.x)
	multiplier := make_slice([]od.bigfloat, length.y)
	exponent := make_slice([]od.bigfloat, length.z)

	return Resource_Manager {
		output = resource_pointer,
		base = base,
		multiplier = multiplier,
		exponent = exponent,
	}
}

run_resource_manager :: proc(manager: ^Resource_Manager) {
	if manager.update {
		accumilator: od.bigfloat = od.bigfloat{0, 0}

		for i in 0 ..< len(manager.base) {
			accumilator = od.add(accumilator, manager.base[i])
		}
		for i in 0 ..< len(manager.multiplier) {
			multiplier := od.add(manager.multiplier[i], od.bigfloat{1, 0})
			accumilator = od.mul(accumilator, multiplier)
		}
		for i in 0 ..< len(manager.exponent) {
			exponent := od.add(manager.exponent[i], od.bigfloat{1, 0})
			accumilator = od.add(accumilator, exponent)
		}
		manager.cached_income = accumilator
		manager.update = false
		if manager.static {
			manager.output^ = accumilator
		}
	}
	if !manager.static {
		manager.output^ = od.add(
			manager.output^,
			od.mul(manager.cached_income, manager.external_multiplier^),
		)
	}
  manager.indexes = [3]i32{0,0,0}
}

update_resource :: proc(manager: ^Resource_Manager, set_val: od.bigfloat, boost_type: Boost_Type) {
	manager.update = true
	switch boost_type {
	case Boost_Type.base:
		index := manager.indexes[0]
		manager.base[index] = set_val
		manager.indexes[0] += 1
	case Boost_Type.multiplier:
		index := manager.indexes[1]
		manager.multiplier[index] = set_val
		manager.indexes[1] += 1
	case Boost_Type.exponent:
		index := manager.indexes[2]
		manager.base[index] = set_val
		manager.indexes[2] += 1
	}
}

subtract_m :: proc(manager: ^Resource_Manager, sub: od.bigfloat) {
	manager.output^ = od.sub(manager.output^, sub)
}
