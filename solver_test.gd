extends Node2D

var grid = []
var X = 40
var Y = 40

const NEIGHB_CONFIG = "4"

func constraint_func(state: Array) -> Array[String]:
	if state.is_empty():
		return ["A", "B", "C", "D"]
	
	var allowed = []
	if "A" in state:
		allowed.append_array(["A", "B"])
	if "B" in state:
		allowed.append_array(["A", "B", "C"])
	if "C" in state:
		allowed.append_array(["B", "C", "D"])
	if "D" in state:
		allowed.append_array(["C", "D"])
	
	var ret: Array[String] = []
	for letter in "ABCD":
		if letter in allowed:
			ret.append(letter)
	
	return ret
	
func intersect(arr1, arr2) -> Array[String]:
	var ret: Array[String] = []
	for x in arr1:
		if x in arr2:
			ret.append(x)
			
	return ret
		
func solve_cell(x,y, grid):
	var offsets: Array;
	match NEIGHB_CONFIG:
		"4":
			offsets = [
				[0,-1],
				[1, 0],
				[0, 1],
				[-1, 0]
			]
		"8":
			offsets = [
				[0,-1],
				[1, 0],
				[0, 1],
				[-1, 0],
				[-1, -1],
				[-1, 1],
				[1,1],
				[1, -1]
			]
	
	var solution = ["A","B","C","D"]
	
	for offset in offsets:
		var xoff = offset[0]
		var yoff = offset[1]
		if x + xoff < 0 or x + xoff >= X or y + yoff < 0 or y + yoff >= Y:
			continue
		solution = intersect(solution, constraint_func(grid[x+xoff][y+yoff]))

	
	return solution
	
# Returns a [x, y, "A']
func next_constraint(grid, current_constr):
	var min_len = 9999
	var min_len_item = null # [X, Y, "constraints"]
	for x in grid.size():
		for y in grid[x].size():
			if current_constr[x][y].is_empty():
				var item = grid[x][y]
				if len(item) < min_len:
					min_len = len(item)
					min_len_item = [x, y, item]
					
	if min_len_item == null:
		return null
				
	var item = min_len_item[2]
	return [min_len_item[0], min_len_item[1], [item[randi() % item.size()]]]
	
func print_grid(grid):
	for row in grid:
		var line = ""
		for cell in row:
			var cell_str = ""
			for letter in cell:
				cell_str += letter
			for i in len("ABCD") - len(cell_str):
				cell_str += " "
			
			line += cell_str +  " "
		print(line)
		
func create_grid(X,Y) -> Array:
	var grid = []
	for x in X:
		grid.append([])
		for y in Y:
			grid[x].append([])
	return grid

func state_to_frame(state):
	match state:
		"A":
			return 2
		"B":
			return 3
		"C":
			return 0
		"D":
			return 1

var sprite_pool = []
func render_grid(grid):
	if sprite_pool.is_empty():
		for x in grid.size():
			for y in grid[x].size()*4:
				var sprite = $template.duplicate()
				add_child(sprite)
				sprite_pool.append(sprite)
				
	const SPRITE_SIZE = 16
	const SPRITE_SCALE = 2
	for sprite in sprite_pool:
		sprite.visible = false
	for x in grid.size():
		for y in grid[x].size():
			var states = grid[x][y]
			var n_states = len(states)
			for i in n_states:
				var state = states[i]
				var sprite: Sprite2D = sprite_pool[x*(Y*4) + y*4 + i]
				sprite.position.x = x*SPRITE_SIZE*SPRITE_SCALE
				sprite.position.y = y*SPRITE_SIZE*SPRITE_SCALE
				sprite.scale = SPRITE_SCALE*Vector2.ONE


				sprite.frame = state_to_frame(state)
				sprite.modulate = Color(1,1,1, 1./n_states)
				sprite.visible = true
				
# Called when the node enters the scene tree for the first time.
var constraints = null
func _ready():
	#var new_grid = create_grid(X,Y)
	
	constraints = create_grid(X,Y)
	constraints[0][0] = ["A"]
	constraints[X-1][Y-1] = ["D"]
	constraints[6][6] = ["A"]



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var start_time = Time.get_unix_time_from_system()
	var grid = create_grid(X,Y)
	for x in constraints.size():
		for y in constraints[x].size():
			grid[x][y] = constraints[x][y]
	var change = true
	var ctr = 0
	while change:
		ctr += 1
		change = false
		for x in X:
			for y in Y:
				if constraints[x][y].is_empty():
					var new_cell = solve_cell(x, y, grid)
					if new_cell != grid[x][y]:
						change = true
						grid[x][y] = new_cell
	

	var next_constr = next_constraint(grid, constraints)
	if next_constr:
		constraints[next_constr[0]][next_constr[1]] = next_constr[2]
	render_grid(grid)
	print(Time.get_unix_time_from_system() - start_time)
