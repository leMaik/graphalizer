class AxisRecognition
  constructor: ->

  #Inspired by hough-transform-js (https://github.com/gmarty/hough-transform-js)
  houghTransform: (img, toleranceSettings = ToleranceSettings::default(),
                   environmentSettings = EnvironmentSettings::default()) ->
    numAngleCells = 360

    rhoMax = Math.sqrt(Math.pow(img.height, 2) + Math.pow(img.width, 2))
    min_d = -max_d
    accum = Array(numAngleCells)
    bgColor = environmentSettings.backgroundColor

    for x in [0..img.width - 1]
      for y in [0..img.height - 1]
        if !toleranceSettings.isTolerated(bgColor, @parentDocument.getPixel(x, y))
          theta = 0;
          thetaIndex = 0;
          x_ = x - img.width / 2
          y_ = y - img.height / 2

          while thetaIndex < numAngleCells
            rho = rhoMax + x_ * Math.cos(theta) + y_ * Math.sin(theta);
            rho >>= 1;
            if !accum[thetaIndex]?
              accum[thetaIndex] = []
            if accum[thetaIndex][rho]?
              accum[thetaIndex][rho]++
            else
              accum[thetaIndex][rho] = 1

            theta += Math.PI / numAngleCells
            thetaIndex++

  #HSctx.beginPath();
  #HSctx.fillRect(thetaIndex, rho, 1, 1);
  #HSctx.closePath();