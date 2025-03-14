package rlib

import nl "libs/nlib"
import od "libs/odinium"
import rg "libs/randgen"
import rsc "libs/resource"
import rl "vendor:raylib"

import "core:encoding/json"
import "core:fmt"
import "core:mem"
import "core:path/filepath"
import "core:strings"

Game_State :: struct {
	global:    ^Global_Data,
	global_m:  Global_Resource,
	events:    Events,
	tab_state: i32,
	tab_1:     Game_Tab_1,
	slide:     bool,
}

Global_Data :: struct {
	entities: []i32,
	oid:      od.bigfloat,
}

Global_Resource :: struct {
	oid: rsc.Resource_Manager,
}

Events :: struct {
	update_town: bool,
}

Game_Tab_1 :: struct {
	camera:            nl.Coord,
	camera_vel:        nl.Coord,
	camera_zoom:       f64,
	camera_zoom_speed: f64,
	hold:              string,
	hold_t:            i32,
	tile_data:         []i32,
	map_mesh:          rg.mesh,
	dev_see:           bool,
	dev_elevation:     bool,
}

// settings tab

settings_tab :: proc(window: ^nl.Window_Data, mouse: nl.Mouse_Data, game: ^Game_State) {
	nl.draw_text(
		text = "Zoom Speed",
		position = nl.Coord{150, 35},
		spacing = 3,
		color = rl.Color{255, 255, 255, 255},
		fontSize = 16,
		window = window^,
	)

	nl.draw_slider(
		position = nl.Coord{150, 50},
		size = nl.Coord{130, 15},
		window = window^,
		mouse = mouse,
		slider_percentage = &game.tab_1.camera_zoom_speed,
		color = rl.Color{150, 150, 150, 255},
	)
}

// all town tab stuff
tile_color_draw :: proc(
	tile_data: $T,
	tile_set: [8]rl.Color,
	max: nl.Coord,
	offset: nl.Coord,
	tilesize: i32,
	window: ^nl.Window_Data,
	size: f64 = 1,
	color: [3]i32,
) {

	pos := 0
	for y in 0 ..< max.y {
		for x in 0 ..< max.x {
			position := nl.Coord {
				i32(f64(x * tilesize) * size) + offset.x,
				i32(f64(y * tilesize) * size) + offset.y,
			}
			val := tile_data[x + y * max.x]
			draw := true
			if (position.x + i32(32 * size)) < offset.x {
				draw = false}
			if (position.y + i32(32 * size)) < 0 {
				draw = false}
			if (position.x) > window.original_size.x {
				draw = false}
			if (position.y) > window.original_size.y {
				draw = false}
			if draw {

				nl.draw_rectangle(
					position = position,
					size = nl.Coord{i32(32 * size) + 2, i32(32 * size) + 2},
					window = window^,
					color = tile_set[int(val * 8)],
				)
			}}
	}}

animate_textures :: proc(window: ^nl.Window_Data, frame: i128) {
	grass := frame / 100 % 4
	if (grass ==
		   0) {nl.switch_texture(original_image_name = "grass.png", new_image_name = "grass1.png", image_cache_map = &window.image_cache_map)}
	if (grass ==
		   1) {nl.switch_texture(original_image_name = "grass.png", new_image_name = "grass2.png", image_cache_map = &window.image_cache_map)}
	if (grass ==
		   2) {nl.switch_texture(original_image_name = "grass.png", new_image_name = "grass3.png", image_cache_map = &window.image_cache_map)}
	if (grass ==
		   3) {nl.switch_texture(original_image_name = "grass.png", new_image_name = "grass1.png", image_cache_map = &window.image_cache_map)}
}

check_can_draw :: proc(
	position: nl.Coord,
	size: f64,
	offset: nl.Coord,
	window: nl.Window_Data,
) -> bool {
	draw := true
	if (position.x + i32(32 * size)) < offset.x {
		draw = false}
	if (position.y + i32(32 * size)) < 0 {
		draw = false}
	if (position.x + i32(32 * size)) > window.original_size.x {
		draw = false}
	if (position.y + i32(32 * size)) > window.original_size.y {
		draw = false}
	return draw
}

global :: proc(game: ^Game_State) {

	count_entities :: proc(game: ^Game_State) -> []i32 {
		list_entities := make_slice([]i32, 8)
		for i in game.tab_1.tile_data {
			list_entities[i] += 1
		}
		return list_entities
	}

	if game.events.update_town {
		delete(game.global.entities)
		game.global.entities = count_entities(game)
		rsc.update_resource(
			&game.global_m.oid,
			od.bigfloat{f64(game.global.entities[3]), 0},
			0,
			rsc.Boost_Type.base,
		)
		game.events.update_town = false
    fmt.println(f64(game.global.entities[3]))
	}

	rsc.run_resource_manager(&game.global_m.oid)

}


