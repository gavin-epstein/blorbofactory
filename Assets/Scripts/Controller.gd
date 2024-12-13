extends Node
var sincelasttick=0;
var wiregrid:wireGrid
var _ghostWire:Wire
var _wireDijkstra:wireGrid.Dijkstra
var _wireStart
var World
const factoryScene = preload("res://Assets/Scenes/Factory.tscn")
const wireScene = preload("res://Assets/Scenes/Wire.tscn")
const productScene = preload("res://Assets/Scenes/Product.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	wiregrid = wireGrid.new()
	World = get_parent().find_child("World")
	test()
	
func test():
	var blop = createProduct(Product.Types.Blop, null)
	var bigblop = createProduct(Product.Types.Blop, null, false, true, false)
	var nothing = createProduct(Product.Types.Nothing, null)
	var inputs: Array[Product] = [blop, blop, nothing, nothing, nothing,nothing]
	var outputs: Array[Product] =[nothing, nothing, nothing, bigblop, nothing, nothing]
	var factory = createFactory( inputs, outputs, Vector2(0,0))
	factory.base_processing_time = 30
	
	
	
	createProduct(blop.type,factory.ports[0])
	createProduct(blop.type,factory.ports[1])
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sincelasttick+=delta
	while sincelasttick>1.0/tickedVar.TPS:
		_gametick(sincelasttick)
		#print(sincelasttick)
		sincelasttick-=1.0/tickedVar.TPS
	#for each ticked object in model, call its frame(sincelasttick)
	World.frame(sincelasttick);
	#adding wire
	if _ghostWire!=null:
		drawGhostWire()
		pass
	#adding factory
func _gametick(delta):
	World.gametick(delta)

func addWireStart(start:Node3D):
	_ghostWire = Wire.new()
	var startspace = wireGrid.fromRealCoords(start.position)
	#actually want to start across from it bc it will be blocked
	startspace = wireGrid.crossHexNeighbor(startspace)
	startspace = wiregrid.nodeAt(startspace)
	_wireStart = start
	_wireDijkstra = wireGrid.Dijkstra.new(wiregrid.grid, startspace)
func drawGhostWire():
	
	#TODO get end based on mouse projection into world space
	var end;
	var path:Array = _wireDijkstra.getPath(end)
	
	pass
func addWireEnd(end:Node3D):
	var path = _wireDijkstra.getPath(end)
	var wire:Wire = wireScene.instantiate()
	wire.setCurve(path)
	for node in path:
		node.contents.append(wire)
	World.get_child("Wires").add_child(wire)
	pass
func cancelGhostWire():
	_wireDijkstra.clear()
	_wireDijkstra = null
	_ghostWire = null
func createProduct(type:Product.Types, container, isZoomy = false, isBiggo= false, isFleezy = false):
	var product = productScene.instantiate()
	product.generate(type, isZoomy, isBiggo, isFleezy)
	if container != null:
		World.find_child("Products").add_child(product)
		product.global_position = container.global_position
		container.content = product
		
	return product
	
func createFactory(inputs: Array[Product], outputs: Array[Product], location:Vector2):
	var factory = factoryScene.instantiate()
	factory.generate(inputs, outputs)
	factory.controller = self
	factory.global_position = Vector3(location.x, 0, location.y)
	World.find_child("Factories").add_child(factory)
	
	return factory
