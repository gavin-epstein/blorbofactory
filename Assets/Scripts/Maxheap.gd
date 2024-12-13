class_name Maxheap
var compare:Callable
var data =[]
func _init(compare):
	self.compare=compare
func getLeft(index:int)->int:
	return 2*index+1
func getRight(index:int)->int:
	return 2*index+2
func push(value):
	data.append(value)
	sift_up(data.size()-1)
func pop():
	var value=data[0]
	data[0]=data.pop_back()
	sift_down(0)
	
func sift_up(i):
	var current = data[i]
	var parenti =   floor((i-1)/2)
	if compare.callv([current,data[parenti]])>0:
		data[i]= data[parenti]
		data[parenti] = current
		if parenti>0:
			sift_up(parenti)
func sift_down(i):
	var current = data[i]
	var lefti = 2*i+1
	var righti =2*i+2
	if lefti >= data.size():
		return
	var biggerchild = lefti
	if righti<data.size() and compare.callv([data[lefti], data[righti]])<0:
		biggerchild = righti
	if compare.callv([current, data[biggerchild]])<0:
		data[i] = data[biggerchild]
		data[biggerchild]=current
		sift_down(biggerchild)
		
