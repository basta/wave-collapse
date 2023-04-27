extends Node2D
var SPRITE_SIZE = 16
var SPRITE_SCALE = 2
var textures: Texture2DArray


func create_map(N):
	var template = $Template
	for x in N:
		for y in N:
			var sprite = template.duplicate()
			sprite.position.x = x*SPRITE_SIZE*SPRITE_SCALE
			sprite.position.y = y*SPRITE_SIZE*SPRITE_SCALE
			sprite.scale = SPRITE_SCALE*Vector2.ONE
			sprite.frame = randi_range(0, 4)
			add_child(sprite)
			
			
# Called when the node enters the scene tree for the first time.
func _ready():
	var tile = WaveTile.new()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
