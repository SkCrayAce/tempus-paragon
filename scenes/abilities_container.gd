extends TextureRect

var entered = false

func _ready():
	pass



func _process(delta):
	pass


func _on_area_2d_mouse_entered():
	if entered == false:
		var tween = create_tween()
		tween.tween_property(self, "position", Vector2(self.position.x, self.position.y) - Vector2(0, 50), 1).set_trans(Tween.TRANS_EXPO)
		entered = true

func _on_area_2d_mouse_exited():
	if entered == true:
		var tween = create_tween()
		tween.tween_property(self, "position", Vector2(self.position.x, self.position.y) + Vector2(0, 50), 1).set_trans(Tween.TRANS_EXPO)
		entered = false
