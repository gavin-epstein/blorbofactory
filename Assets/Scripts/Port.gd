extends Node3D
class_name Port

#TODO accomodate the fact that a port can belong to 2 factories
var content:Product #product
var input
var output
var linkedport
var type:Product.Types
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
	
	
	