// all town tab stuff
draw_all_tiles :: proc(
	tile_data: $T,
	altitude: $C,
	textures: [$P]string,
	tile_set: [8]rl.Color,
	max: nl.Coord,
	offset: nl.Coord,
	tilesize: i32,
	window: ^nl.Window_Data,
	mouse: nl.Mouse_Data,
	size: f64 = 1,
	game: ^Game_State,
) -> nl.Coord {
	highlighted := nl.Coord{-1, 0}
	pos := 0
	for y in 0 ..< max.y {
		for x in 0 ..< max.x {
			val := altitude[x + y * max.x]
			raised := false
			valinfront: f64 = 100
			if (y + 1 < max.y) {
				valinfront = altitude[x + (y + 1) * max.x]
			}

			elevation := i32(val * 8) * 16
			if int(val * 8) < 1 {
				elevation += 1 * 16
			}
			if game.tab_1.dev_elevation {
				elevation = 1
			}
			position := nl.Coord {
				i32(f64(x * tilesize) * size) + offset.x,
				i32((f64(y * tilesize) - f64(elevation)) * size) + offset.y,
			}

			draw := check_can_draw(
				position = position,
				size = size,
				offset = offset,
				window = window^,
			)
			if draw {

				multiply_color :: proc(n: f64, x: rl.Color) -> rl.Color {
					return rl.Color {
						u8(n * f64(x.r)),
						u8(n * f64(x.g)),
						u8(n * f64(x.b)),
						u8(n * f64(x.a)),
					}}

				color_tile := tile_set[int(val * 8)]
				val_f := f64(int(val * 40)) / 40
				if (int(val * 8) == 1) {
					color_tile2 := tile_set[0]
					color_tile =
						multiply_color(val_f * 4, color_tile) +
						multiply_color((1 - val_f * 4), color_tile2)
				}
				if (int(val * 8) == 0) {
					color_tile2 := tile_set[1]
					color_tile =
						multiply_color(val_f * 4, color_tile2) +
						multiply_color((1 - val_f * 4), color_tile)
				}
				nl.draw_rectangle(
					position = position,
					size = nl.Coord{i32(32 * size) + 1, i32(32 * size) + 1},
					window = window^,
					color = color_tile,
				)
				if nl.in_hitbox(
					pos = position,
					size = nl.Coord{i32(32 * size), i32(32 * size)},
					mouse = mouse,
				) {highlighted = nl.Coord{x, y}}
				if i32(valinfront * 8) < i32(val * 8) {
					elevated_pos := position
					elevated_pos.y += i32(f64(tilesize) * size)
					if nl.in_hitbox(
						pos = elevated_pos,
						size = nl.Coord{i32(32 * size), i32(16 * size)},
						mouse = mouse,
					) {highlighted = nl.Coord{x, y}}
					nl.draw_rectangle(
						position = elevated_pos,
						size = nl.Coord{i32(32 * size) + 1, i32(16 * size) + 1},
						window = window^,
						color = rl.Color{25, 25, 25, 255},
					)

				}
				if (nl.Coord{x, y} == highlighted) {
					nl.draw_rectangle(
						position = position,
						size = nl.Coord{i32(32 * size), i32(32 * size)},
						window = window^,
						color = rl.Color{150, 150, 150, 100},
					)
				}
				if i32(32 * size) > 4 {
					nl.draw_png(
						position = position,
						png_name = textures[tile_data[y * max.x + x]],
						window = window,
						size = f32(2 * size),
						color = rl.Color{255, 255, 255, 255},
					)}

			}
		}
	}
	return highlighted
}

