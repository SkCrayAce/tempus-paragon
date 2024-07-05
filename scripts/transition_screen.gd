extends CanvasLayer

signal on_transition_finished

@onready var animation_player = $AnimationPlayer

func _ready():
	$ColorRect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)


func _on_animation_finished(anim_name):
	if anim_name == "dissolve":
		on_transition_finished.emit()
		animation_player.play("fade_out")
		print("faded out")
	elif anim_name == "fade_out":
		$ColorRect.visible = false

func transition():
	$ColorRect.visible = true
	animation_player.play("dissolve")


