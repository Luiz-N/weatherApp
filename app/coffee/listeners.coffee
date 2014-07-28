activateListeners = () ->
	$("#timeSeries .buttons").on "click","button", ->
		metricName = $(this).attr("data-name")
		displayName = $(this).html()
		buildCharts(metricName,displayName)

		dc.filterAll()
		dc.renderAll()
