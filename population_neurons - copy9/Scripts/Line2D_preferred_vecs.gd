extends Line2D

####################
#      PARAMS
####################

# drawing
onready var title = get_node("../Label_title")

var center = Vector2(130,372)
var radius = 30

var color_cyan = Color(0.047, 0.35, 0.137, 1.0)
var color_pink = Color(0.898,0.22,0.588,1.0)
var color_axis = Color(0.34,0.84,0.75,0.8)

var legend_text_shift_x = 20
var legend_text_shift_y = 113

var shrink_radial_scale = 2.0/3.0

# paramter of population vectors and neuron activity
onready var population_vector_node
var population_vector = Vector2(0,0)
onready var activity_node = get_node("../Line2D_barGraph")
var neuron_activity
var head_angle

###########################

func _ready():
	population_vector_node = get_tree().get_root().find_node("Line2D_barGraph", true, false)
	neuron_activity = activity_node.neuron_activity
	
	# set a font
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font.size = 18
	# set the title	
	title.text = "Population Neurons Visualization"
	title.add_color_override("font_color", ColorN("Red"))
	title.add_font_override("font",dynamic_font)
	title.set_global_position(Vector2(114,25))	
	
func _process(_delta):
	population_vector = population_vector_node.population_vector
	neuron_activity = activity_node.neuron_activity
	update()
	
func _draw():	
	# draw a radial axis
	for i in range(1,5):
		draw_concentric_circle(center, radius+shrink_radial_scale*25*i, 1.0, color_axis)
	# 	
	draw_line(center+Vector2(radius*cos(deg2rad(112.5)),-radius*sin(deg2rad(112.5))),\
		center+Vector2(shrink_radial_scale*180*cos(deg2rad(112.5)),-180*shrink_radial_scale*sin(deg2rad(112.5))),\
		color_axis,1.0,true)
	draw_line(center+Vector2(shrink_radial_scale*180*cos(deg2rad(112.5)),-shrink_radial_scale*180*sin(deg2rad(112.5))),\
		center+Vector2(shrink_radial_scale*180*cos(deg2rad(112.5)),-shrink_radial_scale*180*sin(deg2rad(112.5)))+Vector2(-3,10),\
		color_axis,1.0,true)
	draw_line(center+Vector2(shrink_radial_scale*180*cos(deg2rad(112.5)),-shrink_radial_scale*180*sin(deg2rad(112.5))),\
		center+Vector2(shrink_radial_scale*180*cos(deg2rad(112.5)),-shrink_radial_scale*180*sin(deg2rad(112.5)))+Vector2(9,4.5),\
		color_axis,1.0,true)

	# set a font
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font.size = 14

	var dynamic_font_2 = DynamicFont.new()
	dynamic_font_2.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font_2.size = 18
	
	if !get_node_or_null("radial_label"):
		var node = Label.new()
		node.name = "radial_label"
		add_child(node)		
	get_node("radial_label").set_global_position(\
		center+Vector2(shrink_radial_scale*130*cos(deg2rad(112.5)),-shrink_radial_scale*130*sin(deg2rad(112.5)))+\
		Vector2(-30,-15))
	get_node("radial_label").text = "100"
	get_node("radial_label").add_color_override("font_color", color_axis)	
	get_node("radial_label").add_font_override("font",dynamic_font_2)
		
	# mark neuron locations inside the circle
	if !get_node_or_null("neuron_location_0"):
		var node = Label.new()
		node.name = "neuron_location_0"
		add_child(node)		
	get_node("neuron_location_0").set_global_position(\
		center+Vector2(20,-6))
	get_node("neuron_location_0").text = "0"
	get_node("neuron_location_0").add_color_override("font_color", color_axis)		
	get_node("neuron_location_0").add_font_override("font",dynamic_font)	

	if !get_node_or_null("neuron_location_90"):
		var node = Label.new()
		node.name = "neuron_location_90"
		add_child(node)		
	get_node("neuron_location_90").set_global_position(\
		center+Vector2(-5.5,-25))
	get_node("neuron_location_90").text = "90"
	get_node("neuron_location_90").add_color_override("font_color", color_axis)	
	get_node("neuron_location_90").add_font_override("font",dynamic_font)

	if !get_node_or_null("neuron_location_180"):
		var node = Label.new()
		node.name = "neuron_location_180"
		add_child(node)		
	get_node("neuron_location_180").set_global_position(\
		center+Vector2(-27,-6))
	get_node("neuron_location_180").text = "180"
	get_node("neuron_location_180").add_color_override("font_color", color_axis)	
	get_node("neuron_location_180").add_font_override("font",dynamic_font)

	if !get_node_or_null("neuron_location_270"):
		var node = Label.new()
		node.name = "neuron_location_270"
		add_child(node)		
	get_node("neuron_location_270").set_global_position(\
		center+Vector2(-8,14))
	get_node("neuron_location_270").text = "270"
	get_node("neuron_location_270").add_color_override("font_color", color_axis)	
	get_node("neuron_location_270").add_font_override("font",dynamic_font)

