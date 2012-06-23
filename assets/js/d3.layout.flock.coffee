# This code here is forked from:
#   http://harry.me/2011/02/17/neat-algorithms---flocking
# which is a Processing-based implementation of the Boids algorithm by Craig Reynolds
#   http://www.red3d.com/cwr/boids/

#= require vector.coffee

NEIGHBOUR_RADIUS = 50
DESIRED_SEPARATION = 6
SEPARATION_WEIGHT = 2
ALIGNMENT_WEIGHT = 1
COHESION_WEIGHT = 1
MAX_FORCE = 0.05
MAX_SPEED = 2

class Flock

  constructor: ->
    @_size = [256, 256]
    @_event = d3.dispatch 'tick'
    @_boids = []
    @r(2)

  on: () -> @_event.on.apply @_event, arguments; @

  # radius
  r: (x) ->
    @_r = x
    @_update_borders()
    @

  # size [width, height]
  size: (x) ->
    return @_size unless arguments.length
    @_size = x
    @_update_borders()
    @

  # nodes
  nodes: (x) ->
    return @_boids unless arguments.length
    @_boids = x
    # center position and random velocity unless otherwise specified
    for b in @_boids
      b.location ||= new Vector @_size[0] / 2, @_size[1] / 2
      b.velocity = new Vector(Math.random()*2-1,Math.random()*2-1)
    @

  # start
  start: ->
    @_started = true
    d3.timer =>
      # TODO: more efficient calculation of neighbors
      @_update(@_boids)
      @_event.tick type: 'tick'
      !@_started
    @

  stop: ->
    @_started = false
    @

  _update_borders: ->
    two_r = @_r * 2

    @_wrap_borders =
      north:  -two_r
      south:  @_size[1] + two_r
      west:   -two_r
      east:   @_size[0] + two_r
      width:  @_size[1] + 2*two_r
      height: @_size[1] + 2*two_r

  _update: (neighbours) ->
    for b in @_boids
      acceleration = @_flock(b, neighbours)
      b.velocity.add(acceleration).limit(MAX_SPEED) # Limit the maximum speed at which a boid can go
      b.location.add(b.velocity)
      @_wrapIfNeeded(b)

  # Implements the flocking algorthim by collecting the three components
  # and returning a weighted sum.
  _flock: (b, neighbours) ->
    separation = @_separate(b, neighbours).multiply(SEPARATION_WEIGHT)
    alignment = @_align(b, neighbours).multiply(ALIGNMENT_WEIGHT)
    cohesion = @_cohere(b, neighbours).multiply(COHESION_WEIGHT)
    return separation.add(alignment).add(cohesion)

  # Separation component for the frame's acceleration
  _separate: (b, neighbours) ->
    mean = new Vector
    count = 0
    for boid in neighbours
      d = b.location.distance(boid.location)
      if d > 0 and d < DESIRED_SEPARATION
        # Normalized, weighted by distance vector pointing away from the neighbour
        mean.add Vector.subtract(b.location,boid.location).normalize().divide(d)
        count++

    mean.divide(count) if count > 0
    mean

  # Alignment component for the frame's acceleration
  _align: (b, neighbours) ->
    mean = new Vector
    count = 0
    for boid in neighbours
      d = b.location.distance(boid.location)
      if d > 0 and d < NEIGHBOUR_RADIUS
        mean.add(boid.velocity)
        count++

    mean.divide(count) if count > 0
    mean.limit(MAX_FORCE)
    return mean

  # Called to get the cohesion component of the acceleration
  _cohere: (b, neighbours) ->
    sum = new Vector
    count = 0
    for boid in neighbours
      d = b.location.distance(boid.location)
      if d > 0 and d < NEIGHBOUR_RADIUS
        sum.add(boid.location)
        count++

    if count > 0
      return @_steer_to b, sum.divide(count)
    else
      return sum # Empty vector contributes nothing

  _steer_to: (b, target) ->
    desired = Vector.subtract(target, b.location) # A vector pointing from the location to the target
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
      steer = desired.subtract(b.velocity)
      steer.limit(MAX_FORCE)  # Limit to maximum steering force
    else
      steer = new Vector(0,0)

    return steer

  _wrapIfNeeded: (b) ->
    if b.location.x < @_wrap_borders.west
      b.location.x = @_wrap_borders.east

    if b.location.y < @_wrap_borders.north
      b.location.y = @_wrap_borders.south

    if b.location.x > @_wrap_borders.east
      b.location.x = @_wrap_borders.west

    if b.location.y > @_wrap_borders.south
      return b.location.y = @_wrap_borders.north

d3.layout.flock = -> new Flock()
