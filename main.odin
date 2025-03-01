package rlib

import rl "vendor:raylib"
import "core:fmt"
import "core:mem"
import nl "libs/nlib"

tile_draw :: proc(tile_data : $T, textures : [$P]rl.Texture2D, x_max : i32, y_max : i32, x_offset : i32, y_offset: i32,tilesize : i32) {
  for y in 0..<y_max
  {

    for x in 0..<x_max
    {
      pos := y*x_max+x
      fmt.println(pos);
      tile_type := tile_data[pos]
      if (tile_type > 0){
        texture : rl.Texture2D = textures[tile_type-1]
        rl.DrawTexture(texture, x*tilesize + x_offset, y*tilesize + y_offset, rl.Color{255,255,255,255});
      }
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

Screen_Width :: 800
Screen_Height :: 450

rl.InitWindow(Screen_Width,Screen_Height, "window name here~")
rl.SetTargetFPS(60)


texture := rl.LoadTexture("bongbongbutpixelz.png");
textures := [?]rl.Texture{rl.LoadTexture("house_lv1.png")}; 


tile_data := [?]i32{
  1,1,0,0,0,0,0,0,0,0,
  0,1,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0
  };



for !rl.WindowShouldClose() {
  rl.BeginDrawing()
  rl.ClearBackground(rl.Color{49, 36, 58, 255})
  // rl.DrawText("here~", 49, 36, 58, rl.LIGHTGRAY)

  rl.DrawTexture(texture, Screen_Width/2 - texture.width/2, Screen_Height/2 - texture.height/2, rl.Color{255,255,255,255});
  tile_draw(tile_data,textures,10,10,50,50,16)
  rl.EndDrawing()
}

rl.CloseWindow()
}
