## Introduction

A re-usable D3 [flocking](http://www.red3d.com/cwr/boids/) layout based on [a Processing implementation by Harry](http://harry.me/2011/02/17/neat-algorithms---flocking).

## Example usage

    boids = ({} for i in [0..100])

    layout = d3.layout.flock()
      .size([WIDTH, HEIGHT])
      .nodes(boids)

    sprites = d3.select('#root').selectAll('circle').data(boids)
    sprites.enter()
      .append('svg:circle')
        .classed('boid', true)
        .attr('r', 2)
        .attr('cx', 100)
        .attr('cy', 100)

    layout.start().on 'tick', ->
      sprites.attr('cx', (d) -> d.location.x)
      sprites.attr('cy', (d) -> d.location.y)

[View a live example](http://shuw.github.com/)


## Install this project

    npm install
    node app.js
    open http://localhost:5000