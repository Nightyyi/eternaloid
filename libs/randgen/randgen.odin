package randgen

import "core:fmt"
import "core:math/noise"

mesh :: struct {
	size:  [2]i32,
	array: []f64,
}



create_mesh_custom :: proc(size: [2]i32, zoom: f64, seed: i64) -> mesh {
	array: []f64 = make_slice([]f64, size.x * size.y)
	for y in 0 ..< size.y {
		for x in 0 ..< size.x {
			value := (noise.noise_2d(seed = seed, coord = noise.Vec2{f64(x) / zoom, f64(y) / zoom})+1)/2
      if (x%2 == y%2){ value = value - 0.005} else {value = value + 0.005}
      if ((x/2)%2 != (y/2)%2){ value = value + 0.01} else {value = value - 0.01}
      value = f32((i32(value*8)))/8
      value = clamp(value,0,1)
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
