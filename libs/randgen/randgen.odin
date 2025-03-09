package randgen

import "core:fmt"
import "core:math/noise"

mesh :: struct {
	size:  [2]i32,
	array: []f64,
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
