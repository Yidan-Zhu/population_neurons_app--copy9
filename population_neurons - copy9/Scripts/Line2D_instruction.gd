extends Line2D

# control params
export var animation_finish = false
var animation_count = 0
var origin = Vector2(320,470)
var y_limit = 120
var x_limit = 390
var illustration_region_color=Color(107.0/255.0,208.0/255.0,137.0/255.0,0.45)
var text_color = Color(246.0/255.0,89.0/255.0,26.0/255.0,1)
var line_color = Color(28/255.0,165/255.0,196/255.0,1)
var origin_up = Vector2(220,210)

# parameters
var neuron_activity_1
var bar_space = 28
var bar_width = 20
var first_bar_spacing = 18

##########################################

func _ready():
	neuron_activity_1 = tuning_function(0, 0)

func _input(event):
	if event is InputEventScreenTouch:
#		event.position.x > origin.x and \
#		event.position.x < origin.x+x_limit-10 and\
#		event.position.y < origin.y and\
#		event.position.y > origin.y-1.3*y_limit:
		if event.pressed:
			animation_count += 1
			update()

func _draw():
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font.size = 19
	
	if animation_count < 4:
		# add a button to skip animation
		if !get_node_or_null("button"):
			var node_button = Button.new()
			node_button.name = "button"
			add_child(node_button)		
		get_node("button").set_global_position(origin+Vector2(50,-180))
		get_node("button").text = "Skip Instruction"
		if (get_node("button").is_pressed()):
			animation_count = 4
			get_node("button").queue_free()
			# delete
			if get_node_or_null("Instruction_one"):
				get_node("Instruction_one").queue_free()
				get_node("example_sprite1").queue_free()
			if get_node_or_null("Instruction_two"):
				get_node("Instruction_two").queue_free()
			if get_node_or_null("Instruction_three"):
				get_node("Instruction_three").queue_free()
			if get_node_or_null("Instruction_four"):
				get_node("Instruction_four").queue_free()	

		# illustration part
		if animation_count == 0:
			# draw a region 
			draw_rect(Rect2(origin.x, \
				origin.y - y_limit, x_limit-10, \
				y_limit), illustration_region_color,true,1.0,true)
	
			if !get_node_or_null("example_sprite1"):
				var node2 = Sprite.new()
				node2.name = "example_sprite1"
				add_child(node2)
			get_node("example_sprite1").set_global_position(\
				origin+Vector2(77,-65))
			get_node("example_sprite1").texture = load("res://Sprites/finger_swipe.png")
			get_node("example_sprite1").rotation_degrees = -75
			get_node("example_sprite1").set_scale(Vector2(0.35,0.35))
	
			if !get_node_or_null("Instruction_one"):
				var node = Label.new()
				node.name = "Instruction_one"
				add_child(node)	
			get_node("Instruction_one").set_global_position(\
				origin+Vector2(110,-110))
			get_node("Instruction_one").text = \
				"Drag a bar to change its activity\nCurrent max activity is limited by gain.\n\ntunning curve gives the neuron's activity"
			get_node("Instruction_one").add_color_override("font_color", text_color)	
			get_node("Instruction_one").add_font_override("font",dynamic_font)
			
			# draw a new bar - drag the mean
			draw_line(Vector2(origin.x+first_bar_spacing,\
				origin.y-neuron_activity_1), \
				Vector2(bar_width+origin.x+first_bar_spacing,\
				origin.y-neuron_activity_1),\
				line_color,2.0,true)
			
			neuron_activity_1 += 40
			draw_line(Vector2(origin.x+first_bar_spacing,\
				origin.y-neuron_activity_1), \
				Vector2(bar_width+origin.x+first_bar_spacing,\
				origin.y-neuron_activity_1),\
				line_color,2.0,true)
			
			draw_line(Vector2(origin.x+first_bar_spacing+bar_width/2.0+1,\
				origin.y-neuron_activity_1+40),\
				Vector2(origin.x+first_bar_spacing+bar_width/2.0+1,\
				origin.y-neuron_activity_1),\
				line_color,2.0,true)		
				
			draw_small_arrow(Vector2(origin.x+first_bar_spacing+bar_width/2.0,\
				origin.y-neuron_activity_1+40),\
				Vector2(0,1), line_color)								

		elif animation_count == 1:
			# explain basis set
			if get_node_or_null("Instruction_one"):
				get_node("Instruction_one").queue_free()
				get_node("example_sprite1").queue_free()

			draw_rect(Rect2(origin_up.x, \
				origin_up.y - 120, 380, \
				50), illustration_region_color,true,1.0,true)
	
			if !get_node_or_null("Instruction_two"):
				var node = Label.new()
				node.name = "Instruction_two"
				add_child(node)	
			get_node("Instruction_two").set_global_position(\
				Vector2(400,50))
			get_node("Instruction_two").text = \
				"Basis set is a weight function of the neuron's response\nThe larger the gain, the more weight to side angles"
			get_node("Instruction_two").add_color_override("font_color", ColorN("Black"))	
			get_node("Instruction_two").add_font_override("font",dynamic_font)

		elif animation_count == 2:
			# explain posterior
			if get_node_or_null("Instruction_two"):
				get_node("Instruction_two").queue_free()		

			draw_rect(Rect2(origin_up.x, \
				origin_up.y - 70, 380, \
				70), illustration_region_color,true,1.0,true)
	
			if !get_node_or_null("Instruction_three"):
				var node = Label.new()
				node.name = "Instruction_three"
				add_child(node)	
			get_node("Instruction_three").set_global_position(\
				Vector2(280,146))
			get_node("Instruction_three").text = \
				"Posterior is a predicted head angle,\nfrom the stimulus pattern of neurons"
			get_node("Instruction_three").add_color_override("font_color", ColorN("Black"))	
			get_node("Instruction_three").add_font_override("font",dynamic_font)

		elif animation_count == 3:
			# explain noise 
			if get_node_or_null("Instruction_three"):
				get_node("Instruction_three").queue_free()

			draw_rect(Rect2(origin.x+x_limit-5, \
				origin.y - y_limit+23, 27, \
				30), illustration_region_color,true,1.0,true)
	
			if !get_node_or_null("Instruction_four"):
				var node = Label.new()
				node.name = "Instruction_four"
				add_child(node)	
			get_node("Instruction_four").set_global_position(\
				origin+Vector2(0.3*x_limit,-1.1*y_limit))
			get_node("Instruction_four").text = \
				"Turn on the Poisson noise,\nPopulation vector and posterior peak \nwill deviate from the real head angle"
			get_node("Instruction_four").add_color_override("font_color", text_color)	
			get_node("Instruction_four").add_font_override("font",dynamic_font)

	elif animation_count >= 4:
		if get_node_or_null("Instruction_four"):
			get_node("Instruction_four").queue_free()
			get_node("button").queue_free()
		animation_finish = true

