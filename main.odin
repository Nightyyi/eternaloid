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
	window: ^nl.window_data,
) {
	pos := 0
	for y in 0 ..< y_max {

		for x in 0 ..< x_max {
			if (tile_data[pos] > 0) {
				tile_type := texture_names[tile_data[pos] - 1]
				nl.draw_png(x * tilesize + x_offset, y * tilesize + y_offset, tile_type, window, 1)
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

	Screen_Width :: 150
	Screen_Height :: 120

	rl.InitWindow(Screen_Width, Screen_Height, "ETERNALOID")
	rl.SetTargetFPS(60)
	rl.SetWindowState(rl.ConfigFlags{.WINDOW_RESIZABLE})
	rl.SetWindowState(rl.ConfigFlags{.WINDOW_ALWAYS_RUN})

	

	// odinfmt: disable
	tile_data := [?]i32 {
		1,1,0,0,0,0,0,0,0,0,
		0,1,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,1,0,
		0,0,0,0,0,0,0,0,0,0
	}
	// odinfmt: enable

	img_cache := make(map[nl.image_key]rl.Texture)
	window := nl.window_data {
		original_width  = Screen_Width,
		original_height = Screen_Height,
		present_width   = Screen_Width,
		present_height  = Screen_Height,
		image_cache_map = img_cache,
	}

	mouse := nl.mouse_data {
		mouse_x         = 0,
		mouse_y         = 0,
		virtual_mouse_x = 0,
		virtual_mouse_y = 0,
		clicking        = false,
	}

  shader := rl.LoadShader("", "shaders/pixel_filter.glsl")
	defer rl.UnloadShader(shader)
	rotation_test : f32 = 0;
  for !rl.WindowShouldClose() {

		if rl.IsWindowResized() {
			window.present_width = rl.GetScreenWidth()
			window.present_height = rl.GetScreenHeight()
			delete(img_cache)
			img_cache = make(map[nl.image_key]rl.Texture)
			window.image_cache_map = img_cache

		}

		nl.update_mouse(&mouse, &window)

		rl.BeginDrawing()
		rl.ClearBackground(rl.Color{49, 36, 58, 255})

    rl.BeginShaderMode(shader)
		rl.DrawText("here~", 49, 36, 58, rl.LIGHTGRAY)
		tile_set := [?]string{"house_lv1.png"}
		tile_draw(tile_data, tile_set, 10, 10, 50, 50, 32, &window)
		nl.button_png_t(
			50,
			50,
			{"house_button.png", "house_button_2.png", "house_button_3.png"},
			&window,
			mouse,
			32,
			32,
			rotation_test,
		)
    rotation_test = rotation_test+1
    rl.EndShaderMode()
		nl.draw_borders(&window)
		rl.EndDrawing()
	}

	rl.CloseWindow()

	// crying 
	delete(img_cache)
}
