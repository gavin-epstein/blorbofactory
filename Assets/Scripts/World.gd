extends Node3D
const sqrt3 = 1.73205080757 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


static func toGridCoords(c:Vector3)->Vector2i:
	var gridx = floor(c.z+.5)
	var gridy = .5*c.z + sqrt3*c.x/2
	gridy = floor(gridy+.5)
	return Vector2i(gridx, gridy)

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
