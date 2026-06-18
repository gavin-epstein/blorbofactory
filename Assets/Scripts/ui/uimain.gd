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
				stoptracking()
				#global.controller.addWireStart(;
	elif event is InputEventMouseMotion:
		if tracking == trackingstates.WIRESTART:
			global.world.trackMouse()

func stoptracking():
	tracking = trackingstates.NONE
	global.world.hideTracker();
