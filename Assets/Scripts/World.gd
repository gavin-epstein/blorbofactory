extends Node3D
const sqrt3 = 1.73205080757 
const neighborcoords = [Vector2i(1,0), Vector2i(0,1), Vector2i(-1,1), Vector2i(-1,0),Vector2i(0,-1), Vector2i(1,-1) ]
@onready var cam = $Camera3D;
# Called when the node enters the scene tree for the first time.
func _ready():
	global.world = self;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



static func toGridCoords(c:Vector3)->Vector2i:
	var gridy = floor(c.z+.5)
	var gridx = .5*c.z + sqrt3*c.x/2
	gridy = floor(gridy+.5)
	return Vector2i(gridx, gridy)
static func fromGridCoords(v:Vector2i)->Vector3:
		var x = sqrt3*v.x/2
		var z = v.y + v.x/2.0
		return Vector3(x,0.0,z)

func cast_mouse_to_wire()-> Vector4i:
	var mousepos = get_viewport().get_mouse_position()
	var origin = cam.project_ray_origin(mousepos)
	var direction = cam.project_ray_normal(mousepos)
	var steppos =  origin;
	while steppos.y>-2:
		var gridcoords = wireGrid.fromRealCoords(steppos);
		if gridcoords.z<=0 or gridcoords.z <wireGrid.MAXHEIGHT  and $Wires/wireGrid.hasNode(gridcoords):
			return gridcoords
		steppos += direction*wireGrid.HEIGHTINTERVAL;
	return Vector4i(0,0,0,0)
func cast_mouse_debug()-> Vector3:
	var mousepos = get_viewport().get_mouse_position()
	var origin = cam.project_ray_origin(mousepos)
	var direction = cam.project_ray_normal(mousepos)
	var steppos =  origin;
	while steppos.z>-2:
		var gridcoords = wireGrid.fromRealCoords(steppos);
		if gridcoords.z<=0 or gridcoords.z <wireGrid.MAXHEIGHT  and $Wires/wireGrid.hasNode(gridcoords):
			return steppos
		steppos += direction*wireGrid.HEIGHTINTERVAL;
	return steppos


func gametick(delta):
	for object in $Factories.get_children():
		object.gametick(delta)
		pass
	#for each ticked object in model, call its gametick(delta)
	#factories first, then ports, then wires
	
func frame(sincelasttick):
	for object in $Factories.get_children():
		object.frame(sincelasttick)
		pass
	#for each procedurally animated object in model, call its frame(sincelasttick)
	#factories first, then wires
	
	#TODO: optimize more efficient method of storing factories
func getFactoryAt(gridcoords:Vector2i):
	for factory in $Factories.get_children():
		if toGridCoords(factory.global_position) ==gridcoords:
			return factory


func trackMouse(wiremode:bool = true):
	$MouseIndicator.visible = true
	if wiremode:
		var gridpos = cast_mouse_to_wire()
		$MouseIndicator.position = wireGrid.toRealCoords(gridpos+Vector4i(0,0,1,0))-$Wires/wireGrid.position;
		$MouseIndicator2.position = cast_mouse_debug()
		#print($MouseIndicator.position)
func hideTracker():
	$MouseIndicator.visible = false
