class_name Boss
extends CharacterBody2D

const BattleNode = preload("res://scripts/battle.gd")

@onready var tile_map = get_parent() as TileMap
@onready var battle_node = get_node("../..") as BattleNode
@onready var animation_timer = get_node("../../AnimationTimer") as Timer
@onready var anim : AnimatedSprite2D = $AnimatedSprite2D
@onready var healthbar : TextureProgressBar = $BossHealthContainer/HealthBar
@onready var hit_effect = $HitEffect

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

@onready var kai = get_node("../../VBoxContainer/kai") as Node2D
@onready var emerald = get_node("../../VBoxContainer/emerald") as Node2D
@onready var tyrone = get_node("../../VBoxContainer/tyrone") as Node2D
@onready var bettany = get_node("../../VBoxContainer/bettany") as Node2D

var kai_hitbox : Array[int]
var emerald_hitbox : Array[int]
var tyrone_hitbox : Array[int]
var bettany_hitbox : Array[int]

#Boss Data
var health : int
var current_map_position : Vector2i
var tween : Tween
var new_position : Vector2
var attack_states = []


func _ready():
	attack_states.append(ranged_attack_state)
	attack_states.append(melee_attack_state)
	attack_states.append(power_attack_state)
	
	#will go to move state after certain amount of time
	idle_state.idle_finished.connect(fsm.change_state.bind(moving_state))
	
	#randomly select between attack states after moving around
	moving_state.moving_finished.connect(fsm.change_state.bind(attack_states[randi() % attack_states.size()]))
	
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
	
func _process(delta):
	pass
