class_name Boss
extends CharacterBody2D

@export var health : int
@export var attack_damage : int

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D
@onready var healthbar : TextureProgressBar = $BossHealthContainer/HealthBar
@onready var hit_effect = $HitEffect
@onready var damage_number_origin = $DamageNumberOrigin
@onready var tile_map = get_parent() as TileMap
@onready var boss_name = $BossHealthContainer/BossName
@onready var enemy_move_timer = get_node("../../EnemyMoveTimer") as Timer
@onready var animation_timer = get_node("../../AnimationTimer") as Timer
@onready var boss_sfx = $BossSFX

#Sound Effects----------------------------------------
const BOSS_STOMP = preload("res://audio/04 - Boss/01 - Stomping/boss-stomp.mp3")
const BOSS_LAUGH = preload("res://audio/04 - Boss/02 - Evil Laugh/boss-laugh.mp3")

#FSM References---------------------------------------
@onready var fsm = $FiniteStateMachine as FiniteStateMachine
@onready var idle_state = $FiniteStateMachine/IdleState as IdleState
@onready var moving_state = $FiniteStateMachine/MovingState as MovingState
@onready var ranged_attack_state = $FiniteStateMachine/RangedAttackState as RangedAttackState
@onready var melee_attack_state = $FiniteStateMachine/MeleeAttackState as MeleeAttackState
@onready var power_attack_state = $FiniteStateMachine/PowerAttackState as PowerAttackState
@onready var stunned_state = $FiniteStateMachine/StunnedState as StunnedState
@onready var avoid_state = $FiniteStateMachine/AvoidState as AvoidState
@onready var return_to_grid_state = $FiniteStateMachine/ReturnToGridState as ReturnToGridState
#-----------------------------------------------------

var kai_hitbox : Array[int]
var emerald_hitbox : Array[int]
var tyrone_hitbox : Array[int]
var bettany_hitbox : Array[int]

#Boss Data
var current_map_position : Vector2i
var tween : Tween
var new_position : Vector2
var states_to_choose = []
var new_index
var rng = RandomNumberGenerator.new()
var is_defeated : bool

signal boss_killed

func _ready():
	if global.boss_is_defeated:
		return
	
	var end_hb_pos = healthbar.position
	var end_bn_pos = boss_name.position
	healthbar.position.y = -100
	boss_name.position.y = -100
	var tween = create_tween().set_parallel()
	tween.tween_property(healthbar, "position", end_hb_pos, 2).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(boss_name, "position", end_bn_pos, 2).set_trans(Tween.TRANS_EXPO)
	
	var enemy_map_pos = tile_map.local_to_map(position)
	global.enemy_dict[enemy_map_pos] = position
	healthbar.max_value = health
	healthbar.value = healthbar.max_value
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	anim.frame_changed.connect(boss_stomp)
	
	rng.randomize()
	#states_to_choose.append(ranged_attack_state)
	#states_to_choose.append(melee_attack_state)
	states_to_choose.append(power_attack_state)
	#states_to_choose.append(idle_state)
	#states_to_choose.append(moving_state)
	
	if not global.boss_is_defeated:
		#will go to move state after certain amount of time
		idle_state.idle_finished.connect(fsm.change_state.bind(moving_state))
		
		#randomly select between attack states after moving around
		moving_state.moving_finished.connect(randomize_index)
		
		#finish attacking goes back to idle
		ranged_attack_state.r_attack_finished.connect(fsm.change_state.bind(idle_state))
		melee_attack_state.m_attack_finished.connect(fsm.change_state.bind(idle_state))
		power_attack_state.p_attack_finished.connect(fsm.change_state.bind(idle_state))
		
		#when hit during wind up in power attack
		power_attack_state.hit_at_wind_up.connect(fsm.change_state.bind(stunned_state))
		
		#will go out of grid after being stunned
		stunned_state.stun_done.connect(fsm.change_state.bind(avoid_state))
		
		#will return to grid after summoning a wave of enemies
		avoid_state.summon_finished.connect(fsm.change_state.bind(return_to_grid_state))
		
		#will return to idle after returning
		return_to_grid_state.returned_to_grid.connect(fsm.change_state.bind(idle_state))
	
	
	health = healthbar.max_value
	healthbar.value = health

func _physics_process(delta):
	pass
		
func randomize_index():
	new_index = rng.randi() % states_to_choose.size()
	fsm.change_state(states_to_choose[new_index])

func burn(damage : int):
	for i in 5:
		hit(damage)	
		await get_tree().create_timer(1).timeout
		continue
		
func hit(damage : int):
	hit_effect.play("hit_flash")
	show_damage_numbers(damage)
	
	if (healthbar.value - damage) <= 0:
		death()
	
	healthbar.value -= damage

func hit_by_eme_skill(damage : int):
	if is_defeated:
			return
	enemy_move_timer.set_paused(true)
	animation_timer.set_paused(true)
	
	for i in 3:
		show_damage_numbers.call_deferred(damage)
		if is_instance_valid(hit_effect):
			hit_effect.play("hit_flash", -1, 1.5)
			healthbar.value -= damage/3
			if healthbar.value <= 0:
				death()
		await get_tree().create_timer(0.5).timeout
	enemy_move_timer.set_paused(false)
	animation_timer.set_paused(false)
	
func show_damage_numbers(damage : int):
	
	var number = Label.new()
	
	if not is_instance_valid(number): return
	
	number.label_settings = LabelSettings.new()
	number.text = str(damage)
	number.position = damage_number_origin.position
	number.z_index = 30
	
	var color = Color.RED
	
	number.label_settings.font_color = color
	number.label_settings.font_size = 7
	number.label_settings.outline_color = Color.BLACK
	number.label_settings.outline_size = 2
	add_child.call_deferred(number)
	number.pivot_offset = Vector2(number.size/2)
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(number, "position:y", number.position.y - 10, 1).set_ease(Tween.EASE_OUT)
	await tween.finished
	number.queue_free()
	

func death():
	global.enemy_dict.clear()
	anim.stop()
	global.boss_is_defeated = true
	boss_killed.emit()
	queue_free()


func boss_stomp():
	if anim.animation != "moving":
		return
	if anim.frame == 1:
		boss_sfx.play()
		return
	if anim.frame == 4:
		boss_sfx.play()
		return


