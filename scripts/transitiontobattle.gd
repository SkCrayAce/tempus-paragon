extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer
@onready var sfx_player = $SFXPlayer

@export var animation = "pixelate"

const INTO_BATTLE_TRANSITION = preload("res://audio/05 - Misc/07 - Entering battle/into-battle-transition.mp3")
const OUT_FROM_BATTLE_TRANSITION = preload("res://audio/05 - Misc/08 - Exiting battle/out from-battle-transition.mp3")

func _ready():
	#var img = get_viewport().get_texture()
	#var texture = ImageTexture.create_from_image(img.get_image())
	#texture_rect.texture = texture
	play_animation()
	print("animation playing")

func play_animation():
	animation_player.play(animation)
	sfx_player.stream = INTO_BATTLE_TRANSITION
	play_sfx()

func play_animation_backwards():
	#var img = get_viewport().get_texture()
	#var texture = ImageTexture.create_from_image(img.get_image())
	#texture_rect.texture = texture
	animation_player.play_backwards(animation)
	print("animation playing backwards")
	sfx_player.stream = OUT_FROM_BATTLE_TRANSITION
	play_sfx()

func play_sfx():
	sfx_player.play()
