COLOR = d3.scale.category10()

# Just instantiate 100 empty boids with random weights
boids = boids = ({weight: Math.pow(Math.random() * 0.6, 2) + 0.8} for i in [0..100])

sprites = d3.select('#root').selectAll('.boid').data(boids)
sprites.enter()
  .append('svg:polygon')
    .classed('boid', true)
    .attr('r', 2)
    .attr('fill', (d, i) -> COLOR(i) )
    .attr('points', (d) -> "0,0 -#{12 * d.weight},#{4 * d.weight} -#{12 * d.weight},-#{4 * d.weight}")

# Let's add the mouse as an invisible boid
boids.push(im_a_mouse: true, weight: 10)

layout = d3.layout.flock()
  .size([window.innerWidth, window.innerHeight])
  .nodes(boids)
layout.start().on 'tick', ->
  sprites.attr('transform', (d) ->
    "translate(#{d.location.x}, #{d.location.y})" +
    "rotate(#{Math.atan2(d.velocity.y, d.velocity.x) * 180 / Math.PI})"
  )

window.onresize = ->
  layout.size([window.innerWidth, window.innerHeight])
window.onmousemove = (e) ->
  boids[101].location.x = e.x
  boids[101].location.y = e.y
