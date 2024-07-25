extends Control

@onready var return_button = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/ReturnButton as Button
const MAIN_MENU_MUSIC = preload("res://audio/music/main_menu_music.mp3") 


func _ready():
	if AudioPlayer.stream == MAIN_MENU_MUSIC:
		AudioPlayer.set_stream_paused(false)

func _on_return_button_pressed():
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
