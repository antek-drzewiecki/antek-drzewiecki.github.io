---
---

class @ForceGraph
  width = 900
  height = 800
  nodeScale = 1.08

  constructor: () ->
    @color = d3.scale.category20();
    @force = d3.layout.force()
      .gravity(.05)
      .charge(-400)
      .linkDistance((d) -> d.distance * 10)
      .size([width, height])

    @breath = (element, node) ->
      console.log(element)
      console.log(node)


  prepare: () ->
    @svg = d3.select('#force_graph').append('svg')
    .attr("width", width)
    .attr("height", height)

    @imageDefintions = @svg.append("defs")
    .attr("id", "imgdefs")

  drawGraph: () ->
    d3.json '/data.json', (error, data) =>
      throw error if error

      images = @svg.selectAll(".patterns")
        .data(data.images)
        .enter()
        .append("pattern")
        .attr("class", '.pattern')
        .attr("id", (d) -> d.id)
        .attr("height", 1)
        .attr("width", 1)
        .attr('viewBox', (d) -> "0 0 #{d.width} #{d.height}")
        .attr("x", 0)
        .attr("y", 0)
        .attr('preserveAspectRatio','none')
        .append("image")
        .attr("height", (d) -> d.height)
        .attr("width", (d) -> d.width)
        .attr("xlink:href", (d) -> d.url)

      @force.nodes(data.nodes)
        .links(data.links)
        .start()

      link = @svg.selectAll(".link")
        .data(data.links)
        .enter().append("line")
        .attr("class", "link")
        .style("stroke-width", (d) -> Math.sqrt(d.value) )

      nodes = @svg.selectAll("g.node")
        .data(data.nodes)

      nodes.exit().remove()

      nodeGroup = nodes.enter()
        .append("svg:g")
        .attr('class', 'nodegroup')
        .call(@force.drag)

      # The normal nodes - image nodes.
      nodeGroup.filter (d) -> d.type == "image"
        .append("circle")
        .attr("class", "node")
        .attr("r", (d) -> d.size)
        .style("fill", (d) => if d.type_id?.length then "url(##{d.type_id})" else  @color(d.group))

      # The textnodes
      textNodes = nodeGroup.filter (d) -> d.type == "text"
      textNodes.append("circle")
      .attr("class", "node")
      .attr("r", (d) -> d.size)
      .style("fill", (d) => if d.type_id?.length then "url(##{d.type_id})" else  @color(d.group))

      textNodes.append("text")
      .attr("dx", 0)
      .attr("dy", ".35em")
      .attr("text-anchor", "middle")
      .style("fill", "white")
      .text((d) -> d.name)

      # append node title.
      nodes.append("title").text( (d) -> d.name )

      nodes.on 'click', (node) ->
        return if (d3.event.defaultPrevented)
        window.location = node.url if node.url?.length

      nodes.on 'mouseover', (node) ->
        d3.select(this).select('circle').transition()
        .duration(300)
        .attr 'r', node.size * nodeScale
        d3.select(this).select('text').transition()
        .duration(400)
        .text (d) -> d.altname
        link.style 'stroke-width', (link) ->
          if (node == link.source || node == link.target) then 3 else 1

      nodes.on 'mouseout', (node) ->
        d3.select(this).select('text').text((d) -> d.name)
        d3.select(this).select('circle').attr('r', node.size)

      @force.on "tick", () ->
        link.attr("x1", (d) -> d.source.x)
          .attr("y1", (d) -> d.source.y)
          .attr("x2", (d) -> d.target.x)
          .attr("y2", (d) -> d.target.y)

        nodes.attr "transform", (d) ->
          "translate(#{d.x}, #{d.y})"

  draw: () =>
    @prepare()
    @drawGraph()

