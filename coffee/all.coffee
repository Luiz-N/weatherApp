ndx = null
all = null
dateDim = null
dayOfWeek = null
avgTempByMonth = null
dataSlice = null
chart = null
monthNameDim = null
monthDim = null
seasonDim = null
timeChart = null
seasonChart = null
all = null
db = null
cal = null
startTime = new Date()
(($) ->) jQuery
t1 = null


parseDate = d3.time.format("%Y-%m-%d %H:%M:%S").parse

d3.csv("static/aggedWeather.csv", (data) ->
  #d.Date = parseDate(d.Date)

  #data = jsondata.map (d) -> 
  # cf = crossfilter(data)
  # all = cf.groupAll()
  # for d in data
  #   #console.log(d)
  #   d.Date = parseDate(d.Date)
  #   d.monthNum = d.Date.getMonth()
  #   d.Year = d.Date.getFullYear()
  #   d.monthStamp = d3.time.month(d.Date)
  #   d.dayStamp = d3.time.day(d.Date)
  #   d.weekStamp = d3.time.week(d.Date)
    #d.Temp = +d.Temp
    #d.Temp_Feels = +d.Temp_Feels
    #d.Wind = +d.Wind
    #d.Precip = +d.Precip
    #d.Solar = +d.Solar
    #debugger
  db = new Dashboard()
  db.parseData(data)
  dc.renderAll()
  db.activateListeners()
  # db.loadCalendar()

  dataSlice = data[0]
  console.log(dataSlice)
  console.log((new Date() - startTime)/1000)
)
  # yearlyDimension = cf.dimension (d) -> d.Year

  # seasonDim = cf.dimension (d) -> 
  #       month = d.monthNum
  #       if (month == 11 or month == 0 or month == 1)
  #           return "Winter";
  #       else if (month >= 2 && month <= 4)
  #           return "Spring";
  #       else if (month >= 5 && month <= 7)
  #           return "Summer";
  #       else
  #           return "Fall";
  
  # monthDim = cf.dimension (d) -> d.monthStamp

  # weekDim = cf.dimension (d) -> d.weekStamp

  # dayDim = cf.dimension (d) -> d.dayStamp
  



  

  # dayOfWeek = cf.dimension (d) ->
  #   day = d.Weekday
  #   name=["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
  #   day+"."+name[day]

  # months = cf.dimension (d) ->
  #   month = d.monthNum
  #   name=["Jan","Feb","Mar","Apr","May","June","July","Aug","Sept","Oct","Nov","Dec"]
  #   month+"."+name[month]
     

    
  #monthChart = dc.rowChart("#monthChart")
  
  # monthChart
  #   .width(580)
  #   .height(580)
  #   .margins({top: 20, left: 10, right: 10, bottom: 20})
  #   .dimension(months)
  #   .group(avgTempByMonth)
  #   .valueAccessor (d) ->
  #     d.value.avg
  #   #.stack(avgTempByMonth, "Violent Crime", (d) -> d.value.sum)
  #   #.ordinalColors(['#3182bd', '#6baed6', '#9ecae1', '#c6dbef', '#dadaeb'])
  #   .ordering (d) -> d.value.avg
  #   .label (d) ->
  #     d.key.split(".")[1]
  #   .title (d) ->
  #     #console.log(d)
  #     d.value.avg
  #   .elasticX(true)
  #   .xAxis().ticks(4);



  # activateListeners()
  # buildCharts("Temp","Temperature (F)")
  # dc.renderAll()
  # #$("#timeSeries .buttons button:first").click()



# buildCharts = (metric,displayName) ->
#   chart = timeSeries(metric,displayName)

#   seasonsChart(metric,displayName) 

  


# activateListeners = () ->
#   console.log(activated)
#   $("#timeSeries .buttons").on "click","button", -> console.log(this)


