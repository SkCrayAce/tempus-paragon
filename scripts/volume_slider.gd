extends HSlider

#enum AudioBus {Master, Music, SFX}
@export_enum("Master", "Music", "SFX") var bus_name : String = "Master"

var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(str(bus_name))
	value_changed.connect(_on_value_changed)
	prints(bus_name)
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	
func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
