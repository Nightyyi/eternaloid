package nlib

import "core:fmt"
import "core:path/filepath"
import "core:strings"
import rl "vendor:raylib"

Mouse_Data :: struct {
	mouse_x:         i32,
	mouse_y:         i32,
	virtual_mouse_x: i32,
	virtual_mouse_y: i32,
	clicking:        bool,
}

Window_Data :: struct {
	original_width:  i32,
	original_height: i32,
	present_width:   i32,
	present_height:  i32,
	image_cache_map: map[string]Texture_Cache,
}

Image_Key :: struct {
	string_key: string,
	size_key:   f32,
}

Texture_Cache :: struct {
	cached_texture: rl.Texture,
	size:           f32,
}

get_virtual_window :: proc(window: ^Window_Data) -> (i32, i32, f64) {
	width_ratio := f64(window.present_width) / f64(window.original_width)
	height_ratio := f64(window.present_height) / f64(window.original_height)

	ratio: f64
	ratio = min(height_ratio, width_ratio)

	v_width := i32(f64(window.original_width) * ratio)
	v_height := i32(f64(window.original_height) * ratio)

	return v_width, v_height, ratio
}

get_virtual_x_y_ratio :: proc(x: i32, y: i32, window: ^Window_Data) -> (i32, i32, f64) {
	virtual_width, virtual_height, virtual_ratio := get_virtual_window(window)
	padding_x := (window.present_width - virtual_width) / 2
	padding_y := (window.present_height - virtual_height) / 2
	virtual_x := i32(f64(x) * virtual_ratio) + padding_x
	virtual_y := i32(f64(y) * virtual_ratio) + padding_y

	return virtual_x, virtual_y, virtual_ratio
}

update_mouse :: proc(mouse: ^Mouse_Data, window: ^Window_Data) {
	virtual_width, virtual_height, virtual_ratio := get_virtual_window(window)
	padding_x := (window.present_width - virtual_width) / 2
	padding_y := (window.present_height - virtual_height) / 2
	pos := rl.GetMousePosition()
	mouse.mouse_x = i32(f64(i32(pos.x) - padding_x) / virtual_ratio)
	mouse.mouse_y = i32(f64(i32(pos.y) - padding_y) / virtual_ratio)
	mouse.virtual_mouse_x = i32(pos.x)
	mouse.virtual_mouse_y = i32(pos.y)
	mouse.clicking = rl.IsMouseButtonPressed(rl.MouseButton.LEFT)
}

acquire_texture :: proc(image_name: string) -> rl.Texture {
	new_image_name := filepath.join([]string{"assets", image_name})
	image_name_C: cstring = strings.clone_to_cstring(new_image_name)
	texture: rl.Texture = rl.LoadTexture(image_name_C)
	delete(image_name_C)
	delete(new_image_name)
	return texture
}

pull_texture :: proc(
	image_name: string,
	image_cache_map: ^map[string]Texture_Cache,
	size: f32,
) -> rl.Texture {
	cached_texture, ok := image_cache_map[image_name]
	if ok {
		if (cached_texture.size == size) {
			return cached_texture.cached_texture
		} else {
			texture := acquire_texture(image_name)
			new_texture_cache := Texture_Cache{texture, size}
			image_cache_map[image_name] = new_texture_cache
			return texture
		}
	} else {
		texture := acquire_texture(image_name)
		new_texture_cache := Texture_Cache{texture, size}
		image_cache_map[image_name] = new_texture_cache
		return texture
	}
}

in_hitbox :: proc(x: i32, y: i32, width: i32, height: i32, mouse: Mouse_Data) -> bool {
	return (0 < (mouse.mouse_x - x) && (mouse.mouse_x - x) < width) &&
		(0 < (mouse.mouse_y - y) && (mouse.mouse_y - y) < height)
}

in_hitbox_v :: proc(x: i32, y: i32, width: i32, height: i32, mouse: Mouse_Data) -> bool {
	return (0 < (mouse.virtual_mouse_x - x) && (mouse.virtual_mouse_x - x) < width) &&
		(0 < (mouse.virtual_mouse_y - y) && (mouse.virtual_mouse_y - y) < height)
}

draw_rectangle :: proc(
	x: i32,
	y: i32,
	width: i32,
	height: i32,
	window: ^Window_Data,
	color: rl.Color,
) {
	virtual_x, virtual_y, virtual_ratio := get_virtual_x_y_ratio(x, y, window)
	rl.DrawRectangle(
		i32(virtual_x),
		i32(virtual_y),
		i32(f64(width) * virtual_ratio),
		i32(f64(height) * virtual_ratio),
		color,
	)
}


