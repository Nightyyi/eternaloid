package resource

import od "../odinium"

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
	if manager.update {

		accumilator := od.bigfloat{0, 0}
		for i in 0 ..< len(manager.base) {
			accumilator = od.add(accumilator, manager.base[i])
		}
		for i in 0 ..< len(manager.multiplier) {
			multiplier := od.add(manager.multiplier[i], od.bigfloat{1, 0})
			accumilator = od.mul(accumilator, multiplier)
		}
		for i in 0 ..< len(manager.base) {
			exponent := od.add(manager.exponent[i], od.bigfloat{1, 0})
			accumilator = od.add(accumilator, exponent)
		}
		manager.cached_income = accumilator
	}
	manager.output^ = od.add(manager.output^, manager.cached_income)
}
