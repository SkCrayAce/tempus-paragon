extends Control

@onready var item_icon = $InnerBorder/ItemIcon
@onready var item_quantity = $InnerBorder/ItemQuantity #not sure if will be used
@onready var item_name = $DetailsPanel/ItemName
@onready var item_type = $DetailsPanel/ItemType
@onready var item_rarity = $DetailsPanel/ItemRarity
@onready var item_effect = $DetailsPanel/ItemEffect
@onready var details_panel = $DetailsPanel
@onready var usage_panel = $UsagePanel
@onready var use_button = $UsagePanel/UseButton
@onready var item_button = $ItemButton
@onready var inner_border = $InnerBorder

var itemdragsprite = preload("res://scenes/item_drag_sprite.tscn")
var itemdragsprite_instance = itemdragsprite.instantiate()

signal drag_start(slot)
signal drag_end()

#Slot Item
var item = null

func _ready():
	pass

func _process(delta):
	#details_panel.position = get_global_mouse_position()
	pass
	

func _on_item_button_mouse_entered():
	if item != null:
		usage_panel.visible = false
		details_panel.visible = true

func _on_item_button_mouse_exited():
	details_panel.visible = false

func set_empty():
	item_icon.texture = null
	item_quantity.text = ""
	item_button.visible = false

func set_item(new_item):
	item = new_item
	item_name.text = str(new_item["name"])
	item_rarity.text = str(new_item["rarity"])
	item_icon.texture = new_item["texture"]
	item_quantity.text = str(new_item["quantity"])
	item_type.text = str(new_item["type"])
	
	#Give color to text based on rarity
	match new_item["rarity"]:
		"Common":
			item_rarity.set("theme_override_colors/font_color", Color("CADET_BLUE"))
		"Uncommon":
			item_rarity.set("theme_override_colors/font_color", Color("DARK_OLIVE_GREEN"))
		"Rare":
			item_rarity.set("theme_override_colors/font_color", Color("DARK_BLUE"))
		"Epic":
			item_rarity.set("theme_override_colors/font_color", Color("DARK_ORCHID"))
		"Legendary":
			item_rarity.set("theme_override_colors/font_color", Color("CRIMSON"))
		_:
			print("do nothing")
	
	if item["effect"] != "":
		item_effect.text = str(item["effect"])
	else:
		item_effect.text = ""
	

func _on_drop_button_pressed():
	if item != null:
		var drop_position = global.player_node.global_position
		var drop_offset = Vector2(0, 5)
		drop_offset = drop_offset.rotated(global.player_node.rotation)
		global.drop_item(item, drop_position + drop_offset)
		global.remove_item(item["type"], item["effect"])
		usage_panel.visible = false
		

func _on_item_button_gui_input(event):
	if event is InputEventMouseButton:
		#Usage Panel
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if item != null:
				if item["type"] == "Non-consumable":
					use_button.visible = false
			usage_panel.visible = !usage_panel.visible
			details_panel.visible = false
		#Dragging Item
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				get_parent().get_parent().add_child(itemdragsprite_instance)
				inner_border.modulate = Color(1, 1, 0)
				itemdragsprite_instance.texture = item_icon.texture
				drag_start.emit(self)
				item_icon.visible = false
			elif event.is_released():
				inner_border.modulate = Color(1, 1, 1)
				drag_end.emit()
				item_icon.visible = true
				itemdragsprite_instance.visible = false
				itemdragsprite_instance.queue_free()
