@tool
extends UIPanel


signal KeyInput(input: InputEventKey)


func _ui_ready():
	$SubViewport/Control/CenterContainer/Keyboard2D.KeyPressed.connect(KeyInput.emit)
	#KeyInput.connect(print)
