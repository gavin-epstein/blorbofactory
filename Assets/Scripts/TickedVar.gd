class_name tickedVar
static var TPS=10
var _last
var _target
var current
var _type

func _init(type:String, last,target = null):
	_type=type
	_last=last
	current=last
	_target=target
	if _target == null:
		_target=last
	
func tick(newTarget):
	_last=current
	_target=newTarget

func getValue(delta):
	
	if _type == "float":
		current =  _last +( _target-_last)*delta*TPS
	elif _type == "Vector":
		current =  _last.lerp(_target, delta*TPS)
	return current
	
func add(value):
	tick(_target+value)
	
