extends TextureRect

@onready var use_ability_btn = $UseAbilityBtn
@onready var ability_icon = $"AbilityIcon"
@onready var details_panel = $DetailsPanel
@onready var ability_name = $DetailsPanel/AbilityName
@onready var ability_description = $DetailsPanel/AbilityDescription

#Ability
var ability = null


func _on_use_ability_btn_mouse_entered():
	#if ability != null:
	details_panel.visible = true


func _on_use_ability_btn_mouse_exited():
	details_panel.visible = false


func set_ability(new_ability):
	new_ability = ability
	ability_icon.texture = ability["texture"]
	ability_name.text = str(ability["name"])
	ability_description.text = str(ability["description"])
