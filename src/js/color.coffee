# This class should be avoided due to performance penalties

class Color
  constructor: (@r = 0, @g = 0, @b = 0) ->


createColorFromArray(array) ->
  return new Color(array[0], array[1], array[2])