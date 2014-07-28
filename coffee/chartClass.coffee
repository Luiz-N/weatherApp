class Chart
	constructor: (@chartObject,@dimension) ->
		@innerChart = {}
		@width = $(@chartObject.root()[0]).outerWidth()
		
		# @chartObject
			# .width($(object.root()[0]).outerWidth())
			# .height(@chartObject.width * .4)
		# @

	updateMetric: (metricName,displayName) ->
		# chart
		for chartName,chart of @innerChart
			newMetric = @averageMetric(metricName)
			chart.group(newMetric)
			chart.filterAll()
			@chartObject.expireCache()
	averageMetric: (metricName) ->
		if metricName != "Precip"
			averageValues(@dimension,metricName)
		else
			precipReduceHack(@dimension,metricName)	
	getDelta: (metricName) ->
		getDeltas(@dimension,metricName)