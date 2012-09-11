#= require vendor/d3.js
#= require d3.layout.flock.coffee

WIDTH = window.innerWidth
HEIGHT = window.innerHeight
BOID_SIZE = 8

# Instantiate 100 boids who start in the middle of the map, have a maxmimum
# speed of 2, maximum force of 0.05, and give them a reference to the
# processing instance so they can render themselves.
boids = ({} for i in [0..100])

layout = d3.layout.flock()
  .size([WIDTH, HEIGHT])
  .nodes(boids)

root = d3.select('#root')
    .attr('width', WIDTH)
    .attr('height', HEIGHT)

sprites = root.selectAll('circle').data(boids)
sprites.enter()
  .append('svg:polygon')
    .classed('boid', true)
    .attr('r', 2)


TAIL_WIDTH_RADIANS = Math.PI / 10
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
