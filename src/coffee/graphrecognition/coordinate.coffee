#this class can also be avoided, simply use dynamic objects and null for invalid coordinates
class Coordinate
  constructor: ->
    switch arguments.length
      when 1
        @x = arguments[0].x
        @y = arguments[0].y
      when 2
        @x = arguments[0]
        @y = arguments[1]
      else
        @x = -1
        @y = -1

  invalid: -> new Coordinate(-1, -1)

  isInvalid: (c) ->
    c.x == -1 and c.y == -1