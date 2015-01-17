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