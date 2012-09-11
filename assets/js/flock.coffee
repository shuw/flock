#= require vendor/d3.js
#= require d3.layout.flock.coffee

BOID_SIZE = 12
COLOR = d3.scale.category10()
TAIL_WIDTH_RADIANS = Math.PI / 10

# Instantiate 100 boids who start in the middle of the map, have a maxmimum
# speed of 2, maximum force of 0.05, and give them a reference to the
# processing instance so they can render themselves.
boids = ({} for i in [0..100])


window.start_flock = ->
  layout = d3.layout.flock()
    .size([window.innerWidth, window.innerHeight])
    .nodes(boids)

  window.onresize = -> layout.size([window.innerWidth, window.innerHeight])

  root = d3.select('#root')

  sprites = root.selectAll('circle').data(boids)
  sprites.enter()
    .append('svg:polygon')
      .classed('boid', true)
      .attr('r', 2)
      .attr('fill', (d, i) -> COLOR(i))

  layout.start().on 'tick', ->
    sprites.attr('points', (d) ->
      x = d.location.x
      y = d.location.y
      angle = Math.atan2(d.velocity.y, d.velocity.x) - Math.PI
      x1 = x + Math.cos(angle - TAIL_WIDTH_RADIANS) * BOID_SIZE
      y1 = y + Math.sin(angle - TAIL_WIDTH_RADIANS) * BOID_SIZE
      x2 = x + Math.cos(angle + TAIL_WIDTH_RADIANS) * BOID_SIZE
      y2 = y + Math.sin(angle + TAIL_WIDTH_RADIANS) * BOID_SIZE
      "#{x},#{y} #{x1},#{y1} #{x2},#{y2}"
    )
