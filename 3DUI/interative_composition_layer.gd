class_name InteractivePanel extends MeshInstance3D



@export
var report_on_buttons_only: bool = false

const NO_INTERSECTION = Vector2(-1.0, -1.0)

@export
var controller: XRController3D

@export
var button_action: String = "trigger_click"

var was_pressed: bool = false

var was_intersect: Vector2 = NO_INTERSECTION


var quad_size = mesh.size

@export
var layer_viewport: SubViewport


func intersects_ray(origin: Vector3, dir: Vector3, allow_behind: bool = false) -> Vector2:
	var quad_transform: Transform3D = global_transform
	var quad_normal: Vector3 = quad_transform.basis.z
	
	var denom: float = quad_normal.dot(dir)
	
	if not allow_behind and denom > 0: 
		return Vector2(-1, -1)
	
	if abs(denom) > 0.0001:
		var vector: Vector3 = quad_transform.origin - origin
		var t: float = vector.dot(quad_normal) / denom
		if t < 0.0:
			return Vector2(-1, -1)
		var intersection = origin + (dir * t)
		
		var relative_point = intersection - quad_transform.origin
		
		var projected_point = Vector2(
			relative_point.dot(quad_transform.basis.x),
			relative_point.dot(quad_transform.basis.y)
		)
		
		if abs(projected_point.x) > quad_size.x / 2.0:
			return Vector2(-1, -1)
		if abs(projected_point.y) > quad_size.y / 2.0:
			return Vector2(-1, -1)
			
		var u: float = 0.5 + (projected_point.x / quad_size.x)
		var v: float = 1.0 - (0.5 + (projected_point.y / quad_size.y))
		return Vector2(u, v)

	
	return Vector2(-1, -1)


func _intersect_to_global_position(intersect: Vector2) -> Vector3:
	if intersect != NO_INTERSECTION:
		var local_pos :Vector2 = (intersect - Vector2(0.5, 0.5)) * quad_size
		return global_transform * Vector3(local_pos.x, -local_pos.y, 0)
	else:
		return Vector3()
	

func _intersect_to_viewport_pos(intersect : Vector2) -> Vector2i:
	if layer_viewport and intersect != NO_INTERSECTION:
		var pos : Vector2 = intersect * Vector2(layer_viewport.size)
		return Vector2i(pos)
	else:
		return Vector2i(-1, -1)


#func _ready():
	#$Pointer.rotation = Vector3.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	#$Pointer.visible = false
	
	if controller and layer_viewport and controller.get_pose():
		var controller_trans : Transform3D = controller.global_transform
		var intersect: Vector2 = intersects_ray(controller_trans.origin, -controller_trans.basis.z)
	
		#$"../../Cone".global_transform = controller.get_pose().transform
		
	
		if intersect != NO_INTERSECTION:
			var is_pressed = controller.is_button_pressed(button_action)
			var pos: Vector3 = _intersect_to_global_position(intersect)
			
			#$Pointer.visible = true
			#$Pointer.global_position = pos + (transform.basis.z * 0.001)
			

			if was_intersect != NO_INTERSECTION and intersect != was_intersect:
				# Pointer moved
				var event : InputEventMouseMotion = InputEventMouseMotion.new()
				var from : Vector2 = _intersect_to_viewport_pos(was_intersect)
				var to : Vector2 = _intersect_to_viewport_pos(intersect)
				if was_pressed:
					event.button_mask = MOUSE_BUTTON_MASK_LEFT
				event.relative = to - from
				event.position = to
				layer_viewport.push_input(event)
				layer_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

			if not is_pressed and was_pressed:
				# Button was let go?
				var event : InputEventMouseButton = InputEventMouseButton.new()
				event.button_index = MOUSE_BUTTON_LEFT
				event.pressed = false
				event.position = _intersect_to_viewport_pos(intersect)
				layer_viewport.push_input(event)

			elif is_pressed and not was_pressed:
				# Button was pressed?
				var event : InputEventMouseButton = InputEventMouseButton.new()
				event.button_index = MOUSE_BUTTON_LEFT
				event.button_mask = MOUSE_BUTTON_MASK_LEFT
				event.pressed = true
				event.position = _intersect_to_viewport_pos(intersect)
				layer_viewport.push_input(event)
			
			was_pressed = is_pressed
			was_intersect = intersect
			
		else:
			was_pressed = false
			was_intersect = NO_INTERSECTION
