extends Control

@onready var resume_button = $Panel/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/ResumeButton
@onready var options_button = $Panel/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/OptionsButton
@onready var quit_button = $Panel/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/QuitButton
@onready var options = $Options as Control
@onready var options_camera_2d = $Camera2D as Camera2D
@onready var game_camera_2d = get_node("../../Camera2D") as Camera2D
@onready var return_to_pause_button = %ReturnToPauseButton as Button
@onready var yes_button = %YesButton
@onready var no_button = %NoButton
@onready var confirmation_panel = $ConfirmationPanel

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(resume)
	options_button.pressed.connect(open_options)
	quit_button.pressed.connect(show_confirm_panel)
	return_to_pause_button.pressed.connect(close_options)
	yes_button.pressed.connect(quit_game)
	no_button.pressed.connect(hide_confirm_panel)


func resume():
	get_tree().paused = false
	hide()

func open_options():
	options.show()
	game_camera_2d.enabled = false
	options_camera_2d.enabled = true

func close_options():
	options.hide()
	options_camera_2d.enabled = false
	game_camera_2d.enabled = true

func show_confirm_panel():
	confirmation_panel.show()
	
func hide_confirm_panel():
	confirmation_panel.hide()
	
func quit_game():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
