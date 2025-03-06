package rlib

import nl "libs/nlib"
import rl "vendor:raylib"

import "core:encoding/json"
import "core:fmt"
import "core:mem"


tile_draw :: proc(
	tile_data: $T,
	texture_names: [$P]string,
	x_max: i32,
	y_max: i32,
	x_offset: i32,
	y_offset: i32,
	tilesize: i32,
	window: ^nl.Window_Data,
) {
	pos := 0
	for y in 0 ..< y_max {

		for x in 0 ..< x_max {
			if (tile_data[pos] > 0) {
				tile_type := texture_names[tile_data[pos] - 1]
				nl.draw_png(
					nl.Coord{x * tilesize + x_offset, y * tilesize + y_offset},
					tile_type,
					window,
					2,
				)
			}
			pos = pos + 1
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
	rl.SetWindowState(rl.ConfigFlags{.WINDOW_ALWAYS_RUN})


	
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

	shader := rl.LoadShader("", "shaders/pixel_filter.glsl")
	defer rl.UnloadShader(shader)
	for !rl.WindowShouldClose() {

		if rl.IsWindowResized() {
			window.present_size = nl.Coord{rl.GetScreenWidth(), rl.GetScreenHeight()}
			// delete(img_cache)
			// img_cache = make(map[string]nl.Texture_Cache)
			// window.image_cache_map = img_cache

		}
		nl.update_mouse(&mouse, window)
		rl.BeginDrawing()

		rl.ClearBackground(rl.Color{49, 36, 58, 255})

		rl.BeginShaderMode(shader)
		rl.DrawText("here~", 49, 36, 58, rl.LIGHTGRAY)
		tile_set := [?]string{"house_lv0.png", "house_lv1.png", "house_lv2.png", "house_lv3.png"}
		nl.button_png_t(
			nl.Coord{50, 50},
			nl.Coord{32, 32},
			{"house_button.png", "house_button_2.png", "house_button_3.png"},
			&window,
			mouse,
		)
		tile_draw(tile_data, tile_set, 10, 10, 50, 50, 32, &window)
		rl.EndShaderMode()
		// nl.draw_borders(&window)  no longer used, for now.
		rl.EndDrawing()
	}

	rl.CloseWindow()

	// crying 
	delete(img_cache)
}
