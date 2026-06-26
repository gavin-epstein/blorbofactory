extends Control
enum trackingstates {NONE=0,WIRESTART=1,WIREEND=2};
var tracking =trackingstates.NONE ;
func _ready() -> void:
	global.ui =  self;

func _process(delta: float) -> void:
	pass
func _on_new_wire_pressed() -> void:
	tracking = trackingstates.WIRESTART;

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if tracking == trackingstates.WIRESTART:
				#stoptracking()
				global.controller.addWireStart(global.world.cast_mouse_to_wire());
				tracking = trackingstates.WIREEND
			elif tracking == trackingstates.WIREEND:
				if global.controller.addWireEnd(global.world.cast_mouse_to_wire()):
					stoptracking()
	elif event is InputEventMouseMotion:
		if tracking == trackingstates.WIRESTART:
			global.world.trackMouse()
		if tracking == trackingstates.WIREEND:
			global.controller.drawGhostWire()
		pass
	else:
		if event.is_action("CamLeft"):
			global.world.Pan(Vector2(-1,0))
		elif event.is_action("CamRight"):
			global.world.Pan(Vector2(1,0))
		elif event.is_action("CamUp"):
			global.world.Pan(Vector2(0,1))
		elif event.is_action("CamDown"):
			global.world.Pan(Vector2(0,-1))

func stoptracking():
	tracking = trackingstates.NONE
	global.world.hideTracker();
