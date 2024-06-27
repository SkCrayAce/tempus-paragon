extends Node2D

var draggable = false
var is_inside_droppable = false
var body_ref
var offset : Vector2
var initialPos : Vector2


const enemy_script = preload("res://scenes/enemy.gd")

func _ready():
	scale = Vector2(0.3, 0.3)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if draggable:
		if Input.is_action_just_pressed("left_click"):
			initialPos = global_position
			offset = get_global_mouse_position() - global_position
			global.is_dragging = true
			global.is_released = false
			global.dragged_char_name = name
			print("clicked")
		if Input.is_action_pressed("left_click"):
			global_position = get_global_mouse_position() - offset
		elif Input.is_action_just_released("left_click"):
			global.is_released = true
			global.is_dragging = false
			global.dragged_char_name = ""
			
			var tween = get_tree().create_tween()
			if is_inside_droppable:
				tween.tween_property(self, "position", body_ref.position, 0.2).set_ease(Tween.EASE_OUT)
			else:
				tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)
				

func _on_area_2d_mouse_entered():
	if not global.is_dragging:
		draggable = true
		scale = Vector2(0.35, 0.35)

func _on_area_2d_mouse_exited():
	if not global.is_dragging:
		draggable = false
		scale = Vector2(0.3, 0.3)

func _on_area_2d_body_entered(body):
	if body.is_in_group("dropable"):
		is_inside_droppable = true
		body.modulate = Color(Color.REBECCA_PURPLE, 1)
		body_ref = body

func _on_area_2d_body_exited(body):
	if body.is_in_group("dropable"):
		is_inside_droppable = false
		body.modulate = Color(Color.MEDIUM_PURPLE, 0.7)
		# body_ref = body
