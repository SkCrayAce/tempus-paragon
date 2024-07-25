extends CanvasLayer

signal fade_out_finished
signal fade_in_finished

@onready var animation_player = $AnimationPlayer
@onready var transition_screen = $Transition/ColorRect
@onready var transition_node = $Transition as AnimationPlayer


func play_transition(transition : String):
	transition_node.play(str(transition))
	
func _on_transition_animation_finished(anim_name):
	if anim_name == "fade_out":
		fade_out_finished.emit()
	elif anim_name == "fade_in":
		fade_in_finished.emit()
