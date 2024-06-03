@tool
extends Control
class_name BreakScreen_Transition

@export var mesh:MeshInstance2D
@export var seed:int = 0
@export var magnitude:float = 1
@export var rotationMagnitude:float = 1
@export_range(0, 1) var state:float = 0
@export var transparency:Curve

var _lastTexture = null
var _lastState = -1.0
var noise:FastNoiseLite = null
var splices:Vector2i = Vector2i(16,9)

func setTexture(texture:Texture):
	mesh.texture = texture
	seed = randi()

func _process(delta):
	if(noise==null): noise = FastNoiseLite.new()
	if(_lastTexture==mesh.texture && _lastState==state): return
	if !Engine.is_editor_hint():
		splices = Global.Config.currentScreenResolution().aspectRatio
	# Make color
	var c = Color(1, 1, 1, transparency.sample(state))
	# Set position
	mesh.position = Vector2(0,0)
	# Set mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mesh.material)
	var pixelWidth = size.x / splices.x
	var pixelHeight = size.y / splices.y
	var tileWidth = 1.0 / splices.x
	var tileHeight = 1.0 / splices.y
	for iy in range(splices.y):
		var ty = iy * tileHeight
		var by= iy * pixelHeight
		for ix in range(splices.x):
			st.set_color(c)
			var tx = ix * tileWidth
			var bx= ix * pixelWidth
			# Add 6 vertices I guess? :weary:
			var x = _getDisplacementX(bx,ix,iy,0)
			var y = _getDisplacementY(by,ix,iy,0)
			var r = _getRotation(ix,iy,0)
			
			var vertices1:Array[Vector3] = []
			vertices1.append(Vector3(x,y,0))
			vertices1.append(Vector3(x+pixelWidth,y,0))
			vertices1.append(Vector3(x,pixelHeight+y,0))
			var uvs1:Array[Vector2] = []
			uvs1.append(Vector2(tx,ty))
			uvs1.append(Vector2(tx+tileWidth,ty))
			uvs1.append(Vector2(tx,ty+tileHeight))
			
			vertices1 = _rotateTriangle(r, vertices1)
			_addTriangle(st, vertices1, uvs1)
			
			x = _getDisplacementX(bx,ix,iy,1)
			y = _getDisplacementY(by,ix,iy,1)
			r = _getRotation(ix,iy,1)
			
			var vertices2:Array[Vector3] = []
			vertices2.append(Vector3(x+pixelWidth,y,0))
			vertices2.append(Vector3(x+pixelWidth,pixelHeight+y,0))
			vertices2.append(Vector3(x,pixelHeight+y,0))
			var uvs2:Array[Vector2] = []
			uvs2.append(Vector2(tx+tileWidth,ty))
			uvs2.append(Vector2(tx+tileWidth,ty+tileHeight))
			uvs2.append(Vector2(tx,ty+tileHeight))
			
			vertices2 = _rotateTriangle(r, vertices2)
			_addTriangle(st, vertices2, uvs2)
	mesh.mesh = st.commit()
	# Set variables
	_lastTexture = mesh.texture
	_lastState = state

func _rotateTriangle(angle:float,vertices:Array[Vector3]):
	if(vertices.size() == 0): return vertices
	var center:Vector3 = Vector3()
	for v in vertices:
		center += v
	center /= vertices.size()
	var result:Array[Vector3] = []
	for v in vertices:
		var ref = v-center
		var vec = Vector2(ref.x,ref.y).rotated(angle)
		ref = Vector3(vec.x,vec.y,ref.z)
		result.append(ref+center)
	return result

func _addTriangle(st, vertices, uvs):
	st.set_uv(uvs[0])
	st.add_vertex(vertices[0])
	st.set_uv(uvs[1])
	st.add_vertex(vertices[1])
	st.set_uv(uvs[2])
	st.add_vertex(vertices[2])

func _getDisplacementX(base:float,ix:int,iy:int,n:int):
	var idx = ix + (iy*splices.x*2) + n
	var r = pseudorand(idx) * magnitude
	var displace = state + (state * r)
	if (n==1): displace *= -1
	return base + displace * size.x

func _getDisplacementY(base:float,ix:int,iy:int,n:int):
	var idx = ix + (iy*splices.x*2) + n
	var r = pseudorand(idx) * magnitude
	var displace = state + (state * r)
	return base + displace * size.y

func _getRotation(ix:int,iy:int,n:int):
	var idx = ix + (iy*splices.x*2) + n
	var r = pseudorand(idx) * rotationMagnitude
	return state + (state * r)

func pseudorand(i:int):
	noise.seed = seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	var sample:float = 3.943 * i
	return noise.get_noise_1d(sample)
