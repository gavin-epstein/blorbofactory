extends Node3D
class_name Factory
var ports:Array[Port]=[]
var recipe_in:Array[Product]
var recipe_out:Array[Product]
var progress= tickedVar.new("float",0,0)
var processing_time=10 #in ticks
var base_processing_time=10
var isProcessing:bool
var controller
func _ready():
	ports = [$Port0,$Port1,$Port2, $Port3,$Port4, $Port5]
	for i in range(6):
		if recipe_in[i].type!=Product.Types.Nothing:
			ports[i].generate(recipe_in[i].type, true)
			ports[i].output = self
		elif recipe_out[i].type!=Product.Types.Nothing:
			ports[i].generate(recipe_out[i].type, false)
			ports[i].input = self
		else:
			ports[i].generate( Product.Types.Nothing, true)


func frame(sincelasttick):
	#update progress bar with progress.getValue(sincelasttick)
	print(progress.getValue(sincelasttick)/processing_time)
	$factoryprogress/Cylinder_001.set_instance_shader_parameter("progress", progress.getValue(sincelasttick)/processing_time)

func gametick(delta):
	if isProcessing:
		if progress.getValue(delta)>=processing_time:
			if addProducts():
				isProcessing=false
		else:			
			progress.add(1)
	if not isProcessing: #deliberately not an else 
		if removeIngredients():
			isProcessing=true
	

func removeIngredients()-> bool:
	
	for port in ports:
		if port.output==self:
			if not port.isFull():
				return false
				
	
	var fleezy = 0
	for port in ports:
		if port.output== self:
			if port.content.isFleezy:
				fleezy+=1
			if port.content.isBiggo:
				port.content.isBiggo = false
				port.content.scale *= .5
			else:
				port.content.queue_free()
				port.content = null		
	progress= tickedVar.new("float",0,1)
	processing_time = base_processing_time*pow(.8, fleezy)
	return true

func addProducts():
	progress = tickedVar.new("float",0,0)
	#add things to ouput ports
	#check that there's room for all products
	for port in ports:
		if port.output!=self and port.type!=Product.Types.Nothing:
			if port.isFull():
				return false
	for i in range(len(ports)):
		if recipe_out[i]!=null:
			var newProduct = recipe_out[i]
			controller.createProduct(newProduct.type, ports[i], newProduct.isZoomy,newProduct.isBiggo, newProduct.isFleezy)
	return true

func generate(inputs:Array[Product], outputs:Array[Product]):
	self.recipe_in = inputs
	self.recipe_out = outputs
	
