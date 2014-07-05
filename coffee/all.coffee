


d3.json("static/other.json", (error, us) ->
  console.log("in ready")
  console.log(us)

  # features = topojson.feature(us, us.objects.counties).features;
  # US = us
  # data.forEach((d) -> rateById.set(d.id, +d.rate))
  # svg.append("g")
  #     .attr("class", "counties")
  #   .selectAll("path")
  #     .data(features)
  #   .enter().append("path")
  #     .attr("class", (d) -> quantize(rateById.get(d.id)))
  #     .attr("d", path)

  # svg.append("path")
  #     .datum(topojson.mesh(us, us.objects.states, (a, b) ->  a != b))
  #     .attr("class", "states")
  #     .attr("d", path)

  #initScene()
  #geo.setupGeo();
  #addGeoObject(us.features)
  #map = new Map({width: width, height: height})
  #renderFeatures(map.projection, us.features, map.scene, false)
  #map.renderer.render(map.scene, map.camera)
)
#d3.select(self.frameElement).style("height", height + "px")






