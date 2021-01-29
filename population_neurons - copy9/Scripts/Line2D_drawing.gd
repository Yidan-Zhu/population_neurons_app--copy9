extends Line2D

#####################
#       PARAM
#####################

# coordinate
var axes_origin = Vector2(220,210)
var bar_space = 45
var bar_width = 0
var first_bar_spacing = 0
var y_axis_length = 120
var x_axis_length = 390

# bar graph parameters
var neuron_number = 8

#############################

func _ready():
	pass

func _draw():
# draw the bar graph axes
	# x
	draw_line(Vector2(axes_origin.x, axes_origin.y), Vector2(axes_origin.x + x_axis_length,axes_origin.y),Color(0.25,0.25,0.25,1.0),1.5,true)
	draw_triangle(Vector2(axes_origin.x + x_axis_length,axes_origin.y),Vector2(1,0), 5, Color(0.25,0.25,0.25,1.0))
	# y
	draw_line(axes_origin, Vector2(axes_origin.x,axes_origin.y - y_axis_length),Color(0.25,0.25,0.25,1.0),1.5,true)
	draw_triangle(Vector2(axes_origin.x,axes_origin.y - y_axis_length),Vector2(0,-1),5,Color(0.25,0.25,0.25,1.0))

	# set a font
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font.size = 18

	# ticks
	for i in range(neuron_number+1):
		# x ticks
		if i!=0:
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

	# x-axis label
	if !get_node_or_null("Label_x_axis"):
		var node = Label.new()
		node.name = "Label_x_axis"
		add_child(node)		
	get_node("Label_x_axis").set_global_position( \
		Vector2(axes_origin.x + x_axis_length,axes_origin.y+12))		
	get_node("Label_x_axis").text = "Location of Neurons"
	get_node("Label_x_axis").add_font_override("font",dynamic_font)
	get_node("Label_x_axis").add_color_override("font_color", Color(0,0,0,1))

	# y-axis label
	if !get_node_or_null("Label_y_axis"):
		var node = Label.new()
		node.name = "Label_y_axis"
		add_child(node)		
	get_node("Label_y_axis").set_global_position( \
		Vector2(axes_origin.x - 30, axes_origin.y - y_axis_length- 21))		
	get_node("Label_y_axis").text = "Basis Set Function"
	get_node("Label_y_axis").add_font_override("font",dynamic_font)
	get_node("Label_y_axis").add_color_override("font_color", Color(0,0,0,1))
	
	
	# a box of legend
	draw_rect(Rect2(axes_origin.x + x_axis_length, axes_origin.y - y_axis_length, 92, 44),\
		Color(1, 250/255.0, 153/255.0, 1),1.0,true)

	if !get_node_or_null("legend_basis"):
		var node = Label.new()
		node.name = "legend_basis"
		add_child(node)		
	get_node("legend_basis").set_global_position(\
		Vector2(axes_origin.x + x_axis_length+8, \
		axes_origin.y - y_axis_length+27))
	get_node("legend_basis").text = "- Basis set"
	get_node("legend_basis").add_color_override("font_color", Color(0.9,0.5,0.1,1.0))

	if !get_node_or_null("legend_posterior"):
		var node = Label.new()
		node.name = "legend_posterior"
		add_child(node)		
	get_node("legend_posterior").set_global_position(\
		Vector2(axes_origin.x + x_axis_length+8, \
		axes_origin.y - y_axis_length+7))
	get_node("legend_posterior").text = "- Posterior"
	get_node("legend_posterior").add_color_override("font_color", ColorN("Blue"))

####################################################
# draw a triangle on the 2d canvas
func draw_triangle(pos:Vector2, dir:Vector2, size, color):
	dir = dir.normalized()
	var a = pos + dir*size
	var b = pos + dir.rotated(2*PI/3)*size
	var c = pos + dir.rotated(4*PI/3)*size
	var points = PoolVector2Array([a,b,c])
	draw_polygon(points, PoolColorArray([color]))	
