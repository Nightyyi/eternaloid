package randgen

import "core:fmt"
import "core:math"
import "core:math/noise"

mesh :: struct {
	size:  [2]i32,
	array: []f64,
}

fractal_noise :: proc(pos: [2]i32, iterations: i32, zoom: f64, seed: i64) -> f32 {
	z: f64
	m: f32
	val_sum: f32
	for iteration in 0 ..< iterations {
		z = math.pow(2, (f64(iteration)))
		c := zoom / z
		m += 1 / f32(z)
		coordinate := noise.Vec2{f64(pos.x) / c, f64(pos.y) / c}
		val_sum += ((noise.noise_2d(seed = seed * i64(c), coord = coordinate) + 1) / 2) / f32(z)
	}
	return val_sum / m
}

generate_objects_i32 :: proc(
	mesh: mesh,
	array: ^[]i32,
	percentage: f64,
	range: [2]f64,
	set: i32,
	seed: ^i64,
	target: [2]i32,
) {
	for y in 0 ..< mesh.size.y {
		for x in 0 ..< mesh.size.x {
			tile_type := i32(mesh.array[x + y * mesh.size.x]*8)
			if (target.x < tile_type) && (tile_type < target.y) {
				percent :=
					(noise.noise_2d(seed = seed^, coord = noise.Vec2{f64(x) / 4, f64(y) / 4}) +
						1) /
					2
				percent *= percent
				val := mesh.array[x + y * mesh.size.x]
				if (range.x < val) && (val < range.y) {
					if (f64(percent) > (1 - percentage)) {
						array[x + y * mesh.size.x] = set
					}}

			}
		}
	}
	seed^ = (seed^ * seed^ + 2) % 10000
	seed^ = seed^ >> 5
	seed^ = seed^ << 6
	seed^ = (seed^ * seed^ + 2) % 10000
}


create_mesh_custom :: proc(size: [2]i32, zoom: f64, seed: i64) -> mesh {
	array: []f64 = make_slice([]f64, size.x * size.y)
	for y in 0 ..< size.y {
		for x in 0 ..< size.x {
			value1 := fractal_noise({x, y}, 14, zoom, seed)
			value2 := fractal_noise({x, y}, 18, zoom, seed * 4)
			value1 = f32(math.smoothstep(0.0, 1.0, f64(value1)))
			value2 = f32(math.smoothstep(0.0, 1.0, f64(value2)))
			value2 = 1 - value2
			value2 *= value2
			value1 = clamp(value1, 0, 1)
			value2 = clamp(value2, 0, 1)
			value := (value2 + value1) / 2
			if (x % 2 == y % 2) {value = value - 0.0025} else {value = value + 0.0025}
			if ((x / 2) % 2 !=
				   (y / 2) % 2) {value = value + 0.00125} else {value = value - 0.00125}
			value *= value + 0.2
			value = clamp(value, 0, 1)

			array[x + y * size.x] = f64(value)
		}
	}
	return mesh{size = size, array = array}
}

create_mesh :: proc(size: [2]i32, zoom: f64, seed: i64) -> mesh {
	array: []f64 = make_slice([]f64, size.x * size.y)
	for y in 0 ..< size.y {
		for x in 0 ..< size.x {
			value := noise.noise_2d(seed = seed, coord = noise.Vec2{f64(x) / zoom, f64(y) / zoom})
			array[x + y * size.x] = f64(value)
		}
	}
	return mesh{size = size, array = array}
}
