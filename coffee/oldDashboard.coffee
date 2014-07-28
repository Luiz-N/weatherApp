class Dashboard
	constructor: () ->
		# @defaultMetric = {metricName:"Temp",displayName:"Temperature (F)"}
		@metricName = "Temp"
		@displayName = "Temperature (F)"
		@queries = []
		@inputBox = null
		@cf = null
		@allGroups = null
		@charts = []
		@dimension = {}
		@cal = null
		@monthAvgs = null
		@avgMonthOverTime = null
		@yearAvgs = null
		@hourAvgs = null 
		@timeSpan = null

	parseData: (data) ->
		#@data = data
		@cf = crossfilter(data)
		console.log(@cf) 
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

		@buildDimensions()
		@buildMetrics()
		@buildCharts()
		@loadCalendar()
		
		@activateListeners()

	buildDimensions: () ->
		@dimension.yearName = @cf.dimension (d) -> d.Year

		# @dimension.seasons = @cf.dimension (d) -> 
		#     month = d.monthNum
		#     if (month == 11 or month == 0 or month == 1)
		#         return "Winter";
		#     else if (month >= 2 && month <= 4)
		#         return "Spring";
		#     else if (month >= 5 && month <= 7)
		#         return "Summer";
		#     else
		#         return "Fall";
		# seasonDim = @dimension.seasons
		@dimension.timeOfDay = @cf.dimension (d) -> d.hourlyNum
		@dimension.monthStamp = @cf.dimension (d) -> d.monthStamp
		# @dimension.monthStamp2 = @cf.dimension (d) -> d.monthStamp
		# @dimension.yearStamp = @cf.dimension (d) -> d.yearStamp

		#monthDim = @dimension.monthStamp

		# @dimension.deltaPcnt = @cf.dimension (d) -> 
		# 	Math.round((d.))

		@dimension.dayStamp = @cf.dimension (d) -> d.dayStamp

		# @dimension.dayNames = @cf.dimension (d) ->
		# 	day = d.Weekday
		# 	name=["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
		# 	day+"."+name[day]

		@dimension.monthNames = @cf.dimension (d) ->
			month = d.monthNum
			name=["Jan","Feb","Mar","Apr","May","June","July","Aug","Sept","Oct","Nov","Dec"]
			name[month]

	buildMetrics: () ->
		@avgMonthOverTime = averageValues(@dimension.monthStamp,@metricName)
		@yearAvgs = averageValues(@dimension.yearName,@metricName)
		@hourAvgs = averageValues(@dimension.timeOfDay,@metricName+"_avg")
		@monthAvgs = averageValues(@dimension.monthNames,@metricName)
		@avgDayOverTime = averageValues(@dimension.dayStamp,@metricName)

	buildCharts: () ->

				# timeChart.renderlet () ->			
			# if timeChart.hasFilter() and timeChart.filter() != @timeSpan
				# @timeSpan = timeChart.filter()
				# setTimeout ( -> go.loadCalendar()),500
		go = @
		@charts.push(monthChart(@dimension.monthNames,@metricName,@displayName,@monthAvgs))
		@charts.push(yearChart(@dimension.yearName,@metricName,@displayName,@yearAvgs))
		

		timeChart = timeSeries(@dimension.monthStamp,@metricName,@displayName,@avgMonthOverTime)
		# debugger
		@charts.push(timeChart)

		for chart in @charts
			chart.renderlet () ->
				dc.events.trigger( -> 
					@timeSpan = timeChart.filter()
					setTimeout ( -> go.loadCalendar()),500
				)
				
				# dc.events.trigger ( -> console.log('event trigger'))

		@charts.push(hourChart(@dimension.timeOfDay,@metricName,@displayName,@hourAvgs))

	refreshCharts: () ->
		dc.filterAll()
		for chart in @charts
			chart.expireCache()
		@charts = []
		@buildMetrics()
		@buildCharts()
		# @loadCalendar()
		dc.renderAll()

	activateListeners: () ->
		go = @
		@inputBox = $("#searchArea .input-group input")[0]
		$("#timeSeries .buttons").on "click","button", ->
			go.metricName = $(this).attr("data-name")
			go.displayName = $(this).html()
			go.refreshCharts()

		$("#searchArea").on "click","button", ->
			queryString = go.inputBox.value
			go.getWordCount(queryString)

		$(@inputBox).keypress (e) ->
    if e.which == 13
        $("#searchArea button").click()

	loadCalendar: () ->
		console.log("in calendar")
		$("#cal-heatmap").children().remove()

		@cal = new CalHeatMap()

		begin = @dimension.dayStamp.bottom(1)[0].Date
		end = @dimension.dayStamp.top(1)[0].Date

		json = buildCalendarJson(@avgDayOverTime.all())
		values = _.values(json)
		max = _.max(values)
		#get max for avgs instead
		interval = max/8;
		
		numOfMonths = Math.ceil(((end - begin) / 31536000000)*12)

		@cal.init({
			domain: "month",
			subDomain: "x_day",
			start: begin,
			range: numOfMonths,
			legend: [interval, 2 * interval, 3 * interval, 4 * interval,5 * interval,6 * interval,7 * interval, max],
			legendColors: ["#efefef", "black"]
			cellSize: 12
			data: json
			dataType: "json"
		})

	getWordCount: (queryString) ->
		go = @
		queryObject = _.findWhere(@queries,{query:queryString})

		if queryObject
			renderWordCountGraph(queryObject)
		else
			$.ajax $SCRIPT_ROOT+'/newQuery',
			  data :
			    query : queryString
			  success  : (res, status, xhr) -> go.renderWordCountGraph(res,status,xhr)
			  error    : (xhr, status, err) -> console.log(err,status,xhr)
			  # complete : (xhr, status) ->

	renderWordCountGraph: (queryObject) ->
		console.log(queryObject)
		

		# cal.update(calFormattedJson)
		# console.log((new Date() - startTime)/1000)
		# console.log(new Date(2000, 0, 15))







# 