generate_objects :: proc(game: ^Game_State) {
	gen_seed: i64 = 15124
	rg.generate_objects_i32(
		mesh = game.tab_1.map_mesh,
		array = &game.tab_1.tile_data,
		percentage = 0.7,
		range = {0.15, 1},
		set = 3,
		seed = &gen_seed,
		target = nl.Coord{1, 8},
	)
	rg.generate_objects_i32(
		mesh = game.tab_1.map_mesh,
		array = &game.tab_1.tile_data,
		percentage = 0.2,
		range = {0.8, 1},
		set = 1,
		seed = &gen_seed,
		target = nl.Coord{1, 8},
	)
	rg.generate_objects_i32(
		mesh = game.tab_1.map_mesh,
		array = &game.tab_1.tile_data,
		percentage = 0.1,
		range = {0.15, 1},
		set = 1,
		seed = &gen_seed,
		target = nl.Coord{1, 8},
	)
	rg.generate_objects_i32(
		mesh = game.tab_1.map_mesh,
		array = &game.tab_1.tile_data,
		percentage = 0.2,
		range = {0.7, 0.8},
		set = 1,
		seed = &gen_seed,
		target = nl.Coord{1, 8},
	)
	rg.generate_objects_i32(
		mesh = game.tab_1.map_mesh,
		array = &game.tab_1.tile_data,
		percentage = 0.2,
		range = {0.4, 0.65},
		set = 2,
		seed = &gen_seed,
		target = nl.Coord{1, 8},
	)
	rg.generate_objects_i32(
		mesh = game.tab_1.map_mesh,
		array = &game.tab_1.tile_data,
		percentage = 0.3,
		range = {0.15, 0.4},
		set = 2,
		seed = &gen_seed,
		target = nl.Coord{1, 8},
	)

}
// yes i do want a sepeate function for this
set_icon :: proc() {
	icon_filepath := filepath.join([]string{"assets", "ball.png"})
	icon_filepath_c: cstring = strings.clone_to_cstring(icon_filepath)
	rl.SetWindowIcon(rl.LoadImage(icon_filepath_c))
	delete(icon_filepath)
	delete(icon_filepath_c)
}

display_icon_text :: proc(
	png: string,
	text: string,
	position: nl.Coord,
	offset: nl.Coord,
	font_size: f32,
	window: ^nl.Window_Data,
) {
	nl.draw_png(position = position, png_name = png, window = window, size = 2)
	nl.draw_text(
		text = text,
		position = position + offset,
		spacing = 3,
		color = rl.Color{200, 200, 200, 240},
		fontSize = font_size,
		window = window^,
	)
}

building_select_tab :: proc(game: ^Game_State, window: ^nl.Window_Data, mouse: nl.Mouse_Data) {
	if nl.button_png_t(
		position = nl.Coord{10, 300},
		hitbox = nl.Coord{64, 64},
		png_name = [3]string{"house_bt_1.png", "house_bt_2.png", "house_bt_3.png"},
		window = window,
		mouse = mouse,
		size = 2,
	) {game.tab_1.hold = "house_lv0.png";game.tab_1.hold_t = 4}
}

set_town :: proc(game: ^Game_State, tile: nl.Coord, mouse: nl.Mouse_Data) {
	if (mouse.clicking) {
		if (game.tab_1.hold != "") {
			tile_index: i32 = game.tab_1.map_mesh.size.x * tile.y + tile.x
			fmt.println(tile_index)
			game.tab_1.tile_data[tile_index] = game.tab_1.hold_t
			game.tab_1.hold = ""
			game.tab_1.hold_t = -1
			game.events.update_town = true
		}}
}

