# StdDeviation, Mean, Median, etc.
StochasticHelpers =
  mean: (arr) ->
    if arr.length == 0
      throw "mean of empty array ist not allowed"
    accum = 0
    for v in arr
      accum += v
    return v / arr.length

  median: (arr) ->
    if arr.length == 0
      throw "median of empty array is not allowed"
    arr.sort()
    return arr[Math.floor(arr.length / 2)]

  variance: (arr) ->
    mean = mean(arr)
    accum = 0
    for v in arr
      diff = v - mean
      accum += diff * diff
    return accum / arr.length

  standardDeviation: (arr) ->
    return Math.sqrt(arr)
