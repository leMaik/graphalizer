class AxisRecognition
  constructor: (@img, @toleranceSettings = ToleranceSettings::default(),
                @environmentSettings = EnvironmentSettings::default()) ->

    @numAngleCells = 180
    @rhoMax = Math.sqrt(@img.getWidth() * @img.getWidth() + @img.getHeight() * @img.getHeight())
    @accum = Array(@numAngleCells)

  houghAcc: (x, y) =>
    theta = 0
    thetaIndex = 0
    x -= @img.getWidth() / 2
    y -= @img.getHeight() / 2
    while thetaIndex < @numAngleCells
      rho = @rhoMax + x * Math.cos(theta) + y * Math.sin(theta)
      rho >>= 1

      @accum[thetaIndex] = [] unless @accum[thetaIndex]?
      if @accum[thetaIndex][rho]?
        @accum[thetaIndex][rho]++
      else
        @accum[thetaIndex][rho] = 1

      theta += Math.PI / @numAngleCells
      thetaIndex++

  #Inspired by hough-transform-js (https://github.com/gmarty/hough-transform-js)
  houghTransform:  =>
    bgColor = @environmentSettings.backgroundColor

    for x in [0...@img.getWidth()]
      for y in [0...@img.getHeight()]
        @houghAcc(x, y) unless @toleranceSettings.isTolerated(bgColor, @img.getPixel(x, y))

    max = @findMaximum @accum
    console.log max
    oc = $('<canvas/>').get(0);
    oc.width = @numAngleCells
    oc.height = @rhoMax

    ctx = oc.getContext('2d')
    ctx.fillStyle = 'rgba(0,0,0,0.01)'
    for thetaIndex of @accum
      for rho of @accum[thetaIndex]
          for i in [0...@accum[thetaIndex][rho]]
            ctx.beginPath()
            ctx.fillRect(thetaIndex, rho, 1, 1)
            ctx.closePath()
        #console.log '%d, %d', thetaIndex, rho
    data = oc.toDataURL()
    houghRoom = new Image()
    houghRoom.onload = =>
      IMAGES.push new ScalableImage(houghRoom)
    houghRoom.src = data

  findMaximum: (array) ->
    max = [0, 0, -1]
    for thetaIndex of @accum
      for rho of @accum[thetaIndex]
        if @accum[thetaIndex][rho] > max[2]
          max = [thetaIndex, rho, @accum[thetaIndex][rho]]
    return max