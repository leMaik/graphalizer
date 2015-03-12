# class for producing linear random sample concesus regressions
class LinearRansac
  constructor: (@randomSampleSize, @epsilonConsensus, @degree) ->
    @simpleRegress = new LeastSquare(@degree)

  # produce an estimate of necessary iterations for a good result
  estimateIterations: (pointCount, probability, outliersShare) ->
    return Math.log(1 - probability) / Math.log (1 - Math.pow(1 - outliersShare, pointCount))

  # return value is optional
  compute: (points, consensusMinimumSize, iterations, forceListing) ->
    consensusSet = []

    for i in [0..iterations-1]
      sample = @selectSample(points, Math.min(@randomSampleSize, points.length))
      polynomial = @simpleRegress.regress(sample)
      consensus = @selectConsensus(points, polynomial)
      if forceListing or consensus.length >= consensusMinimumSize
        consensusSet.push {size: consensus.length, polynomial: polynomial}

    if consensusSet.length == 0
      return undefined
    else
      consensusSet.sort((a, b) ->
        b.size - a.size
      )
      return consensusSet[0].polynomial

  selectSample: (points, sampleSize) ->
    result = []
    indexList = [0..points.length-1]
    util = new Util
    indexList = util.randomShuffle(indexList)
    for i in [0..sampleSize-1]
      result.push points[indexList[i]]
    return result

  selectConsensus: (points, polynomial) ->
    result = []
    for i in points
      if polynomial.distance(i) < @epsilonConsensus
        result.push i
    return result


