extends Line2D

####################
#      PARAMS
####################
# UI control
onready var headAngle_slider = get_node("../../HSlider_headAngle")
onready var headAngle_text = get_node("../../HSlider_headAngle/Label_headAngle")
onready var mouse_head = get_node("../Sprite_RotatingMouse")
onready var noise_flag_node = get_node("../Line2D_axes_for_activity_bar")

# bar graph parameters
var neuron_angle_step = 45
var neuron_number = 8

export var neuron_activity = [100,100,100,100,100,100,100,100]
var preferred_direction
export var head_angle = 0
var head_vector

export var population_vector = Vector2(0,0)
var denominator = 0

# coordinate
var axes_origin = Vector2(320,470)
var bar_space = 28
var bar_width = 20
var first_bar_spacing = 18

# one-finger gesture
var events = {}
var y_touch_delta = 20
var input_position
var input_activity_height = 0

# noise check box
var noise_flag
var rng = RandomNumberGenerator.new()
export var input_change = true    # reversely input change bar graph, head angle
								  # first time to add a noise
var static_neural_activity = [100,100,100,100,100,100,100,100]
onready var gain_node = get_node("../Line2D_basis_set")
var gain

# animation finish
onready var animation_finish_node = get_node("../../CanvasLayer_start_instruction/Line2D_instruction")
var animation_finish = false

###############################

func _ready():
	rng.randomize()
	noise_flag = noise_flag_node.noise_flag
	gain = gain_node.gain
	
	# initialize the slider
	headAngle_slider.set_global_position(Vector2(axes_origin.x + 180,axes_origin.y + 50))
	headAngle_slider.rect_size = Vector2(150,16)
	headAngle_slider.min_value = 0
	headAngle_slider.max_value = 2*PI # in radian
	headAngle_slider.step = 0.01
	headAngle_slider.value = 0
	
	mouse_head.set_global_position(Vector2(axes_origin.x + 170+1.3*headAngle_slider.rect_size.x,\
		axes_origin.y + 50+5))
	mouse_head.rotation_degrees = 90
	
	# set a font
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font.size = 18
	
	headAngle_text.set_position(Vector2(-157,2))
	headAngle_text.text = "Head Facing Angle: 0" # show in degree
	headAngle_text.add_color_override("font_color", ColorN("Black"))
	headAngle_text.add_font_override("font",dynamic_font)

func _process(_delta):
	noise_flag = noise_flag_node.noise_flag
	gain = gain_node.gain
	animation_finish = animation_finish_node.animation_finish
	
	if animation_finish == false:
		headAngle_slider.editable = false
	else:
		headAngle_slider.editable = true
	
	# set a font
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font.size = 18
	
	# get the current head angle
	if head_angle != headAngle_slider.value:
		input_change = true
	
	head_angle = headAngle_slider.value  # in radian
	headAngle_text.add_font_override("font",dynamic_font)
	headAngle_text.text = "Head Facing Angle: " + \
		str(stepify(rad2deg(headAngle_slider.value),1))
		
	mouse_head.rotation_degrees = 90 - rad2deg(headAngle_slider.value)
	
	# calculate the activity of each neuron, by head angle and preferred vecs
	if noise_flag == false:
		for k in range(neuron_number):
#			preferred_direction = get_the_preferred_vec(k) # counterclockly
#			head_vector = Vector2(cos(head_angle),-sin(head_angle)) # angle is positive downwards in Godot
#			var diff_angle = acos(preferred_direction.dot(head_vector) / \
#				(length_of_vector(preferred_direction)*length_of_vector(head_vector))) # the angle diff can be 0 to PI.
			#neuron_activity[k] = 100*exp(-diff_angle)
			neuron_activity[k] = tuning_function(k, head_angle)
	elif noise_flag and input_change == true:
		for k in range(neuron_number):
#			preferred_direction = get_the_preferred_vec(k)
#			head_vector = Vector2(cos(head_angle),-sin(head_angle)) 
#			var diff_angle = acos(preferred_direction.dot(head_vector) / \
#				(length_of_vector(preferred_direction)*length_of_vector(head_vector))) 
			#neuron_activity[k] = 100*exp(-diff_angle)
			neuron_activity[k] = tuning_function(k, head_angle)
			static_neural_activity[k] = neuron_activity[k]
			# sample on the basis of the fixed activity
			neuron_activity[k] = Poisson_generator(k)
		input_change = false

	# sum for the population vector
	population_vector = Vector2(0,0)
	denominator = 0
	for k in range(neuron_number):
		preferred_direction = get_the_preferred_vec(k)
		population_vector += preferred_direction*neuron_activity[k]
		denominator += neuron_activity[k]
	population_vector = population_vector / denominator
	
	update()
 
