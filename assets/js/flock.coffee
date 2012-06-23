#= require vendor/d3.js
#= require d3.layout.flock.coffee

WIDTH = window.innerWidth
HEIGHT = window.innerHeight


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
  .append('svg:circle')
    .classed('boid', true)
    .attr('r', 2)
    .attr('cx', 100)
    .attr('cy', 100)

layout.start().on 'tick', ->
  sprites.attr('cx', (d) -> d.location.x)
  sprites.attr('cy', (d) -> d.location.y)