###########################################################

	# draw a circle of neurons
	draw_concentric_circle(center, radius, 1.0, color_cyan)
			
	# draw neurons and preferred vectors
	var theta = PI/4   # in radian
	var x = center.x
	var y = center.y
	for i in range(0,8):
		x = center.x + radius * cos(i*theta)
		y = center.y - radius * sin(i*theta)  # theta positive is downwards in Godot
		draw_preferred_vector(i, x, y, neuron_activity[i])
		draw_circle(Vector2(x,y), 3, color_cyan)

	# draw population vector
	var end_x = center.x + population_vector.x
	var end_y = center.y + population_vector.y
	draw_line(center, Vector2(end_x, end_y), \
		color_pink, 2.0, true)
	# anti-aliasing
	draw_line(Vector2(center.x, center.y), Vector2(end_x, end_y), \
		Color(0.898,0.22,0.588,0.3), 2.2, true)		
	draw_triangle(Vector2(end_x, end_y), population_vector, 6.5, \
		color_pink)	

	# a box of legend
	draw_rect(Rect2(center.x-legend_text_shift_x, center.y+legend_text_shift_y, 150, 51),\
		Color(1, 1, 1, 1),1.0,true)

	if !get_node_or_null("legend_basis"):
		var node = Label.new()
		node.name = "legend_basis"
		add_child(node)		
	get_node("legend_basis").set_global_position(\
		Vector2(center.x - legend_text_shift_x +10, \
		center.y+legend_text_shift_y+10))
	get_node("legend_basis").text = "- Preferred direction"
	get_node("legend_basis").add_color_override("font_color", color_cyan)

	if !get_node_or_null("legend_posterior"):
		var node = Label.new()
		node.name = "legend_posterior"
		add_child(node)		
	get_node("legend_posterior").set_global_position(\
		Vector2(center.x - legend_text_shift_x+10, \
		center.y +legend_text_shift_y+30))
	get_node("legend_posterior").text = "- Population vector"
	get_node("legend_posterior").add_color_override("font_color", color_pink)

####################################################

# draw arrows with defined directions
func draw_preferred_vector(index, start_x, start_y,activity):
	var arrow
	var end_x 
	var end_y
	arrow = shrink_radial_scale*Vector2(activity*cos(deg2rad(index*45)),-activity*sin(deg2rad(index*45)))
	# draw the vecs		
	end_x = start_x + arrow.x
	end_y = start_y + arrow.y
	draw_line(Vector2(start_x, start_y), Vector2(end_x, end_y), \
		color_cyan, 1.5, true)
	# anti-aliasing
	draw_line(Vector2(start_x, start_y), Vector2(end_x, end_y), \
		Color(0.047, 0.35, 0.137, 0.3), 1.7, true)
			
	draw_triangle(Vector2(end_x, end_y), arrow, 5, \
		color_cyan)

# draw a triangle on the 2d canvas
func draw_triangle(pos:Vector2, dir:Vector2, size, color):
	dir = dir.normalized()
	var a = pos + dir*size
	var b = pos + dir.rotated(2*PI/3)*size
	var c = pos + dir.rotated(4*PI/3)*size
	var points = PoolVector2Array([a,b,c])
	draw_polygon(points, PoolColorArray([color]))		

func draw_concentric_circle(center, radius, linewidth, color):
	var step = PI/99
	var circle_x
	var circle_y
	var next_x
	var next_y
	for i in range(99):
		circle_x = radius*cos(step*i)
		circle_y = -radius*sin(step*i)
		next_x = radius*cos(step*(i+1))
		next_y = -radius*sin(step*(i+1))
		draw_line(center+Vector2(circle_x,circle_y),center+Vector2(next_x,next_y),\
			color,linewidth,true)
	for i in range(99):
		circle_x = radius*cos(step*i)
		circle_y = radius*sin(step*i)
		next_x = radius*cos(step*(i+1))
		next_y = radius*sin(step*(i+1))
		draw_line(center+Vector2(circle_x,circle_y),center+Vector2(next_x,next_y),\
			color,linewidth,true)
