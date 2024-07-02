extends Node2D

var draggable = false
var offset : Vector2
var initialPos : Vector2
var on_cooldown = false
var defeated = false
var is_dragging : bool = false

const enemy_script = preload("res://scripts/enemy.gd")
const battle_script := preload("res://scenes/battle.tscn")

@onready var cooldown_bar = $Control/CooldownBar
@onready var cooldown_timer = $CooldownTimer
@onready var sprite = $Sprite2D
@onready var health_bar = $Control/HealthBar
@onready var defeat_filter = $Control/DefeatFilter
@onready var battle = $"../../Battle"
#@onready var tween := create_tween()

# @onready var character_ids : Dictionary = battle.character_ids

func _ready():
	#prints("character ready")
	on_cooldown = false
	initialPos = sprite.global_position
	health_bar.value = health_bar.max_value # health_bar.max_value
	#battle.attack_finished.connect(start_cooldown)
	#prints(character_ids)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health_bar.value <= 0:
		defeat_filter.visible = true
		defeated = true
	if draggable and !on_cooldown and !defeated:
		if Input.is_action_just_pressed("left_click"):
			global.is_dragging = true
			offset = get_global_mouse_position() - global_position
			global.dragged_char_name = name
			#prints("dragged character at click:", global.dragged_char_name, draggable)
			#prints("actual name:", name)
			#prints("dictionary name:", character_ids.get(get_instance_id()))
			# print("clicked")
		if Input.is_action_pressed("left_click"):
			global.dragged_char_name = name
			#global.is_dragging = true
		elif Input.is_action_just_released("left_click") and name == global.dragged_char_name:
			sprite.scale = Vector2(0.2, 0.2)
			global.is_dragging = false
			global.dragged_char_name = " "
			#prints("dragged character at drop:", global.dragged_char_name)
			#var tween = get_tree().create_tween()
			#tween.tween_property(self, "global_position", initialPos, 0.1).set_ease(Tween.EASE_OUT)
			start_cooldown()
			
	cooldown_bar.value = cooldown_timer.time_left

func _on_area_2d_mouse_entered():
	#prints("mouse entered at:", name)
	var tween := create_tween()
	# prints("mouse entered")
	if !global.is_dragging and !on_cooldown and !defeated:
		draggable = true
		#sprite.scale = Vector2(0.25, 0.25)
		tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1).set_ease(Tween.EASE_OUT)

func _on_area_2d_mouse_exited():
	#prints("mouse exited at:", name)
	var tween := create_tween()
	if !global.is_dragging:
		draggable = false
		#sprite.scale = Vector2(0.2, 0.2)
		tween.tween_property(self, "scale", Vector2(1, 1), 0.1).set_ease(Tween.EASE_OUT)

func start_cooldown():
	on_cooldown = true
	sprite.scale = Vector2(0.2, 0.2)
	if not on_cooldown: return 
	
	cooldown_bar.max_value = cooldown_timer.wait_time
	cooldown_timer.start()
	cooldown_bar.show()
	
func _on_cooldown_timer_timeout():
	var char_id : int = 1
	on_cooldown = false
	#cooldown_timer.stop()
	cooldown_bar.hide()
	#prints(name, "cooldown at timer end:", on_cooldown)
	draggable = false

func take_damage(damage : int):
	health_bar.value -= damage
	
	if health_bar.value <= 0:
		defeated = true
		defeat_filter.show()
	#prints("damage taken: ")
	
		
