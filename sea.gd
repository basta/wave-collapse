extends WaveTile

class_name Sea

func _ready():
	frame = 0
	
func setup():
	set_rule_for_all([[self, 0.8], [get_parent().beach, 0.2]])
	
