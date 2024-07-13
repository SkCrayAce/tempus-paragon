extends CanvasLayer

@onready var texture_rect = $TextureRect
@onready var animation_player = $AnimationPlayer

@export var animation = "pixelate"


func _ready():
	#var img = get_viewport().get_texture()
	#var texture = ImageTexture.create_from_image(img.get_image())
	#texture_rect.texture = texture
	play_animation()
	print("animation playing")

func play_animation():
	animation_player.play(animation)

func play_animation_backwards():
	#var img = get_viewport().get_texture()
	#var texture = ImageTexture.create_from_image(img.get_image())
	#texture_rect.texture = texture
	animation_player.play_backwards(animation)
	print("animation playing backwards")
