extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$CityMusic.volume_db -= 15
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $CityMusic.playing == false:
		$CityMusic.playing = true
	
	
