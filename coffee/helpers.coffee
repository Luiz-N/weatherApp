averageValues = (dim,attr) ->
  reduceAddAvg = (attr) ->
    (p,v) ->
      # debugger;
      ++p.count
      p.sum += +v[attr]
      p.avg_sum += +v[attr+"_avg"]
      p.avg_avg = checkAvg(p,p.avg_sum)
      # p.avg_avg = p.avg_sum/p.count
      p.avg = checkAvg(p,p.sum)
      # p.avg = p.sum/p.count
      # p.avg = Math.round(p.sum)/p.count
      p
    
  reduceRemoveAvg = (attr) ->
    (p,v) ->
      --p.count
      p.sum -= +v[attr]
      p.avg_sum -= +v[attr+"_avg"]
      p.avg_avg = checkAvg(p,p.avg_sum)
      # p.avg_avg = p.avg_sum/p.count
      p.avg = checkAvg(p,p.sum)
      # p.avg = p.sum/p.count
      # p.avg = Math.round(p.sum)/p.count
      p

  reduceInitAvg = () -> {count:0, sum:0, avg:0, avg_sum:0, avg_avg:0}

  dim.group().reduce(reduceAddAvg(attr), reduceRemoveAvg(attr), reduceInitAvg)

precipReduceHack = (dim,attr) ->
  reduceAddAvg = (attr) ->
    (p,v) ->
      # debugger;
      ++p.count
      p.avg += +v[attr]
      p.avg_avg += +v[attr+"_avg"]
      # p.avg_avg = checkAvg(p,p.avg_sum)
      # p.avg = checkAvg(p,p.sum)
      # p.avg = Math.round(p.sum)/p.count
      p
    
  reduceRemoveAvg = (attr) ->
    (p,v) ->
      --p.count
      p.avg -= +v[attr]
      p.avg_avg -= +v[attr+"_avg"]
      # p.avg_avg = checkAvg(p,p.avg_sum)
      # p.avg = checkAvg(p,p.sum)
      # p.avg = Math.round(p.sum)/p.count
      p

  reduceInitAvg = () -> {avg:0, avg_avg:0}

  dim.group().reduce(reduceAddAvg(attr), reduceRemoveAvg(attr), reduceInitAvg)



# orderByAvg = (p) ->
#   p.avg


getDeltas = (dim,attr) ->
  reduceAddAvg = (attr) ->
    (p,v) ->
      ++p.count
      p.sum += +(+v[attr]).toFixed(4)
      p.avg = checkAvg(p,p.sum)
      # p.delta = 10
      # p.delta = +((p.avg-v[attr+"_avg"])/v[attr+"_avg"]*100).toFixed(3)
      p.delta = +((p.avg-v[attr+"_avg"])/v[attr+"_avg"]*100).toFixed(4)
      # if p.delta%1 == 0
        # debugger
        # console.log(typeof(p.delta))
        # p.delta = 0
      p
    
  reduceRemoveAvg = (attr) ->
    (p,v) ->
      --p.count
      p.sum -= +(+v[attr]).toFixed(4)
      p.avg = checkAvg(p,p.sum)
      # p.delta = 0
      p.delta = +((p.avg-v[attr+"_avg"])/v[attr+"_avg"]*100).toFixed()
      if p.delta%1 == 0
        # debugger
        # console.log(typeof(p.delta))
        p.delta = 0
      p

  reduceInitAvg = () -> {count:0, sum:0, avg:0, delta:0}

  dim.group().reduce(reduceAddAvg(attr), reduceRemoveAvg(attr), reduceInitAvg)


checkAvg = (p,sum) ->
  if sum < 0.0000001
    p.avg = 0
  else
    p.avg = sum/p.count
  p.avg


buildCalendarJson = (metricArray) ->
  calFormattedJson = {}
  for object in metricArray
    calFormattedJson[String(object.key.getTime()).slice(0,-3)] = +object.value.avg.toFixed(2)
  calFormattedJson    

getColorIndex = (diff) ->
  abs_diff = Math.abs(diff)
  if abs_diff < .025
      3
  else if abs_diff < .05
    if diff > 0
      2
    else 
      4
  else if abs_diff < .075
    if diff > 0
      1
    else
      5
  else
    if diff > 0
      0
    return 6

calculateIntervals = (metric) ->
  max = _.max(_.pluck(_.pluck(metric.all(),'value'),'avg_avg'))
  #get max for avgs instead
  interval = max/10
  [interval, 2 * interval, 3 * interval, 4 * interval,5 * interval,6 * interval,7 * interval,8*interval,9*interval, max]

months = (currentMonth) ->
  # currentMonth = (@dimension.dayStamp.bottom(1)[0].Date).getMonth()
  # domain.push(@monthArray[firstMonth])
  monthArray = ["Jan","Feb","Mar","Apr","May","June","July","Aug","Sept","Oct","Nov","Dec"]

  monthsLeft = 12
  currentMonth -= 1
  domain = while monthsLeft -= 0
    monthsLeft -= 1
    if currentMonth < 11
      currentMonth += 1
      # console.log(months[currentMonth])
      monthArray[currentMonth]
    else
      currentMonth = 0
      # console.log(months[currentMonth])
      monthArray[currentMonth]



buildFakeGroup = (array) ->
  g = []
  for obj in array
    monthStamp = d3.time.format("%Y-%m").parse(obj['key'])
    g.push({key:monthStamp,value:obj['value']})
  return {all: () -> g}

