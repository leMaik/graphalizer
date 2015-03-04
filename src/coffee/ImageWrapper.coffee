class ImageWrapper
  # isMarkedImpl erwartet x, y relativ zum Bild (wie bei getPixel), gibt true zurück falls der Pixel markiert ist, false sonst
  constructor: (img, @isMarkedImpl) ->
    @oc = $('<canvas/>').get(0);
    @oc.width = img.width
    @oc.height = img.height
    @ctx = @oc.getContext('2d')
    @ctx.drawImage(img, 0, 0, img.width, img.height)

  getPixel: =>
    switch arguments.length
      when 1 then @ctx.getImageData(arguments[0].x, arguments[0].y, 1, 1).data
      when 2 then @ctx.getImageData(arguments[0], arguments[1], 1, 1).data
      else
        []

  isMarked: =>
    switch arguments.length
      when 1 then @isMarkedImpl(arguments[0].x, arguments[0].y)
      when 2 then @isMarkedImpl(arguments[0], arguments[1])
      else
        []

  getWidth: =>
    @oc.width

  getHeight: =>
    @oc.height