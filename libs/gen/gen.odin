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

random_num :: proc(seed: ^f64) -> f64{
  new_seed := f64(noise.noise_2d(i64(seed^*100000), {f64(seed^*2),seed^}))
  seed^ = new_seed*100000+1
  return new_seed

}

hash_string :: proc (str: string, hash: ^i64){
  accumilator : i64 = 0
  for char in str{
    fmt.print(char)
    accumilator = (accumilator ~ i64(char)) << 2
  }
  hash^ = accumilator
}

bfd :: proc(globalmap: ^map[[2]i32]bool,pos: [2]i32, mesh: mesh, min: f64) -> (map[[2]i32][2]i32, bool) {
	check_in :: proc(pos: [2]i32, min, max: i32, output: map[[2]i32][2]i32) -> bool {
		out := true
		if pos.x < min {out = false}
		if pos.y < min {out = false}
		if pos.x > max {out = false}
		if pos.y > max {out = false}
		if pos in output {out = false}
		return out
	}
	add_neighbours :: proc(
		output: map[[2]i32][2]i32,
		queue: ^[dynamic][2]i32,
		pos: [2]i32,
		min, max: i32,
	) {
		x_1 := pos.x + 1
		x_2 := pos.x - 1
		y_1 := pos.y + 1
		y_2 := pos.y - 1
		a := [2]i32{pos.x, y_1}
		b := [2]i32{pos.x, y_2}
		c := [2]i32{x_1, pos.y}
		d := [2]i32{x_2, pos.y}
		if check_in(a, min, max, output) {append(queue, a)}
		if check_in(b, min, max, output) {append(queue, b)}
		if check_in(c, min, max, output) {append(queue, c)}
		if check_in(d, min, max, output) {append(queue, d)}
		a = [2]i32{x_1, y_1}
		b = [2]i32{x_1, y_2}
		c = [2]i32{x_2, y_1}
		d = [2]i32{x_2, y_2}
		if check_in(a, min, max, output) {append(queue, a)}
		if check_in(b, min, max, output) {append(queue, b)}
		if check_in(c, min, max, output) {append(queue, c)}
		if check_in(d, min, max, output) {append(queue, d)}
	}


	if min < mesh.array[pos.x + pos.y * mesh.size.x] {

		output := make(map[[2]i32][2]i32)
		queue := make([dynamic][2]i32)
		append(&queue, pos)
		run := true
		for run {
			pos, ok := pop_safe(&queue)
			if !ok {
				run = false
			} else if ((pos.x + pos.y * mesh.size.x) < mesh.size.x * mesh.size.y) {
				value_pos := mesh.array[pos.x + pos.y * mesh.size.x]
				if value_pos > min {
					output[pos] = pos
          globalmap^[pos] = true
					add_neighbours(output, &queue, pos, 0, mesh.size.x)
				}
			}
		}
		delete(queue)
		return output, true
	} else {
		return nil, false
	}
}

generate_objects_list_i32 :: proc(
	mesh: mesh,
	array: ^[]i32,
	percentage: f64,
	range: [2]f64,
	set: [$T]i32,
	seed: ^i64,
	target: [2]i32,
) {
	for x in set {
		generate_objects_i32(
			mesh = mesh,
			array = array,
			percentage = percentage,
			range = range,
			set = x,
			target = target,
      seed= seed,
		)
	}
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
			tile_type := i32(mesh.array[x + y * mesh.size.x] * 8)
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
			river := fractal_noise({x, y}, 3, zoom / 2, seed * 2)
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
			if value > (0.25) {
				if river < 0.2 {
					value *= river + 0.7
				}
				if (0.55 < river) && (river < 0.6) {
					value = value / 1.2
				}
				if (0.55 < river) && (river < 0.6) {
					value = (value / 8 * 2) + 0.125
					value = clamp(value, 0.125, 0.24)
				}

			}
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
