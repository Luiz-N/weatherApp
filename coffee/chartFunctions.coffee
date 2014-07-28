timeSeries = (dim, metricName, displayName,metric) ->
	timeChart = dc.compositeChart("#timeSeries .chart")
	#yearRange = dc.barChart("#yearRange");
	# metric = db.dimension.monthStamp.group().reduceSum (d) -> d.Precip
	# metric_avg = db.dimension.monthStamp.group().reduceSum (d) -> d.Precip_avg
	metric_avg = averageValues(dim,metricName+"_avg")


	minDate = dim.bottom(1)[0].Date
	maxDate = dim.top(1)[0].Date
	width = $(timeChart.root()[0]).innerWidth() + 30
  # debugger
  # height = $(timeChart.root()[0]).innerHeight()
	timeChart
		.width(width)
    .height(width*.333)
		.dimension(dim)
		.renderHorizontalGridLines(true)
		.x(d3.time.scale().domain([minDate,maxDate]))
		    .xUnits(d3.time.months)
		    .elasticY(true)
		    .brushOn(true)
		    .legend(dc.legend().x(60).y(10).itemHeight(13).gap(5))
		.yAxisLabel(displayName)
		.compose([
				dc.lineChart(timeChart)
          .colors(['blue'])
          .group(metric, "actual" + displayName)
          .valueAccessor (d) -> d.value.avg
          .interpolate('basis-open')
          .dimension(dim),
        dc.lineChart(timeChart)
          # .dimension(dim)
          .colors(['red'])
          # .dashStyle([5,5])
          .group(metric, "Normal " + displayName)
          .valueAccessor (d) -> d.value.avg_avg
          .interpolate('basis-open')
         # dc.lineChart(timeChart)
         	# .colors(['#666'])
         	# .group() #I just want to feed a simple array of values into here
		])
			# .renderlet (chart) -> console.log(chart)

	# timeChart.colorCalculator (x) -> timeChart.colors()(x)
	timeChart

monthChart = (dim, metricName, displayName, metric) ->
	mainChart = dc.compositeChart("#monthChart")
	width = $(mainChart.root()[0]).outerWidth() + 100
	# metric = averageValues(dim,metricName)
	monthArray = ["Jan","Feb","Mar","Apr","May","June","July","Aug","Sept","Oct","Nov","Dec"]

	actualTemp = dc.barChart(mainChart)
	avgTemp = dc.barChart(mainChart)

	actualTemp
		.group(metric)
		.valueAccessor (d) -> d.value.avg
		.colors(['lightblue','blue','green'])
    .colorAccessor (d,i) ->
    	# debugger
    	if d.y > 50
      	return 2
      else
      	return 0
    .colorDomain ([0,2])
	avgTemp
		.group(metric)
		.valueAccessor (d) -> d.value.avg_avg
		.colors(['red'])
	# actualTemp.colorCalculator (c) -> actualTemp.colors()(c)
	mainChart
    .width(width)
    .height(width*.4)
    .dimension(dim)
    .group(metric)
    .elasticY(false)
    .yAxisLabel(displayName)
    .title (d) -> "Title"
    .renderTitle(true)
    #.x(d3.time.scale().domain(timeExtent))
    .x(d3.scale.ordinal().domain(monthArray))
    .xUnits(dc.units.ordinal)
    # .valueAccessor (d) -> d.value.avg
    .renderHorizontalGridLines(true)
    .compose([actualTemp,avgTemp])

	mainChart

