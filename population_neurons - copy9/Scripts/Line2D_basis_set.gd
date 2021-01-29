extends Line2D

#####################
#      PARAMS
#####################
# UI
onready var gain_slider = get_node("../../VSlider_basis_gain")
onready var gain_text = get_node("../../VSlider_basis_gain/Label_basisGain")

# coordinate
var axes_origin = Vector2(220,210)
var bar_space = 45
var bar_width = 0
var first_bar_spacing = 0

# bar graph parameters
var neuron_number = 8

# basis set parameters
var mean
var std_deviation = 8
export var gain = 0.01
var drawing_deviation_number = 5
var number_dots = 40
var x
var y
var next_x
var next_y
var Gaussian_scale_up = 50

# likelihood paramters
var likelihood_point_value = 0
var likelihood = Array()
onready var neuron_activity_node
var neuron_activity = Array()
var normalizing_likelihood = 0

# posterior paramters
var posterior = Array()
var normalizing_posterior = 0

# likelihood and posterior drawing
var interval_number = 400.0
var interval_min = 0.0-3.0*drawing_deviation_number*std_deviation
var interval_max = 360+3.0*drawing_deviation_number*std_deviation

# animation finish
onready var animation_finish_node = get_node("../../CanvasLayer_start_instruction/Line2D_instruction")
var animation_finish = false
onready var head_angle_node = get_node("../Line2D_barGraph")
var head_angle

##############################

func _ready():
	neuron_activity_node = get_node("../Line2D_barGraph")
	head_angle = head_angle_node.head_angle
	
	gain_slider.set_global_position(Vector2(axes_origin.x-50, axes_origin.y - 100))
	gain_slider.rect_size = Vector2(16,100)
	gain_slider.min_value = 0.01 # maximum spike count = 100
	gain_slider.max_value = 0.05 # minimum spike count = 20
	gain_slider.step = 0.001
	gain_slider.value = 0.03

	# set a font
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font.size = 18

	var dynamic_font_2 = DynamicFont.new()
	dynamic_font_2.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font_2.size = 15
		
	gain_text.set_position(Vector2(-30,110))
	gain_text.text = "Gain:" + str(gain_slider.value)
	gain_text.add_color_override("font_color", Color(1,0.357,0.376,1))
	gain_text.add_font_override("font",dynamic_font)
	
	if !get_node_or_null("min"):
		var node = Label.new()
		node.name = "min"
		add_child(node)	
	get_node("min").set_global_position(gain_slider.rect_position + \
		Vector2(-24,90))
	get_node("min").text = "0.05"
	get_node("min").add_color_override("font_color", Color(1,0.357,0.376,1))	
	get_node("min").add_font_override("font",dynamic_font_2)

	if !get_node_or_null("max"):
		var node = Label.new()
		node.name = "max"
		add_child(node)	
	get_node("max").set_global_position(gain_slider.rect_position + \
		Vector2(-23,-4))
	get_node("max").text = "0.01"
	get_node("max").add_color_override("font_color", Color(1,0.357,0.376,1))	
	get_node("max").add_font_override("font",dynamic_font_2)	
	
func _process(_delta):
	animation_finish = animation_finish_node.animation_finish
	
	if animation_finish == false:
		gain_slider.editable = false
	else:
		gain_slider.editable = true	
		
	head_angle = head_angle_node.head_angle
	neuron_activity = neuron_activity_node.neuron_activity
	gain = gain_slider.value
	std_deviation = sqrt(1.0/gain)
	gain_text.text = "Gain:" + str(gain_slider.value)
	update()

func _draw():
	# draw the Quadratic func
	var step = 2.0*drawing_deviation_number*std_deviation / (number_dots-1)
	for k in range(0,number_dots-2):
		# start with a quadratic with center = 0
		x = -drawing_deviation_number*std_deviation + k*step
		y = Parabolic_value(0, std_deviation, x)
		next_x = -drawing_deviation_number*std_deviation + (k+1)*step	
		next_y = Parabolic_value(0, std_deviation, next_x)	 
		# shift to each location
		for i in range(neuron_number):
			mean = i*bar_space
			if mean + x < 0:
				draw_line(Vector2(axes_origin.x + mean + x+360, axes_origin.y - y), \
					Vector2(axes_origin.x + mean + next_x+360, axes_origin.y - next_y), \
					Color(0.925,0.54,0.19,1.0), 1.5, true)			
			else:	
				draw_line(Vector2(axes_origin.x + mean + x, axes_origin.y - y), \
					Vector2(axes_origin.x + mean + next_x, axes_origin.y - next_y), \
					Color(0.925,0.54,0.19,1.0), 1.5, true)

