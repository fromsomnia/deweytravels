// construct the DeweyGraph
function DeweyGraph (selector, data) {

	var svg,
		container,
		links,
		nodes,
		linkContainers,
		lines,
		nodeContainers,
		anchors,
		circles,
		texts;

	var data,
		width,
		height,
		force;

	function init () {

    // calculate width and height each time directive initiates
		width = $(window).width();
		height = $(window).height();	  

	  // svg containers
	  d3.select(selector)
	  	.selectAll('*')
	  	.remove();
	  svg = d3.select(selector)
	    .append('svg')
	    .attr('width', '100%')
	    .attr('height', '100%');
	  container = svg.append('g')
	    .attr('class', 'graph-container');

	}

	function createNodes () {

		nodes = container.append('g')
      .attr('class', 'nodes');

    nodeContainers = nodes.selectAll('g')
      .data(data.nodes)
      .enter()
      .append('g');

    anchors = nodeContainers.append('a')
      .attr('xlink:href', function (datum) {
        if (datum.first_name) {
          return '#/users/' + datum.id;
        }
        return '#/topics/' + datum.id;
      });

    circles = anchors.append('circle')
      .attr('class', 'node')
      .attr('r', function (datum) {
        if (datum.first_name) {
          datum.r = 10;
        } else {
          datum.r = 60;
        }
        return datum.r;
      })
      .attr('fill', function (datum) {
        if (datum.first_name) {
          return '#FFFF66';
        }
        return '#00CC66';
      });

    texts = nodeContainers.append('text')
      .attr('pointer-events', 'none')
      .text(function (datum) {
        if (datum.first_name) {
          return datum.first_name + ' ' + datum.last_name;
        }
        return datum.title;
      });

	}

	function createLinks () {

    links = container.append('g')
      .attr('class', 'links');

    linkContainers = links.selectAll('g')
      .data(data.links)
      .enter()
      .append('g');

    lines = linkContainers.append('line')
      .attr('class', 'link')
      .attr('stroke-width', function (datum) {
        return 2;
      });

	}

	function initAnimations () {

		force = d3.layout
		  .force()
		  .charge(-1200)
		  .linkDistance(205)
		  .size([width, height]);

    // apply force animations on graph
    force.nodes(data.nodes)
      .links(data.links)
      .theta(1)
      .on('tick', tick)
      .start();
	}

  // tick function calculations position values for graph elements
	function tick () {
    nodeContainers.attr('transform', function (datum) {
      datum.x = Math.max(datum.r, Math.min(width - datum.r, datum.x));
      datum.y = Math.max(datum.r, Math.min(height - datum.r, datum.y));
      return 'translate(' + datum.x + ',' + datum.y + ')';
    });
    texts.attr('dx', function (datum) {
        return '-' + $(this).width() / 2;
      });
    lines.attr('x1', function (datum) {
        return datum.source.x;
      })
      .attr('y1', function (datum) {
        return datum.source.y;
      })
      .attr('x2', function (datum) {
        return datum.target.x;
      })
      .attr('y2', function (datum) {
        return datum.target.y;
      });
	}

	function render (newData) {
		data = newData;
		init();
		createLinks();
		createNodes();
		initAnimations();
	}

	(function () {
		render(data);
	})();

	return {

		svg: svg,
		container: container,
		nodes: nodes,
		nodeContainers: nodeContainers,
		anchors: anchors,
		circles: circles,
		texts: texts,
		links: links,
		linkContainers: linkContainers,
		lines: lines,
		
		render: render,

	};

};