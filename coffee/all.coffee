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

  db = new Dashboard()
  db.parseData(data)
  dc.renderAll()
  db.activateListeners()
  # db.loadCalendar()

  dataSlice = data[0]
  console.log(dataSlice)
  $("a.months").click()
  $("a.search").click()
  
  console.log((new Date() - startTime)/1000)
)

  

