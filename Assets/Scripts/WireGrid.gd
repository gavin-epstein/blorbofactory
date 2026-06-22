class_name	wireGrid
extends Node3D
var grid = {}
const HEIGHTINTERVAL = .3
const MAXHEIGHT=7
const sqrt3 = 1.73205080757 

class wireNode:
	var prev
	var neighbors
	var dist=0;
	var gridCoords:Vector4i #[x->hexgridx, y->hexgridy, z-> height, w->hexgrid->rotation]
							#[hexgridx -> worldz, hexgridy -> world sqrt3/2 x + .5 z, height -> world y
	var contents = []
	func _init(ingridCoords):
		gridCoords = ingridCoords
	func mark(other, distance):
		prev=other
		dist=distance
	func unmark():
		prev=null
		dist =0
	func impassable():
		return contents.size()!=0


	#get node if there is one, else make it
func nodeAt(gridCoords:Vector4i ) -> wireNode:
	if grid.has(gridCoords):
		return grid[gridCoords]
	var node =wireNode.new(gridCoords)
	grid[gridCoords]=node
	return node
func hasNode(gridCoords:Vector4i)->bool:
	return  grid.has(gridCoords) and grid[gridCoords].impassable();
class Dijkstra: #TODO replace with A* when grid is mostly empty
	const MAXSTEPS = 500 #most nodes that will be explored PER FRAME
	var _start:wireNode
	var _ends:Array[wireNode]
	var _heap:Maxheap
	var _parent:wireGrid
	var _steps
	func _init(start:wireNode, parent:wireGrid):
		_ends =[]
		_parent=parent
		_heap=Maxheap.new(compnodes)
		setStart(start)
	func compnodes(a:wireNode, b:wireNode)	:
		return b.dist - a.dist	
	func setStart(start):
		_start = start
		start.prev = start
		_steps = 0
		clear()
		_heap.push(start)
		#for i in range(3):
			#iterate()
	func addEnd(end):
		if end not in _ends:
			_ends.append(end)
		var _cursteps =0
		while end.prev==null  and _heap.size()>0:
			#print("size:",_heap.size())
			_cursteps+=1;
			iterate()
			if _cursteps >= MAXSTEPS:
				print("max exceeded, total steps:", _steps)
				return false
				
		print("steps:", _steps)
		return true
	func clear():
		for node in _parent.grid.values():
			node.unmark()
	func iterate():
		_steps+=1
		var next = _heap.pop()
		#print(next.gridCoords, next.dist)
		if next.impassable() and not next == _start:
		#	print("Impassable at:" , next.gridCoords)
			return 
		if abs(next.gridCoords.x )> global.world.MAXEXTENTS or abs(next.gridCoords.y)> global.world.MAXEXTENTS:
			return
		for neigh:wireNode in _parent.getNeighbors(next):
			if neigh.prev ==null:
				neigh.mark(next, next.dist+wireGrid.distbetween(neigh.gridCoords,next.gridCoords ) )
				_heap.push(neigh)
				#print("size:", _heap.size())
		return  #continue
	func getPath(end:wireNode)->Array[wireNode]:
		if end.prev==null:
			addEnd(end)
		
		if end.prev == null:
			return []
			#for node:wireNode in _parent.grid.values():
				#if node.prev != null:
					##print(node.gridCoords)
					#end = node
					#break
		var current:wireNode = end
		var path:Array[wireNode]=[]
		while current != _start:
			path.push_back(current)
			current = current.prev
		path.push_back(_start)
		path.reverse()
		return path
static func distbetween(c1:Vector4i, c2:Vector4i)->float:
	if c1.x ==c2.x and c1.y == c2.y:
		#same hex
		var between  = toRealCoords(c1)- toRealCoords(c2)
		if c1.z==c2.z:
			return between.length()+.1
		else:
			return between.length()+1 #each extra hex crossing costs 1, so that up up up and over not too cheap
	elif crossHexNeighbor(c1) == c2:
		return 0 #touching across neighboring hexes
	else:
		return INF
static func toRealCoords(gridcoords:Vector4i)-> Vector3:
	return getHandleCoords(gridcoords,0)
