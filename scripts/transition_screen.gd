extends CanvasLayer

signal transition_finished

@onready var animation_player = $AnimationPlayer
@onready var transition_screen = $Transition/ColorRect
@onready var transition_node = $Transition


func _ready():
	pass
	
func _on_transition_animation_finished(anim_name):
	if anim_name == "fade_out" or anim_name == "fade_in":
		transition_finished.emit()
