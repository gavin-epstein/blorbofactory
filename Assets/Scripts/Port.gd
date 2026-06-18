extends Node3D
class_name Port

#TODO accomodate the fact that a port can belong to 2 factories
# ^ use linkedport
var content:Product #product
var input
var output
var linkedport: Port
var type:Product.Types

static func Link(a:Port, b:Port):
	a.linkedport = b
	b.linkedport = a

func isFull()->bool:
	return type==Product.Types.Nothing or content!=null or (linkedport!=null and linkedport.content!=null)

func generate(type:Product.Types, input:bool ):
	self.type = type
	if self.type == Product.Types.Nothing:
		self.visible = false
	if input:	
		$inarrow.visible =  true 
		$outarrow.visible = false
	else:
		$inarrow.visible =  false 
		$outarrow.visible = true
	if self.type == Product.Types.Blop:
		$sphereport.visible = true
	elif self.type == Product.Types.Tungo:
		$cubeport2.visible = true
	#TODO repetitive
	
func empty():
	content.queue_free()
	content = null	
	if linkedport != null:
		linkedport.content = null
	
func addContent(added:Product):
	content = added
	if linkedport != null:
		linkedport.content = added