static func fromRealCoords(c:Vector3)->Vector4i:
	var gridxy = World.toGridCoords(c)
	var gridx = gridxy.x
	var gridy = gridxy.y 
	var height = (c.y / HEIGHTINTERVAL) -.1
	height = clampi(height,0,MAXHEIGHT)
	var hexcenter = World.fromGridCoords(gridxy)
	#zero angle is -z
	var angle = -Vector2(0,-1).angle_to(Vector2(c.x,c.z)-Vector2(hexcenter.x, hexcenter.z))
	
	#var hexcenter =getHandleCoords(Vector4i(gridx,gridy,height,0),1)
	#var tozeroangle = getHandleCoords(Vector4i(gridx,gridy,height,0),0)
	#print(tozeroangle - hexcenter)
	#var angle = (tozeroangle-hexcenter).angle_to((c-hexcenter)) #{0, 2*PI}
	var w = (int(round(angle*3/PI))+6)%6
	return Vector4i(gridx,gridy,height,w)
static func getHandleCoords(gridcoords:Vector4i, handlelength)-> Vector3: 
	var xyz = World.fromGridCoords(Vector2i(gridcoords.x,gridcoords.y))
	var x = xyz.x#gridcoords.x + .5*gridcoords.y;
	var z = xyz.z#sqrt3*gridcoords.y/2
	var height = HEIGHTINTERVAL * (gridcoords.z+.1)
	var out:Vector3 = Vector3(x,height,z)
	var tohexedge:Vector3 = Vector3(0,0,-.5)*(1-handlelength)
	tohexedge = tohexedge.rotated(Vector3(0,1,0),PI/3*gridcoords.w)
	return out + tohexedge
static func crossHexNeighbor(c: Vector4i)-> Vector4i:
	var offset
	if c.w ==0:
		offset = Vector2i(0,-1)
	elif c.w ==1:
		offset = Vector2i(-1,0)
	elif c.w ==2:
		offset = Vector2i(-1,1)
	elif c.w ==3:
		offset = Vector2i(0,1)
	elif c.w ==4:
		offset = Vector2i(1,0)
	elif c.w ==5:
		offset = Vector2i(1,-1)
	return Vector4i(c.x+offset.x, c.y+offset.y, c.z, (c.w+3)%6)
func getNeighbors(gridNode):
	if gridNode.neighbors !=null:
		return gridNode.neighbors
	gridNode.neighbors = []
	
	var c = gridNode.gridCoords
	var coords = crossHexNeighbor(c)
	gridNode.neighbors.append(nodeAt(coords))
	#within hex
	for z in range(MAXHEIGHT):
		for w in range(6):
			if z!=c.z and w!=c.w:	 
				coords = Vector4i(c.x, c.y, z, w)
				gridNode.neighbors.append(nodeAt(coords))	
	for z in range(c.z-1,-1,-1):
		coords = Vector4i(c.x, c.y, z, c.w)
		var neigh = nodeAt(coords)
		gridNode.neighbors.append(neigh)
		if neigh.impassable():
			break
	for z in range(c.z+1,MAXHEIGHT):
		coords = Vector4i(c.x, c.y, z, c.w)
		var neigh = nodeAt(coords)
		gridNode.neighbors.append(neigh)
		if neigh.impassable():
			break
	#TODO
	var wleftoff = 1
	while wleftoff < 6:
		coords = Vector4i(c.x, c.y, c.z, (c.w+wleftoff)%6)
		var neigh = nodeAt(coords)
		gridNode.neighbors.append(neigh)
		if neigh.impassable():
			break
		wleftoff+=1
	var wrightoff = 1
	while wrightoff < 6-wleftoff:
		coords = Vector4i(c.x, c.y, c.z, (c.w-wrightoff+6)%6)
		var neigh = nodeAt(coords)
		gridNode.neighbors.append(neigh)
		if neigh.impassable():
			break
		wrightoff+=1
			
	return gridNode.neighbors
	
func resetNeighbors(gridNode:wireNode):
	var c = gridNode.gridCoords
	for z in range(MAXHEIGHT):
		var coords = Vector4i(c.x, c.y, z, c.w)
		nodeAt(coords).neighbors = null
	for woff in range(6):
		var coords = Vector4i(c.x, c.y, c.z, (c.w+woff)%6)
		nodeAt(coords).neighbors = null
