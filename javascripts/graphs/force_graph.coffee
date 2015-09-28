---
---

class @ForceGraph
  width = 900
  height = 800
  nodeScale = 1.10

  constructor: () ->
    @color = d3.scale.category20();
    @force = d3.layout.force()
      .gravity(.05)
      .charge(-400)
      .linkDistance((d) -> d.distance * 10)
      .size([width, height])

  prepare: () ->
    @svg = d3.select('#force_graph').append('svg')
    .attr("width", width)
    .attr("height", height)

    @imageDefintions = @svg.append("defs")
    .attr("id", "imgdefs")

  drawGraph: () ->
    d3.json '/data.json', (error, data) =>
      throw error if error

      @images = for im in data.images
        @imageDefintions.append("pattern")
        .attr("id", im.id)
        .attr("height", 1)
        .attr("width", 1)
        .attr('viewBox', "0 0 #{im.width} #{im.height}")
        .attr("x", 0)
        .attr("y", 0)
        .attr('preserveAspectRatio','none')
        .append("image")
        .attr("height", im.height)
        .attr("width", im.width)
        .attr("xlink:href", im.url)

      @force.nodes(data.nodes)
        .links(data.links)
        .start()

      link = @svg.selectAll(".link")
        .data(data.links)
        .enter().append("line")
        .attr("class", "link")
        .style("stroke-width", (d) -> Math.sqrt(d.value) )

      node = @svg.selectAll(".node")
        .data(data.nodes)
        .enter().append("circle")
        .attr("class", "node")
        .attr("r", (d) -> d.size)
        .style("fill", (d) => if d.image?.length then "url(##{d.image})" else  @color(d.group))
        .call(@force.drag)


      node.on 'mouseover', (node) ->
        d3.select(this).transition()
        .duration(300)
        .attr('r', node.size * nodeScale)
        link.style 'stroke-width', (link) ->
          if (node == link.source || node == link.target) then 3 else 1

      node.on 'mouseout', (node) ->
        d3.select(this).attr('r', node.size)

      node.append("title").text( (d) -> d.name )

      @force.on "tick", () ->
        link.attr("x1", (d) -> d.source.x)
          .attr("y1", (d) -> d.source.y)
          .attr("x2", (d) -> d.target.x)
          .attr("y2", (d) -> d.target.y)

        node.attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)

  draw: () =>
    @prepare()
    @drawGraph()

