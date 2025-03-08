package rlib

import nl "libs/nlib"
import rl "vendor:raylib"

import "core:encoding/json"
import "core:fmt"
import "core:mem"
import "core:path/filepath"
import "core:strings"

Game_State :: struct {
	global:    Global_Data,
	tab_state: i32,
	tab_1:     Game_Tab_1,
	slide:     bool,
}

Global_Data :: struct {
	oid: f64,
}

Game_Tab_1 :: struct {
	camera:      nl.Coord,
	camera_vel:  nl.Coord,
	camera_zoom: f64,
	hold:        string,
	hold_t:      i32,
	tile_data:   []i32,
}


tile_draw :: proc(
	tile_data: $T,
	textures: [$P]string,
	max: nl.Coord,
	offset: nl.Coord,
	tilesize: i32,
	window: ^nl.Window_Data,
	size: f64 = 1,
	highlight: nl.Coord,
) {

	pos := 0
	for y in 0 ..< max.y {
		for x in 0 ..< max.x {
			if (nl.Coord{x, y} == highlight) {
				nl.draw_rectangle(
					position = nl.Coord {
						i32(f64(x * tilesize + offset.x) * size),
						i32(f64(y * tilesize + offset.y) * size),
					},
					size = nl.Coord{i32(32 * size), i32(32 * size)},
					window = window^,
					color = rl.Color{150, 150, 150, 255},
				)

			}
			nl.draw_png(
				position = nl.Coord {
					i32(f64(x * tilesize + offset.x) * size),
					i32(f64(y * tilesize + offset.y) * size),
				},
				png_name = textures[tile_data[y * max.x + x]],
				window = window,
				size = f32(2 * size),
				color = rl.Color{255, 255, 255, 0},
			)

		}
	}
}

// yes i do want a seperate function for this
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
	) {game.tab_1.hold = "house_lv0.png";game.tab_1.hold_t = 1}
}

set_town :: proc(game: ^Game_State, tile: nl.Coord, mouse: nl.Mouse_Data) {
	if (mouse.clicking) {
		if (game.tab_1.hold != "") {
			tile_index: i32 = 100 * tile.y + tile.x
			fmt.println(tile_index)
			game.tab_1.tile_data[tile_index] = game.tab_1.hold_t
			game.tab_1.hold = ""
			game.tab_1.hold_t = -1
		}}
}

