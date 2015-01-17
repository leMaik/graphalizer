class ImageWrapper
  constructor: (img) ->
    @oc = $('<canvas/>').get(0);
    @oc.width = img.width
    @oc.height = img.height
    @ctx = @oc.getContext('2d')
    @ctx.drawImage(img, 0, 0, img.width, img.height)

  getPixel: (x, y) =>
    @ctx.getImageData(x, y, 1, 1).data

  getWidth: =>
    @oc.width

  getHeight: =>
    @oc.height