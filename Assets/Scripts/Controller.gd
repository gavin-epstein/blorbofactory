extends Node
var sincelasttick=0;
var wiregrid:wireGrid
var _ghostWire:Wire
var _wireDijkstra:wireGrid.Dijkstra
const factoryScene = preload("res://Assets/Scenes/Factory.tscn")
const wireScene = preload("res://Assets/Scenes/Wire.tscn")
const productScene = preload("res://Assets/Scenes/Product.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	global.controller = self;
	wiregrid = $"../World/Wires/wireGrid"
	
	test()
	
func test():
	var blop = createProduct(Product.Types.Blop, null)
	var bigblop = createProduct(Product.Types.Blop, null, false, true, false)
	var tungo = createProduct(Product.Types.Tungo, null)
	var nothing = createProduct(Product.Types.Nothing, null)
	var inputs: Array[Product] = [blop, blop, nothing, nothing, nothing,nothing]
	var outputs: Array[Product] =[nothing, nothing, nothing, tungo, nothing, nothing]
	var factory = createFactory( inputs, outputs, Vector2(0,0))
	factory.base_processing_time = 30
	var factory2 = createFactory(rotateProductList(outputs,3), rotateProductList(inputs,3), Vector2(0,1))
	
	
	createProduct(tungo.type,factory2.ports[0])
	createProduct(bigblop.type,factory.ports[1])
	
	
	#for x in range(3):
		#for y in range(3):
			#for w in range(6):
				#var type = x+1
				#var p = productScene.instantiate()
				#p.generate(type)
				#p.set_scale(Vector3(.2,.2,.2))
				#global.world.add_child(p)
				#var  pos = wiregrid.toRealCoords(Vector4i(x,y,0,w))
				#pos.y =1
				#p.global_position =pos
				
				#p = productScene.instantiate()
				#p.generate(type)
				#global.world.add_child(p)
				#p.position = wireGrid.toRealCoords(Vector4i(x,y,0,2))
	#for w in range(6):
			#var p = productScene.instantiate()
			#p.generate(w+1)
			#p.global_position = wireGrid.toRealCoords(wireGrid.crossHexNeighbor( Vector4i(0,0,0,w)))
			#global.world.add_child(p)
			#p = productScene.instantiate()
			#p.generate(w+1)
			#p.global_position = wireGrid.toRealCoords( Vector4i(0,0,0,w))
			#global.world.add_child(p)
	#for x in range(24):
		#for z in range(24):
			#for y in range(1):
				##var doubleconv = World.toGridCoords(World.fromGridCoords(Vector2i(x,z)))
				##if doubleconv != Vector2i(x,z):
					##print(doubleconv, Vector2i(x,z))
				#var realpos = Vector3(.1*x,1,.1*z)
				#var p = productScene.instantiate()
				#p.generate(1)
				#var center = World.fromGridCoords(World.toGridCoords(realpos))
				#center.y = realpos.y
				#p.global_position = center
				#global.world.add_child(p)
				#
				#var gridpos= wireGrid.toRealCoords(wireGrid.fromRealCoords(realpos))
				#gridpos.y=realpos.y
				#drawLineDebug(realpos,gridpos)
				##drawLineDebug(realpos,center)
				
			
	addWireStart(Vector4i(0,0,0,1))
	addWireEnd(Vector4i(0,1,0,4))
	addWireStart(Vector4i(0,0,0,4))
	addWireEnd(Vector4i(0,1,0,2))
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sincelasttick+=delta
	while sincelasttick>1.0/tickedVar.TPS:
		_gametick(sincelasttick)
		#print(sincelasttick)
		sincelasttick-=1.0/tickedVar.TPS
	#for each ticked object in model, call its frame(sincelasttick)
	global.world.frame(sincelasttick);
	#adding wire
	
	#adding factory
func _gametick(delta):
	global.world.gametick(delta)

func addWireStart(startspace:Vector4i):
	_ghostWire = wireScene.instantiate()
	global.world.get_node("Wires").add_child(_ghostWire)
	#var startspace = wireGrid.fromRealCoords(start.global_position)

	#actually want to start across from it bc it will be blocked
	startspace = wireGrid.crossHexNeighbor(startspace)
	var startnode = wiregrid.nodeAt(startspace)
	_ghostWire.start = startnode
	_wireDijkstra = wireGrid.Dijkstra.new(startnode,wiregrid)
func drawGhostWire():
	
	#TODO get end based on mouse projection into world space
	var end = global.world.cast_mouse_to_wire();
	var path:Array[wireGrid.wireNode] = _wireDijkstra.getPath(wiregrid.nodeAt(end))
	if len(path) >0:
		_ghostWire.setCurve(path)
	
	pass
func addWireEnd(endspace:Vector4i)->bool:
	#var endspace =  wireGrid.fromRealCoords(end.global_position)
	endspace = wireGrid.crossHexNeighbor(endspace)
	var endnode = wiregrid.nodeAt(endspace)
	if endnode==_ghostWire.start:
		return false #fail to make wire
	_ghostWire.end = endnode
	var path = _wireDijkstra.getPath(endnode)
	while path.size()==0:
		await get_tree().create_timer(.1).timeout 
		path = _wireDijkstra.getPath(wiregrid.nodeAt(endspace))
	for node in path:
		print(node.gridCoords, " ", node.dist)
	_ghostWire.setCurve(path)
	for node in path:
		node.contents.append(_ghostWire)
		wiregrid.resetNeighbors(node)
	_ghostWire = null
	return true
func cancelGhostWire():
	_wireDijkstra.clear()
	_wireDijkstra = null
	_ghostWire = null
func createProduct(type:Product.Types, container, isZoomy = false, isBiggo= false, isFleezy = false):
	var product = productScene.instantiate()
	product.generate(type, isZoomy, isBiggo, isFleezy)
	if container != null:
		global.world.find_child("Products").add_child(product)
		product.global_position = container.global_position
		container.addContent(product)
		
	return product
	
func createFactory(inputs: Array[Product], outputs: Array[Product], location:Vector2i):
	var factory = factoryScene.instantiate()
	factory.generate(inputs, outputs)
	factory.controller = self
	global.world.find_child("Factories").add_child(factory)
	factory.global_position = global.world.fromGridCoords(location)
	
	
	#link ports
	for i in len(global.world.neighborcoords):
		var d = global.world.neighborcoords[i]
		var otherfac:Factory = global.world.getFactoryAt(location+d)
		if otherfac!=null:
			#print("linking "+str((i+5)%6) + " with " + str((i+2)%6))
			Port.Link(factory.ports[(i+5)%6], otherfac.ports[(i+2)%6])
		#add ports to wiregrid:
		wiregrid.nodeAt(Vector4i(location.x,location.y,0,i)).contents.append(factory.ports[i])
	return factory

static func rotateProductList(list:Array[Product],ind:int)->Array:
	var newlist:Array[Product] = [] 
	var l = len(list)
	for i in range(l):
		newlist.append(list[(i+ind)%l])
	return newlist

func drawLineDebug(p1:Vector3, p2:Vector3):
	var meshI:MeshInstance3D = MeshInstance3D.new()
	var mesh:ImmediateMesh = ImmediateMesh.new()
	meshI.mesh = mesh
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_add_vertex(p1)
	mesh.surface_add_vertex(p2)
	mesh.surface_end()
	global.world.add_child(meshI)