#########################################################

func tuning_function(preferred_index, head_angle_value):
	var neuron_number = 8
	var sigma = PI/neuron_number  # the angle spacing between preferred stimuli

	var preferred_direction = get_the_preferred_vec(preferred_index)
	var head_vector = Vector2(cos(head_angle_value),-sin(head_angle_value)) 
	var diff_angle = acos(preferred_direction.dot(head_vector) / \
		(length_of_vector(preferred_direction)*length_of_vector(head_vector))) 
	var gain = 0.03	
	var tuning_value = 1.0/gain * exp(-(diff_angle*diff_angle)/(2.0*sigma*sigma))
	
	return tuning_value

func get_the_preferred_vec(index):
	var arrow
	arrow = Vector2(100*cos(deg2rad(index*45)),-100*sin(deg2rad(index*45)))   # y is positive downwards
	return arrow

func length_of_vector(vector):
	var length = sqrt(pow(vector.x,2)+pow(vector.y,2))
	return length
	
func draw_small_arrow(location, direction, color):
	direction = direction.normalized()
	var b = location + direction.rotated(PI*4.0/5.0)*10
	draw_line(b, location, color, 1.5, true)
	var c = location + direction.rotated(-PI*4.0/5.0)*10
	draw_line(c, location, color, 1.5, true)
