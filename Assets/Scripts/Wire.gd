extends Path3D
class_name Wire
var start
var end




func setCurve(path:Array[wireGrid.wireNode]):
	const defaulthandle = .5
	curve.clear_points()
	#TODO #change vert location to sink the end in a bit?
	var vertpos = wireGrid.toRealCoords(path[0].gridCoords)
	curve.add_point(vertpos,Vector3(0,0,0),wireGrid.getHandleCoords(path[0].gridCoords,defaulthandle)-vertpos)
	for i in range(path.size()-2):
		var innode:wireGrid.wireNode = path[i+1]
		var outnode:wireGrid.wireNode = path[i+2]
		vertpos = wireGrid.toRealCoords(innode.gridCoords)
		curve.add_point(vertpos, wireGrid.getHandleCoords(innode.gridCoords,defaulthandle)-vertpos,wireGrid.getHandleCoords(outnode.gridCoords, defaulthandle)-vertpos)
	
	#add end
	vertpos = wireGrid.toRealCoords(path[path.size()-1].gridCoords)
	curve.add_point(vertpos,Vector3(0,0,0),wireGrid.getHandleCoords(path[path.size()-1].gridCoords,defaulthandle)-vertpos)
