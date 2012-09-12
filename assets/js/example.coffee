BOID_SIZE = 12
COLOR = d3.scale.category10()
TAIL_WIDTH_RADIANS = Math.PI / 10

# Just instantiate 100 empty boids
boids = boids = ({} for i in [0..100])

root = d3.select('#root')

sprites = root.selectAll('circle').data(boids)
sprites.enter()
  .append('svg:polygon')
    .classed('boid', true)
    .attr('r', 2)
    .attr('fill', (d, i) -> COLOR(i) )
boids.push({im_a_mouse: true}) # Let's make the mouse a boid

layout = d3.layout.flock()
  .size([window.innerWidth, window.innerHeight])
  .nodes(boids)

window.onresize = -> layout.size([window.innerWidth, window.innerHeight])

layout.start().on 'tick', ->
  sprites.attr 'points', (d) ->
    x = d.location.x
    y = d.location.y
    angle = Math.atan2(d.velocity.y, d.velocity.x) - Math.PI
    x1 = x + Math.cos(angle - TAIL_WIDTH_RADIANS) * BOID_SIZE
    y1 = y + Math.sin(angle - TAIL_WIDTH_RADIANS) * BOID_SIZE
    x2 = x + Math.cos(angle + TAIL_WIDTH_RADIANS) * BOID_SIZE
    y2 = y + Math.sin(angle + TAIL_WIDTH_RADIANS) * BOID_SIZE

    x + ',' + y + ' ' + x1 + ',' + y1 + ' ' + x2 + ',' + y2

window.onmousemove = (e) ->
  boids[100].location.x = e.x
  boids[100].location.y = e.y
