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
		z = math.pow(1.5,(f64(iteration)))
    c := zoom / z
		m += 1 / f32(z)
		coordinate := noise.Vec2{f64(pos.x) / c, f64(pos.y) / c}
		val_sum += ((noise.noise_2d(seed = seed*i64(c), coord = coordinate)+1)/2 ) / f32(z)
	}
	return val_sum / m
}

generate_objects_i32 :: proc(mesh: mesh, array: ^[]i32, percentage: f64, mm: [2]f64, set: i32) {
	seed: i64 = 1521
	for y in 0 ..< mesh.size.y {
		for x in 0 ..< mesh.size.x {
			percent := (noise.noise_2d(seed = seed, coord = noise.Vec2{f64(x), f64(y)}) + 1) / 2
			val := mesh.array[x + y * mesh.size.x]
			if (mm.x < val) && (val < mm.y) {
				if (f64(percent) > percentage) {
					array[x + y * mesh.size.x] = set
					seed = (i64(x) * i64(y) * seed) % 1523
				}}
		}
	}

}


create_mesh_custom :: proc(size: [2]i32, zoom: f64, seed: i64) -> mesh {
	array: []f64 = make_slice([]f64, size.x * size.y)
	for y in 0 ..< size.y {
		for x in 0 ..< size.x {
			value := fractal_noise({x, y}, 5, zoom, seed)
			value = f32(math.smoothstep(0.0, 1.0, f64(value)))
			value = value * value
			value = clamp(value, 0, 1)
			if (x % 2 == y % 2) {value = value - 0.005} else {value = value + 0.005}
			if ((x / 2) % 2 != (y / 2) % 2) {value = value + 0.01} else {value = value - 0.01}
			value = f32((i32(value * 8))) / 8
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
