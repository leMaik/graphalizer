class Coordinate
  constructor: (@x, @y) ->

  invalid: -> new Coordinate(-1, -1)

  fromObject: (obj) -> new Coordinate(obj.x, obj.y)