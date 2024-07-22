extends TextureRect

@onready var use_ability_btn = $UseAbilityBtn
@onready var ability_icon = $"AbilityIcon"
@onready var details_panel = $DetailsPanel
@onready var ability_name = $DetailsPanel/AbilityName
@onready var ability_description = $DetailsPanel/AbilityDescription
@onready var cooldown_bar = $AbilityIcon/CooldownBar
@onready var cooldown_timer = $AbilityIcon/CooldownBar/CooldownTimer
@onready var cooldown_filter = $AbilityIcon/CooldownFilter

#Ability
var ability = null

func _ready():
	use_ability_btn.pressed.connect(start_cooldown)
	cooldown_bar.max_value = cooldown_timer.wait_time
	prints(Vector2i.UP*2)
	
func start_cooldown():
	if name == "EmeraldAbility": return
	
	cooldown_filter.show()
	cooldown_timer.start()
	cooldown_bar.show()
	use_ability_btn.disabled = true
	cooldown_timer.timeout.connect(end_cooldown)
	
func end_cooldown():
	cooldown_bar.hide()
	cooldown_filter.hide()
	use_ability_btn.disabled = false
	
func _process(delta):
	cooldown_bar.value = cooldown_timer.time_left

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
