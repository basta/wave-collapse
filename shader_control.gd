extends Sprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
var res = 0
func _process(delta):
	res += delta
	var shader_material = material
	material.set_shader_parameter("RESOLUTION", res)
