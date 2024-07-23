extends Control

@onready var mc_health_bar = $MainCharacter/HealthBar
@onready var current_head = $MainCharacter/Character/TextureRect
@onready var character = $MainCharacter/Character
@onready var button = $Button
@onready var party_container = $PartyContainer
@onready var main_character = $MainCharacter
@onready var kai_health_bar = $PartyContainer/kai/HealthBar
@onready var emerald_health_bar = $PartyContainer/emerald/HealthBar
@onready var tyrone_health_bar = $PartyContainer/tyrone/HealthBar
@onready var bettany_health_bar = $PartyContainer/bettany/HealthBar


const pc_init_pos = Vector2(-100, 2)
const pc_end_pos  = Vector2(2, 2)
const c_init_pos = Vector2(2, 2)
const c_end_pos = Vector2(2, -50)
var playermenu_isopen = false

signal switched_character(character : String)

func _ready():
	setup_health()

func setup_health():
	kai_health_bar.max_value = global.kai_max_hp
	kai_health_bar.value = global.kai_curr_hp
	
	emerald_health_bar.max_value = global.emerald_max_hp
	emerald_health_bar.value = global.emerald_curr_hp
	
	tyrone_health_bar.max_value = global.tyrone_max_hp
	tyrone_health_bar.value = global.tyrone_curr_hp
	
	bettany_health_bar.max_value = global.bettany_max_hp
	bettany_health_bar.value = global.bettany_curr_hp
	
	#mc_health_bar.max_value = 

func switch_player(character : String):
	#TODO: check if player dead, switch sprite textures, switch health value
	
	match character:
		"kai":
			mc_health_bar.max_value = global.kai_max_hp
			mc_health_bar.value = global.kai_curr_hp
			current_head.texture = load("res://tempus_assets/chibi heads/kai_chibi_head.png")
			emit_signal("switched_character", "kai")
		"emerald" :
			mc_health_bar.max_value = global.emerald_max_hp
			mc_health_bar.value = global.emerald_curr_hp
			current_head.texture = load("res://tempus_assets/chibi heads/emerald_chibi_head.png")
			emit_signal("switched_character", "emerald")
		"tyrone" :
			mc_health_bar.max_value = global.tyrone_max_hp
			mc_health_bar.value = global.tyrone_curr_hp
			current_head.texture = load("res://tempus_assets/chibi heads/tyrone_chibi_head.png")
			emit_signal("switched_character", "tyrone")
		"bettany" :
			mc_health_bar.max_value = global.bettany_max_hp
			mc_health_bar.value = global.bettany_curr_hp
			emit_signal("switched_character", "bettany")


func _on_button_mouse_entered():
	var tween = create_tween()
	tween.tween_property(character, "scale", Vector2(1.1, 1.1), 0.2).set_ease(Tween.EASE_IN_OUT)


func _on_button_mouse_exited():
	var tween = create_tween()
	tween.tween_property(character, "scale", Vector2(1, 1), 0.2).set_ease(Tween.EASE_IN_OUT)


func _on_button_pressed():
	toggle_player_menu()

func toggle_player_menu():
	print("playermenu toggled")
	if playermenu_isopen == true:
		var tween = create_tween().set_parallel()
		tween.tween_property(main_character, "position", c_init_pos, 1).set_trans(Tween.TRANS_EXPO)
		tween.tween_property(party_container, "position", pc_init_pos, 1).set_trans(Tween.TRANS_EXPO)
		playermenu_isopen = false
	elif playermenu_isopen == false:
		var tween = create_tween().set_parallel()
		tween.tween_property(main_character, "position", c_end_pos, 1).set_trans(Tween.TRANS_EXPO)
		tween.tween_property(party_container, "position", pc_end_pos, 1).set_trans(Tween.TRANS_EXPO)
		playermenu_isopen = true


func _on_kai_button_pressed():
	switch_player("kai")


func _on_emerald_button_pressed():
	switch_player("emerald")


func _on_tyrone_button_pressed():
	switch_player("tyrone")


func _on_bettany_button_pressed():
	switch_player("bettany")
