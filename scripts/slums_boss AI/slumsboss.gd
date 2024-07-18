class_name Boss
extends CharacterBody2D

@export var health : int


@onready var anim : AnimatedSprite2D = $AnimatedSprite2D
@onready var healthbar : TextureProgressBar = $BossHealthContainer/HealthBar
@onready var hit_effect = $HitEffect

@onready var tile_map = get_parent() as TileMap


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


func _ready():
	var enemy_map_pos = tile_map.local_to_map(position)
	global.enemy_dict[enemy_map_pos] = position
	healthbar.max_value = health
	healthbar.value = healthbar.max_value
	
	rng.randomize()
	states_to_choose.append(ranged_attack_state)
	states_to_choose.append(melee_attack_state)
	states_to_choose.append(power_attack_state)
	states_to_choose.append(idle_state)
	states_to_choose.append(moving_state)
	randomize_index()
	
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

func randomize_index():
	new_index = rng.randi() % 5
	fsm.change_state(states_to_choose[new_index])

func hit(damage : int):
	hit_effect.play("hit_flash")
	healthbar.value -= damage
	
	if healthbar.value <= 0:
		death()

func death():
	anim.stop()
	anim.play("death")
	await anim.animation_finished
	global.boss_is_defeated = true
	queue_free()
	


