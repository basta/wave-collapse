extends Node

var sea: Sea
var beach: Beach

func _ready():
	sea = $Sea
	beach = $Beach
	for child in get_children():
		child.setup()
