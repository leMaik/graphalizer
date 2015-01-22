class AxisRecognition
  constructor: ->

  #Inspired by hough-transform-js (https://github.com/gmarty/hough-transform-js)
  houghTransform: (img, toleranceSettings = ToleranceSettings::default(),
                   environmentSettings = EnvironmentSettings::default()) ->
    numAngleCells = 360

    rhoMax = Math.sqrt(Math.pow(img.getHeight(), 2) + Math.pow(img.getWidth(), 2))
    accum = Array(numAngleCells)
    bgColor = environmentSettings.backgroundColor

    xmax = img.getWidth() - 1
    ymax = img.getHeight() - 1
    for x in [0..xmax]
      for y in [0..ymax]
        if !toleranceSettings.isTolerated(bgColor, img.getPixel(x, y))
          theta = 0;
          thetaIndex = 0;
          x_ = x - img.getWidth() / 2
          y_ = y - img.getHeight() / 2

          while thetaIndex < numAngleCells
            rho = Math.floor Math.sqrt(x_ * x_ + y_ * y_)
            #console.log 'distance to center: ' + rho
            #rho = rhoMax / 2 + x_ * Math.cos(theta) + y_ * Math.sin(theta);
            #console.log rho
            if typeof accum[thetaIndex] is 'undefined'
              accum[thetaIndex] = []
            if typeof accum[thetaIndex][rho] is 'undefined'
              console.log 'new'
              accum[thetaIndex][rho] = 1
            else
              console.log 'inc'
              accum[thetaIndex][rho]+=10

            theta += Math.PI / numAngleCells
            thetaIndex++

  #HSctx.beginPath();
  #HSctx.fillRect(thetaIndex, rho, 1, 1);
  #HSctx.closePath();

    oc = $('<canvas/>').get(0);
    oc.width = numAngleCells
    oc.height = rhoMax + 1
    console.log 'oc size: %d*%d', oc.width, oc.height
    ctx = oc.getContext('2d')
    ctx.fillStyle = 'rgba(0,0,0,0.1)'
    for theta,thetaIndex in accum
      for v,rho in theta
        ctx.beginPath()
        ctx.fillRect(thetaIndex, rho, 1, 1)
        ctx.closePath()
        #console.log '%d, %d', thetaIndex, rho
    data = oc.toDataURL()
    #window.location.href = data
    houghRoom = new Image()
    houghRoom.onload = =>
      IMAGES.push new ScalableImage(houghRoom)
    houghRoom.src = data
