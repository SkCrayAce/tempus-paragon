extends Control

@onready var grid_container = $GridContainer

#Drag/Drop
var dragged_slot = null


func _ready():
	global.inventory_updated.connect(_on_inventory_updated)
	_on_inventory_updated()

func _on_inventory_updated():
	#Clear existing slots
	clear_grid_container()
	
	#Add slots for each inventory position
	for item in global.inventory:
		var slot = global.inventory_slot_scene.instantiate()
		
		slot.drag_start.connect(_on_drag_start)
		slot.drag_end.connect(_on_drag_end)
		
		grid_container.add_child(slot)
		if item != null:
			slot.set_item(item)
		else:
			slot.set_empty()

#Clear inventory grid
func clear_grid_container():
	while grid_container.get_child_count() > 0:
		var child = grid_container.get_child(0)
		grid_container.remove_child(child)
		child.queue_free()

#Drag and drop functions ---------------------------------
func _on_drag_start(slot_control : Control):
	dragged_slot = slot_control
	print("Drag started for slot: ", dragged_slot)

func _on_drag_end():
	var target_slot = get_slot_under_mouse()
	if target_slot and dragged_slot != target_slot:
		drop_slot(dragged_slot, target_slot)
	elif dragged_slot != target_slot:
		var drop_position = global.player_node.global_position
		var drop_offset = Vector2(50, 0)
		drop_offset = drop_offset.rotated(global.player_node.rotation)
		global.drop_item(dragged_slot.item, drop_position )
		global.remove_item(dragged_slot.item["type"], dragged_slot.item["effect"])
	dragged_slot = null

func get_slot_under_mouse() -> Control:
	print("getting slot under mouse")
	var mouse_position = get_global_mouse_position()
	for slot in grid_container.get_children():
		slot.size = Vector2(100, 100) #had to set this cuz for some reason all grid sizes are 0
		var slot_rect = Rect2(slot.global_position, slot.size)
		print(slot_rect)
		if slot_rect.has_point(mouse_position):
			return slot
	print("no valid slot found")
	return null
	
func get_slot_index(slot:Control) -> int:
	print("in get slot index")
	for i in range(grid_container.get_child_count()):
		if grid_container.get_child(i) == slot:
			#valid slot found
			return i
	#Invalid slot
	return -1

func drop_slot(slot1: Control, slot2: Control):
	var slot1_index = get_slot_index(slot1)
	var slot2_index = get_slot_index(slot2)
	if slot1_index == -1 or slot2_index == -1:
		print("Invalid slots found")
		return
	else:
		if global.swap_inventory_items(slot1_index, slot2_index):
			print("Dropping slot items: ", slot1, slot2_index)
			_on_inventory_updated()
			

#---------------------------------------------------------
