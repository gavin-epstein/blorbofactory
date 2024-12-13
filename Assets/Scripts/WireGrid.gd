class_name	wireGrid
extends Node3D
var grid = {}
const HEIGHTINTERVAL = .2
const MAXHEIGHT=7
const sqrt3 = 1.73205080757 

class wireNode:
	var prev
	var neighbors
	var dist
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
		return contents.size()==0


	#get node if there is one, else make it
func nodeAt(gridCoords:Vector4i, ):
	if grid[gridCoords]!=null:
		return grid[gridCoords]
	var node =wireNode.new(gridCoords)
	grid[gridCoords]=node
	return node
class Dijkstra:
	const MAXSTEPS = 200
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
		return a.dist - b.dist	
	func setStart(start):
		_start = start
		_steps = 0
		clear()
		_heap.push(start)
		for i in range(3):
			iterate()
	func addEnd(end):
		_ends.append(end)
		while end.prev==null and _steps<MAXSTEPS:
			iterate()
	func clear():
		for node in _parent.grid.values():
			node.unmark()
	func iterate():
		_steps+=1
		var next = _heap.pop()
		if next.impassable() and not next == _start:
			return
		for neigh:wireNode in _parent.getNeighbors(next):
			if neigh.prev ==null:
				neigh.mark(next, next.dist+wireGrid.distbetween(neigh.gridCoords,next.gridCoord ) )
				_heap.push(neigh)
	func getPath(end)->Array[wireNode]:
		if end not in _ends:
			addEnd(end)
		if end.prev == null:
			return []
		var current:wireNode = end
		var path=[]
		while current != _start:
			path.push_front(current)
			current = current.prev
		path.push_front(_start)
		return path
static func distbetween(c1:Vector4i, c2:Vector4i)->float:
	if c1.x ==c2.x and c1.y == c2.y:
		#same hex
		var between  = toRealCoords(c1)- toRealCoords(c2)
		return between.length()+1 #each extra hex crossing costs 1, so that up up up and over not too cheap
	elif (toRealCoords(c1)- toRealCoords(c2)).length_squared() < HEIGHTINTERVAL*HEIGHTINTERVAL + .01:
		return 0 #touching across neighboring hexes
	else:
		return INF
static func toRealCoords(gridcoords:Vector4i)-> Vector3:
	return getHandleCoords(gridcoords,0)
static func fromRealCoords(c:Vector3)->Vector4i:
	var gridx = floor(c.z+.5)
	var gridy = .5*c.z + sqrt3*c.x/2
	gridy = floor(gridy+.5)
	var height = c.y / HEIGHTINTERVAL
	var hexcenter = getHandleCoords(Vector4i(gridx,gridy,height,0),1)
	var tozeroangle = getHandleCoords(Vector4i(gridx,gridy,height,0),0)
	var angle = (tozeroangle-hexcenter).angle_to((c-hexcenter)) #{0, 2*PI}
	angle= floor(angle*3/PI)
	return Vector4i(gridx,gridy,height,angle)
static func getHandleCoords(gridcoords:Vector4i, handlelength)-> Vector3: 
	var x = gridcoords.x + .5*gridcoords.y;
	var y = sqrt3*gridcoords.y/2
	var height = HEIGHTINTERVAL * gridcoords.z
	var out:Vector3 = Vector3(y,height,x)
	var tohexedge:Vector3 = Vector3(0,0,.5)*(1-handlelength)
	tohexedge = tohexedge.rotated(Vector3(0,1,0),PI/3*gridcoords.w)
	return out + tohexedge
static func crossHexNeighbor(c: Vector4i)-> Vector4i:
	var offset
	if c.w ==0:
		offset = Vector2i(1,0)
	elif c.w ==1:
		offset = Vector2i(0,1)
	elif c.w ==2:
		offset = Vector2i(-1,1)
	elif c.w ==3:
		offset = Vector2i(-1,0)
	elif c.w ==4:
		offset = Vector2i(0,-1)
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
			if z!=c.z or w!=c.w:	 
				coords = Vector4i(c.x, c.y, z, w)
				gridNode.neighbors.append(nodeAt(coords))		
	return gridNode.neighbors
	
