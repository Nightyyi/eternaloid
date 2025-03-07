package rlib

import nl "libs/nlib"
import rl "vendor:raylib"

import "core:encoding/json"
import "core:fmt"
import "core:mem"

Game_State :: struct {
	global:    Global_Data,
	tab_state: i32,
	tab_1:     Game_Tab_1,
}

Global_Data :: struct {
	oib: f64,
}

Game_Tab_1 :: struct {
	camera: nl.Coord,
}


tile_draw :: proc(
	tile_data: $T,
	textures: [$P]string,
	max: nl.Coord,
	offset: nl.Coord,
	tilesize: i32,
	window: ^nl.Window_Data,
) {

	pos := 0
	for y in 0 ..< max.y {
		for x in 0 ..< max.x {

			nl.draw_png(
				position = nl.Coord{x * tilesize + offset.x, y * tilesize + offset.y},
				png_name = textures[tile_data[y * max.x + x]],
				window = window,
				size = 2,
				color = rl.Color{255, 255, 255, 0},
			)

		}
	}
}

process_inputs :: proc(game: ^Game_State) {
	if (game.tab_state == 0) {
		if rl.IsKeyPressed(rl.KeyboardKey.A) {game.tab_1.camera.x -= 16}
		if rl.IsKeyPressed(rl.KeyboardKey.D) {game.tab_1.camera.x += 16}
		if rl.IsKeyPressed(rl.KeyboardKey.W) {game.tab_1.camera.y -= 16}
		if rl.IsKeyPressed(rl.KeyboardKey.S) {game.tab_1.camera.y += 16}

		if rl.IsKeyPressedRepeat(rl.KeyboardKey.A) {game.tab_1.camera.x -= 16}
		if rl.IsKeyPressedRepeat(rl.KeyboardKey.D) {game.tab_1.camera.x += 16}
		if rl.IsKeyPressedRepeat(rl.KeyboardKey.W) {game.tab_1.camera.y -= 16}
		if rl.IsKeyPressedRepeat(rl.KeyboardKey.S) {game.tab_1.camera.y += 16}
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
	
	// odinfmt: disable
	tile_data := [?]i32 {
		1,1,0,0,0,0,0,0,0,0,
		0,1,0,0,0,0,0,0,0,0,
		0,0,1,2,3,4,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,1,0,0,0,0,0,
		0,0,0,0,0,0,0,0,1,0,
		0,0,0,0,0,0,0,0,0,0
	}
	// odinfmt: enable

	img_cache := make(map[string]nl.Texture_Cache)
	window := nl.Window_Data {
		original_size   = nl.Coord{Screen_Width, Screen_Height},
		present_size    = nl.Coord{Screen_Width, Screen_Height},
		image_cache_map = img_cache,
	}

	mouse := nl.Mouse_Data {
		pos         = nl.Coord{0, 0},
		virtual_pos = nl.Coord{0, 0},
		clicking    = false,
	}


	game := Game_State {
		global    = Global_Data{},
		tab_state = 0,
		tab_1     = Game_Tab_1{},
	}

	shader := rl.LoadShader("", "shaders/pixel_filter.glsl")
	defer rl.UnloadShader(shader)
	for !rl.WindowShouldClose() {

		if rl.IsWindowResized() {
			window.present_size = nl.Coord{rl.GetScreenWidth(), rl.GetScreenHeight()}
			// delete(img_cache)
			// img_cache = make(map[string]nl.Texture_Cache)
			// window.image_cache_map = img_cache

		}
		process_inputs(&game)
		nl.update_mouse(&mouse, window)

		rl.BeginDrawing()

		rl.ClearBackground(rl.Color{49, 36, 58, 255})
		nl.button_png_t(
			position = nl.Coord{0, 0},
			hitbox = nl.Coord{64, 64},
			png_name = [3]string{"tab_town_1.png","tab_town_2.png","tab_town_3.png",},
			window = &window,
			mouse = mouse,
		)

		if (game.tab_state == 0) {

			rl.BeginBlendMode(rl.BlendMode.SUBTRACT_COLORS)
			nl.draw_rectangle(
				nl.Coord{290, 40},
				nl.Coord{10, 10} * nl.Coord{32, 32},
				window,
				rl.Color{49, 36, 58, 255},
			)
			rl.EndBlendMode()


			// rl.DrawText("here~", 49, 36, 58, rl.LIGHTGRAY)
			nl.begin_draw_area(nl.Coord{290, 40}, nl.Coord{10, 10} * nl.Coord{32, 32}, window)
			rl.BeginShaderMode(shader)
			tile_set := [?]string {
				"tree.png",
				"house_lv0.png",
				"house_lv1.png",
				"house_lv2.png",
				"house_lv3.png",
			}
			tile_draw(
				tile_data = tile_data,
				textures = tile_set,
				max = nl.Coord{10, 10},
				offset = nl.Coord{290, 40} + game.tab_1.camera,
				tilesize = 32,
				window = &window,
			)
			rl.EndShaderMode()
			rl.EndScissorMode()
		}
		rl.EndDrawing()
	}
	// crying 
	delete(img_cache)

	rl.CloseWindow()

}