draw_borders :: proc(window: ^Window_Data) {
	virtual_width, virtual_height, virtual_ratio := get_virtual_window(window)
	padding_x := (window.present_width - virtual_width) / 2
	padding_y := (window.present_height - virtual_height) / 2
	rl.DrawRectangle(
		i32(0),
		i32(0),
		i32(padding_x),
		i32(window.present_height),
		rl.Color{0, 0, 0, 255},
	)
	rl.DrawRectangle(
		i32(padding_x + virtual_width),
		i32(0),
		i32(padding_x),
		i32(window.present_height),
		rl.Color{0, 0, 0, 255},
	)
	rl.DrawRectangle(
		i32(0),
		i32(0),
		i32(window.present_width),
		i32(padding_y),
		rl.Color{0, 0, 0, 255},
	)
	rl.DrawRectangle(
		i32(0),
		i32(padding_y + virtual_height),
		i32(window.present_width),
		i32(padding_y),
		rl.Color{0, 0, 0, 255},
	)


}

draw_png :: proc(
	x: i32,
	y: i32,
	png_name: string,
	window: ^Window_Data,
	size: f32 = 1,
	rotation: f32 = 0,
) {
	texture: rl.Texture = pull_texture(png_name, &window.image_cache_map, size)
	virtual_x, virtual_y, virtual_ratio := get_virtual_x_y_ratio(x, y, window)
	rl.DrawTextureEx(
		texture,
		rl.Vector2{f32(virtual_x), f32(virtual_y)},
		rotation,
		size * f32(virtual_ratio),
		rl.Color{255, 255, 255, 255},
	)
}

button_png_s :: proc(
	x: i32,
	y: i32,
	png_name: string,
	window: ^Window_Data,
	mouse: Mouse_Data,
	rotation: f32 = 0,
	size: f32 = 1,
) -> bool {
	texture: rl.Texture = pull_texture(png_name, &window.image_cache_map, size)
	virtual_x, virtual_y, virtual_ratio := get_virtual_x_y_ratio(x, y, window)
	rl.DrawTextureEx(
		texture,
		rl.Vector2{f32(virtual_x), f32(virtual_y)},
		rotation,
		size * f32(virtual_ratio),
		rl.Color{255, 255, 255, 255},
	)

	return in_hitbox(virtual_x, virtual_y, texture.width, texture.height, mouse) && mouse.clicking
}


button_png_d :: proc(
	x: i32,
	y: i32,
	png_name: [2]string,
	window: ^Window_Data,
	mouse: Mouse_Data,
	width: i32,
	height: i32,
	rotation: f32 = 0,
	size: f32 = 1,
) -> bool {
	button_clicked := in_hitbox(x, y, width, height, mouse) && mouse.clicking
	texture: rl.Texture = pull_texture(
		png_name[int(button_clicked)],
		&window.image_cache_map,
		size,
	)
	virtual_x, virtual_y, virtual_ratio := get_virtual_x_y_ratio(x, y, window)
	rl.DrawTextureEx(
		texture,
		rl.Vector2{f32(virtual_x), f32(virtual_y)},
		rotation,
		size * f32(virtual_ratio),
		rl.Color{255, 255, 255, 255},
	)

	return button_clicked
}

button_png_t :: proc(
	x: i32,
	y: i32,
	png_name: [3]string,
	window: ^Window_Data,
	mouse: Mouse_Data,
	width: i32,
	height: i32,
	rotation: f32 = 0,
	size: f32 = 1,
) -> bool {
	on_button := in_hitbox(x, y, width, height, mouse)
	button_clicked := on_button && mouse.clicking
	which_texture: int = 0
	if button_clicked { which_texture = 2 }
	if on_button {      which_texture = 1      }
	virtual_x, virtual_y, virtual_ratio := get_virtual_x_y_ratio(x, y, window)
	texture: rl.Texture = pull_texture(png_name[which_texture], &window.image_cache_map, size)
	rl.DrawTextureEx(
		texture,
		rl.Vector2{f32(virtual_x), f32(virtual_y)},
		rotation,
		size * f32(virtual_ratio),
		rl.Color{255, 255, 255, 255},
	)

	return button_clicked
}
