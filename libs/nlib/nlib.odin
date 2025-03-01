package nlib

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

image_key :: struct {
	string_key: string,
	size_key:   f64,
}


get_texture :: proc(
	image_name: string,
	image_cache_map: map[image_key]rl.Texture,
	size: f64,
) -> rl.Texture {
  cache_key := image_key{string_key = image_name, size_key = size}
	cached_texture, ok := image_cache_map[cache_key]
	if ok {
		return cached_texture

	} else {
		image_name_C: cstring = strings.clone_to_cstring(image_name)
		texture: rl.Texture = rl.LoadTexture(image_name_C)
		delete(image_name_C)
		image_cache_map[cache_key] = texture
		return texture
	}
}

draw_png :: proc(
	x: i32,
	y: i32,
	png_name: string,
	image_cache_map: map[image_key]rl.Texture,
	size: f64 = 1,
) {
	texture: rl.Texture = get_texture(png_name, image_cache_map, size)
	rl.DrawTexture(texture, x, y, rl.Color{255, 255, 255, 255})
}
