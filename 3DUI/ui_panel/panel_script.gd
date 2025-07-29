@tool
extends UIPanel



func _on_keyboard_3d_key_input(input):
	$SubViewport.push_input(input)
