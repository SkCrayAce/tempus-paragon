extends TextureRect

const Battle = preload("res://scripts/battle.gd")
const Enemy = preload("res://scripts/enemy.gd")

var eme_skill_active : bool
var hovered_tile : Vector2i
var eme_skill_AoE : Array[Vector2i]
var tween
var init_popup_x_pos : int

const SlideDistance = 427

@onready var use_ability_btn = $UseAbilityBtn
@onready var ability_icon = $"AbilityIcon"
@onready var details_panel = $DetailsPanel
@onready var ability_name = $DetailsPanel/AbilityName
@onready var ability_description = $DetailsPanel/AbilityDescription
@onready var cooldown_bar = $AbilityIcon/CooldownBar
@onready var cooldown_timer = $AbilityIcon/CooldownBar/CooldownTimer
@onready var cooldown_filter = $AbilityIcon/CooldownFilter
@onready var battle = get_node("../../../..") as Battle
@onready var slums_tile_map = get_node("../../../../SlumsTileMap") as TileMap

@onready var kai_skill_pop_up = get_node("../../../SkillPopups/KaiSkillPopUp") as ColorRect
@onready var tyrone_skill_pop_up = get_node("../../../SkillPopups/TyroneSkillPopUp") as ColorRect

@onready var kai = get_node("../../../../DraggableIcons/kai") as Node2D
@onready var emerald = get_node("../../../../DraggableIcons/emerald") as Node2D
@onready var tyrone = get_node("../../../../DraggableIcons/tyrone") as Node2D
@onready var bettany = get_node("../../../../DraggableIcons/bettany") as Node2D

#Ability
var ability = null


func _ready():
	use_ability_btn.pressed.connect(switch_ability)
	cooldown_bar.max_value = cooldown_timer.wait_time
	
	#initializing emerald's skill aoe
	for x in range(-1, 2):
		for y in range(-1, 2):
			eme_skill_AoE.append(Vector2i(x, y))
	eme_skill_AoE.append_array([Vector2i.UP*2, Vector2i.DOWN*2, Vector2i.LEFT*2, Vector2i.RIGHT*2])
	
	kai_skill_pop_up.position.x = -SlideDistance
	tyrone_skill_pop_up.position.x = -SlideDistance
	
	
	
func _process(delta):
	cooldown_bar.value = cooldown_timer.time_left
	
	if eme_skill_active:
		hovered_tile = slums_tile_map.local_to_map(slums_tile_map.get_global_mouse_position()) as Vector2i
		var hover_active : bool
	
		for offset in eme_skill_AoE:
			var target_pos : Vector2i = hovered_tile + offset as Vector2i
			var detected_enemy = global.get_enemy(target_pos)
			if battle.within_bounds(target_pos):
				slums_tile_map.set_cell(1, target_pos, 2, Vector2i(0, 0), 0)
				hover_active = true
				if Input.is_action_just_pressed("left_click"):
					prints("hovered tile: ", hovered_tile)
					if is_instance_valid(detected_enemy) and detected_enemy is Enemy:
						detected_enemy.hit(3000)
					eme_skill_active = false
					global.is_dragging = false
					start_cooldown()
					
			hover_active = false	
					
func switch_ability():
	match name:
		"KaiAbility": kai_skill()
		"EmeraldAbility": emerald_skill()
		"TyroneAbility": tyrone_skill()
		"BettanyAbility": bettany_skill()

func kai_skill():
	slide_in.call(kai_skill_pop_up)
	await get_tree().create_timer(2).timeout
	prints("kai skill activate")
	#var update_positions = func():
		#for enemy in get_tree().get_nodes_in_group("enemies"):
			#enemy.stop_animation()
		#prints("nablow na kami!")
		#enemy_move_timer.start(enemy_move_timer.time_left)
		#record_enemies()
		#
	#push_timer.timeout.connect(update_positions)
	#enemy_move_timer.stop()
	#push_timer.start()
	#for enemy in get_tree().get_nodes_in_group("enemies"):
		#enemy.blown_back()
	
func tyrone_skill():
	slide_in.call(tyrone_skill_pop_up)
	await get_tree().create_timer(1).timeout
	
	for character in get_tree().get_nodes_in_group("characters"):
		if not character.is_defeated:
			character.health_bar.value += character.health_bar.max_value * 0.70
	battle.update_team_health()
	start_cooldown()
	
func bettany_skill():
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.burn(600)
	start_cooldown()

func emerald_skill():
	eme_skill_active = ! eme_skill_active
	global.is_dragging = !global.is_dragging
	
func start_cooldown():
	cooldown_filter.show()
	cooldown_timer.start()
	cooldown_bar.show()
	use_ability_btn.disabled = true
	cooldown_timer.timeout.connect(end_cooldown)
	
func end_cooldown():
	cooldown_bar.hide()
	cooldown_filter.hide()
	use_ability_btn.disabled = false
	
func slide_in(pop_up : ColorRect):
	pop_up.position.x = -SlideDistance
	tween = create_tween()
	pop_up.show()
	tween.tween_property(pop_up, "position:x", 0, 0.5).set_trans(Tween.TRANS_EXPO)
	await tween.finished
	get_tree().paused = true
	get_tree().create_timer(1).timeout.connect(slide_out.bind(pop_up))
	
func slide_out(pop_up : ColorRect):
	var reset_popup = func(pop_up : ColorRect):
		pop_up.hide()
		pop_up.position.x = -SlideDistance
		return
	get_tree().paused = false
	tween = create_tween()
	tween.tween_property(pop_up, "position:x", 490, 0.5).set_trans(Tween.TRANS_EXPO)
	tween.finished.connect(reset_popup.bind(pop_up))
	#get_tree().paused = false
	

func _on_use_ability_btn_mouse_entered():
	#if ability != null:
	details_panel.visible = true


func _on_use_ability_btn_mouse_exited():
	details_panel.visible = false


func set_ability(new_ability):
	new_ability = ability
	ability_icon.texture = ability["texture"]
	ability_name.text = str(ability["name"])
	ability_description.text = str(ability["description"])
