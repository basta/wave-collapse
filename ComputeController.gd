extends Node

class_name ComputeController

var rd := RenderingServer.create_local_rendering_device()
var X := 10
var Y := 10
var N_states := 4

# Called when the node enters the scene tree for the first time.

func load_shader(filename) -> RID:
	var shader_file := load(filename)
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	print(shader_spirv.compile_error_compute)
	var shader := rd.shader_create_from_spirv(shader_spirv)
	return shader
	
	
func create_buffer(arr) -> RID:
	var array = PackedInt32Array(arr)
	var array_bytes = array.to_byte_array()
	var buffer := rd.storage_buffer_create(
		array_bytes.size(), 
		array_bytes
		)
	
	return buffer

func get_uniform_for_buffer(buffer, bind) -> RDUniform:
	var uniform = RDUniform.new()
	
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = bind # this needs to match the "binding" in our shader file
	uniform.add_id(buffer)
	return uniform

func iteration(shader, constraints_data, state_data):
	var state_array = state_data
	
	var constr_array = constraints_data
	
	var state_buffer := create_buffer(state_array)
	var constr_buffer := create_buffer(constr_array)
	
	var state_uniform := get_uniform_for_buffer(state_buffer, 0)
	var constr_uniform := get_uniform_for_buffer(constr_buffer, 1)
	
	var uniform_set := rd.uniform_set_create([state_uniform, constr_uniform], shader, 0) 
	# the last parameter (the 0) needs to match the "set" in our shader file
	
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
	return output

func print_buffer(buffer):
	for row in Y:
		var line = ""
		for col in X:
			var cell_str = str(buffer[Y*row + col])
			
			for i in len("1111") - len(cell_str):
				cell_str += " "
			
			line += cell_str +  " "
		print(line)
		


var shader
var timer = 0

func calculate(iters=10):
	var state_data = []
	var constr_data = []
	for x in X:
		for y in Y:
			state_data.append(15)
			constr_data.append(0)
			
	constr_data[0] = 1
	state_data[0] = 1
	for iter in iters:
		state_data = iteration(shader, constr_data, state_data)
	return [state_data, constr_data]
	
#func _process(delta):
#	timer += delta
#	if timer > 1:
#		shader = load_shader("")
#		iteration(shader, [])
#		timer = 0


func int_to_states(n: int) -> Array[bool]:
	assert(n < 16, "Invalid state")
	var states: Array[bool] = []
	
	states.append(n%2 == 1)
	while n > 1:
		n = n >> 1
		states.append(n%2 == 1)
	
	return states

func states_to_int(arr: Array[bool]) -> int:
	var ret = 0
	for i in len(arr):
		if arr[i]:
			ret += pow(2, i)
	return ret
	
func add_constraint_inplace(constr_data, state_data):
	var best_idx = null
	var best_len = 99999999
	for idx in len(state_data):
		if constr_data[idx] != 0: continue
		var states = int_to_states(state_data[idx])
		if len(states) < best_len and len(states) != 0:
			best_idx = idx
			best_len = len(states)
			
	if best_idx == null: return
	
	var best_state = int_to_states(state_data[best_idx])
	var n_options = best_state.count(true)
	var pick = randi() % n_options
	var ctr = 0
	for i in len(best_state):
		var option = best_state[i]
		
		if option and ctr == pick:
			var val = pow(2, i)
			constr_data[best_idx] = val
			state_data[best_idx] = val
			return
		elif option:
			ctr += 1
		
		
func _ready():
	shader = load_shader("res://wavecompute.glsl")

var state_data = []
var constr_data = []
func _process(delta):
	# Initialize
	if len(state_data) == 0:
		for x in X:
			for y in Y:
				state_data.append(15)
				constr_data.append(0)
			
		constr_data[0] = 1
	
	
	var iters = 10
	for iter in iters:
		state_data = iteration(shader, constr_data, state_data)
	
	add_constraint_inplace(constr_data, state_data)
	get_parent().get_node("SpriteRenderer").render_buffer(state_data, X, Y)

	
func timing():
	var time_start = Time.get_unix_time_from_system()
	var ITER = 100;
	for i in ITER:
		calculate()
	print((Time.get_unix_time_from_system() - time_start)/ITER)

