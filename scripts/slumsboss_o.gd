extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var boss_laugh = $BossLaugh

func _ready():
	anim.play("idle")
