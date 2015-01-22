class AxisRecognition
  constructor: (@img, @toleranceSettings = ToleranceSettings::default(),
                @environmentSettings = EnvironmentSettings::default()) ->

    @numAngleCells = 360
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

      @accum[thetaIndex] = []  unless @accum[thetaIndex]?
      unless @accum[thetaIndex][rho]?
        @accum[thetaIndex][rho] = 1
      else
        @accum[thetaIndex][rho]++

      theta += Math.PI / @numAngleCells
      thetaIndex++

  #Inspired by hough-transform-js (https://github.com/gmarty/hough-transform-js)
  houghTransform:  =>
    bgColor = @environmentSettings.backgroundColor

    for x in [0...@img.getWidth()]
      for y in [0...@img.getHeight()]
        @houghAcc x, y unless @toleranceSettings.isTolerated(bgColor, @img.getPixel(x, y))

    oc = $('<canvas/>').get(0);
    oc.width = @numAngleCells
    oc.height = @rhoMax

    console.log 'oc size: %d*%d', oc.width, oc.height

    ctx = oc.getContext('2d')
    ctx.fillStyle = 'rgba(0,0,0,0.5)'
    for thetaIndex in [0...@accum.length]
      for rho in [0...@accum[thetaIndex].length]
        ctx.beginPath()
        ctx.fillRect(thetaIndex, rho, 1, 1)
        ctx.closePath()
        #console.log '%d, %d', thetaIndex, rho
    data = oc.toDataURL()
    houghRoom = new Image()
    houghRoom.onload = =>
      IMAGES.push new ScalableImage(houghRoom)
    houghRoom.src = data
