package texts


import od "../odinium"
import "core:fmt"
import "core:math"

get_tablet_text :: proc(tablet_index: i32, tablet_level: i32, buf: []u8) -> (od.bigfloat, string) {
  temp_buf : [32]u8
  string : string = ""
	cost := od.bigfloat{1, 0}
	switch tablet_index {
	case 0:
    cost = od.bigfloat{1,i128(tablet_level+2)} 
    cost_string := od.print(&temp_buf,cost)
	  string = fmt.bprintf(buf,"Tablet of Wood Essence I (Level %d)\n 2x Wood Gain\nCost: %s", tablet_level,cost_string)
  case 1:
    cost = od.bigfloat{1,i128(tablet_level*2+2)} 
    cost_string := od.print(&temp_buf,cost)
	  string = fmt.bprintf(buf,"Tablet of Wood Essence II (Level %d)\n 3x Oid Gain\nCost: %s", tablet_level,cost_string)
	case 2:
    cost = od.bigfloat{1,i128(tablet_level*20+20)} 
    cost_string := od.print(&temp_buf,cost)
	  string = fmt.bprintf(buf,"Tablet of Wood Essence III (Level %d)\n Wood Gain divided by 100, Sacrifice is 10x stronger.\nCost: %s", tablet_level,cost_string)
	case 3:
    cost = od.bigfloat{1,i128(math.pow(2,f64(tablet_level))+2)} 
    cost_string := od.print(&temp_buf,cost)
	  string = fmt.bprintf(buf,"Tablet of Wood Essence IV (Level %d)\n Boost Wood god.. all other gods are weaker.\nCost: %s", tablet_level,cost_string)
	case 4:
    cost = od.bigfloat{f64(5*tablet_level+1),i128(10*tablet_level)+2} 
    cost_string := od.print(&temp_buf,cost)
	  string = fmt.bprintf(buf,"Tablet of Wood Essence V (Level %d)\n 2x Stronger Sacrifice.\nCost: %s", tablet_level,cost_string)
	case 5:
    cost = od.bigfloat{1,i128(tablet_level+2)} 
    cost_string := od.print(&temp_buf,cost)
	  string = fmt.bprintf(buf,"Tablet of Wood Essence VI (Level %d)\n +1 Builder\nCost: %s", tablet_level,cost_string)
	case 6:
    cost = od.bigfloat{f64(11*tablet_level+1),i128(tablet_level*11)+2} 
    cost_string := od.print(&temp_buf,cost)
	  string = fmt.bprintf(buf,"Tablet of Wood Essence VII (Level %d)\n Towers see 1 tile futher..\nCost: %s", tablet_level,cost_string)
	case 7:
    cost = od.bigfloat{1,i128(tablet_level*2+2)} 
    cost_string := od.print(&temp_buf,cost)
	  string = fmt.bprintf(buf,"Tablet of Wood Essence VIII (Level %d)\n Cost of Woodmills grow twice as slow.\nCost: %s", tablet_level,cost_string)
	case 8:
    cost = od.bigfloat{1,i128(tablet_level*3+2)} 
    cost_string := od.print(&temp_buf,cost)
	  string = fmt.bprintf(buf,"Tablet of Wood Essence IX (Level %d)\n The world is ever so slightly faster.. 1.5x speed\nCost: %s", tablet_level,cost_string)
	case 9:
    cost = od.bigfloat{1,i128(tablet_level+2)} 
	case 10:
    cost = od.bigfloat{1,i128(tablet_level*2+2)} 
	case 11:
    cost = od.bigfloat{1,i128(tablet_level*20+20)} 
	case 12:
    cost = od.bigfloat{1,i128(math.pow(2,f64(tablet_level))+2)} 
	case 13:
    cost = od.bigfloat{f64(5*tablet_level+1),i128(10*tablet_level)+2} 
	case 14:
    cost = od.bigfloat{1,i128(tablet_level+2)} 
	case 15:
    cost = od.bigfloat{f64(11*tablet_level+1),i128(tablet_level*11)+2} 
	case 16:
    cost = od.bigfloat{1,i128(tablet_level*2+2)} 
	case 17:
    cost = od.bigfloat{1,i128(tablet_level*3+2)} 
	case 18:
    cost = od.bigfloat{1,i128(tablet_level+2)} 
	case 19:
    cost = od.bigfloat{1,i128(tablet_level*2+2)} 
	case 20:
    cost = od.bigfloat{1,i128(tablet_level*20+20)} 
	case 21:
    cost = od.bigfloat{1,i128(math.pow(2,f64(tablet_level))+2)} 
	case 22:
    cost = od.bigfloat{f64(5*tablet_level+1),i128(10*tablet_level)+2} 
	case 23:
    cost = od.bigfloat{1,i128(tablet_level+2)} 
	case 24:
    cost = od.bigfloat{f64(11*tablet_level+1),i128(tablet_level*11)+2} 
	case 25:
    cost = od.bigfloat{1,i128(tablet_level*2+2)} 
	case 26:
    cost = od.bigfloat{1,i128(tablet_level*3+2)} 
	case 27:
    cost = od.bigfloat{1,i128(tablet_level+2)} 
	case 28:
    cost = od.bigfloat{1,i128(tablet_level*2+2)} 
	case 29:
    cost = od.bigfloat{1,i128(tablet_level*20+20)} 
	case 30:
    cost = od.bigfloat{1,i128(math.pow(2,f64(tablet_level))+2)} 
	case 31:
    cost = od.bigfloat{f64(5*tablet_level+1),i128(10*tablet_level)+2} 
	case 32:
    cost = od.bigfloat{1,i128(tablet_level+2)} 
	case 33:
    cost = od.bigfloat{f64(11*tablet_level+1),i128(tablet_level*11)+2} 
	case 34:
    cost = od.bigfloat{1,i128(tablet_level*2+2)} 
	case 35:
    cost = od.bigfloat{1,i128(tablet_level*3+2)} 
	}
	return cost, string
}