town_tab :: proc(
	game: ^Game_State,
	window: ^nl.Window_Data,
	mouse: nl.Mouse_Data,
	shader: rl.Shader,
) {
	print_coord_mouse :: proc(on_tile_pos: nl.Coord, window: nl.Window_Data) {

		buffer: [16]u8
		temp_string := fmt.bprintf(buffer[:], "X %d, Y %d", on_tile_pos.x, on_tile_pos.y)
		nl.draw_text(
			text = temp_string,
			position = nl.Coord{300, 380},
			spacing = 5,
			color = rl.Color{50, 50, 50, 255},
			fontSize = 20,
			window = window,
		)

	}

	display_oidstat :: proc(game: Game_State, window: ^nl.Window_Data) {
		buffer: [16]u8
		temp_string := fmt.bprintf(
			buffer[:],
			"%fe%f",
			game.global.oid.mantissa,
			f64(game.global.oid.exponent),
		)
		display_icon_text(
			png = "oid.png",
			text = temp_string,
			position = nl.Coord{70, 8},
			offset = nl.Coord{32, 9},
			font_size = 15,
			window = window,
		)

	}

	buildings_manager :: proc(
		on_tile_pos: nl.Coord,
		game: ^Game_State,
		window: ^nl.Window_Data,
		mouse: nl.Mouse_Data,
	) {
		valid_tile := false
		if on_tile_pos.x >= 0 {
			if on_tile_pos.y >= 0 {
				if on_tile_pos.x < game.tab_1.map_mesh.size.x {
					if on_tile_pos.y < game.tab_1.map_mesh.size.y {
						valid_tile = true
					}}}}
		nl.draw_png(position = mouse.pos, png_name = game.tab_1.hold, window = window, size = 2)
		if (valid_tile) {set_town(game, on_tile_pos, mouse)}
		building_select_tab(game = game, window = window, mouse = mouse)
	}

	display_tiles :: proc(
		game: ^Game_State,
		on_tile_pos: ^nl.Coord,
		shader: rl.Shader,
		window: ^nl.Window_Data,
		mouse: nl.Mouse_Data,
	) {
		tile_set := [?]string {
			"",
			"boulders.png",
			"tree.png",
			"grass.png",
			"house_lv0.png",
			"house_lv1.png",
			"house_lv2.png",
			"house_lv3.png",
		}
		offset_tiles := nl.Coord{295, 0} + game.tab_1.camera
		if !game.tab_1.dev_see {
			nl.begin_draw_area(nl.Coord{295, 0}, nl.Coord{19, 13} * nl.Coord{32, 32}, window^)
			rl.BeginShaderMode(shader)
			on_tile_pos^ = draw_all_tiles(
				tile_data = game.tab_1.tile_data,
				altitude = game.tab_1.map_mesh.array,
				tile_set = {
					rl.Color{25, 25, 35, 255},
					rl.Color{25, 25, 125, 255},
					rl.Color{25, 65, 25, 255},
					rl.Color{25, 75, 45, 255},
					rl.Color{85, 125, 85, 255},
					rl.Color{105, 105, 85, 255},
					rl.Color{125, 125, 125, 255},
					rl.Color{165, 165, 165, 255},
				},
				textures = tile_set,
				max = nl.Coord{300, 300},
				offset = offset_tiles,
				tilesize = 32,
				window = window,
				size = game.tab_1.camera_zoom,
				mouse = mouse,
				game = game,
			)
			rl.EndShaderMode()
			rl.EndScissorMode()
		}
	}

	camera_manager :: proc(game: ^Game_State) {
		sum_velocity :=
			game.tab_1.camera_vel.x * game.tab_1.camera_vel.x +
			game.tab_1.camera_vel.y * game.tab_1.camera_vel.y
		if (sum_velocity > 1) {
			game.tab_1.camera += nl.Coord {
				i32(f64(game.tab_1.camera_vel.x) * game.tab_1.camera_zoom),
				i32(f64(game.tab_1.camera_vel.y) * game.tab_1.camera_zoom),
			}
			if !game.slide {
				game.tab_1.camera_vel.x = i32(f64(game.tab_1.camera_vel.x) * 0.999)
				game.tab_1.camera_vel.y = i32(f64(game.tab_1.camera_vel.y) * 0.999)
			}
		}
	}

	draw_town_background :: proc(window: nl.Window_Data) {
		nl.draw_rectangle(nl.Coord{285, 0}, nl.Coord{10, 400}, window, rl.Color{33, 31, 50, 255})
		rl.BeginBlendMode(rl.BlendMode.SUBTRACT_COLORS)
		nl.draw_rectangle(
			nl.Coord{295, 0},
			nl.Coord{19, 13} * nl.Coord{32, 32},
			window,
			rl.Color{10, 10, 10, 255},
		)
		rl.EndBlendMode()

	}

	on_tile_pos: nl.Coord
	draw_town_background(window = window^)
	display_tiles(game, &on_tile_pos, shader, window, mouse)
	camera_manager(game = game)
	buildings_manager(on_tile_pos = on_tile_pos, game = game, window = window, mouse = mouse)
	display_oidstat(game^, window)
	print_coord_mouse(on_tile_pos, window^)
	// display resources


}

side_bar_tab :: proc(window: ^nl.Window_Data, mouse: nl.Mouse_Data, game: ^Game_State) {
	if nl.button_png_t(
		position = nl.Coord{0, 0},
		hitbox = nl.Coord{64, 64},
		png_name = [3]string{"tab_setting_1.png", "tab_setting_2.png", "tab_setting_3.png"},
		window = window,
		mouse = mouse,
		size = 2,
	) {game.tab_state = 0}
	if nl.button_png_t(
		position = nl.Coord{0, 64},
		hitbox = nl.Coord{64, 64},
		png_name = [3]string{"tab_town_1.png", "tab_town_2.png", "tab_town_3.png"},
		window = window,
		mouse = mouse,
		size = 2,
	) {game.tab_state = 1}

}