flashFloodArray = [{'key': '2009-01', 'value': 0}, {'key': '2009-06', 'value': 0}, {'key': '2009-07', 'value': 514}, {'key': '2009-08', 'value': 576}, {'key': '2009-09', 'value': 706}, {'key': '2009-10', 'value': 473}, {'key': '2009-11', 'value': 831}, {'key': '2009-12', 'value': 528}, {'key': '2010-01', 'value': 499}, {'key': '2010-02', 'value': 357}, {'key': '2010-03', 'value': 755}, {'key': '2010-04', 'value': 670}, {'key': '2010-05', 'value': 486}, {'key': '2010-06', 'value': 649}, {'key': '2010-07', 'value': 652}, {'key': '2010-08', 'value': 1257}, {'key': '2010-09', 'value': 814}, {'key': '2010-10', 'value': 326}, {'key': '2010-11', 'value': 455}, {'key': '2010-12', 'value': 656}, {'key': '2011-01', 'value': 505}, {'key': '2011-02', 'value': 499}, {'key': '2011-03', 'value': 537}, {'key': '2011-04', 'value': 800}, {'key': '2011-05', 'value': 1416}, {'key': '2011-06', 'value': 714}, {'key': '2011-07', 'value': 551}, {'key': '2011-08', 'value': 1120}, {'key': '2011-09', 'value': 1137}, {'key': '2011-10', 'value': 484}, {'key': '2011-11', 'value': 365}, {'key': '2011-12', 'value': 356}, {'key': '2012-01', 'value': 437}, {'key': '2012-02', 'value': 263}, {'key': '2012-03', 'value': 370}, {'key': '2012-04', 'value': 287}, {'key': '2012-05', 'value': 525}, {'key': '2012-06', 'value': 715}, {'key': '2012-07', 'value': 692}, {'key': '2012-08', 'value': 823}, {'key': '2012-09', 'value': 372}, {'key': '2012-10', 'value': 840}, {'key': '2012-11', 'value': 154}, {'key': '2012-12', 'value': 166}, {'key': '2013-01', 'value': 326}, {'key': '2013-02', 'value': 306}, {'key': '2013-03', 'value': 0}, {'key': '2013-04', 'value': 53}, {'key': '2013-05', 'value': 93}, {'key': '2013-06', 'value': 164}, {'key': '2013-07', 'value': 58}, {'key': '2013-08', 'value': 180}, {'key': '2013-09', 'value': 285}, {'key': '2013-10', 'value': 212}, {'key': '2013-11', 'value': 52}, {'key': '2013-12', 'value': 77}, {'key': '2014-01', 'value': 37}, {'key': '2014-02', 'value': 90}, {'key': '2014-03', 'value': 33}, {'key': '2014-04', 'value': 0}, {'key': '2014-05', 'value': 0}, {'key': '2014-06', 'value': 0}, {'key': '2014-07', 'value': 151}]
hurricaneSandyArray = [{'key': '2009-01', 'value': 0}, {'key': '2009-06', 'value': 0}, {'key': '2009-07', 'value': 95}, {'key': '2009-08', 'value': 52}, {'key': '2009-09', 'value': 47}, {'key': '2009-10', 'value': 48}, {'key': '2009-11', 'value': 62}, {'key': '2009-12', 'value': 55}, {'key': '2010-01', 'value': 65}, {'key': '2010-02', 'value': 43}, {'key': '2010-03', 'value': 88}, {'key': '2010-04', 'value': 50}, {'key': '2010-05', 'value': 161}, {'key': '2010-06', 'value': 133}, {'key': '2010-07', 'value': 115}, {'key': '2010-08', 'value': 112}, {'key': '2010-09', 'value': 80}, {'key': '2010-10', 'value': 65}, {'key': '2010-11', 'value': 62}, {'key': '2010-12', 'value': 59}, {'key': '2011-01', 'value': 79}, {'key': '2011-02', 'value': 56}, {'key': '2011-03', 'value': 36}, {'key': '2011-04', 'value': 58}, {'key': '2011-05', 'value': 79}, {'key': '2011-06', 'value': 97}, {'key': '2011-07', 'value': 118}, {'key': '2011-08', 'value': 90}, {'key': '2011-09', 'value': 42}, {'key': '2011-10', 'value': 58}, {'key': '2011-11', 'value': 57}, {'key': '2011-12', 'value': 89}, {'key': '2012-01', 'value': 78}, {'key': '2012-02', 'value': 42}, {'key': '2012-03', 'value': 42}, {'key': '2012-04', 'value': 72}, {'key': '2012-05', 'value': 78}, {'key': '2012-06', 'value': 80}, {'key': '2012-07', 'value': 71}, {'key': '2012-08', 'value': 71}, {'key': '2012-09', 'value': 53}, {'key': '2012-10', 'value': 823}, {'key': '2012-11', 'value': 723}, {'key': '2012-12', 'value': 666}, {'key': '2013-01', 'value': 419}, {'key': '2013-02', 'value': 378}, {'key': '2013-03', 'value': 0}, {'key': '2013-04', 'value': 56}, {'key': '2013-05', 'value': 80}, {'key': '2013-06', 'value': 20}, {'key': '2013-07', 'value': 20}, {'key': '2013-08', 'value': 58}, {'key': '2013-09', 'value': 172}, {'key': '2013-10', 'value': 122}, {'key': '2013-11', 'value': 26}, {'key': '2013-12', 'value': 34}, {'key': '2014-01', 'value': 54}, {'key': '2014-02', 'value': 14}, {'key': '2014-03', 'value': 16}, {'key': '2014-04', 'value': 0}, {'key': '2014-05', 'value': 0}, {'key': '2014-06', 'value': 0}, {'key': '2014-07', 'value': 12}]
