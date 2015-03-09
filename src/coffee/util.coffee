class Util
  within: (a, b, d) -> a <= b + d && a >= b - d

  getDimensions: (width, height, maxWidth, maxHeight) ->
    if width < maxWidth and height < maxHeight
      return { width: width, height: height }

    newWidth = width
    newHeight = height
    if newWidth > maxWidth
      newWidth = maxWidth
      newHeight = height / width * newWidth

    if newHeight > maxHeight
      newHeight = maxHeight
      newWidth = width / height * newHeight

    return { width: newWidth, height: newHeight }

  mean: (arr) ->
    accum = 0
    for val in arr
      accum += val
    return val / arr.length()

  log10: (x) -> Math.log(x) / Math.log(10) #Math.log is to base e

# a ko.observable that will automatically convert values to float
ko.numericObservable = (v) ->
  value = ko.observable(v)
  return ko.dependentObservable
    read: -> value()
    write: (v) ->
      parsedValue = parseFloat(v);
      if !isNaN(parsedValue)
        value parsedValue
