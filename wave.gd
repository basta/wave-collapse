extends Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var image = Image.new()
	image.set_data(4, 1, false, Image.FORMAT_L8, [255,5,255,255])
	var dataTexture = ImageTexture.create_from_image(image)
	material.set_shader_parameter("dataTexture", dataTexture)
	#texture = dataTexture
	