yearChart = (dim,metricName,displayName, metric) ->
	mainChart = dc.compositeChart("#yearChart")
	width = $(mainChart.root()[0]).outerWidth() + 100
	# metric = averageValues(dim,metricName)

	actualTemp = dc.barChart(mainChart)
	avgTemp = dc.barChart(mainChart)

	actualTemp
		.group(metric)
		.valueAccessor (d) -> d.value.avg
		.colors(['rgb(215,48,39)','rgb(252,141,89)','rgb(254,224,144)','rgb(255,255,191)','rgb(224,243,248)','rgb(145,191,219)','rgb(69,117,180)'])
    .colorAccessor (d,i) ->
    	norm = d.data.value.avg_avg
    	diff = (d.y - norm)/norm
    	getColorIndex(diff)
    .colorDomain ([0,6])
	avgTemp
		.group(metric)
		.valueAccessor (d) -> d.value.avg_avg
		.colors(['rgba(255,255,191,0)'])
	# actualTemp.colorCalculator (c) -> actualTemp.colors()(c)
	mainChart
    .width(width)
    .height(width*.4)
    .dimension(dim)
    .group(metric)
    .elasticY(true)
    .yAxisLabel(displayName)
    .title (d) -> "Title"
    .renderTitle(true)
    .x(d3.scale.ordinal())
    .xUnits(dc.units.ordinal)
    # .valueAccessor (d) -> d.value.avg
    .renderHorizontalGridLines(true)
    .compose([actualTemp,avgTemp])

	mainChart
# monthChart = (dim, metricName, displayName, metric) ->
# 	chartObject = dc.barChart("#monthChart")
# 	width = $(chartObject.root()[0]).outerWidth() + 100
# 	# metric = averageValues(dim,metricName)
# 	monthArray = ["Jan","Feb","Mar","Apr","May","June","July","Aug","Sept","Oct","Nov","Dec"]

# 	chartObject
#     .width(width)
#     .height(width*.4)
#     .dimension(dim)
#     .group(metric)
#     .elasticY(true)
#     .yAxisLabel(displayName)
#     .title (d) -> "Title"
#     .renderTitle(true)
#     #.x(d3.time.scale().domain(timeExtent))
#     .x(d3.scale.ordinal().domain(monthArray))
#     .xUnits(dc.units.ordinal)
#     .valueAccessor (d) -> d.value.avg
#     .centerBar(false)
#     .renderHorizontalGridLines(true)

# 	chartObject

# yearChart = (dim,metricName,displayName, metric) ->
# 	chartObject = dc.barChart("#yearChart")
# 	width = $(chartObject.root()[0]).outerWidth() + 100
# 	#hours = ["Midnight","1","2","3","4","5","6","7","8","9","10","11","Noon","1","2","3","4","5","6","7","8","9","10","11"]

# 	# metric = averageValues(dim,metricName)

# 	chartObject
#     .width(width)
#     .height(width*.4)
#     .dimension(dim)
#     .group(metric)
#     .elasticY(true)
#     .yAxisLabel(displayName)
#     .brushOn(true)
#     #.x(d3.time.scale().domain(timeExtent))
#     .round(dc.round.floor)
#     .x(d3.scale.ordinal())
#     #.xAxis().ticks(24)
#     .xUnits(dc.units.ordinal)
#     .valueAccessor (d) -> d.value.avg
#     .centerBar(false)
#     .renderHorizontalGridLines(true)

# 	chartObject

hourChart = (dim,metricName,displayName, metric) ->
	chartObject = dc.barChart("#hourChart")
	width = $(chartObject.root()[0]).outerWidth() + 100
	#hours = ["Midnight","1","2","3","4","5","6","7","8","9","10","11","Noon","1","2","3","4","5","6","7","8","9","10","11"]

	# metric = averageValues(dim,metricName)
	
	#debugger;

	chartObject
    .width(width)
    .height(width*.4)
    .dimension(dim)
    .group(metric)
    .elasticY(true)
    .yAxisLabel(displayName)
    .brushOn(true)
    #.x(d3.time.scale().domain(timeExtent))
    .round(dc.round.floor)
    .x(d3.scale.ordinal())
    #.xAxis().ticks(24)
    .xUnits(dc.units.ordinal)
    .valueAccessor (d) -> d.value.avg
    .centerBar(false)
    .renderHorizontalGridLines(true)
	chartObject

#deltaPrcnt = (dim,metricName,displayName) ->
#["Fall","Winter","Spring","Summer"]

