# initialize the scene, camera, light, and background plane
Map = (params) ->
  this.width     = params.width
  this.height    = params.height
  this.container = params.target || document.body

  this.renderer = new THREE.WebGLRenderer({antialias: true})
  this.renderer.setSize(this.width, this.height)
  this.renderer.setClearColor(0x303030, 1.0)

  this.container.appendChild(this.renderer.domElement)

  this.camera = new THREE.PerspectiveCamera(45, this.width / this.height, 1, 10000)
  this.scene = new THREE.Scene()
  this.scene.add(this.camera)

  this.camera.position.z = 550
  this.camera.position.x = 0
  this.camera.position.y = 550

  this.camera.lookAt(this.scene.position)

  this.projection = d3.geo.albersUsa()
    .scale(1000)
    .translate([250, 0])


  pointLight = new THREE.PointLight(0xFFFFFF)
  pointLight.position.x = 800
  pointLight.position.y = 800
  pointLight.position.z = 800

  planeGeo = new THREE.PlaneGeometry(10000, 10000, 10, 10)
  planeMesh = new THREE.MeshLambertMaterial({color: 0xffffff})
  plane = new THREE.Mesh(planeGeo, planeMesh)

  plane.rotation.x = -Math.PI/2

  this.scene.add(pointLight)
  this.scene.add(plane)

'Map.renderCounties = () ->
  $.getJSON("/data/us-counties.json", function(json) {
    renderFeatures(this.projection, json.features, this.scene, false);
    this.renderer.render(this.scene, this.camera);
  }.bind(this));'
