extends TextureRect

const Battle = preload("res://scripts/battle.gd")
const Enemy = preload("res://scripts/enemy.gd")
const Boss = preload("res://scripts/slums_boss AI/slumsboss.gd")

var eme_skill_active : bool
var hovered_tile : Vector2i
var eme_skill_AoE : Array[Vector2i]
var tween
var init_popup_x_pos : int
var disabled : bool
var kai_iteration : int

const SlideDistance = 700

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
@onready var skill_sfx_player = $AudioStreamPlayer2D as AudioStreamPlayer2D
@onready var push_timer = get_node("../../../../PushTimer") as Timer


@onready var kai_skill_pop_up = get_node("../../../SkillPopups/KaiSkillPopUp") as ColorRect
@onready var tyrone_skill_pop_up = get_node("../../../SkillPopups/TyroneSkillPopUp") as ColorRect
@onready var emerald_skill_pop_up = get_node("../../../SkillPopups/EmeraldSkillPopUp") as ColorRect
@onready var bettany_skill_pop_up = get_node("../../../SkillPopups/BettanySkillPopUp") as ColorRect

@onready var kai = get_node("../../../../DraggableIcons/kai") as Node2D
@onready var emerald = get_node("../../../../DraggableIcons/emerald") as Node2D
@onready var tyrone = get_node("../../../../DraggableIcons/tyrone") as Node2D
@onready var bettany = get_node("../../../../DraggableIcons/bettany") as Node2D

@onready var bettany_anim_sprite = get_node("../../../../DraggableIcons/bettany/BattleSprite/AnimatedSprite2D") as AnimatedSprite2D

const BETTANY_SKILL_SFX = preload("res://audio/02 - Skill Attacks/Bettany/bettany-skill.mp3")
const EMERALD_SKILL_SFX= preload("res://audio/02 - Skill Attacks/Emerald/emerald-skill.mp3")
const KAI_SKILL_SFX = preload("res://audio/02 - Skill Attacks/Kai/kai-skill_v02.mp3")
const TYRONE_SKILL_SFX = preload("res://audio/02 - Skill Attacks/Tyrone/tyrone-skill.mp3")
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
	emerald_skill_pop_up.position.x = -SlideDistance
	tyrone_skill_pop_up.position.x = -SlideDistance
	bettany_skill_pop_up.position.x = -SlideDistance
	
	skill_sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	#start_cooldown()
	
func _process(delta):
	cooldown_bar.value = cooldown_timer.time_left
	
	# Emerald Skill
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
					activate_emerald_skill(detected_enemy)
			hover_active = false	
					
func switch_ability():
	match name:
		"KaiAbility": kai_skill()
		"EmeraldAbility": toggle_emerald_skill()
		"TyroneAbility": tyrone_skill()
		"BettanyAbility": bettany_skill()

func play_sfx(sfx_stream : AudioStream):
	skill_sfx_player.stream = sfx_stream
	skill_sfx_player.play()
	await skill_sfx_player.finished
	return
		
func kai_skill():
	slide_in.call(kai_skill_pop_up)
	await get_tree().create_timer(2).timeout
	play_sfx(KAI_SKILL_SFX)
	prints("kai skill activate")
	kai_iteration = 0
	push_timer.timeout.connect(update_positions)
	battle.set_timers_paused(true)
	update_positions.call()
	
func update_positions():
	battle.record_enemies()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if kai_iteration < 3 :
			enemy.blown_back()
		else:
			await enemy.stop_animation()
			battle.set_timers_paused(false)
	if kai_iteration < 3:
		push_timer.start()
	else:
		push_timer.timeout.disconnect(update_positions)
	kai_iteration += 1
	prints("iter", kai_iteration)
		
			#enemy.position.x += 48
	prints("nablow na kami!")

func tyrone_skill():
	slide_in.call(tyrone_skill_pop_up)
	await get_tree().create_timer(2).timeout
	play_sfx(TYRONE_SKILL_SFX)
	tween = create_tween().set_parallel()
	for character in get_tree().get_nodes_in_group("characters"):
		if not character.is_defeated:
			var new_health = character.health_bar.value + character.health_bar.max_value * 0.70
			tween.tween_property(character.health_bar, "value", new_health, 1)
			#character.health_bar.value += character.health_bar.max_value * 0.70
	battle.update_team_health()
	start_cooldown()
	
func bettany_skill():
	slide_in(bettany_skill_pop_up)
	await get_tree().create_timer(2).timeout
	play_sfx(BETTANY_SKILL_SFX)
	bettany_anim_sprite.play("special_attack")
	await bettany_anim_sprite.animation_finished
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.burn(600)
	start_cooldown()

func toggle_emerald_skill():
	if not eme_skill_active:
		slide_in(emerald_skill_pop_up)
	eme_skill_active = !eme_skill_active
	global.is_dragging = !global.is_dragging
	
func activate_emerald_skill(detected_enemy : CharacterBody2D):
	battle.set_timers_paused(true)
	eme_skill_active = false
	play_sfx(EMERALD_SKILL_SFX)
	var valid_enemy = detected_enemy is Enemy or detected_enemy is Boss
	if is_instance_valid(detected_enemy) and valid_enemy:
		detected_enemy.hit_by_eme_skill(3000)
	global.is_dragging = false
	await get_tree().create_timer(skill_sfx_player.stream.get_length()).timeout
	battle.set_timers_paused(false)
	start_cooldown()
	
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
	pop_up.process_mode = Node.PROCESS_MODE_ALWAYS
	
	tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	get_tree().paused = true
	pop_up.show()
	tween.tween_property(pop_up, "position:x", 0, 0.5).set_trans(Tween.TRANS_EXPO)
	await tween.finished
	get_tree().create_timer(1).timeout.connect(slide_out.bind(pop_up))
	
func slide_out(pop_up : ColorRect):
	var reset_popup = func(pop_up : ColorRect):
		get_tree().paused = false
		pop_up.hide()
		pop_up.position.x = -SlideDistance
		return
	
	pop_up.process_mode = Node.PROCESS_MODE_ALWAYS
	tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(pop_up, "position:x", SlideDistance, 0.5).set_trans(Tween.TRANS_EXPO)
	tween.finished.connect(reset_popup.bind(pop_up))
	#get_tree().paused = false
	
func disable():
	use_ability_btn.set_disabled(true)
	disabled = true
	end_cooldown()
	cooldown_filter.show()

func _on_use_ability_btn_mouse_entered():
	if disabled : return
	
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	details_panel.visible = true


func _on_use_ability_btn_mouse_exited():
	details_panel.visible = false


func set_ability(new_ability):
	new_ability = ability
	ability_icon.texture = ability["texture"]
	ability_name.text = str(ability["name"])
	ability_description.text = str(ability["description"])
