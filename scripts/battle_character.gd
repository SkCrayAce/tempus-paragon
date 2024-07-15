extends Node2D

@onready var anim = $AnimatedSprite2D
@onready var shadow = $Shadow


func _ready():
	anim.play("idle")


func _process(delta):
	pass
