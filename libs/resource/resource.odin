package resource

import od "../odinium"
import "core:fmt"

Boost_Type :: enum {
	base,
	multiplier,
	exponent,
}

Resource_Manager :: struct {
	output:        ^od.bigfloat,
	base:          []od.bigfloat,
	multiplier:    []od.bigfloat,
	exponent:      []od.bigfloat,
	cached_income: od.bigfloat,
	update:        bool,
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
  fmt.println(manager)
  accumilator : od.bigfloat= od.bigfloat{0, 0}
	if manager.update {

    fmt.print("1")
		for i in 0 ..< len(manager.base) {
			accumilator = od.add(accumilator, manager.base[i])
		}
    fmt.print("1")
		for i in 0 ..< len(manager.multiplier) {
			multiplier := od.add(manager.multiplier[i], od.bigfloat{1, 0})
			accumilator = od.mul(accumilator, multiplier)
		}
    fmt.print("1")

		for i in 0 ..< len(manager.base) {
			exponent := od.add(manager.exponent[i], od.bigfloat{1, 0})
			accumilator = od.add(accumilator, exponent)
		}
    fmt.print("1")
		manager.cached_income = accumilator
		manager.update = false
	}
  fmt.print("1")
	manager.output^ = od.add(manager.output^, manager.cached_income)
}

update_resource :: proc(
	manager: ^Resource_Manager,
	set_val: od.bigfloat,
	index: int,
	boost_type: Boost_Type,
) {
	manager.update = true
	switch boost_type {
	case Boost_Type.base:
		manager.base[index] = set_val
	case Boost_Type.multiplier:
		manager.multiplier[index] = set_val
	case Boost_Type.exponent:
		manager.base[index] = set_val
	}
}
