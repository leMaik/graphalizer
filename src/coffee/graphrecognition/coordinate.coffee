#this class can also be avoided, simply use dynamic objects and null for invalid coordinates
class Coordinate
  constructor: (@x, @y) ->

  invalid: -> new Coordinate(-1, -1)

  fromObject: (obj) -> new Coordinate(obj.x, obj.y)