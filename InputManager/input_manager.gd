extends Node

var ui_panels: Array[UIPanel] = []

var current_panel: UIPanel = null:
	set(value):
		if current_panel != null and value != current_panel:
			current_panel.mouse_exit()
			
		current_panel = value



var right_is_primary: bool = true:
	set(value):
		if right_is_primary == value: return
		
		right_is_primary = value
		

var right_hand: XRControllerTracker = XRServer.get_tracker("right_hand")
var left_hand: XRControllerTracker = XRServer.get_tracker("left_hand")



func get_primary_hand() -> XRControllerTracker:
	if right_is_primary:
		return right_hand
	else:
		return left_hand

func get_secondary_hand() -> XRControllerTracker:
	if right_is_primary:
		return left_hand
	else:
		return right_hand


func get_primary_click_float() -> float:
	return get_primary_hand().get_input("trigger") as float


const CLICK_THRESHOLD := 0.3

func get_primary_click_bool() -> bool:
	return get_primary_click_float() > CLICK_THRESHOLD
