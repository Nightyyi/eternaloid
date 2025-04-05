package texts


import od "../odinium"
import "core:fmt"
import "core:math"

get_tablet_text :: proc(
	tablet_index: i32,
	tablet_level: i32,
	buf: []u8,
) -> (
	od.bigfloat,
	string,
	i32,
) {
	texts := []string {
		"Tablet of Wood Essence I (Level %d)\n 2x Wood Gain\nCost: %s",
		"Tablet of Wood Essence II (Level %d)\n 3x Oid Gain\nCost: %s",
		"Tablet of Wood Essence I (Level %d)\n 2x Wood Gain\nCost: %s",
		"Tablet of Wood Essence II (Level %d)\n 3x Oid Gain\nCost: %s",
		"Tablet of Wood Essence III (Level %d)\n Wood Gain divided by 100\n Sacrifice is 10x stronger.\nCost: %s",
		"Tablet of Wood Essence IV (Level %d)\n Boost Wood god,\n all other gods are weaker.\nCost: %s",
		"Tablet of Wood Essence V (Level %d)\n 2x Stronger Sacrifice.\nCost: %s",
		"Tablet of Wood Essence VI (Level %d)\n +1 Builder\nCost: %s",
		"Tablet of Wood Essence VII (Level %d)\n Towers see 1 tile futher..\nCost: %s",
		"Tablet of Wood Essence VIII (Level %d)\n Cost of Woodmills grow twice as slow.\nCost: %s",
		"Tablet of Wood Essence IX (Level %d)\n The world is ever so slightly faster..\n 1.5x speed\nCost: %s",

		"Tablet of Oid Essence I (Level %d)\n 2x Wood Gain\nCost: %s",
		"Tablet of Oid Essence II (Level %d)\n 3x Oid Gain\nCost: %s",
		"Tablet of Oid Essence I (Level %d)\n 2x Wood Gain\nCost: %s",
		"Tablet of Oid Essence II (Level %d)\n 3x Oid Gain\nCost: %s",
		"Tablet of Oid Essence III (Level %d)\n  Gain divided by 100\n Sacrifice is 10x stronger.\nCost: %s",
		"Tablet of Oid Essence IV (Level %d)\n Boost Wood god,\n all other gods are weaker.\nCost: %s",
		"Tablet of Oid Essence V (Level %d)\n 2x Stronger Sacrifice.\nCost: %s",
		"Tablet of Oid Essence VI (Level %d)\n +1 Builder\nCost: %s",
		"Tablet of Oid Essence VII (Level %d)\n Towers see 1 tile futher..\nCost: %s",
		"Tablet of Oid Essence VIII (Level %d)\n Cost of Woodmills grow twice as slow.\nCost: %s",
		"Tablet of Oid Essence IX (Level %d)\n The world is ever so slightly faster..\n 1.5x speed\nCost: %s",

		"Tablet of Food Essence I (Level %d)\n 2x Wood Gain\nCost: %s",
		"Tablet of Food Essence II (Level %d)\n 3x Oid Gain\nCost: %s",
		"Tablet of Food Essence I (Level %d)\n 2x Wood Gain\nCost: %s",
		"Tablet of Food Essence II (Level %d)\n 3x Oid Gain\nCost: %s",
		"Tablet of Food Essence III (Level %d)\n Wood Gain divided by 100\n Sacrifice is 10x stronger.\nCost: %s",
		"Tablet of Food Essence IV (Level %d)\n Boost Wood god,\n all other gods are weaker.\nCost: %s",
		"Tablet of Food Essence V (Level %d)\n 2x Stronger Sacrifice.\nCost: %s",
		"Tablet of Food Essence VI (Level %d)\n +1 Builder\nCost: %s",
		"Tablet of Food Essence VII (Level %d)\n Towers see 1 tile futher..\nCost: %s",
		"Tablet of Food Essence VIII (Level %d)\n Cost of Woodmills grow twice as slow.\nCost: %s",
		"Tablet of Food Essence IX (Level %d)\n The world is ever so slightly faster..\n 1.5x speed\nCost: %s",
		
    "Tablet of Stone Essence I (Level %d)\n 2x Wood Gain\nCost: %s",
		"Tablet of Stone Essence II (Level %d)\n 3x Oid Gain\nCost: %s",
		"Tablet of Stone Essence I (Level %d)\n 2x Wood Gain\nCost: %s",
		"Tablet of Stone Essence II (Level %d)\n 3x Oid Gain\nCost: %s",
		"Tablet of Stone Essence III (Level %d)\n Wood Gain divided by 100\n Sacrifice is 10x stronger.\nCost: %s",
		"Tablet of Stone Essence IV (Level %d)\n Boost Wood god,\n all other gods are weaker.\nCost: %s",
		"Tablet of Stone Essence V (Level %d)\n 2x Stronger Sacrifice.\nCost: %s",
		"Tablet of Stone Essence VI (Level %d)\n +1 Builder\nCost: %s",
		"Tablet of Stone Essence VII (Level %d)\n Towers see 1 tile futher..\nCost: %s",
		"Tablet of Stone Essence VIII (Level %d)\n Cost of Woodmills grow twice as slow.\nCost: %s",
		"Tablet of Stone Essence IX (Level %d)\n The world is ever so slightly faster..\n 1.5x speed\nCost: %s",
	}
	temp_buf: [32]u8
	type: i32
	string: string = ""
	cost := od.bigfloat{1, 0}
	switch tablet_index {
	case 0:
		cost = od.bigfloat{1, i128(tablet_level + 2)}
	case 1:
		cost = od.bigfloat{1, i128(tablet_level * 2 + 2)}
	case 2:
		cost = od.bigfloat{1, i128(tablet_level * 20 + 20)}
	case 3:
		cost = od.bigfloat{1, i128(math.pow(2, f64(tablet_level)) + 2)}
	case 4:
		cost = od.bigfloat{f64(5 * tablet_level + 1), i128(10 * tablet_level) + 2}
	case 5:
		cost = od.bigfloat{1, i128(tablet_level + 2)}
	case 6:
		cost = od.bigfloat{f64(11 * tablet_level + 1), i128(tablet_level * 11) + 2}
	case 7:
		cost = od.bigfloat{1, i128(tablet_level * 2 + 2)}
	case 8:
		cost = od.bigfloat{1, i128(tablet_level * 3 + 2)}
	case 9:
		cost = od.bigfloat{1, i128(tablet_level + 2)}
	case 10:
		cost = od.bigfloat{1, i128(tablet_level * 2 + 2)}
	case 11:
		cost = od.bigfloat{1, i128(tablet_level * 20 + 20)}
	case 12:
		cost = od.bigfloat{1, i128(math.pow(2, f64(tablet_level)) + 2)}
	case 13:
		cost = od.bigfloat{f64(5 * tablet_level + 1), i128(10 * tablet_level) + 2}
	case 14:
		cost = od.bigfloat{1, i128(tablet_level + 2)}
	case 15:
		cost = od.bigfloat{f64(11 * tablet_level + 1), i128(tablet_level * 11) + 2}
	case 16:
		cost = od.bigfloat{1, i128(tablet_level * 2 + 2)}
	case 17:
		cost = od.bigfloat{1, i128(tablet_level * 3 + 2)}
	case 18:
		cost = od.bigfloat{1, i128(tablet_level + 2)}
	case 19:
		cost = od.bigfloat{1, i128(tablet_level * 2 + 2)}
	case 20:
		cost = od.bigfloat{1, i128(tablet_level * 20 + 20)}
	case 21:
		cost = od.bigfloat{1, i128(math.pow(2, f64(tablet_level)) + 2)}
	case 22:
		cost = od.bigfloat{f64(5 * tablet_level + 1), i128(10 * tablet_level) + 2}
	case 23:
		cost = od.bigfloat{1, i128(tablet_level + 2)}
	case 24:
		cost = od.bigfloat{f64(11 * tablet_level + 1), i128(tablet_level * 11) + 2}
	case 25:
		cost = od.bigfloat{1, i128(tablet_level * 2 + 2)}
	case 26:
		cost = od.bigfloat{1, i128(tablet_level * 3 + 2)}
	case 27:
		cost = od.bigfloat{1, i128(tablet_level + 2)}
	case 28:
		cost = od.bigfloat{1, i128(tablet_level * 2 + 2)}
	case 29:
		cost = od.bigfloat{1, i128(tablet_level * 20 + 20)}
	case 30:
		cost = od.bigfloat{1, i128(math.pow(2, f64(tablet_level)) + 2)}
	case 31:
		cost = od.bigfloat{f64(5 * tablet_level + 1), i128(10 * tablet_level) + 2}
	case 32:
		cost = od.bigfloat{1, i128(tablet_level + 2)}
	case 33:
		cost = od.bigfloat{f64(11 * tablet_level + 1), i128(tablet_level * 11) + 2}
	case 34:
		cost = od.bigfloat{1, i128(tablet_level * 2 + 2)}
	case 35:
		cost = od.bigfloat{1, i128(tablet_level * 3 + 2)}
	}
	cost_string := od.print(&temp_buf, cost)
	string = fmt.bprintf(buf, texts[tablet_index], tablet_level, cost_string)
	return cost, string, type
}
