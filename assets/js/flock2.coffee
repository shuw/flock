#= require vendor/d3.js
#= require vendor/processing.js
#= require vector.coffee

# Ported almost directly from http://processingjs.org/learning/topic/flocking
# thanks a whole lot to Craig Reynolds and Daniel Shiffman


NEIGHBOUR_RADIUS = 50
DESIRED_SEPARATION = 6
SEPARATION_WEIGHT = 2
ALIGNMENT_WEIGHT = 1
COHESION_WEIGHT = 1
MAX_FORCE = 0.05
MAX_SPEED = 2


class Boid
  location: false
  velocity: false
  r: 2 # "radius" of the triangle

  render: () ->
    # Draw a triangle rotated in the direction of velocity
    theta = @velocity.heading() + @p.radians(90)
    @p.fill(70)
    @p.stroke(255,255,255)
    @p.pushMatrix()
    @p.translate(@location.x,@location.y)
    @p.rotate(theta)
    @p.beginShape(@p.TRIANGLES)
    @p.vertex(0, -1 * @r *2)
    @p.vertex(-1 * @r, @r * 2)
    @p.vertex(@r, @r * 2)
    @p.endShape()
    @p.popMatrix()

  constructor: (loc, processing) ->
    @velocity = new Vector(Math.random()*2-1,Math.random()*2-1)
    @location = loc.copy()
    @p = processing

    twor = @r * 2

    @wrapDimensions =
      north:  -twor
      south:  @p.height + twor
      west:   -twor
      east:   @p.width + twor
      width:  @p.width + 2*twor
      height: @p.height + 2*twor

  # Called every frame. Calculates the acceleration using the flock method,
  # and moves the boid based on it.
  step: (neighbours) ->
    acceleration = @flock(neighbours)
    @velocity.add(acceleration).limit(MAX_SPEED) # Limit the maximum speed at which a boid can go
    @location.add(@velocity)
    @_wrapIfNeeded()

  # Implements the flocking algorthim by collecting the three components
  # and returning a weighted sum.
  flock: (neighbours) ->
    separation = @separate(neighbours).multiply(SEPARATION_WEIGHT)
    alignment = @align(neighbours).multiply(ALIGNMENT_WEIGHT)
    cohesion = @cohere(neighbours).multiply(COHESION_WEIGHT)
    return separation.add(alignment).add(cohesion)

  # Called to get the cohesion component of the acceleration
  cohere: (neighbours) ->
    sum = new Vector
    count = 0
    for boid in neighbours
      d = @location.distance(boid.location)
      if d > 0 and d < NEIGHBOUR_RADIUS
        sum.add(boid.location)
        count++

    if count > 0
      return @steer_to sum.divide(count)
    else
      return sum # Empty vector contributes nothing

  steer_to: (target) ->
    desired = Vector.subtract(target, @location) # A vector pointing from the location to the target
    d = desired.magnitude()  # Distance from the target is the magnitude of the vector

    # If the distance is greater than 0, calc steering (otherwise return zero vector)
    if d > 0
      desired.normalize()

      # Two options for desired vector magnitude (1 -- based on distance, 2 -- maxspeed)
      if d < 100.0
        desired.multiply(MAX_SPEED*(d/100.0)) # This damping is somewhat arbitrary
      else
        desired.multiply(MAX_SPEED)

      # Steering = Desired minus Velocity
      steer = desired.subtract(@velocity)
      steer.limit(MAX_FORCE)  # Limit to maximum steering force
    else
      steer = new Vector(0,0)

    return steer

  # Alignment component for the frame's acceleration
  align: (neighbours) ->
    mean = new Vector
    count = 0
    for boid in neighbours
      d = @location.distance(boid.location)
      if d > 0 and d < NEIGHBOUR_RADIUS
        mean.add(boid.velocity)
        count++

    mean.divide(count) if count > 0
    mean.limit(MAX_FORCE)
    return mean

  # Separation component for the frame's acceleration
  separate: (neighbours) ->
    mean = new Vector
    count = 0
    for boid in neighbours
      d = @location.distance(boid.location)
      if d > 0 and d < DESIRED_SEPARATION
        # Normalized, weighted by distance vector pointing away from the neighbour
        mean.add Vector.subtract(@location,boid.location).normalize().divide(d)
        count++

    mean.divide(count) if count > 0
    mean

  _wrapIfNeeded: ->
    if @location.x < @wrapDimensions.west
      @location.x = @wrapDimensions.east

    if @location.y < @wrapDimensions.north
      @location.y = @wrapDimensions.south

    if @location.x > @wrapDimensions.east
      @location.x = @wrapDimensions.west

    if @location.y > @wrapDimensions.south
      return @location.y = @wrapDimensions.north


# flock function, passed the Processing instance by Processing itself
flock = (processing) ->
  processing.size(window.innerWidth, window.innerHeight)
  start = new Vector(processing.width/2,processing.height/2)

  # Instantiate 100 boids who start in the middle of the map, have a maxmimum 
  # speed of 2, maximum force of 0.05, and give them a reference to the 
  # processing instance so they can render themselves.
  boids = for i in [0..300]
    new Boid(start, processing)

  processing.draw = ->
    processing.background(255)
    for boid in boids
      boid.step(boids)
      boid.render()
    true


canvas = d3.select('canvas#flockingDemo')[0][0]
processingInstance = new Processing(canvas, flock)