town_tab :: proc(
	game: ^Game_State,
	window: ^nl.Window_Data,
	mouse: nl.Mouse_Data,
	shader: rl.Shader,
) {
	nl.draw_rectangle(nl.Coord{285, 0}, nl.Coord{10, 400}, window^, rl.Color{33, 31, 50, 255})
	rl.BeginBlendMode(rl.BlendMode.SUBTRACT_COLORS)
	nl.draw_rectangle(
		nl.Coord{295, 0},
		nl.Coord{19, 13} * nl.Coord{32, 32},
		window^,
		rl.Color{10, 10, 10, 255},
	)
	rl.EndBlendMode()
	nl.begin_draw_area(nl.Coord{295, 0}, nl.Coord{19, 13} * nl.Coord{32, 32}, window^)
	tile_set := [?]string {
		"tree.png",
		"house_lv0.png",
		"house_lv1.png",
		"house_lv2.png",
		"house_lv3.png",
	}
	zoom_ts := (32 * game.tab_1.camera_zoom)
	offset_tiles := nl.Coord{295, 0} + game.tab_1.camera
	delta := (mouse.pos - offset_tiles)
	on_tile_pos := nl.Coord {
		i32(f64(delta.x) / zoom_ts),
		i32(f64(delta.y) / zoom_ts),
	}

	sum_velocity :=
		game.tab_1.camera_vel.x * game.tab_1.camera_vel.x +
		game.tab_1.camera_vel.y * game.tab_1.camera_vel.y
	if (sum_velocity > 1) {
		game.tab_1.camera += game.tab_1.camera_vel
		if !game.slide {
			game.tab_1.camera_vel.x = i32(f64(game.tab_1.camera_vel.x) * 0.999)
			game.tab_1.camera_vel.y = i32(f64(game.tab_1.camera_vel.y) * 0.999)

		}


	}

	valid_tile := false
	if on_tile_pos.x >= 0 {
		if on_tile_pos.y >= 0 {
			if on_tile_pos.x < 100 {
				if on_tile_pos.y < 100 {
					valid_tile = true
				}}}}

	rl.BeginShaderMode(shader)
	tile_draw(
		tile_data = game.tab_1.tile_data,
		textures = tile_set,
		max = nl.Coord{100, 100},
		offset = offset_tiles,
		tilesize = 32,
		window = window,
		size = game.tab_1.camera_zoom,
		highlight = on_tile_pos,
	)
	rl.EndShaderMode()
	rl.EndScissorMode()
	nl.draw_png(position = mouse.pos, png_name = game.tab_1.hold, window = window, size = 2)

	if (valid_tile) {set_town(game, on_tile_pos, mouse)}

	building_select_tab(game = game, window = window, mouse = mouse)
	buffer: [16]u8
	temp_string := fmt.bprintf(buffer[:], "%f", game.global.oid)
	display_icon_text(
		png = "oid.png",
		text = temp_string,
		position = nl.Coord{70, 8},
		offset = nl.Coord{32, 9},
		font_size = 15,
		window = window,
	)

	temp_string = fmt.bprintf(buffer[:], "X %d, Y %d", on_tile_pos.x, on_tile_pos.y)
	nl.draw_text(
		text = temp_string,
		position = nl.Coord{300, 380},
		spacing = 5,
		color = rl.Color{50, 50, 50, 255},
		fontSize = 20,
		window = window^,
	)


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
	if (game.tab_state == 1) {
		// odinfmt: disable
		if rl.IsKeyDown(
			rl.KeyboardKey.A,
		) {game.tab_1.camera_vel.x += 1;game.slide = true} else if rl.IsKeyDown(rl.KeyboardKey.D) {game.tab_1.camera_vel.x -= 1;game.slide = true} else if rl.IsKeyDown(rl.KeyboardKey.W) {game.tab_1.camera_vel.y += 1;game.slide = true} else if rl.IsKeyDown(rl.KeyboardKey.S) {game.tab_1.camera_vel.y -= 1;game.slide = true} else {game.slide = false}
		// odinfmt: disable


		if rl.IsKeyPressed(rl.KeyboardKey.UP) {
			game.tab_1.camera_zoom *= 2
			game.tab_1.camera.x /= 2
			game.tab_1.camera.y /= 2
		}
		if rl.IsKeyPressed(rl.KeyboardKey.DOWN) {
			game.tab_1.camera_zoom /= 2
			game.tab_1.camera.x *= 2
			game.tab_1.camera.y *= 2
		}
	}
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
	tile_data_NO_USE: [10000]i32
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
	game := Game_State {
		global = Global_Data{oid = 1},
		tab_state = 1,
		tab_1 = Game_Tab_1{hold = "", tile_data = tile_data_NO_USE[:], camera_zoom = 1},
	}

	shader := rl.LoadShader("", "shaders/pixel_filter.glsl")
	defer rl.UnloadShader(shader)


	for !rl.WindowShouldClose() {

		if rl.IsWindowResized() {
			window.present_size = nl.Coord{rl.GetScreenWidth(), rl.GetScreenHeight()}

		}
		process_inputs(&game)
		nl.update_mouse(&mouse, window)

		rl.BeginDrawing()

		side_bar_tab(&window, mouse, &game)


		rl.ClearBackground(rl.Color{49, 36, 58, 255})

		if (game.tab_state == 1) {
			town_tab(game = &game, window = &window, mouse = mouse, shader = shader)
		}
		rl.EndDrawing()
	}

	delete(window.image_cache_map)

}
