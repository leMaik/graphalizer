#this class can also be avoided, simply use dynamic objects and null for invalid coordinates
class Coordinate
  constructor: (@x, @y) ->

  invalid: -> new Coordinate(-1, -1)

  isInvalid: (c) ->
    c.x == -1 and c.y == -1

  fromObject: (obj) -> new Coordinate(obj.x, obj.y)

makeCoordinate: ->
  switch arguments.length
      when 1 then return {x: arguments[0].x, y: arguments[0].y}
      when 2 then return {x: arguments[0], y: arguments[1]}
      else
        return Coordinate::invalid()