//Define the SVG area dimensions
var svgWidth = 1000;
var svgHeight = 1000;

//Define the dimension of the chart and chart area
var margin = {top: 25, right: 40, bottom: 50, left: 100};

var chartWidth = svgWidth - margin.left - margin.right;
var chartHeight = svgHeight - margin.top - margin.bottom;

//Create a SVG warper and append the SVG group that will hold our chart and 
//the latter by the top and right margins.
var svg = d3
    .select(".chart")
    .append("svg")
    .attr("width", svgWidth)
    .attr("height", svgHeight)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

var chart = svg.append("g");

//Append a div to the body to create tooltips & assign it a class
d3.select(".chart").append("div").attr("class", "tooltip").style("opacity", 1);

//Load the CSV file.
d3.csv("data.csv", function(error,healthData){
    if (error) throw error;

	healthData.forEach(function(data){
		// data.abbr = data.abbr
		data.depression = +data.depression;
		data.education = +data.education;
	});


	//Create a scale
	var xLinearScale = d3.scaleLinear().range([chartHeight, 0]);
	var yLinearScale = d3.scaleLinear().range([0, chartWidth]);

	//Create the axis functions
	var bottomAxis = d3.axisBottom(yLinearScale);
	var leftAxis = d3.axisLeft(xLinearScale);

	//Scale the domain
	xLinearScale.domain([0, d3.max(healthData, function(data){
		return +data.depression;
	})]);

	yLinearScale.domain([0, d3.max(healthData,function(data){
		return +data.education;
	})]);

	//Associate the tooltips with the data
    var toolTip = d3
        .tip()
        .attr("class", "toolTip")
        .offset([80, -60])
        .html(function(data) {
            var state = data.state;
	        var depressionRate = +data.depression;
	        var education = +data.education;
	        return (state + "<br> Depression Rate: " + depressionRate +  '<br> College Education: ' + education);
	  });

	chart.call(toolTip);

	//Function to append the data points to the chart
    chart.selectAll("circle")
        .data(healthData)
	    .enter().append("circle")
	    .attr("cx", function(data, index) {
	        return xLinearScale(data.depression);
	    })
	    .attr("cy", function(data, index) {
	        return yLinearScale(data.education);
	    })
	    .attr("r", "15")
	    .attr("fill","lightblue")
	    .style("opacity", 0.5)
    
        // display tooltip on click
		.on("mouseenter", function(data) {
			toolTip.show(data);
		})
		// hide tooltip on mouseout
		.on("mouseout", function(data, index) {
			toolTip.hide(data);
		});

	//Append the bottom axis.
	chart.append("g")
	  .attr("transform", `translate(0, ${chartHeight})`)
	  .call(bottomAxis);

  //Append the left axis.
  chart.append("g")
    .call(leftAxis);

  //Append the y-axis labels.
  chart.append("text")
		.attr("transform", "rotate(-90)")
		.attr("y", 0 - margin.left + 40)
		.attr("x", 0 - chartHeight + 40)
		.attr("dy", "1em")
		.attr("class", "axisText")
		.text("Percentage with a college education");

     //Append the x-axis labels.
	chart.append("text")
		.attr("transform", "translate(" + (chartWidth/4) + "," + (chartHeight + margin.top + 5) + ")") 
		.attr("class", "axisText")
		.text("Percentage with depression");
	
		chart.append("text")
		.style("text-anchor", "middle")
		.style("font-size", "12px")
		.selectAll("tspan")
		.data(healthData)
		.enter()
		.append("tspan")
		.attr("x", function(data) {
				return xLinearScale(data.depression);
		})
		.attr("y", function(data) {
				return yLinearScale(data.education);
		})
		.text(function(data) {
				return data.abbr
		});
});