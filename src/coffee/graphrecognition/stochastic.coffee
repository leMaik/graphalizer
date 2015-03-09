# StdDeviation, Mean, Median, etc.
class StochasticHelpers
  mean: (arr) ->
    accum = 0
    for val in arr
      accum += val
    return val / arr.length()

  median: (arr) ->
    if arr.length() == 0
      return undefined
    arr.sort()
    return arr[arr.length() / 2]

  variance: (arr) ->
    mean = mean(arr)
    accum = 0
    for var in arr
      diff = var - mean
      accum += diff * diff
    return accum / arr.length()

  standardDeviation: (arr) ->
    return Math.sqrt(arr)
