extends WaveTile

class_name Beach

func _ready():
	frame = 3
	
func setup():
	set_rule_for_all([[self, 0.8], [get_parent().sea, 0.2]])
	