process_inputs :: proc(game: ^Game_State) {
	if (game.tab_state == 0) {
		if rl.IsKeyPressed((rl.KeyboardKey.M)) {
			game.tab_1.dev_see = game.tab_1.dev_see != true
			fmt.println("dev seek: map")
		}
		if rl.IsKeyPressed((rl.KeyboardKey.E)) {
			game.tab_1.dev_see = game.tab_1.dev_see != true
			fmt.println("dev seek: elevation")
		}
	} else if (game.tab_state == 1) {
			// odinfmt: disable
		if rl.IsKeyDown(
			rl.KeyboardKey.A,
		) 
    {game.tab_1.camera_vel.x += 1;game.slide = true} else if rl.IsKeyDown(rl.KeyboardKey.D) 
    {game.tab_1.camera_vel.x -= 1;game.slide = true} else if rl.IsKeyDown(rl.KeyboardKey.W) 
    {game.tab_1.camera_vel.y += 1;game.slide = true} else if rl.IsKeyDown(rl.KeyboardKey.S) 
    {game.tab_1.camera_vel.y -= 1;game.slide = true} else {game.slide = false}
		// odinfmt: enable
		resize := f64(rl.GetMouseWheelMove())
		if resize != 0 {
			resize = resize * 0.05 * game.tab_1.camera_zoom_speed * 3
			old_z: f64
			if (resize < 0) {
				game.tab_1.camera_zoom *= 2
				// zoom_a := game.tab_1.camera_zoom
				// margin: [2]f64 = {605.0, 400.0} / {4, 4} * {zoom_a, zoom_a}
				// game.tab_1.camera -= {i32(margin.x), i32(margin.y)}
			} else {
				game.tab_1.camera_zoom /= 2
				// zoom_a := game.tab_1.camera_zoom
				// margin: [2]f64 = {605.0, 400.0} / {2, 2} * {zoom_a, zoom_a}
				// game.tab_1.camera += {i32(margin.x), i32(margin.y)}
			}
		}}
}

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	Screen_Width :: 900
	Screen_Height :: 400

	rl.InitWindow(Screen_Width, Screen_Height, "ETERNALOID")
	rl.SetTargetFPS(60)
	rl.SetWindowState(rl.ConfigFlags{.WINDOW_RESIZABLE})
	// rl.SetWindowState(rl.ConfigFlags{.WINDOW_ALWAYS_RUN})
	set_icon()
	tile_data_NO_USE: []i32 = make_slice([]i32, 300 * 300)
	window := nl.Window_Data {
		original_size   = nl.Coord{Screen_Width, Screen_Height},
		present_size    = nl.Coord{Screen_Width, Screen_Height},
		image_cache_map = make(map[string]rl.Texture),
		font            = rl.LoadFont("assets\\BigBlueTerm437NerdFont-Regular.ttf"),
	}
	mouse := nl.Mouse_Data {
		pos         = nl.Coord{0, 0},
		virtual_pos = nl.Coord{0, 0},
		clicking    = false,
	}
	global_resources := Global_Data {
		oid = od.bigfloat{0, 0},
	}
	global_resource_managers := Global_Resource {
		oid = rsc.Resource_Manager {
			output = &global_resources.oid,
			base = make_slice([]od.bigfloat, 1),
			multiplier = make_slice([]od.bigfloat, 0),
			exponent = make_slice([]od.bigfloat, 0),
      cached_income = od.bigfloat{0,0} 
		},
	}
	game := Game_State {
		global = &global_resources,
		tab_state = 1,
		tab_1 = Game_Tab_1 {
			hold = "",
			tile_data = tile_data_NO_USE,
			map_mesh = rg.create_mesh_custom({300, 300}, 300, 2151232),
			camera_zoom = 1,
			camera_zoom_speed = 0.3,
		},
	}
	generate_objects(&game)

	shader := rl.LoadShader("", "shaders/pixel_filter.glsl")
	defer rl.UnloadShader(shader)

	frame: i128 = 0

	for !rl.WindowShouldClose() {


		if rl.IsWindowResized() {
			window.present_size = nl.Coord{rl.GetScreenWidth(), rl.GetScreenHeight()}
		}
		process_inputs(&game)
		nl.update_mouse(&mouse, window)

		rl.BeginDrawing()
		rl.ClearBackground(rl.Color{49, 36, 58, 255})

		side_bar_tab(&window, mouse, &game)
		if (game.tab_state == 0) {
			settings_tab(window = &window, mouse = mouse, game = &game)
		} else if (game.tab_state == 1) {
			town_tab(game = &game, window = &window, mouse = mouse, shader = shader)
		}
		rl.EndDrawing()
		frame += 1
		animate_textures(window = &window, frame = frame)
    global(&game)
	}
	delete(window.image_cache_map)
	delete(tile_data_NO_USE)
	delete(game.tab_1.map_mesh.array)
	delete(global_resource_managers.oid.base)
	delete(global_resource_managers.oid.multiplier)
	delete(global_resource_managers.oid.exponent)
}
