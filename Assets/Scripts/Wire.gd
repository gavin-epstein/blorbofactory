extends Path3D
class_name Wire
var start
var end
#const dot = preload("res://Assets/Models/cube.glb")

func _init():
	curve = Curve3D.new()

func setCurve(path:Array[wireGrid.wireNode]):
	const defaulthandle = .2
	curve.clear_points()
	var startpos = wireGrid.toRealCoords(path[0].gridCoords)
	self.position = startpos
	var prevpos = startpos
	for i in range(len(path)):
		var node = path[i]
		var vertpos:Vector3 = wireGrid.toRealCoords(node.gridCoords)
		var handlepos=  wireGrid.getHandleCoords(node.gridCoords,defaulthandle) - vertpos
		if i==0:
			curve.add_point(vertpos-2*startpos, -1.*handlepos, handlepos);
		elif i == len(path)-1:
			curve.add_point(vertpos-2*startpos, handlepos, -1*handlepos);
		elif (vertpos - prevpos).is_zero_approx():
			curve.add_point(vertpos-2*startpos, Vector3.ZERO, handlepos);
		else:
			curve.add_point(vertpos-2*startpos,handlepos, Vector3.ZERO);
