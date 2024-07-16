class_name Boss
extends CharacterBody2D

const BattleNode = preload("res://scripts/battle.gd")

@export var test = 0.0

@onready var tile_map = get_parent() as TileMap
@onready var battle_node = get_node("../..") as BattleNode
@onready var animation_timer = get_node("../../AnimationTimer") as Timer
@onready var anim = $AnimatedSprite2D
@onready var health_bar = $BossHealthContainer/HealthBar

#FSM References---------------------------------------
@onready var finite_state_machine = $FiniteStateMachine
@onready var idle_state = $FiniteStateMachine/IdleState
@onready var moving_state = $FiniteStateMachine/MovingState
@onready var ranged_attack_state = $FiniteStateMachine/RangedAttackState
@onready var melee_attack_state = $FiniteStateMachine/MeleeAttackState
@onready var power_attack_state = $FiniteStateMachine/PowerAttackState
@onready var stunned_state = $FiniteStateMachine/StunnedState
@onready var avoid_state = $FiniteStateMachine/AvoidState
#-----------------------------------------------------

var health : int
var current_map_position : Vector2i
var tween : Tween
var new_position : Vector2
