@tool
class_name UIPanel extends MeshInstance3D

@export_tool_button("Reload UI") var ui_fun = reload_ui

@export
var ui_scene: PackedScene

@onready
var viewport: SubViewport = $SubViewport

@export
var disable_override: bool = false

@export_range(1.0, 1000.0)
var res_scale: float = 300:
	set(value):
		res_scale = value
		if disable_override: return
		if !Engine.is_editor_hint(): return
		if !is_node_ready(): return
		viewport.size.x = int(width * res_scale)
		viewport.size.y = int(height * res_scale)

@export
var width: float = 1.0:
	set(value):
		width = value
		if disable_override: return
		if !Engine.is_editor_hint(): return
		if !is_node_ready(): return
		$Back.mesh.size.x = width
		mesh.size.x = width
		viewport.size.x = int(width * res_scale)

@export
var height: float = 1.0:
	set(value):
		height = value
		if disable_override: return
		if !Engine.is_editor_hint(): return
		if !is_node_ready(): return
		$Back.mesh.size.y = height
		mesh.size.y = height
		viewport.size.y = int(height * res_scale)

## Keeps track of the last point of intersection.
##
## This value is updated by the [method intersects_ray] method
var intersection_point: Vector3 = Vector3.ZERO


const NO_INTERSECTION = Vector3(-1, -1, -1)


# Code ported from XR Tools. Thank you Bastiaan 
## Returns the intersection on the screen with a Vector3. 
## X and Y are the 2d components of the intersection 
## while Z is the distance from the ray origin to the point.
## A value of (-1, -1, -1) is no intersection
func intersects_ray(origin: Vector3, dir: Vector3) -> Vector3:
	if not is_visible_in_tree():
		return NO_INTERSECTION
	
	var quad_transform: Transform3D = global_transform
	var quad_normal: Vector3 = quad_transform.basis.z
	
	var denom: float = quad_normal.dot(dir)
	
	if denom > 0: 
		return NO_INTERSECTION
	
	if abs(denom) <= 0.0001:
		return NO_INTERSECTION
	
	var vector: Vector3 = quad_transform.origin - origin
	var t: float = vector.dot(quad_normal) / denom
	if t < 0.0:
		return NO_INTERSECTION
	
	intersection_point = origin + (dir * t)
	
	var relative_point = intersection_point - quad_transform.origin
	
	var projected_point = Vector2(
		relative_point.dot(quad_transform.basis.x),
		relative_point.dot(quad_transform.basis.y)
	)
	
	if abs(projected_point.x) > width / 2.0:
		return NO_INTERSECTION
	if abs(projected_point.y) > height / 2.0:
		return NO_INTERSECTION
		
	var u: float = 0.5 + (projected_point.x / width)
	var v: float = 1.0 - (0.5 + (projected_point.y / height))
	return Vector3(u, v, t)



func _intersect_to_viewport_pos(intersection : Vector2) -> Vector2i:
	var pos : Vector2 = intersection * Vector2(viewport.size)
	return Vector2i(pos)



var last_mouse_position := Vector2(-1, -1)
var was_button_pressed := false
var last_event: int = 0

func push_mouse_input(new_pos: Vector2):
	@warning_ignore("integer_division")
	var now = Time.get_ticks_msec() / 1000
	
	var is_button_pressed = InputManager.get_primary_click_bool()
	
	# we've just pressed or unpressed trigger
	if was_button_pressed != is_button_pressed:
		
		var event_push = InputEventMouseButton.new()
		event_push.button_index = MOUSE_BUTTON_LEFT
		if is_button_pressed:
			event_push.button_mask = MOUSE_BUTTON_MASK_LEFT
		event_push.pressed = is_button_pressed
		event_push.position = new_pos
		event_push.global_position = new_pos
		viewport.push_input(event_push)
		
	else:
		
		var event = InputEventMouseMotion.new()
		event.screen_relative = new_pos - last_mouse_position
		event.relative = new_pos - last_mouse_position
		event.velocity = event.relative / (now - last_event)
		event.position = new_pos
		event.global_position = new_pos
		if is_button_pressed:
			event.button_mask = MOUSE_BUTTON_MASK_LEFT
		viewport.push_input(event)
	last_event = now
	last_mouse_position = new_pos
	was_button_pressed = is_button_pressed

func mouse_exit():
	last_mouse_position = Vector2(-1, -1)
	was_button_pressed = false
	
	var event_move = InputEventMouseMotion.new()
	event_move.position = last_mouse_position
	viewport.push_input(event_move)
	
	var event_push = InputEventMouseButton.new()
	event_push.pressed = false
	event_push.button_index = MOUSE_BUTTON_LEFT
	viewport.push_input(event_push)


func force_update_panel():
	pass

var ui_instance: Node = null

func _ready():
	reload_ui()
	
	if !Engine.is_editor_hint():
		#add ourselves to list of known ui panels
		InputManager.ui_panels.append(self)
		print("INIT UI ", name)
		_ui_ready()

func _ui_ready():
	pass


func _exit_tree():
	if !Engine.is_editor_hint():
		InputManager.ui_panels.erase(self)


func reload_ui():
	res_scale = res_scale
	
	if not disable_override:
		viewport.size.x = int(width * res_scale)
		viewport.size.y = int(height * res_scale)
	
	if ui_scene != null:
		if ui_instance != null:
			viewport.remove_child(ui_instance)
			ui_instance.queue_free()
			ui_instance = null
		ui_instance = ui_scene.instantiate()
		viewport.add_child(ui_instance)
