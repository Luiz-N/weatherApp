class Dashboard
	constructor: () ->
		@upperHeight = ($("#upperHalf .leftCol").width()*.225)
		@lowerHeight = $("#graphTitle").offset().top + @upperHeight
		@metricArray = ["H_Pcnt"]
		@metricName = "Precip"
		@displayName = "Rain/Snow"
		@queries = []
		@inputBox = null
		@tvFrameTemplate = $("div.template").clone()
		# @cf = null
		@weatherColor = '#1C8B98'
		# @allGroups = null
		@charts = {}
		@dimension = {}
		@metric = {}
		@cal = null
		@brushFilter = [d3.time.format("%Y-%m-%d").parse("2011-02-01"),d3.time.format("%Y-%m-%d").parse("2012-02-01")]
		@monthArray = ["Jan","Feb","Mar","Apr","May","June","July","Aug","Sept","Oct","Nov","Dec"]
		@lastQuery = "flash flood"
		@lastQueryResults = null

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
		@getWordCount()
		# @loadCalendar()
		dc.constants.EVENT_DELAY = 80

		# $("#timeSpan").text(@brushFilter[0].format("MMM YYYY")+" - "+@brushFilter[1].format("MMM YYYY"))


		# tvCols = Math.round($("#mainCol").innerWidth()/$(".tv-col").width()) - 1
		# until tvCols -= 0


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
			.colors([@weatherColor])
			.valueAccessor (d) -> d.value.avg
			.elasticX(true)

		thisChart.chartObject
			.dimension(@dimension.monthNames)
			.width(thisChart.width + 70)
			.height(@upperHeight)
			.yAxisLabel(@displayName)
			# .ordering( (d) ->  d.value.avg)
			.elasticY(true)
			.elasticX(true)
			.x(d3.scale.ordinal().domain(months(@dimension.dayStamp.bottom(1)[0].Date.getMonth())))
			.xUnits(dc.units.ordinal)
			.renderHorizontalGridLines(true)
			.compose([actualValuesChart])
			.on "preRedraw", (_chart) =>
				# debugger
				@brushFilter[0] = moment(@charts.timeSeries.chartObject.filter()[0])
				@brushFilter[1] = moment(@charts.timeSeries.chartObject.filter()[1])

				# @brushFilter[0] = moment(_chart.brush().extent()[0])
				# @brushFilter[1] = moment(_chart.brush().extent()[1])
				$("#timeSpan").text(@brushFilter[0].format("MMMM YYYY")+" - "+@brushFilter[1].format("MMMM YYYY"))
				$("#timeSeries h4 span.metric").text(@displayName)
				$("#timeSeries h4 span.query").text(@lastQuery)

		
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

	buildTimeSeriesChart: () ->
		go = @
		thisChart = new Chart(dc.compositeChart("#upperHalf .leftCol div.chart"),@dimension.monthStamp)
		metric = thisChart.averageMetric(@metricName)
	
		minDate = @dimension.monthStamp.bottom(1)[0].Date
		maxDate = @dimension.monthStamp.top(1)[0].Date

		actualValuesChart = dc.lineChart(thisChart.chartObject)
			.group(metric, "actual " + @displayName)
			.valueAccessor (d) ->  d.value.avg
			.colors([@weatherColor])
			.interpolate('basis-open')

		normValuesChart = dc.lineChart(thisChart.chartObject)
			.group(metric, "Recorded " + @displayName)
			.valueAccessor (d) -> d.value.avg_avg
			.colors(['rgba(28,139,152,.7)'])
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
				_chart.selectAll("g.sub path").style("stroke-width",3)
				_chart.selectAll("g.sub._1 path").style("stroke-dasharray",3)
				act_legend = $(_chart.anchor()+" g.dc-legend-item text")[0]
				$(act_legend).text("Recorded " + @displayName)
				avg_legend = $(_chart.anchor()+" g.dc-legend-item text")[1]
				$(avg_legend).text("10 year average")
				dc.events.trigger( => 
					if !_chart.brushOn()
						_chart.brushOn(true)
						_chart.renderBrush(_chart.g())
						_chart.brush().extent(@brushFilter)
						@brushFilter = _chart.brush().extent()
						_chart.redrawBrush(_chart.g())
						_chart.filter(@brushFilter)
						@charts.monthChart.updateXAxis(@dimension.dayStamp)
						@charts.monthChart.chartObject.redraw()
						@getWordCount()
					@loadCalendar()
				)
			)
			.on("filter", (_chart,filter) =>
				alert(filter)
				# debugger
				# timeSpan.text()

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
		$("a.months").click()
		

	activateListeners: () ->
		go = @
		timeChart = go.charts.timeSeries.chartObject
		@inputBox = $(".input-group input")[0]
		$("#upperHalf .leftCol ul li a").on "click", ->
			go.metricName = $(this).attr("data-name")
			go.displayName = $(this).html()
			$("#upperHalf .leftCol li a").removeClass("active")
			$(this).addClass("active")
			go.refreshCharts()

		$("#lowerHalf .rightCol").on "click","button", =>
			@lastQuery = @inputBox.value
			@getWordCount()

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
			legendColors: ["#efefef", @weatherColor]
			cellSize: cellSize
			legendCellSize: cellSize/2
			domainGutter: cellSize/2
			legendOrientation: "vertical"
			legendVerticalPosition: "center"
			legendMargin: [0,cellSize,0,0]
			data: json
			# tooltip: true
			dataType: "json"
			onClick: (date,items) => 
				@loadNewsClips(date, items)
				date = moment(date)
				$("#date").text(date.format("dddd MMM Do, YYYY"))
				$("#date").addClass("invisible")
				$(".tv-clip").remove()
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
			  success: (response, status, xhr) =>
			  	console.log(response)
			  	@displayNewsClips(response.clips)
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

	getWordCount: () =>
		queryObject = _.findWhere(@queries,{query:@lastQuery})

		if queryObject
			@lastQueryResults = queryObject.results
			@renderWordCountGraph()
		else
			$.ajax $SCRIPT_ROOT+'/newQuery',
			  data :
			    query : @lastQuery
			  success  : (response, status, xhr) =>
			  	@lastQueryResults = response.dailyCounts
			  	@queries.push({query:@lastQuery,results:response.dailyCounts})
					# console.log(response)
			  	@renderWordCountGraph()
			  error    : (xhr, status, err) -> console.log(err,status,xhr)
			  # complete : (xhr, status) ->

	renderWordCountGraph: () =>
				# $("a.months").click()
				$("g.area").remove()
				chart = @charts.timeSeries.chartObject
				# chart.redraw()
				# console.log(@lastQuery)
				height = chart.xAxisY() 
				max = _.max(_.pluck(@lastQueryResults,"value"))
				x = chart.x()
				y = d3.scale.linear().domain([0, max]).range([height, 0])


				group = chart.g().append("g")
								.attr("class","area")
								.attr("transform", "translate(42,0)")


				area = d3.svg.area()
							 .x( (d) -> x(d3.time.format("%Y-%m").parse(d.key)))
							 .y0(height	)
							 .y1( (d) ->
							 		# debugger
							 		if moment(d3.time.format("%Y-%m").parse(d.key)).year() < 2014
							 			y(d.value)
							  	else 
							  		y(0)
							  )
							 .interpolate("basis-open")
							 # .y( (d) -> 4000)
				chart.g().select("g.area").append("path")
							 .datum(@lastQueryResults)
							 .attr("d",area)
							 .style("fill", "rgba(153,153,153,.25)" )
		
				yAxisRight = d3.svg.axis().scale(y).orient("right").ticks(3)
				group.append("g")
								.attr("transform", "translate(" + (chart.xAxisLength()) + ",0)")
								.attr("class","axis y hack")
								.call(yAxisRight)

				$("g.brush").remove()
				chart.renderBrush(chart.g())

	displayNewsClips: (clips) =>

		$(".tv-clip").remove()
		$("#date").removeClass("invisible")

		if clips.length == 0
			dte = $("#date").text()
			$("#date").text('No local news clips containg "'+@lastQuery+'"" were found on '+dte)


		for clip in clips
			tvFrame = @tvFrameTemplate.clone().removeClass("template").addClass("tv-clip")
			iFrame = tvFrame.find("iframe").remove().addClass("well")
			tvFrame.appendTo("#tv-container")

			tvFrame.find(".show").text(clip.show)
			tvFrame.find(".date").text(clip.date.split(" ")[3]+" "+clip.date.split(" ")[4])
			tvFrame.find(".station").text(clip.station)
			# debugger
			iFrame.attr("src", clip.link)
			width = tvFrame.find(".caption").innerWidth()
			iFrame.attr("width", width)
			iFrame.attr("height", width*.75)
			iFrame.prependTo(tvFrame)

			# break


		# cal.update(calFormattedJson)
		# console.log((new Date() - startTime)/1000)
		# console.log(new Date(2000, 0, 15))







# 