extends Line2D

# coordinate
var axes_origin = Vector2(320,470)
var bar_space = 28
var bar_width = 20
var first_bar_spacing = 18
var y_axis_length = 120
var x_axis_length = 390

# bar graph parameters
var neuron_number = 8

# noise check box
export var noise_flag = false
var check_box_y_shift = 30
var color_checkbox = Color(0.55,0.74,0.86,0.8)
var events = {}
onready var drawn_once_node = get_node("../Line2D_barGraph")

# animation finish
onready var animation_finish_node = get_node("../../CanvasLayer_start_instruction/Line2D_instruction")
var animation_finish = false

####################################

func _ready():
	pass
#	if !get_node_or_null("Explain"):
#		var node = Label.new()
#		node.name = "Explain"
#		add_child(node)	
#	get_node("Explain").set_global_position(Vector2(axes_origin.x + 0.2*x_axis_length,axes_origin.y - 1.3*y_axis_length))
#	get_node("Explain").text = "Neuron firing rate goes exponentially down when \nthe head angle is away from the preferred direction"
#	get_node("Explain").add_color_override("font_color", Color(0,0,0,1))

func _process(_delta):
	animation_finish = animation_finish_node.animation_finish
	
func _input(event):
	if event is InputEventScreenTouch and animation_finish:
		if event.pressed:
			events[event.index] = event
		else:
			events.erase(event.index)
	
	if event.position.x <= axes_origin.x+x_axis_length+15 and \
	   event.position.x >= axes_origin.x+x_axis_length and \
	   event.position.y >= axes_origin.y-y_axis_length+check_box_y_shift and \
	   event.position.y <= axes_origin.y-y_axis_length+check_box_y_shift+15:
		if event is InputEventScreenTouch and events.size() == 1 and animation_finish:
			noise_flag = !noise_flag
			update()
			if noise_flag == true:
				drawn_once_node.input_change = true 
			

func _draw():
	# draw the bar graph
	# axes
	draw_line(axes_origin, Vector2(axes_origin.x + x_axis_length,axes_origin.y),Color(0.25,0.25,0.25,1.0),1.5,true)
	draw_triangle(Vector2(axes_origin.x + x_axis_length,axes_origin.y),Vector2(1,0), 5, Color(0.25,0.25,0.25,1.0))
	draw_line(axes_origin, Vector2(axes_origin.x,axes_origin.y - y_axis_length),Color(0.25,0.25,0.25,1.0),1.5,true)
	draw_triangle(Vector2(axes_origin.x,axes_origin.y - y_axis_length),Vector2(0,-1),5,Color(0.25,0.25,0.25,1.0))

	# a check box for noise
	draw_rect(Rect2(axes_origin.x+x_axis_length,axes_origin.y-y_axis_length+check_box_y_shift,\
		15,15), color_checkbox, true)

	if !get_node_or_null("check_box"):
		var node = Label.new()
		node.name = "check_box"
		add_child(node)	
	get_node("check_box").set_global_position( \
		axes_origin+Vector2(x_axis_length+18,-y_axis_length+1.6+check_box_y_shift))		
	get_node("check_box").text = "Noise"
	get_node("check_box").add_color_override("font_color", Color(0,0,0,1))	

	# draw a √ if noise == true.
	if noise_flag:
		draw_a_tick(Vector2(axes_origin.x+x_axis_length+7.5, \
			axes_origin.y - y_axis_length + check_box_y_shift+ 10))

#############################################################

	# set a font
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font.size = 18

	# ticks
	for i in range(neuron_number):
		# x ticks
		draw_line(Vector2(axes_origin.x+first_bar_spacing+i*(bar_space+bar_width)+bar_width/2.0,axes_origin.y),\
			Vector2(axes_origin.x+first_bar_spacing+i*(bar_space+bar_width)+bar_width/2.0,axes_origin.y+5),\
			Color(0.25,0.25,0.25,1.0),1.0,true)
		# x tick labels	
		if !get_node_or_null("Label_(" + str(i)+",0)"):
			var node = Label.new()
			node.name = "Label_(" + str(i)+",0)"
			add_child(node)	
		if i == 0:
			get_node("Label_(" + str(i)+",0)").set_global_position(Vector2(axes_origin.x+first_bar_spacing+i*(bar_space+bar_width)+bar_width/2.0-4.5,axes_origin.y+12))
		elif i == 1 or i == 2:
			get_node("Label_(" + str(i)+",0)").set_global_position(Vector2(axes_origin.x+first_bar_spacing+i*(bar_space+bar_width)+bar_width/2.0-8,axes_origin.y+12))
		else:
			get_node("Label_(" + str(i)+",0)").set_global_position(Vector2(axes_origin.x+first_bar_spacing+i*(bar_space+bar_width)+bar_width/2.0-12,axes_origin.y+12))	
		get_node("Label_(" + str(i)+",0)").text = str(45*i)
		get_node("Label_(" + str(i)+",0)").add_color_override("font_color", Color(0,0,0,1))			
		get_node("Label_(" + str(i)+",0)").add_font_override("font",dynamic_font)
	# y tick
	for j in range(1,5):
		draw_line(Vector2(axes_origin.x, axes_origin.y - 25*j), \
			Vector2(axes_origin.x-5, axes_origin.y - 25*j), \
			Color(0.25,0.25,0.25,1.0),1.0,true)	
			
	# y tick labels
	if !get_node_or_null("Label_y"):
		var node = Label.new()
		node.name = "Label_y"
		add_child(node)	
	get_node("Label_y").set_global_position( \
		Vector2(axes_origin.x-32, axes_origin.y - 100 - 7))		
	get_node("Label_y").text = "100"
	get_node("Label_y").add_font_override("font",dynamic_font)
	get_node("Label_y").add_color_override("font_color", Color(0,0,0,1))
	
	# x-axis label
	if !get_node_or_null("Label_x_axis"):
		var node = Label.new()
		node.name = "Label_x_axis"
		add_child(node)		
	get_node("Label_x_axis").set_global_position( \
		Vector2(axes_origin.x + x_axis_length,axes_origin.y+12))		
	get_node("Label_x_axis").text = "Locations"
	get_node("Label_x_axis").add_font_override("font",dynamic_font)
	get_node("Label_x_axis").add_color_override("font_color", Color(0,0,0,1))

	# y-axis label
	if !get_node_or_null("Label_y_axis"):
		var node = Label.new()
		node.name = "Label_y_axis"
		add_child(node)		
	get_node("Label_y_axis").set_global_position( \
		Vector2(axes_origin.x - 58, axes_origin.y - y_axis_length- 27))		
	get_node("Label_y_axis").text = "Spike count"
	get_node("Label_y_axis").add_font_override("font",dynamic_font)
	get_node("Label_y_axis").add_color_override("font_color", Color(0,0,0,1))

####################################################
# draw a triangle on the 2d canvas
func draw_triangle(pos:Vector2, dir:Vector2, size, color):
	dir = dir.normalized()
	var a = pos + dir*size
	var b = pos + dir.rotated(2*PI/3)*size
	var c = pos + dir.rotated(4*PI/3)*size
	var points = PoolVector2Array([a,b,c])
	draw_polygon(points, PoolColorArray([color]))	

func draw_a_tick(location):
	draw_line(location, location+Vector2(-5,-5),ColorN("Black"),1.5,true)
	draw_line(location, location+Vector2(5.5,-11),ColorN("Black"),1.5,true)
