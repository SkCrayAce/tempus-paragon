extends Node2D

@onready var anim = $AnimatedSprite2D
@onready var shadow = $Shadow
@onready var hit_effect = $HitEffect

@onready var kai = $"../../VBoxContainer/kai"


func _ready():
	anim.play("idle")
	kai.character_damaged.connect(_on_character_damaged)

func _process(delta):
	pass

func _on_character_damaged():
	hit_effect.play("hit_flash")
