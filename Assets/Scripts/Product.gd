extends Node3D
class_name Product #Blorpo
const productScene = preload("res://Assets/Scenes/Product.tscn")
enum Types{
	Nothing,
	Blop,
	Tungo,
	Speeble,
	Flooper,
	ZeepZeep,
	Pazango,
	PozzyWozzyFleepDooblescup
}
var type:Types
var isZoomy #fast
var isBiggo #counts double
var isFleezy #reduces production time

func generate(type, isZoomy = false, isBiggo= false, isFleezy = false):
	self.type = type
	self.isZoomy = isZoomy
	self.isBiggo = isBiggo
	self.isFleezy  = isFleezy
	
	if self.type == Product.Types.Blop:
		$sphere.visible = true
	elif self.type == Product.Types.Tungo:
		$yellowshape.visible= true
	#TODO rest of shapes
	
	if self.isBiggo:
		self.scale = self.scale*2
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.isFleezy:
		self.rotate(Vector3.UP, delta*.1)

	
func copy():
	var newcopy = productScene.instantiate()
	newcopy.generate(type,isZoomy,isBiggo,isFleezy)
	return newcopy
