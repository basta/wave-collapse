extends ComputeController

func flatten(arr2D: Array) -> Array[int]:
	var ret: Array[int] = []
	for x in arr2D.size():
		for y in arr2D[x].size():
			ret.append(arr2D[x][y])
	return ret
	

func image_to_matrix(path):
	var image = Image.load_from_file(path)
	var width = image.get_width()
	var height = image.get_height()
	
	var matrix = []
	for x in width:
		matrix.append([])
		for y in height:
			matrix[x].append(0)
	
	
	var data = {}
	var next_type_number = 1
	for x in width:
		for y in height:
			var pixel
			pixel = image.get_pixel(x, y)
			if pixel not in data.keys():
				data[pixel] = next_type_number
				next_type_number = next_type_number*2
			
			matrix[x][y] = data[pixel]
	return matrix
	
func print_debug_buffer(buf):
	for i in len(buf):
		print(i, ": ", buf[i])
		

func iteration_matrix(shader, constraints_data, state_data, matrix, window_x=3, window_y=3):
	var state_array = state_data
	var constr_array = constraints_data
	var matrix_array := flatten(matrix)
	
	var state_buffer := create_buffer(state_array)
	var constr_buffer := create_buffer(constr_array)
	var matrix_buffer := create_buffer(matrix_array)
	var config_buffer := create_buffer([matrix.size(), matrix[0].size(), window_x, window_y])
	
	var debug_array = []
	for i in 20:
		debug_array.append(255)
		
	var debug_buffer := create_buffer(debug_array)
	
	
	var state_uniform := get_uniform_for_buffer(state_buffer, 0)
	var constr_uniform := get_uniform_for_buffer(constr_buffer, 1)
	var matrix_uniform := get_uniform_for_buffer(matrix_buffer, 2)
	var config_uniform := get_uniform_for_buffer(config_buffer, 3)
	var debug_uniform := get_uniform_for_buffer(debug_buffer, 4)
	
	var uniform_set := rd.uniform_set_create(
		[state_uniform, constr_uniform, matrix_uniform, config_uniform, debug_uniform],
		shader, 0) 

	# Create a compute pipeline
	var pipeline := rd.compute_pipeline_create(shader)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, 1, 1, 1)
	rd.compute_list_end()
	

	rd.submit()
	rd.sync()
	
	# Read back the data from the buffer
	var output_bytes := rd.buffer_get_data(state_buffer)
	var output := output_bytes.to_int32_array()
#	print_debug_buffer(rd.buffer_get_data(debug_buffer).to_int32_array())
	return output
	
var matrix_shader
var matrix
func _ready():
	matrix = image_to_matrix("res://sea.png")
	matrix_shader = load_shader("wavecompute-matrix.glsl")
	for x in X:
			for y in Y:
				state_data.append(15)
				constr_data.append(0)
			
	constr_data[0] = 1
	state_data[0] = 1
	
	


func _process(delta):
	var iters = 10
	for iter in iters:
		print("Iteration: ", iter)
		state_data = iteration_matrix(matrix_shader, constr_data, state_data,
			matrix, 3, 3
		)
		print_buffer(state_data)
	print()
	
	add_constraint_inplace(constr_data, state_data)
	get_parent().get_node("SpriteRenderer").render_buffer(state_data, X, Y)
