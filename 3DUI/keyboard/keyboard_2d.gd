extends Control


enum STATE {
	LOWER,
	SHIFT,
	CAPS_LOCK,
}

var caps_state: STATE = STATE.LOWER

signal KeyPressed(key: InputEventKey)



# Called when the node enters the scene tree for the first time.
func _ready():
	
	var children = get_children()
	
	#KeyPressed.connect(print)
	
	while not children.is_empty():
		var child: Node = children.pop_front()
		
		children.append_array(child.get_children())
		
		if child is Button and not child.is_in_group("NonKey"):
			var button: Button = child
			
			button.button_down.connect(key_button_down.bind(button))
	









func key_button_down(button: Button):
	#print(">", button.text)
	var key_label = button.text
	
	var keycode: Key
	
	var shift_pressed: bool = false
	
	match key_label:
		"space":
			keycode = KEY_SPACE
		"Del":
			keycode = KEY_BACKSPACE
		"Enter":
			keycode = KEY_ENTER
		"":
			return
		",":
			keycode = KEY_COMMA
		'`':
			keycode = KEY_QUOTELEFT
		'=':
			keycode = KEY_EQUAL
		'-': 
			keycode = KEY_MINUS
		'[':
			keycode = KEY_BRACKETLEFT
		']':
			keycode = KEY_BRACERIGHT
		"'":
			keycode = KEY_APOSTROPHE
		';':
			keycode = KEY_SEMICOLON
		_:
			if caps_state != STATE.LOWER:
				shift_pressed = true
			
			keycode = OS.find_keycode_from_string(key_label)
			
			if keycode == KEY_NONE:
				print(key_label)
				keycode = OS.find_keycode_from_string(button.name)
				
				
			if keycode == KEY_NONE:
				match key_label:
					'dot':
						keycode = OS.find_keycode_from_string('.')
					#'slash':
						#keycode = OS.find_keycode_from_string('/')
			
			if caps_state == STATE.SHIFT:
				$LeftShift.button_pressed = false
				to_lower()
				caps_state = STATE.LOWER
	var event = InputEventKey.new()
	
	event.keycode = keycode
	if shift_pressed:
		event.unicode = event.as_text_keycode().unicode_at(0)
	else:
		event.unicode = event.as_text_keycode().to_lower().unicode_at(0)
	event.shift_pressed = shift_pressed
	event.pressed = true
	KeyPressed.emit(event)

func to_lower():
	$Lower.show()
	$Upper.hide()

func to_upper():
	$Upper.show()
	$Lower.hide()



func _on_left_shift_toggled(toggled_on):
	$RightShift.button_pressed = toggled_on
	if toggled_on:
		$CapsLock.button_pressed = false
		caps_state = STATE.SHIFT
		to_upper()
	elif $CapsLock.button_pressed == false:
		caps_state = STATE.LOWER
		to_lower()

func _on_right_shift_toggled(toggled_on):
	$LeftShift.button_pressed = toggled_on


func _on_caps_lock_toggled(toggled_on):
	if toggled_on:
		$LeftShift.button_pressed = false
		caps_state = STATE.CAPS_LOCK
		to_upper()
	elif $LeftShift.button_pressed == false:
		caps_state = STATE.LOWER
		to_lower()



#func _unhandled_input(event):
	#if event is InputEventKey:
		#print(event)
