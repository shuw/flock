COLOR = d3.scale.category10()

# Just instantiate 100 empty boids
boids = boids = ({weight: Math.pow(Math.random() * 0.6, 2) + 0.8} for i in [0..100])

debugger
sprites = d3.select('#root').selectAll('circle').data(boids)
sprites.enter()
  .append('svg:polygon')
    .classed('boid', true)
    .attr('r', 2)
    .attr('fill', (d, i) -> COLOR(i) )
    .attr('points', (d) -> "0,0 -#{12 * d.weight},#{4 * d.weight} -#{12 * d.weight},-#{4 * d.weight}")

boids.push im_a_mouse: true, weight: 10 # Let's make the mouse a boid

layout = d3.layout.flock()
  .size([window.innerWidth, window.innerHeight])
  .nodes(boids)

window.onresize = -> layout.size([window.innerWidth, window.innerHeight])

layout.start().on 'tick', ->
  sprites.attr('transform', (d) ->
    "translate(#{d.location.x}, #{d.location.y})" +
    "rotate(#{Math.atan2(d.velocity.y, d.velocity.x) * 180 / Math.PI})"
  )

window.onmousemove = (e) ->
  boids[101].location.x = e.x
  boids[101].location.y = e.y
