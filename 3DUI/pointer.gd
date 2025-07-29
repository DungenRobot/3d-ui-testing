extends RayCast3D


const UI_LAYER = 512

const WORLD_LAYER = 1 + 4

@export
var cursor: Node3D

var current_screen: UIPanel = null

var offset: Transform3D


func _process(_delta):
	
	cursor.hide()
	
	var res = nearest_panel_intersection()
	
	InputManager.current_panel = res[0]
	
	if InputManager.current_panel == null: return
	
	var panel: UIPanel = InputManager.current_panel
	var pos_on_panel: Vector2 = res[1]
	
	cursor.global_position = panel.intersection_point
	cursor.show()
	
	var viewport_pos = panel._intersect_to_viewport_pos(pos_on_panel)
	
	# Sends the position of the mouse input to the ui panel.
	# The UI panel does the processing to turn this position into an
	# InputEvent for itself
	panel.push_mouse_input(viewport_pos)
	
	current_screen = panel
		


const NO_INTERSECTION = Vector3(-1, -1, -1)


## Returns an array of two elements: 
## The nearest panel and 2d intersection with that panel
func nearest_panel_intersection() -> Array:
	
	var nearest_panel: UIPanel = null
	var nearest_distance: float = INF
	var nearest_intersection: Vector2 = -Vector2.ONE
	
	for panel in InputManager.ui_panels:
		
		var res = panel.intersects_ray(global_position, -global_transform.basis.z)
		
		if res == Vector3(-1, -1, -1): continue
		
		var distance = res.z
		
		if distance > nearest_distance: continue
		
		var intersection = Vector2(res.x, res.y)
		
		nearest_panel = panel
		nearest_distance = distance
		nearest_intersection = intersection
	
	return [nearest_panel, nearest_intersection]
