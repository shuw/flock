# Ported to CoffeeScript from [this Processing version](http://harry.me/2011/02/17/neat-algorithms---flocking)

class window.Vector
  # Class methods for nondestructively operating
  for name in ['add', 'subtract', 'multiply', 'divide']
    do (name) ->
      Vector[name] = (a,b) ->
        a.copy()[name](b)

  constructor: (x=0,y=0,z=0) ->
    [@x,@y,@z] = [x,y,z]

  copy: ->
    new Vector(@x,@y,@z)

  magnitude: ->
    Math.sqrt(@x*@x + @y*@y + @z*@z)

  normalize: ->
    m = @magnitude()
    @divide(m) if m > 0
    return this

  limit: (max) ->
    if @magnitude() > max
      @normalize()
      return @multiply(max)
    else
      return this

  heading: ->
    -1 * Math.atan2(-1 * @y,@x)

  eucl_distance: (other) ->
    dx = @x-other.x
    dy = @y-other.y
    dz = @z-other.z
    Math.sqrt(dx*dx + dy*dy + dz*dz)

  distance: (other, dimensions = false) ->
    dx = Math.abs(@x-other.x)
    dy = Math.abs(@y-other.y)
    dz = Math.abs(@z-other.z)

    # Wrap
    if dimensions
      dx = if dx < dimensions.width/2 then dx else dimensions.width - dx
      dy = if dy < dimensions.height/2 then dy else dimensions.height - dy

    Math.sqrt(dx*dx + dy*dy + dz*dz)

  subtract: (other) ->
    @x -= other.x
    @y -= other.y
    @z -= other.z
    this

  add: (other) ->
    @x += other.x
    @y += other.y
    @z += other.z
    this

  divide: (n) ->
    [@x,@y,@z] = [@x/n,@y/n,@z/n]
    this

  multiply: (n) ->
    [@x,@y,@z] = [@x*n,@y*n,@z*n]
    this

  dot: (other) ->
    @x*other.x + @y*other.y + @z*other.z

  # Not the strict projection, the other isn't converted to a unit vector first.
  projectOnto: (other) ->
    other.copy().multiply(@dot(other))

  # Called on a vector acting as a position vector to return the wrapped representation closest
  # to another location
  wrapRelativeTo: (location, dimensions) ->
    v = @copy()
    for a,key of {x:"width", y:"height"}
      d = this[a]-location[a]
      map_d = dimensions[key]
      # If the distance is greater than half the map wrap it.
      if Math.abs(d) > map_d/2
        # If the distance is positive, then the this vector is in front of the location, and it
        # would be closer to the location if it were wrapped to the negative behind the axis
        if d > 0
          # Take the distance to the axis and put the point behind the opposite side of the map by
          # that much
          v[a] = (map_d - this[a]) * -1
        else
        # If the distance is negative, then this this vector is behind the location, and it
        # would be closer if it were wrapped in front of the location past the axis in the positive
        # direction. Take the distance back to the axis, and put the point past the edge by that much
          v[a] = (this[a] + map_d)
    v

  invalid: () ->
    return (@x == Infinity) || isNaN(@x) || @y == Infinity || isNaN(@y) || @z == Infinity || isNaN(@z)