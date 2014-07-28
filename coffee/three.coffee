scene = null
camera = null
renderer = null
initScene = () -> 
	# set the scene size
	WIDTH = 800
	HEIGHT = 800

	# set some camera attributes
	VIEW_ANGLE = 45
	ASPECT = WIDTH / HEIGHT
	NEAR = 0.1
	FAR = 10000

	# create a WebGL renderer, camera, and a scene
	renderer = new THREE.WebGLRenderer({antialias:true})
	camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR)
	scene = new THREE.Scene()

	# add and position the camera at a fixed position
	scene.add(camera)
	camera.position.z = 550
	camera.position.x = 0
	camera.position.y = 550
	camera.lookAt( scene.position )

	# start the renderer, and black background
	renderer.setSize(WIDTH, HEIGHT)
	renderer.setClearColor(0x000)

	# add the render target to the page
	$("body").append(renderer.domElement)

	# add a light at a specific position
	pointLight = new THREE.PointLight(0xFFFFFF)
	scene.add(pointLight)
	pointLight.position.x = 800
	pointLight.position.y = 800
	pointLight.position.z = 800

	# add a base plane on which well render our map
	planeGeo = new THREE.PlaneGeometry(10000, 10000, 10, 10)
	planeMat = new THREE.MeshLambertMaterial({color: 0x666699})
	plane = new THREE.Mesh(planeGeo, planeMat)

	# rotate it to correct position
	plane.rotation.x = -Math.PI/2
	scene.add(plane)

# add the loaded gis object (in geojson format) to the map
addGeoObject = (features) ->
	# keep track of rendered objects
	meshes = []
	averageValues = []
	totalValues = []


	# keep track of min and max, used to color the objects
	maxValueAverage = 0
	minValueAverage = -1

	# keep track of max and min of total value
	maxValueTotal = 0
	minValueTotal = -1

	# convert to mesh and calculate values
	for feature in features
		geoFeature = feature
		#console.log(feature)
		stringFeature = geo.path(geoFeature)
		#console.log(stringFeature)
		# we only need to convert it to a three.js path
		mesh = transformSVGPathExposed(stringFeature);
		# add to array
		meshes.push(mesh);
		console.log(mesh)
		# we get a property from the json object and use it
		# to determine the color later on
		#value = parseInt(geoFeature.properties.bev_dichth)
		value = Math.random()
		maxValueAverage = value if value > maxValueAverage
		minValueAverage = value if value < minValueAverage || minValueAverage == -1
		averageValues.push(value)

		# and we get the max values to determine height later on.
		#value = parseInt(geoFeature.properties.aant_inw)
		value = value
		maxValueTotal = value if value > maxValueTotal
		minValueTotal = value if value < minValueTotal || minValueTotal == -1

		totalValues.push(value)
    

	# weve got our paths now extrude them to a height and add a color
	for value, i in averageValues 
		# create material color based on average
		console.log(i)
		scale = ((value - minValueAverage) / (maxValueAverage - minValueAverage)) * 255
		mathColor = gradient(Math.round(scale),255)
		material = new THREE.MeshLambertMaterial()
		
		# create extrude based on total
		extrude = ((totalValues[i] - minValueTotal) / (maxValueTotal - minValueTotal)) * 100
		extrude = 100
		console.log(meshes[i])
		for mesh in meshes[i]
			console.log(mesh)
			shape3d = mesh.extrude({amount: Math.round(extrude), bevelEnabled: false})
		#console.log("shape:" + shape3d)
		# create a mesh based on material and extruded shape
			toAdd = new THREE.Mesh(shape3d)

		# rotate and position the elements nicely in the center
			toAdd.rotation.x = Math.PI/2
			toAdd.translateX(-490)
			toAdd.translateZ(50)
			toAdd.translateY(extrude/2)
			#console.log(scene)
			# add to scene
			scene.add(toAdd)

	renderer.render(scene,camera)


  # simple gradient function
gradient = (length, maxLength) ->

	i = (length * 255 / maxLength)
	r = i
	g = 255-(i)
	b = 0

	rgb = b | (g << 8) | (r << 16)