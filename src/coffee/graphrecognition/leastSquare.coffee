class LeastSquare
  constructor: (@degree) ->

  # returns least square polynomial
  # see polynom.coffee
  regress: (points) ->
    util = new Util

    # zeroes(height, width)
    A = util.createDenseMatrix(points.length, @degree+1)

    # fill matrix A
    for x in [0..@degree]
      for y in [0..points.length-1]
        A[y][x] = Math.pow(points[y].x, x)

    transposed = numeric.transpose(A)

    # lift hand side matrix of equation
    lhsM = numeric.dot(transposed, A)

    b = []
    for p in points
      b.push p.y

    # right hand side vector of equation
    rhsV = numeric.dot(transposed, b)

    # solve equation
    solved = numeric.solve(lhsM, rhsV)

    return new Polynomial(solved)


