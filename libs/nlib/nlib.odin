package nlib

import "core:fmt"
import "core:path/filepath"
import "core:strings"
import rl "vendor:raylib"

Coord :: [2]i32


Mouse_Data :: struct {
	pos:         Coord,
	virtual_pos: Coord,
	clicking:    bool,
}

Window_Data :: struct {
	original_size:   Coord,
	present_size:    Coord,
	image_cache_map: map[string]rl.Texture,
  font: rl.Font,
}

Image_Key :: struct {
	string_key: string,
	size_key:   f32,
}

Texture_Cache :: struct {
	cached_texture: rl.Texture,
	size:           f32,
}


get_virtual_window :: proc(window: Window_Data) -> (Coord, f64) {
	width_ratio := f64(window.present_size.x) / f64(window.original_size.x)
	height_ratio := f64(window.present_size.y) / f64(window.original_size.y)

	ratio: f64 = min(height_ratio, width_ratio)

	v_width := i32(f64(window.original_size.x) * ratio)
	v_height := i32(f64(window.original_size.y) * ratio)

	return Coord{v_width, v_height}, ratio
}

get_virtual_x_y_ratio :: proc(pos: Coord, window: Window_Data) -> (Coord, f64) {
	virtual_size, virtual_ratio := get_virtual_window(window)
	padding := get_padding(window, virtual_size)
	return Coord {
			i32(f64(pos.x) * virtual_ratio) + padding.x,
			i32(f64(pos.y) * virtual_ratio) + padding.y,
		},
		virtual_ratio


}

get_padding :: proc(window: Window_Data, virtual_size: Coord) -> Coord {
	return Coord {
		(window.present_size.x - virtual_size.x) / 2,
		(window.present_size.y - virtual_size.y) / 2,
	}

}

update_mouse :: proc(mouse: ^Mouse_Data, window: Window_Data) {
	virtual_size, virtual_ratio := get_virtual_window(window)
	padding := get_padding(window, virtual_size)
	pos := rl.GetMousePosition()
	mouse.pos = Coord {
		i32(f64(i32(pos.x) - padding.x) / virtual_ratio),
		i32(f64(i32(pos.y) - padding.y) / virtual_ratio),
	}
	mouse.virtual_pos = Coord{i32(pos.x), i32(pos.y)}
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
	image_cache_map: ^map[string]rl.Texture,
	size: f32,
) -> rl.Texture {
	cached_texture, ok := image_cache_map[image_name]
	if ok {
		return cached_texture
	} else {
		texture := acquire_texture(image_name)
		image_cache_map[image_name] = texture
		return texture
	}
}

in_hitbox :: proc(pos: Coord, size: Coord, mouse: Mouse_Data) -> bool {
	delta := mouse.pos - pos
	return (0 < delta.x && delta.x < size.x) && (0 < delta.y && delta.y < size.y)


}

in_hitbox_v :: proc(x: i32, y: i32, width: i32, height: i32, mouse: Mouse_Data) -> bool {
	return(
		(0 < (mouse.virtual_pos.x - x) && (mouse.virtual_pos.x - x) < width) &&
		(0 < (mouse.virtual_pos.y - y) && (mouse.virtual_pos.y - y) < height) \
	)
}

draw_text :: proc(
  text: string,
	position: Coord,
	spacing: f32,
	color: rl.Color,
	fontSize: f32,
	window: Window_Data,
) {
	virtual_pos, virtual_ratio := get_virtual_x_y_ratio(position, window)
	text_c: cstring = strings.clone_to_cstring(text)
	rl.DrawTextEx(
		font = window.font,
		text = text_c,
		position = rl.Vector2{f32(virtual_pos.x), f32(virtual_pos.y)},
		fontSize = fontSize*f32(virtual_ratio),
		spacing = spacing*f32(virtual_ratio),
		tint = color,
	)
  delete(text_c)
}

draw_rectangle :: proc(position: Coord, size: Coord, window: Window_Data, color: rl.Color) {
	virtual_pos, virtual_ratio := get_virtual_x_y_ratio(position, window)
	rl.DrawRectangle(
		i32(virtual_pos.x),
		i32(virtual_pos.y),
		i32(f64(size.x) * virtual_ratio),
		i32(f64(size.y) * virtual_ratio),
		color,
	)
}


draw_png :: proc(
	position: Coord,
	png_name: string,
	window: ^Window_Data,
	size: f32 = 1,
	rotation: f32 = 0,
	color: rl.Color = rl.Color{255, 255, 255, 255},
) {
	if (png_name != "") {
		texture: rl.Texture = pull_texture(png_name, &window.image_cache_map, size)
		virtual_pos, virtual_ratio := get_virtual_x_y_ratio(position, window^)
		rl.DrawTextureEx(
			texture,
			rl.Vector2{f32(virtual_pos.x), f32(virtual_pos.y)},
			rotation,
			size * f32(virtual_ratio),
			color,
		)
	}
}

button_png_t :: proc(
	position: Coord,
	hitbox: Coord,
	png_name: [3]string,
	window: ^Window_Data,
	mouse: Mouse_Data,
	rotation: f32 = 0,
	size: f32 = 1,
) -> bool {

	on_button := in_hitbox(position, hitbox, mouse)
	button_clicked := on_button && mouse.clicking
	which_texture: int = 0

	if on_button {which_texture = 1}
	if button_clicked {which_texture = 2}

	virtual_pos, virtual_ratio := get_virtual_x_y_ratio(position, window^)
	texture: rl.Texture = pull_texture(png_name[which_texture], &window.image_cache_map, size)

	rl.DrawTextureEx(
		texture,
		rl.Vector2{f32(virtual_pos.x), f32(virtual_pos.y)},
		rotation,
		size * f32(virtual_ratio),
		rl.Color{255, 255, 255, 255},
	)

	return button_clicked
}

begin_draw_area :: proc(pos: Coord, size: Coord, window: Window_Data) {
	virtual_pos, virtual_ratio := get_virtual_x_y_ratio(pos, window)
	rl.BeginScissorMode(
		virtual_pos.x,
		virtual_pos.y,
		i32(f64(size.x) * virtual_ratio),
		i32(f64(size.y) * virtual_ratio),
	)
}