func _input(event):
	# finger drag on the activity bar
	if event is InputEventScreenDrag and animation_finish:
		events[event.index] = event
	# one-finger drag
	if events.size() == 1 and animation_finish:
		input_position = events[0].position
		for i in range(neuron_number):
			var current_y = axes_origin.y - neuron_activity[i] # absolute location on canvas
			var current_x_min = axes_origin.x + i*(bar_space+bar_width) + first_bar_spacing
			var current_x_max = axes_origin.x + i*(bar_space+bar_width) + first_bar_spacing + bar_width
			if input_position.x >= current_x_min and input_position.x <= current_x_max and \
				input_position.y >= current_y - y_touch_delta and \
				input_position.y <= current_y + y_touch_delta:
				# dragging
				var current_max = 1.0/gain
				if input_position.y <= axes_origin.y-5 and \
					input_position.y >= axes_origin.y - current_max:
					neuron_activity[i] = abs(axes_origin.y - input_position.y) 
					# calculate the head angle
					headAngle_slider.value = calculate_head_angle(i,neuron_activity[i])  # in radian
					if noise_flag:
						input_change == true
				elif input_position.y < axes_origin.y - current_max:
					neuron_activity[i] = current_max
					headAngle_slider.value = calculate_head_angle(i,neuron_activity[i])	
					if noise_flag:
						input_change == true
						
func _draw():
	# draw bars
	for i in range(neuron_number):
		draw_rect(Rect2(axes_origin.x+first_bar_spacing+i*(bar_space+bar_width),\
			axes_origin.y-2, bar_width,-neuron_activity[i]),ColorN("White"), true)
	# draw the fixed activity by a black line, in noise mode
	if noise_flag :
		for k in range(neuron_number):
			draw_line(Vector2(axes_origin.x+first_bar_spacing+k*(bar_space+bar_width),\
				axes_origin.y-static_neural_activity[k]), \
				Vector2(bar_width+axes_origin.x+first_bar_spacing+k*(bar_space+bar_width)+1,\
				axes_origin.y-static_neural_activity[k]),\
				ColorN("Black"),1.0,true)
		
###############################################################

func get_the_preferred_vec(index):
	var arrow
	arrow = Vector2(100*cos(deg2rad(index*45)),-100*sin(deg2rad(index*45)))   # y is positive downwards
	return arrow

# draw a triangle on the 2d canvas
func draw_triangle(pos:Vector2, dir:Vector2, size, color):
	dir = dir.normalized()
	var a = pos + dir*size
	var b = pos + dir.rotated(2*PI/3)*size
	var c = pos + dir.rotated(4*PI/3)*size
	var points = PoolVector2Array([a,b,c])
	draw_polygon(points, PoolColorArray([color]))	

# function to get the length of a vector
func length_of_vector(vector):
	var length = sqrt(pow(vector.x,2)+pow(vector.y,2))
	return length
	
# return the head angle with a new neuron_activity	
func calculate_head_angle(index, activity):
	var preferred_vec = get_the_preferred_vec(index)
	var original_theta
	# convert to the normal theta we use, in radian
	if preferred_vec.x >= 0 and preferred_vec.y <= 0:  # the first quarter
		original_theta = atan2(preferred_vec.x, preferred_vec.y) - PI/2.0
	else: 
		original_theta = atan2(preferred_vec.x, preferred_vec.y) + PI + PI/2.0
		
#	var theta_difference = -log(activity/100.0)/log(2.718282)
	var sigma = PI/neuron_number
	var theta_difference = -log(gain*activity)/log(2.718282)
	theta_difference = 2.0*sigma*sigma*theta_difference
	theta_difference = sqrt(theta_difference)  # reverse tuning function
	var return_angle = original_theta + theta_difference # in radian, return the counterclockwise one
	return_angle = fmod(return_angle,2*PI) # within 0 to 2*PI
	return return_angle

# return an integer value with Poisson distribution
func Poisson_generator(neuron_index):
	var Poisson_mean = tuning_function(neuron_index, head_angle)
	Poisson_mean = round(Poisson_mean)   # start from the nearest integer
	var poisson_probability = Poission_probability_for_n(Poisson_mean,Poisson_mean)
	var random_generator_array = Array()
	for i in range(poisson_probability):
		random_generator_array.append(Poisson_mean)
	
	# search for other integers
	for other_activity in range(Poisson_mean + 1, 150):  # 150 is choosen that is big enough to cover possible spike count
		poisson_probability=Poission_probability_for_n(Poisson_mean,other_activity)
		if poisson_probability > 1:
			for i in range(poisson_probability):
				random_generator_array.append(other_activity)
		else: 
			break

	if Poisson_mean != 0:
		for other_activity in range(Poisson_mean-1, 0, -1):
			poisson_probability=Poission_probability_for_n(Poisson_mean,other_activity)
			if poisson_probability > 1:
				for i in range(poisson_probability):
					random_generator_array.append(other_activity)
			else: 
				break		
	
	var random_integer_max = random_generator_array.size()
	var random_poission_index = rng.randi_range(0,random_integer_max-1)
	return random_generator_array[random_poission_index]
	
	
func Poission_probability_for_n(lambda,n):	
	var probability = exp(-lambda)*pow(lambda,n)
	var factorial_deno = 1.0
	for i in range(1,n+1):
		factorial_deno *= i
	probability = stepify(100*probability/factorial_deno,1)  # return as xx%.
	return probability

# return a mean f(s) from tuning curve	
func tuning_function(preferred_index, head_angle_value):
	var sigma = PI/neuron_number  # the angle spacing between preferred stimuli

	var preferred_direction = get_the_preferred_vec(preferred_index)
	var head_vector = Vector2(cos(head_angle_value),-sin(head_angle_value)) 
	var diff_angle = acos(preferred_direction.dot(head_vector) / \
		(length_of_vector(preferred_direction)*length_of_vector(head_vector))) 
		
	var tuning_value = 1.0/gain * exp(-(diff_angle*diff_angle)/(2.0*sigma*sigma))
	return tuning_value
