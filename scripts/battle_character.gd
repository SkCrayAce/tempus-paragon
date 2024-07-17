extends Node2D

@onready var anim = $AnimatedSprite2D
@onready var shadow = $Shadow
@onready var hit_effect = $HitEffect

@onready var kai = $"../../DraggableIcons/kai"


func _ready():
	anim.play("idle")
	kai.character_damaged.connect(_on_character_damaged)
	kai.character_killed.connect(_on_character_killed)
	prints("sprite name:", name)
	
	
func _process(delta):
	pass

func _on_character_damaged():
	hit_effect.play("hit_flash")

func _on_character_killed():
	anim.play("death")
	print("anim stopped")
