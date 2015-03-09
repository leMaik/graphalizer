class ScalableImage
  constructor: (img) ->
    dim = Util::getDimensions(img.width, img.height, STAGE.width() - 40, STAGE.height() - 40)
    @img = new Kinetic.Image
      x: img.width / 2 + 20
      y: img.height / 2 + 20
      image: img,
      width: dim.width,
      height: dim.height,
      offset:
        x: img.width / 2
        y: img.height / 2
      dash: [10, 10]
      shadowColor: 'black'
      shadowBlur: 5
      shadowOpacity: 0.5

    @img.on 'click', =>
      #new AxisRecognition(new ImageWrapper(@img.image())).houghTransform()
      if GUI.mode() is 'analyze'
        mousePos = STAGE.getPointerPosition()

        #transform mousePos (relative to canvas) to a point that is relative to the non-rotated, non-zoomed document
        relative = @img.getAbsoluteTransform().copy().invert().point(mousePos) #get mouse position relative to @img
        original = @img.image();
        relative =
          x: relative.x * original.width / @img.width()
          y: relative.y * original.height / @img.height()
        #the point 'relative' is now relative to the original image, which is nice

        #wrap the image for the analyzer
        markImg = new Image()
        markImg.onload = =>
          oc = $('<canvas/>').get(0);
          oc.width = markImg.width
          oc.height = markImg.height
          ctx = oc.getContext('2d')
          ctx.drawImage(markImg, 0, 0, markImg.width, markImg.height)
          isMarked = (x, y) =>
            p = @img.getAbsoluteTransform().point({x: x, y: y})
            return ctx.getImageData(p.x, p.y, 1, 1).data[3] > 0

          document = new ImageWrapper(original, isMarked)

          #use the analyzer to find the nearest point on the graph
          fixedClickPos = new GraphAnalyser(document).findGraphInProximity(relative)

          #transform that found point back to canvas coordinates
          transformBack = (pos) =>
            newPos =
              x: pos.x * @img.width() / original.width
              y: pos.y * @img.height() / original.height
            newPos = @img.getAbsoluteTransform().copy().point(newPos)

          for rawPoint in new GraphAnalyser(document).analyse(fixedClickPos)
            console.log rawPoint
            absolutePos = transformBack rawPoint
            POINTS.push new AnalyzeValue(absolutePos.x, absolutePos.y)

          absoluteFixedPos = transformBack fixedClickPos
          point = new AnalyzeValue(absoluteFixedPos.x, absoluteFixedPos.y)
          Layers.POINTS.add(point.kineticElement).draw()
          POINTS.push point

          pixel = document.getPixel(relative.x, relative.y)
          hexColor = "#" + ((1 << 24) + (pixel[0] << 16) + (pixel[1] << 8) + pixel[2]).toString(16).slice(1) #http://stackoverflow.com/a/5624139

        markImg.src = @markLayer.toDataURL()
      else if GUI.mode() is 'mark'
        #nothing to do here
      else
        @isEditing(!@isEditing())

    Layers.PAPER.add(@img).draw()
    @markLayer = new Kinetic.Layer()
    STAGE.add(@markLayer)

    @resize = null
    @rotate = null
    @removeBtn = null

    @isDrawing = ko.observable(no)

    @isEditing = ko.observable(no)
    @isEditing.subscribe (v) =>
      console.log 'isEditing: ' + v
      if v
        deselectAllExcept(@)
        @img.draggable(yes).shadowBlur(15)
        @addEditControls()
      else
        @removeEditControls()
        @isDrawing no

    @img.on 'mousedown', =>
      @img.draggable(yes) if GUI.mode() is 'setup'
      @isDrawing(yes) if GUI.mode() is 'mark'
    @img.on 'mouseup', =>
      @isDrawing(no) if GUI.mode() is 'mark'
    @img.on 'mouseout', =>
      @isDrawing(no) if GUI.mode() is 'mark'
    @img.on 'mousemove', =>
      if @isDrawing()
        mousePos = STAGE.getPointerPosition()
        relative = @img.getAbsoluteTransform().copy().invert().point(mousePos) #get mouse position relative to @img
        @markLayer.add(new Kinetic.Circle
          x: mousePos.x
          y: mousePos.y
          radius: 20
          fill: 'red',
          hitFunc: -> #disable hitting
        ).draw()
    @img.on 'dragmove', =>
      if @isEditing()
        @setControlsPosition()
        @resize.draw()
        @rotate.draw()
        @removeBtn.draw()
      else
        @isEditing yes

  analyze: =>
    original = @img.image();

    #wrap the image for the analyzer
    markImg = new Image()
    markImg.onload = =>
      oc = $('<canvas/>').get(0);
      oc.width = markImg.width
      oc.height = markImg.height
      ctx = oc.getContext('2d')
      ctx.drawImage(markImg, 0, 0, markImg.width, markImg.height)
      isMarked = (x, y) =>
        p = @img.getAbsoluteTransform().point({x: x, y: y})
        return ctx.getImageData(p.x, p.y, 1, 1).data[3] > 0
      console.log "(0,0) marked = " + isMarked(0, 0)
      document = new ImageWrapper(original, isMarked)

      #transform that found point back to canvas coordinates
      transformBack = (pos) =>
        newPos =
          x: pos.x * @img.width() / original.width
          y: pos.y * @img.height() / original.height
        newPos = @img.getAbsoluteTransform().copy().point(newPos)

      dots = @markLayer.getChildren().toArray()
      if dots.length > 0
        firstMarkedDot = {x: dots[0].x(), y: dots[0].y()}

      for rawPoint in new GraphAnalyser(document).analyse(firstMarkedDot)
        console.log rawPoint
        absolutePos = transformBack rawPoint
        POINTS.push new AnalyzeValue(absolutePos.x, absolutePos.y)

    markImg.src = @markLayer.toDataURL()

  setControlsPosition: =>
    halfDiag = Math.sqrt(@img.width() * @img.width() + @img.height() * @img.height()) / 2
    degr = Math.atan(@img.height() / @img.width()) * 180 / Math.PI
    @rotate.x(@img.x() - halfDiag * Math.cos((@img.rotation() + degr) * Math.PI / 180))
    @rotate.y(@img.y() - halfDiag * Math.sin((@img.rotation() + degr) * Math.PI / 180))

    @resize.x(@img.x() + halfDiag * Math.cos((@img.rotation() + degr) * Math.PI / 180))
    @resize.y(@img.y() + halfDiag * Math.sin((@img.rotation() + degr) * Math.PI / 180))

    @removeBtn.x(@img.x() - halfDiag * Math.cos((@img.rotation() - degr) * Math.PI / 180))
    @removeBtn.y(@img.y() - halfDiag * Math.sin((@img.rotation() - degr) * Math.PI / 180))

    Layers.PAPER.draw()

  getTopLeftPoint: =>
    halfDiag = Math.sqrt(@img.width() * @img.width() + @img.height() * @img.height())
    degr = Math.atan(@img.height() / @img.width())
    p =
      x: @img.x() - halfDiag * Math.cos(@img.rotation() * Math.PI / 180 + degr) / 2
      y: @img.y() - halfDiag * Math.sin(@img.rotation() * Math.PI / 180 + degr) / 2
    return p

  addEditControls: =>
    @rotate = ImageCircle
      size: 20
      image: 'res/rotate.svg'
      tooltip: 'Drehen'

    @resize = ImageCircle
      size: 20
      image: 'res/scale.svg'
      tooltip: 'Skalieren'

    @removeBtn = ImageCircle
      size: 20
      image: 'res/delete.svg'
      tooltip: 'Entfernen'

    @setControlsPosition()

    @rotate.on('dragmove', =>
      degr = Math.atan2(@img.width(), @img.height()) * 180 / Math.PI
      newRotation = -Math.atan2(@img.x() - @rotate.x(), @img.y() - @rotate.y()) * 180 / Math.PI + degr
      if shifted
        oldRotation = @img.rotation()
        @img.rotate((newRotation - oldRotation) * 0.01)
      else
        @img.rotation(newRotation)
      @setControlsPosition()
      STAGE.draw()
    )

    @resize.on('dragmove', =>
      if (@resize.x() - @img.x() <= 10 && @resize.y() - @img.y() <= 10)
        @setControlsPosition()
        return

      #calculate new width and height
      rad = Math.atan(@img.height() / @img.width())
      pr = Math.sqrt(Math.pow(@resize.x() - @img.x(), 2) + Math.pow(@resize.y() - @img.y(), 2))
      width = 2 * pr * Math.cos(rad)
      height = 2 * pr * Math.sin(rad)

      @img
      .width(width)
      .height(height)
      .offsetX(@img.width() / 2)
      .offsetY(@img.height() / 2)

      #rearrange controls and repaint
      @setControlsPosition()
    )

    @removeBtn.on 'click', => @remove()

    Layers.PAPER.add(@rotate).add(@resize).add(@removeBtn).draw()

  removeEditControls: =>
    @rotate?.remove()
    @resize?.remove()
    @removeBtn?.remove()
    @img.shadowBlur(5).draggable(no)
    Layers.PAPER.draw()

  remove: =>
    if @isEditing()
      @removeEditControls()
    @img.remove()
    Layers.PAPER.draw()

  showMarkings: => @markLayer.opacity(1).draw()
  hideMarkings: => @markLayer.opacity(0).draw()