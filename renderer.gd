extends Node2D

var sprite_pool = []

var frame_map = [2, 3, 0, 1]


#func render_grid(grid, X, Y):
#	if sprite_pool.is_empty():
#		for x in grid.size():
#			for y in grid[x].size()*4:
#				var sprite = $template.duplicate()
#				add_child(sprite)
#				sprite_pool.append(sprite)
#
#	const SPRITE_SIZE = 16
#	const SPRITE_SCALE = 2
#	for sprite in sprite_pool:
#		sprite.visible = false
#	for x in grid.size():
#		for y in grid[x].size():
#			var states = grid[x][y]
#			var n_states = len(states)
#			for i in n_states:
#				var state = states[i]
#				var sprite: Sprite2D = sprite_pool[x*(Y*4) + y*4 + i]
#				sprite.position.x = x*SPRITE_SIZE*SPRITE_SCALE
#				sprite.position.y = y*SPRITE_SIZE*SPRITE_SCALE
#				sprite.scale = SPRITE_SCALE*Vector2.ONE
#
#
#				sprite.frame = state_to_frame(state)
#				sprite.modulate = Color(1,1,1, 1./n_states)
#				sprite.visible = true
				

func int_to_states(n: int) -> Array[bool]:
	assert(n < 16, "Invalid state")
	var states: Array[bool] = []
	
	states.append(n%2 == 1)
	while n > 1:
		n = n >> 1
		states.append(n%2 == 1)
	
	return states

func render_buffer(buffer, X, Y, numeric=true):
	if sprite_pool.is_empty():
		for x in X:
			for y in Y*4:
				var sprite = $template.duplicate()
				add_child(sprite)
				sprite_pool.append(sprite)
				
	const SPRITE_SIZE = 16
	const SPRITE_SCALE = 2
	for sprite in sprite_pool:
		sprite.visible = false
	for x in X:
		for y in Y:
			var state = buffer[y*X + x]
			if numeric:
				state = int_to_states(state)
			
			var n_states = len(state)
			for i in n_states:
				if state[i]:
					var sprite: Sprite2D = sprite_pool[x*(Y*4) + y*4 + i]
					sprite.position.x = x*SPRITE_SIZE*SPRITE_SCALE
					sprite.position.y = y*SPRITE_SIZE*SPRITE_SCALE
					sprite.scale = SPRITE_SCALE*Vector2.ONE
					sprite.frame = frame_map[i]
					sprite.modulate = Color(1,1,1, 1./state.count(true))
					sprite.visible = true
				
