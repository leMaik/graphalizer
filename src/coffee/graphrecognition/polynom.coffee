class Polynomial
  # accepts a list of coefficients that are in this order: c[0] + c[1]x + c[2]x^2
  constructor: (@coefficients) ->

  f: (x) ->
    accum = 0
    for i in [0..@coefficients.length-1]
      accum += @coefficients[i] * Math.pow(x, i)
      ++i
    return accum

  distance: (coord) ->
    return Math.abs(@f(coord.x) - coord.y)
