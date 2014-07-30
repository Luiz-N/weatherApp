class Dashboard
	constructor: () ->
		@upperHeight = ($("#upperHalf .leftCol").width()*.225)
		@lowerHeight = $("#graphTitle").offset().top + @upperHeight
		@metricArray = ["H_Pcnt"]
		@metricName = "Temp"
		@displayName = "Temperature (F)"
		@queries = []
		@inputBox = null
		# @cf = null
		# @allGroups = null
		@charts = {}
		@dimension = {}
		@metric = {}
		@cal = null
		@brushFilter = [d3.time.format("%Y-%m-%d").parse("2011-01-01"),d3.time.format("%Y-%m-%d").parse("2012-01-01")]
		@monthArray = ["Jan","Feb","Mar","Apr","May","June","July","Aug","Sept","Oct","Nov","Dec"]
		@lastQuery = "hurricane sandy"

	parseData: (data) ->
		#@data = data
		@cf = crossfilter(data)
		# console.log(@cf) 
		@allGroups = @cf.groupAll()

		for d in data
		    #console.log(d)
		    d.Date = parseDate(d.Date)
		    d.monthNum = d.Date.getMonth()
		    d.hourlyNum = d.Date.getHours()
		    d.Year = d.Date.getFullYear()
		    d.monthStamp = d3.time.month(d.Date)
		    d.dayStamp = d3.time.day(d.Date)
		    # d.yearStamp = d3.time.year(d.Date)
		    #d.weekStamp = d3.time.week(d.Date)

		
		$("#lowerHalf").height(@lowerHeight)

		@buildDimensions()
		@buildMonthChart()
		@buildTimeSeriesChart()
		# @loadCalendar()
		dc.constants.EVENT_DELAY = 100
		

	buildDimensions: () ->
		go = @
		# @dimension.yearName = @cf.dimension (d) -> d.Year
		# @dimension.timeOfDay = @cf.dimension (d) -> d.hourlyNum
		@dimension.monthStamp = @cf.dimension (d) -> d.monthStamp
		@dimension.dayStamp = @cf.dimension (d) -> d.dayStamp
		@dimension.monthNames = @cf.dimension (d) =>
			month = d.monthNum
			@monthArray[month]

	buildMetrics: () ->
		@metric.avgMonthOverTime = averageValues(@dimension.monthStamp,@metricName)
		# @metric.avg_avgMonthOverTime = averageValues(@dimension.monthStamp,@metricName+"_avg")
		# @metric.yearAvgs = averageValues(@dimension.yearName,@metricName)
		# @metric.hourAvgs = averageValues(@dimension.timeOfDay,@metricName)
		@metric.monthAvgs = averageValues(@dimension.monthNames,@metricName)
		@metric.avgDayOverTime = averageValues(@dimension.dayStamp,@metricName)

	buildMonthChart: () ->
		go = @
		thisChart = new Chart(dc.compositeChart("#monthChart"),@dimension.monthNames)
		metric = thisChart.averageMetric(@metricName)

		# domain = []
		# (@dimension.dayStamp.bottom(1)[0].Date).getMonth()
		# group.top(Infinity).forEach( (d) ->
		#     domain[domain.length] = d.key
		# )
		
		

		actualValuesChart = dc.barChart(thisChart.chartObject)
		actualValuesChart
			.group(metric)
			.colors(['rgb(64, 130, 163)'])
			.valueAccessor (d) -> d.value.avg
			.elasticX(true)

		thisChart.chartObject
			.dimension(@dimension.monthNames)
			.width(thisChart.width + 75)
			.height(@upperHeight - $("#currentYear").height())
			.yAxisLabel(@displayName)
			# .ordering( (d) ->  d.value.avg)
			.elasticY(true)
			.elasticX(true)
			.x(d3.scale.ordinal().domain(months(@dimension.dayStamp.bottom(1)[0].Date.getMonth())))
			.xUnits(dc.units.ordinal)
			.renderHorizontalGridLines(true)
			.compose([actualValuesChart])
			.on "preRedraw", (_chart) =>
				if actualValuesChart.filter() == null
					thisChart.updateXAxis(@dimension.dayStamp)
			.renderlet( (_chart) =>
				dc.events.trigger( => 
					# @loadCalendar()
					# actualValuesChart.renderXAxis(actualValuesChart.g())
				)
			)

		thisChart.innerChart.values = actualValuesChart
		@charts.monthChart = thisChart
		# thisChart.innerChart.avgValues = dc.barChart(thisChart.chartObject)

	buildYearChart: () ->
		thisChart = new Chart(dc.compositeChart("#yearChart"),@dimension.yearName)
		metric = thisChart.averageMetric(@metricName)

		actualValuesChart = dc.barChart(thisChart.chartObject)
		actualValuesChart
			.group(metric)
			.valueAccessor (d) -> d.value.avg

		thisChart.chartObject
			.dimension(@dimension.yearName)
			.width(thisChart.width + 100)
			.height(thisChart.width*.4)
			.yAxisLabel(@displayName)
			.elasticY(true)
			.group(metric)
	    .x(d3.scale.ordinal())
	    .xUnits(dc.units.ordinal)
    	.renderHorizontalGridLines(true)
    	.compose([actualValuesChart])

		thisChart.innerChart.values = actualValuesChart
		@charts.yearChart = thisChart

	buildHourlyChart: () ->
		thisChart = new Chart(dc.compositeChart("#hourChart"),@dimension.timeOfDay)
		metric = thisChart.averageMetric(@metricName)

		actualValuesChart = dc.barChart(thisChart.chartObject)
		actualValuesChart
			.group(metric)
			.valueAccessor (d) -> d.value.avg

		thisChart.chartObject
			.dimension(@dimension.timeOfDay)
			.width(thisChart.width + 100)
			.height(thisChart.width*.4)
			.yAxisLabel(@displayName)
			.elasticY(true)
			.group(metric)
	    .x(d3.scale.ordinal())
	    .xUnits(dc.units.ordinal)
    	.renderHorizontalGridLines(true)
    	.compose([actualValuesChart])

		thisChart.innerChart.values = actualValuesChart
		@charts.hourChart = thisChart

	buildTimeSeriesChart: () ->
		go = @
		thisChart = new Chart(dc.compositeChart("#upperHalf .leftCol div.chart"),@dimension.monthStamp)
		metric = thisChart.averageMetric(@metricName)
	
		minDate = @dimension.monthStamp.bottom(1)[0].Date
		maxDate = @dimension.monthStamp.top(1)[0].Date

		actualValuesChart = dc.lineChart(thisChart.chartObject)
			.group(metric, "actual " + @displayName)
			.valueAccessor (d) ->  d.value.avg
			.colors(['#2a6496'])
			.interpolate('basis-open')

		normValuesChart = dc.lineChart(thisChart.chartObject)
			.group(metric, "normal " + @displayName)
			.valueAccessor (d) -> d.value.avg_avg
			.colors(['#428bca'])
			.interpolate('basis-open')
		
		# clipsCountChart = dc.lineChart(thisChart.chartObject)
		# 	.group(buildFakeGroup(@lastQuery))
		# 	.colors(['black'])
		# 	.interpolate('basis-open')
		#   .y(d3.scale.linear().range([100, 0]))
		# 	.yAxis(d3.svg.axis().scale(d3.scale.linear().range([100, 0])))

		thisChart.chartObject
			.dimension(@dimension.monthStamp)
			.width(thisChart.width + 30)
			.height(@upperHeight)
			.yAxisLabel(@displayName)
			.elasticY(true)
	    .x(d3.time.scale().domain([minDate,maxDate]))
		  .xUnits(d3.time.months)
		  .brushOn(false)
			.legend(dc.legend().x(60).y(10).itemHeight(13).gap(5))
    	.renderHorizontalGridLines(true)
    	.compose([actualValuesChart,normValuesChart])
    	.renderlet( (_chart) =>
				dc.events.trigger( => 
					if !_chart.brushOn()
						_chart.brushOn(true)
						_chart.renderBrush(_chart.g())
						_chart.brush().extent(@brushFilter)
						_chart.redrawBrush(_chart.g())
						_chart.filter(@brushFilter)
						@charts.monthChart.updateXAxis(@dimension.dayStamp)
						@charts.monthChart.chartObject.redraw()
					@loadCalendar()
				)
			)

		thisChart.innerChart.values = actualValuesChart
		thisChart.innerChart.normalValues = normValuesChart
		# thisChart.innerChart.clipCounts = clipsCountChart

		@charts.timeSeries = thisChart
	
	buildCharts: () ->
		thisChart = new Chart(dc.lineChart("#dlta .chart"),@dimension.monthStamp)
		# metric = thisChart.averageMetric(@metricName)
	
		minDate = @dimension.monthStamp.bottom(1)[0].Date
		maxDate = @dimension.monthStamp.top(1)[0].Date

		# actualValuesChart = dc.lineChart(thisChart.chartObject)
		# 	.group(metric, "actual " + @displayName)
		# 	.valueAccessor (d) -> d.value.avg
		# 	.colors(['green'])
		# 	.interpolate('basis-open')

		# normValuesChart = dc.lineChart(thisChart.chartObject)
		# 	.group(metric, "normal " + @displayName)
		# 	.valueAccessor (d) -> d.value.avg_avg
		# 	.colors(['rgba(0,0,255,1)'])
		# 	.interpolate('basis-open')
		
		# clipsCountChart = dc.lineChart(thisChart.chartObject)
		# 	.group(buildFakeGroup(defaultClipsArray))
		# 	.colors(['red'])
		# 	.interpolate('basis-open')
		  # .y(d3.scale.linear().range([100, 0]))
			# .yAxis(d3.svg.axis().scale(d3.scale.linear().range([100, 0])))

		thisChart.chartObject
			.dimension(@dimension.monthStamp)
			.group(thisChart.getDelta("Temp"),"Temp")
			.width(thisChart.width + 30)
			.height(thisChart.width*.333)
			# .yAxisLabel(@displayName)
			.valueAccessor (d) -> d.value.delta
			.elasticY(true)
	    .x(d3.time.scale().domain([minDate,maxDate]))
		  .xUnits(d3.time.months)
		  # .brushOn(true)
		  .legend(dc.legend().x(60).y(10).itemHeight(13).gap(5))
    	.renderHorizontalGridLines(true)
    	# .stack(thisChart.getDelta("Wind"),"Wind")
    	# .stack(thisChart.getDelta("Precip"),"Precip")
    	# .stack(thisChart.getDelta("Temp_Feels"),"Temp_Feels")


    	# .compose([actualValuesChart,normValuesChart,clipsCountChart])

		# for metric in @metricArray
    	# thisChart.chartObject.stack(thisChart.getDelta(metric),metric)

		# thisChart.innerChart.values = actualValuesChart
		# thisChart.innerChart.normalValues = normValuesChart

		@charts.delta = thisChart

	refreshCharts: () ->
		go = @
		dc.filterAll()
		@buildMetrics()
		@charts.timeSeries.chartObject.brushOn(false)
		for chartName,chart of @charts
			chart.chartObject.yAxisLabel(@displayName)
			chart.updateMetric(@metricName,@displayName)
			# chart.object.group(chart.averageMetric(@metricName))
		dc.renderAll()
		

	activateListeners: () ->
		go = @
		timeChart = go.charts.timeSeries.chartObject
		@inputBox = $(".input-group input")[0]
		$("#upperHalf .leftCol ul li").on "click","a", ->
			go.metricName = $(this).attr("data-name")
			go.displayName = $(this).html()
			$("#upperHalf .leftCol li").removeClass("active")
			$(this).parent().addClass("active")
			go.refreshCharts()

		$("#lowerHalf .rightCol").on "click","button", ->
			queryString = go.inputBox.value
			go.getWordCount(queryString)

		$(@inputBox).keypress (e) ->
			if e.which == 13
					$(".rightCol button").click()

	loadCalendar: () ->
		# console.log("in calendar")
		$("div.ch-tooltip").remove()
		
		if @cal
			@cal = @cal.destroy()
			@cal = new CalHeatMap()
		else
			@cal = new CalHeatMap()

		begin = @dimension.dayStamp.bottom(1)[0].Date
		end = @dimension.dayStamp.top(1)[0].Date
		# begin = @brushFilter[0]
		# end = @brushFilter[1]
		if @metricName != "Precip"
			metricValues = averageValues(@dimension.dayStamp,@metricName)
		else
			metricValues = precipReduceHack(@dimension.dayStamp,@metricName)

		json = buildCalendarJson(metricValues.all())
		legendIntervals = calculateIntervals(metricValues)
		numOfMonths = Math.ceil(((end - begin) / 31536000000)*12)
		cellSize = @upperHeight*.125

		@cal.init({
			domain: "month",
			subDomain: "x_day",
			start: begin,
			range: numOfMonths,
			legend: legendIntervals
			legendColors: ["#efefef", "#2a6496"]
			cellSize: cellSize
			legendCellSize: cellSize/2
			domainGutter: cellSize/2
			legendOrientation: "vertical"
			legendVerticalPosition: "center"
			legendMargin: [0,cellSize,0,0]
			data: json
			# tooltip: true
			dataType: "json"
			onClick: (date,items) => @loadNewsClips(date, items)
		})

		metricValues.dispose()

	loadNewsClips: (date,items) =>
		# console.log(date.toISOString())
		# console.log(items)
		firstDate = new Date(date.getTime())
		date.setDate(date.getDate()+1)
		$.ajax $SCRIPT_ROOT+'/grabClips',
			  data :
			    year1  : String(firstDate.getFullYear())
			    month1 : ('0' + (firstDate.getMonth()+1)).slice(-2)
			    day1  : ('0' + firstDate.getDate()).slice(-2)
			    year2  : String(date.getFullYear())
			    month2 : ('0' + (date.getMonth()+1)).slice(-2)
			    day2  : ('0' + date.getDate()).slice(-2)
			    query : @lastQuery
			  success: (response, status, xhr) ->
			  	console.log(response)
			  error: (xhr, status, err) -> console.log(err,status,xhr)
			  # complete : (xhr, status) ->

	updateCal: () ->
		go = @
		if @metricName != "Precip"
			# metricValues = averageValues(@dimension.dayStamp,@metricName)
			metricValues = go.metric.avgDayOverTime

		else
			metricValues = precipReduceHack(@dimension.dayStamp,@metricName)

		json = buildCalendarJson(metricValues.all())

		max = _.max(_.pluck(_.pluck(metricValues.all(),'value'),'avg_avg'))
		#get max for avgs instead
		interval = max/10;
		
		numOfMonths = Math.ceil(((end - begin) / 31536000000)*12)

		begin = @dimension.dayStamp.bottom(1)[0].Date
		end = @dimension.dayStamp.top(1)[0].Date

		# @cal.options.start = begin
		# @cal.options.range = numOfMonths
		@cal.options.legend = [interval, 2 * interval, 3 * interval, 4 * interval,5 * interval,6 * interval,7 * interval,8*interval,9*interval, max]
		@cal.update(json)

	getWordCount: (queryString) ->
		go = @
		queryObject = _.findWhere(@queries,{query:queryString})

		if queryObject
			renderWordCountGraph(queryObject)
		else
			$.ajax $SCRIPT_ROOT+'/newQuery',
			  data :
			    query : queryString
			  success  : (response, status, xhr) ->
			  	go.lastQuery = response.dailyCounts
					# console.log(response)
			  	go.renderWordCountGraph()
			  error    : (xhr, status, err) -> console.log(err,status,xhr)
			  # complete : (xhr, status) ->

	renderWordCountGraph: () ->
				$("g.area").remove()
				chart = @charts.timeSeries.chartObject
				chart.render()
				console.log(@lastQuery)
				height = chart.xAxisY() 
				max = _.max(_.pluck(@lastQuery,"value"))
				x = chart.x()
				y = d3.scale.linear().domain([0, max]).range([height, 0])


				group = chart.g().append("g")
								.attr("class","area")
								.attr("transform", "translate(42,0)")


				area = d3.svg.area()
							 .x( (d) -> x(d3.time.format("%Y-%m").parse(d.key)))
							 .y0(height	)
							 .y1( (d) -> y(d.value))
							 .interpolate("basis-open")
							 # .y( (d) -> 4000)
				chart.g().select("g.area").append("path")
							 .datum(@lastQuery)
							 .attr("d",area)
							 .style("fill", "rgba(153,153,153,.25)" )
		
				yAxisRight = d3.svg.axis().scale(y).orient("right").ticks(3)
				group.append("g")
								.attr("transform", "translate(" + (chart.xAxisLength()) + ",0)")
								.attr("class","axis y hack")
								.call(yAxisRight)

				$("g.brush").remove()
				chart.renderBrush(chart.g())

		# cal.update(calFormattedJson)
		# console.log((new Date() - startTime)/1000)
		# console.log(new Date(2000, 0, 15))







# 