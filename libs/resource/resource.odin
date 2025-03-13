package resource

import od "../odinium"

Resource_Manager :: struct {
	output:     ^od.bigfloat,
	base:       []od.bigfloat,
	multiplier: []od.bigfloat,
	exponent:   []od.bigfloat,
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
