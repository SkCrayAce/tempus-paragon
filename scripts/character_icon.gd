extends Node2D

var draggable = false
var offset : Vector2
var initialPos : Vector2
var on_cooldown = false
var defeated = false

const enemy_script = preload("res://scripts/enemy.gd")

@onready var cooldown_bar = $Control/CooldownBar
@onready var cooldown_timer = $CooldownTimer
@onready var sprite = $Sprite2D
@onready var health_bar = $Control/HealthBar
@onready var defeat_filter = $Control/DefeatFilter

func _ready():
	initialPos = global_position
	health_bar.value = health_bar.max_value # health_bar.max_value
		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cooldown_bar.value = cooldown_timer.time_left
	if draggable and !on_cooldown and !defeated:
		if Input.is_action_just_pressed("left_click"):
			global.is_dragging = true
			offset = get_global_mouse_position() - global_position
			global.dragged_char_name = name
			print("clicked")
		if Input.is_action_pressed("left_click"):
			global_position = get_global_mouse_position() - offset
			sprite.scale = Vector2(0.1, 0.1)
		elif Input.is_action_just_released("left_click"):
			sprite.scale = Vector2(0.2, 0.2)
			global.is_dragging = false
			global.dragged_char_name = ""
			
			var tween = get_tree().create_tween()
			tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)
			
			start_cooldown()

func _on_area_2d_mouse_entered():
	prints("mouse entered")
	if !global.is_dragging and !on_cooldown and !defeated:
		draggable = true
		sprite.scale = Vector2(0.25, 0.25)

func _on_area_2d_mouse_exited():
	if !global.is_dragging:
		draggable = false
		sprite.scale = Vector2(0.2, 0.2)

func start_cooldown():
	on_cooldown = true
	cooldown_bar.max_value = cooldown_timer.wait_time
	cooldown_timer.start()
	cooldown_bar.show()
	
func _on_cooldown_timer_timeout():
	on_cooldown = false
	# cooldown_timer.stop()
	cooldown_bar.hide()
	
func deal_damage(damage_taken : int):
	health_bar.value -= damage_taken
		
	if health_bar.value <= 0:
		defeat_filter.visible = true
		defeated = true
