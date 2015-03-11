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

  log10: (x) -> Math.log(x) / Math.log(10) #Math.log is to base e

  # creates a dense matrix (opposed to sparse)
  createDenseMatrix: (rows, columns) ->
    matrix = []
    for i in [0..rows-1]
      matrix[i] = new Array(columns)
    return matrix

  # shuffle array using Fisher-Yates
  randomShuffle: (arr) ->
    counter = arr.length
    temp = 0
    index = 0

    while counter > 0
      index = Math.floor(Math.random() * counter)
      counter--

      # perform swap
      temp = arr[counter]
      arr[counter] = arr[index]
      arr[index] = temp

    return arr


# a ko.observable that will automatically convert values to float
ko.numericObservable = (v) ->
  value = ko.observable(v)
  return ko.dependentObservable
    read: -> value()
    write: (v) ->
      parsedValue = parseFloat(v);
      if !isNaN(parsedValue)
        value parsedValue
