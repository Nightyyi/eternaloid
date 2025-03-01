package nlib

import rl "vendor:raylib"
import "core:fmt"
import "core:strings"

image_key :: struct{
  string_key : string,
  size_key   : i32,
}


get_texture :: proc(image_name : string, image_cache_map : map[image_key]rl.Texture ) -> rl.Texture{
  image_name_C : cstring = strings.clone_to_cstring(image_name) 
  texture : rl.Texture = rl.LoadTexture(image_name_C)
  delete(image_name_C)
  return (texture)
}

draw_png :: proc(x : i32, y: i32, png_name: string, image_cache_map : map[image_key]rl.Texture) {
  texture : rl.Texture = get_texture(png_name, image_cache_map)
  rl.DrawTexture(texture, x, y, rl.Color{255,255,255,255});
}

