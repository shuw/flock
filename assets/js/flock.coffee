#= require vendor/d3.js
#= require vendor/underscore.js

w = window.innerWidth
h = window.innerHeight
n = 100
m = 12
degrees = 180 / Math.PI

spermatozoa = d3.range(n).map ->
  {
    vx: Math.random() * 2 - 1
    vy: Math.random() * 2 - 1
    path: d3.range(m).map -> [Math.random() * w, Math.random() * h]
    count: 0
  }

svg = d3.select('body').append('svg:svg')
    .attr('width', w)
    .attr('height', h)

g = svg.selectAll('g')
    .data(spermatozoa)
  .enter().append('svg:g')

head = g.append('svg:ellipse')
    .attr('rx', 6.5)
    .attr('ry', 4)

g.append('svg:path')
    .map((d) -> d.path.slice(0, 3))
    .attr('class', 'mid')

g.append('svg:path')
    .map((d) -> d.path)
    .attr('class', 'tail')

tail = g.selectAll('path')

d3.timer ->
  _(spermatozoa).each (spermatozoon) ->
    path = spermatozoon.path
    dx = spermatozoon.vx
    dy = spermatozoon.vy
    x = path[0][0] += dx
    y = path[0][1] += dy
    speed = Math.sqrt(dx * dx + dy * dy)
    count = speed * 10
    k1 = -5 - speed / 3

    # Bounce off the walls.
    spermatozoon.vx *= -1 if (x < 0 || x > w)
    spermatozoon.vy *= -1 if (y < 0 || y > h)

    # Swim!
    j = 0
    while ++j < m
      vx = x - path[j][0]
      vy = y - path[j][1]
      k2 = Math.sin(((spermatozoon.count += count) + j * 3) / 300) / speed

      path[j][0] = (x += dx / speed * k1) - dy * k2
      path[j][1] = (y += dy / speed * k1) + dx * k2
      speed = Math.sqrt((dx = vx) * dx + (dy = vy) * dy)

  head.attr 'transform', (d) -> 'translate(' + d.path[0] + ')rotate(' + Math.atan2(d.vy, d.vx) * degrees + ')'
  tail.attr 'd', (d) -> 'M' + d.join('L')
  false