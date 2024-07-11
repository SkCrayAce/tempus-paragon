extends CharacterBody2D
class_name Player

const max_speed = 120
const accel = 2000
#const friction = 2500

#Scene Tree Node References
@onready var anim = $AnimatedSprite2D
@onready var cam = $Camera2D
@onready var interact_ui = $InteractUI
@onready var inventory_ui = $InventoryUI
@onready var inventory_panel = $InventoryUI/Panel
@onready var init_point = $InventoryUI/Init_point
@onready var end_point = $InventoryUI/End_point

@onready var control = $Control

var inventory_isopen = false
var input = Vector2.ZERO
var current_dir = "none"

func _ready():
	anim.play("front_idle")
	
	#Set Camera Bound to Tilemap Size
	var tilemap_rect = get_parent().get_node("TileMap").get_used_rect()
	var tilemap_cell_size = get_parent().get_node("TileMap").tile_set.tile_size 
	cam.limit_left = tilemap_rect.position.x * tilemap_cell_size.x 
	cam.limit_right = tilemap_rect.end.x * tilemap_cell_size.x
	cam.limit_bottom = tilemap_rect.end.y * tilemap_cell_size.y 
	cam.limit_top = tilemap_rect.position.y * tilemap_cell_size.y 
	
	global.set_player_reference(self)

func _physics_process(delta):
	player_movement(delta)
	

func get_input():
	input.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return input.normalized()

func player_movement(delta):
	input = get_input()
	
	if input == Vector2.ZERO:
		#if velocity.length() > (friction * delta):
			#velocity -= velocity.normalized() * (friction * delta)
		#else:
		velocity = Vector2.ZERO
	else:
		velocity += (input * accel * delta)
		velocity = velocity.limit_length(max_speed)
	
	move_and_slide()
	
	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		play_anim(1)
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		play_anim(1)
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		play_anim(1)
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		play_anim(1)
	else:
		play_anim(0)

func play_anim(movement):
	var dir = current_dir

	if dir == "right":
		if movement == 1:
			anim.play("side_walk_right")
		elif movement == 0:
			anim.play("side_idle_right")
	elif dir == "left":
		if movement == 1:
			anim.play("side_walk_left")
		elif movement == 0:
			anim.play("side_idle_left")
	elif dir == "down":
		anim.flip_h = false
		if movement == 1:
			anim.play("front_walk")
		elif movement == 0:
			anim.play("front_idle")
	elif dir == "up":
		anim.flip_h = false
		if movement == 1:
			anim.play("back_walk")
		elif movement == 0:
			anim.play("back_idle")

func _input(event):
	if event.is_action_pressed("ui_inventory"):
		#flip flops
		#inventory_ui.visible = !inventory_ui.visible
		inventory_ui_anim()
		#get_tree().paused = !get_tree().paused

func apply_item_effect(item):
	match item["name"]:
		"Shard of Time":
			print("i am effecting")
		_:
			print("no fuckin effect")
	

func inventory_ui_anim():
	var tween = create_tween()
	if inventory_isopen == false:
		tween.tween_property(inventory_panel, "position", end_point.position, 0.5).set_trans(Tween.TRANS_SINE)
		inventory_isopen = true
	else:
		tween.tween_property(inventory_panel, "position", init_point.position, 0.5).set_trans(Tween.TRANS_SINE)
		inventory_isopen = false
