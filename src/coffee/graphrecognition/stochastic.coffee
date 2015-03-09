# StdDeviation, Mean, Median, etc.
class StochasticHelpers
  mean: (arr) ->
    accum = 0
    for v in arr
      accum += v
    return val / arr.length()

  median: (arr) ->
    if arr.length() == 0
      throw "median of empty array is not allowed"
    arr.sort()
    return arr[arr.length() / 2]

  variance: (arr) ->
    mean = mean(arr)
    accum = 0
    for v in arr
      diff = v - mean
      accum += diff * diff
    return accum / arr.length()

  standardDeviation: (arr) ->
    return Math.sqrt(arr)
