STAGE = null
PAPER = null
IMAGES = []
AXES = []
shifted = no

Layers =
  PAPER: new Kinetic.Layer()
  AXES: new Kinetic.Layer()

deselectAll = ->
  image.removeEditControls() for image in IMAGES when image.isEditing
  axis.isEditing(no) for axis in AXES when axis.isEditing()

resizeStage = ->
  canvas = $('#canvas')
  STAGE.width(canvas.width())
  STAGE.height(canvas.height())
  console.log "%d x %d", canvas.width(), canvas.height()

  STAGE.find('#background').width(canvas.width()).height(canvas.height()).draw()

$(window).load -> resizeStage()

$ ->
  STAGE = new Kinetic.Stage
    container: 'canvas'

  $(window).resize(resizeStage)

  bgLayer = new Kinetic.Layer()
  bgLayer.add new Kinetic.Rect
    x: 0
    y: 0
    offset:
      x: 0
      y: 0
    fill: '#fff'
    width: STAGE.width()
    height: STAGE.height()
    id: 'background'

  bgLayer.on('click', deselectAll)

  Layers.PAPER = new Kinetic.Layer()
  Layers.AXES = new Kinetic.Layer()
  STAGE.add(bgLayer).add(Layers.PAPER).add(Layers.AXES);

  $('body')
  .on('drop', (e) ->
      e.stopPropagation();
      e.preventDefault();

      files = e.originalEvent.dataTransfer.files #FileList object (contains Files)
      if files.length > 1
        alert 'Only one file at a time, please!'
        return
      f = files[0]
      console.log 'File added: %s (%s)', f.name, f.type

      if f.type.indexOf('image') == 0
        reader = new FileReader()
        reader.onload = (e) =>
          img = new Image()
          img.onload = () =>
            IMAGES.push(new ScalableImage(img))
          img.src = e.target.result
        reader.readAsDataURL(f)
      else if f.type == 'application/pdf'
        reader = new FileReader()
        reader.onload = (e) =>
          canvas = document.createElement('canvas') #off-screen canvas for rendering
          ctx = canvas.getContext('2d')
          PDFJS.getDocument(e.target.result).then((pdf) =>
            p = prompt 'PDF has ' + pdf.numPages + ' pages, which do you want?', 1
            console.log 'Page ' + p
            pdf.getPage(parseInt(p, 10)).then((page) =>
              viewport = page.getViewport(2.0)
              canvas.width = viewport.width
              canvas.height = viewport.height
              page.render({canvasContext: ctx, viewport: viewport}).then =>
                data = canvas.toDataURL()
                img = new Image()
                img.onload = ->
                  IMAGES.push(new ScalableImage(img))
                  console.log 'Done, %dx%d', canvas.width, canvas.height
                img.src = data
            )
          )
        reader.readAsArrayBuffer(f)
      else
        alert 'Unsupported file type'
        return
    )
  .on('dragover', (e) ->
      e.stopPropagation()
      e.preventDefault()
      e.originalEvent.dataTransfer.dropEffect = 'copy' #/ Explicitly show this is a copy.
    )

  $(document).on 'keyup keydown', (e) ->
    shifted = e.shiftKey
    return yes

class ScalableImage
  constructor: (img) ->
    @img = new Kinetic.Image
      x: img.width / 2 + 20
      y: img.height / 2 + 20
      image: img,
      width: img.width,
      height: img.height,
      offset:
        x: img.width / 2
        y: img.height / 2
      dash: [10, 10]
      shadowColor: 'black'
      shadowBlur: 5
      shadowOpacity: 0.5

    @img.on 'click', =>
      mousePos = STAGE.getPointerPosition()
      relative = @img.getAbsoluteTransform().copy().invert().point(mousePos) #get mouse position relative to @img
      original = @img.image();
      relative =
        x: relative.x * original.width / @img.width()
        y: relative.y * original.height / @img.height()
      #the point 'relative' is now relative to the original image, which is nice

      oc = $('<canvas/>').get(0);
      oc.width = original.width
      oc.height = original.height
      oc.getContext('2d').drawImage(original, 0, 0, original.width, original.height)
      getPixel = (x, y) -> oc.getContext('2d').getImageData(x, y, 1, 1).data

      #TODO Insert Tim's magic image recognition here!

      pixel = getPixel(relative.x, relative.y)
      hexColor = "#" + ((1 << 24) + (pixel[0] << 16) + (pixel[1] << 8) + pixel[2]).toString(16).slice(1) #http://stackoverflow.com/a/5624139
      console.log 'Color at %d,%d is %s', relative.x, relative.y, hexColor

    Layers.PAPER.add(@img).draw()

    @resize = null
    @rotate = null
    @removeBtn = null

    @isEditing = no
    @img
    .on 'mousedown', =>
        @img.draggable(yes)
        .on 'click', => if @isEditing then @removeEditControls() else @startEdit()
          .on 'dragmove', =>
              if @isEditing
                @setControlsPosition()
                @resize.draw()
                @rotate.draw()
                @removeBtn.draw()
              else
                @startEdit()

  startEdit: =>
    deselectAll()
    @img.draggable(yes).shadowBlur(15)
    @isEditing = yes
    @addEditControls()
    @img.draw()
    @resize.draw()
    @rotate.draw()
    @removeBtn.draw()

  setControlsPosition: =>
    halfDiag = Math.sqrt(@img.width() * @img.width() + @img.height() * @img.height()) / 2
    degr = Math.atan(@img.height() / @img.width()) * 180 / Math.PI
    @rotate.x(@img.x() - halfDiag * Math.cos((@img.rotation() + degr) * Math.PI / 180))
    @rotate.y(@img.y() - halfDiag * Math.sin((@img.rotation() + degr) * Math.PI / 180))

    @resize.x(@img.x() + halfDiag * Math.cos((@img.rotation() + degr) * Math.PI / 180))
    @resize.y(@img.y() + halfDiag * Math.sin((@img.rotation() + degr) * Math.PI / 180))

    @removeBtn.x(@img.x() - halfDiag * Math.cos((@img.rotation() - degr) * Math.PI / 180))
    @removeBtn.y(@img.y() - halfDiag * Math.sin((@img.rotation() - degr) * Math.PI / 180))

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
    #@rotate.on('dragend', @removeEditControls)

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
      STAGE.draw()
    )
    #@resize.on('dragend', @removeEditControls)

    @removeBtn.on 'click', => @remove()


    Layers.PAPER.add(@rotate).add(@resize).add(@removeBtn)

  removeEditControls: =>
    @rotate.remove()
    @resize.remove()
    @removeBtn.remove()
    @img.shadowBlur(5).draggable(no)
    @isEditing = no
    STAGE.draw()

  remove: =>
    if @isEditing
      @removeEditControls()
    @img.remove()
    STAGE.draw()