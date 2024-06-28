extends CharacterBody2D

const speed = 100
var current_dir = "none"

func _ready():
	$AnimatedSprite2D.play("front_idle")
	var tilemap_rect = get_parent().get_node("TileMap").get_used_rect() # I think this gets all the tiles in your tile map.
	var tilemap_cell_size = get_parent().get_node("TileMap").tile_set.tile_size # this gets the size of each tile map to help with the math later
	$Camera2D.limit_left = tilemap_rect.position.x * tilemap_cell_size.x # this will set the limit to the camera to the left. you get the position of the last tile to the left and multiply by its size to get the exact pixle size
	$Camera2D.limit_right = tilemap_rect.end.x * tilemap_cell_size.x # same as above but for the right of the map. Im not sure why you use end. plz help explain.
	$Camera2D.limit_bottom = tilemap_rect.end.y * tilemap_cell_size.y # same as above but for the bottom
	$Camera2D.limit_top = tilemap_rect.position.y * tilemap_cell_size.y # same but for the top.


func _physics_process(delta):
	player_movement(delta)


func player_movement(delta):
	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		play_anim(1)
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		play_anim(1)
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		play_anim(1)
		velocity.x = 0
		velocity.y = speed
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		play_anim(1)
		velocity.x = 0
		velocity.y = -speed
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0
		
	move_and_slide()

func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D

	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			anim.play("side_idle")
	elif dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			anim.play("side_idle")
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
