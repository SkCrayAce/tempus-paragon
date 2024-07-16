extends Node2D

@onready var anim = $AnimatedSprite2D
@onready var shadow = $Shadow
@onready var hit_effect = $HitEffect

#Drag and drop scene references
@onready var kai = $"../../VBoxContainer/kai"
@onready var emerald = $"../../VBoxContainer/emerald"
@onready var tyrone = $"../../VBoxContainer/tyrone"
@onready var bettany = $"../../VBoxContainer/bettany"



func _ready():
	anim.play("idle")
	kai.character_damaged.connect(_on_character_damaged)
	kai.character_killed.connect(_on_character_killed)
	#emerald.character_damaged.connect(_on_character_damaged)
	#emerald.character_killed.connect(_on_character_killed)
	#tyrone.character_damaged.connect(_on_character_damaged)
	#tyrone.character_killed.connect(_on_character_killed)
	#bettany.character_damaged.connect(_on_character_damaged)
	#bettany.character_killed.connect(_on_character_killed)
	
func _process(delta):
	pass

func _on_character_damaged():
	hit_effect.play("hit_flash")

func _on_character_killed():
	anim.play("death")
	await anim.animation_looped
	anim.stop()
	print("anim stopped")