################################################################
				
	# calculate the likelihood and then posterior p(r|s)
	if neuron_activity != Array():
		likelihood = Array()			
		posterior = Array() 
		var interval_step = (interval_max - interval_min)/(interval_number-1)
		for m in range(interval_number-2):
			var small_left = interval_min+m*interval_step
			# calculate the likelihood and posterior
			likelihood_point_value = 0
			if head_angle < deg2rad(296) and \
				head_angle > deg2rad(40): # middle
				for index in range(neuron_number):
					likelihood_point_value += neuron_activity[index]*\
						Parabolic_value(index*bar_space, std_deviation, small_left)
			elif head_angle >= deg2rad(296): # right-end
				for index in range(2):
					likelihood_point_value += neuron_activity[index]*\
						Parabolic_value(index*bar_space, std_deviation, small_left-360)
				for index in range(neuron_number-2,neuron_number):
					likelihood_point_value += neuron_activity[index]*\
						Parabolic_value(index*bar_space, std_deviation, small_left)
			else: # left-end
				for index in range(2):
					likelihood_point_value += neuron_activity[index]*\
						Parabolic_value(index*bar_space, std_deviation, small_left)
				for index in range(neuron_number-2,neuron_number):
					likelihood_point_value += neuron_activity[index]*\
						Parabolic_value(index*bar_space, std_deviation, small_left+360)
						
			likelihood.append(Vector2(small_left,likelihood_point_value))
			posterior.append(Vector2(small_left,exp(likelihood_point_value/(100*Gaussian_scale_up))))
			
		normalizing_posterior = integrate_probablity_curve(posterior, interval_step) 	# flat-prior

		# draw the posterior curve
		for z in range(len(posterior)-1):
			if posterior[z].x >= 0 and posterior[z].x <= 360 and \
				100*Gaussian_scale_up*posterior[z].y/normalizing_posterior>1:			
				draw_line(Vector2(axes_origin.x + posterior[z].x, axes_origin.y - 100*Gaussian_scale_up*posterior[z].y/normalizing_posterior),\
					Vector2(axes_origin.x + posterior[z+1].x, axes_origin.y - 100*Gaussian_scale_up*posterior[z+1].y/normalizing_posterior),\
					ColorN("Blue"), 1.5, true)
			elif posterior[z].x < 0 and \
				100*Gaussian_scale_up*posterior[z].y/normalizing_posterior>1:
				draw_line(Vector2(axes_origin.x + posterior[z].x+360, axes_origin.y - 100*Gaussian_scale_up*posterior[z].y/normalizing_posterior),\
					Vector2(axes_origin.x + posterior[z+1].x+360, axes_origin.y - 100*Gaussian_scale_up*posterior[z+1].y/normalizing_posterior),\
					ColorN("Blue"), 1.5, true)		
			elif posterior[z].x > 360 and \
				100*Gaussian_scale_up*posterior[z].y/normalizing_posterior>1:
				draw_line(Vector2(axes_origin.x + posterior[z].x-360, axes_origin.y - 100*Gaussian_scale_up*posterior[z].y/normalizing_posterior),\
					Vector2(axes_origin.x + posterior[z+1].x-360, axes_origin.y - 100*Gaussian_scale_up*posterior[z+1].y/normalizing_posterior),\
					ColorN("Blue"), 1.5, true)					

#############################
# quaratic function	
func Parabolic_value(mean, std_deviation, x):
	var y = 0
	y = 100.0-(x-mean)*(x-mean)/(std_deviation*std_deviation)
	return y

func integrate_probablity_curve(posterior, interval_step):
	var total_area = 0
	for i in range(len(posterior)):
		total_area += posterior[i].y * interval_step
	return total_area
