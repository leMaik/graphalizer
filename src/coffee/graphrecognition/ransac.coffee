# class for producing linear random sample concesus regressions
class LinearRansac
  constructor: (@randomSampleSize, @epsilonConsensus) ->
    @simpleRegress = new LeastSquare(1)

  # produce an estimate of necessary iterations for a good result
  estimateIterations: (pointCount, probability, outliersShare) ->
    return Math.log(1 - probability) / Math.log (1 - Math.pow(1 - outliersShare, pointCount))

  # return value is optional
  compute: (points, consensusMinimumSize, iterations) ->
    consensusSet = []

    for i in [0..iterations-1]
      sample = @selectSample(points, Math.min(@randomSampleSize, points.length))
      polynom = @simpleRegress.regress(sample)
      consensus = @selectConsensus(points, polynom)
      if consensus.length >= consensusMinimumSize
        consensusSet.push {size: consensus.length, polynom: polynom}

    if consensusSet.length == 0
      return undefined
    else
      consensusSet.sort((a, b) ->
        b.size - a.size
      )
      return consensusSet[0].polynom

  selectSample: (points, sampleSize) ->
    result = []
    indexList = [0..points.length-1]
    for i in [0..sampleSize-1]
      result.push points[indexList[i]]
    return result

  selectConsensus: (points, polynom) ->
    result = []
    for i in points
      if polynom.distance(i) < @epsilonConsensus
        result.push i
    return result


