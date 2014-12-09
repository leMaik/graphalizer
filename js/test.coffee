STAGE = null
PAPER = null
shifted = no

$ ->
  STAGE = new Kinetic.Stage({
    container: 'canvas',
    width: window.innerWidth,
    height: window.innerHeight
  });
  PAPER = new Kinetic.Layer()
  PAPER.add(new Kinetic.Text({
    x: 15,
    y: 15,
    text: 'Drop images here.',
    fontSize: 20,
    fontFamily: 'sans-serif',
    fill: 'gray'
  }))
  STAGE.add(PAPER)
  IMAGES = []

  $('body')
  .on('drop', (e) ->
      e.stopPropagation();
      e.preventDefault();

      files = e.originalEvent.dataTransfer.files #FileList object (contains Files)
      if files.length > 1
        alert 'Only one file at a time, please!'
        return
      f = files[0]
      if f.type.indexOf('image') != 0
        alert 'File is not an image!'
        return
      console.log 'File added: ' + f.name

      reader = new FileReader()
      reader.onload = (e) =>
        img = new Image()
        img.onload = () =>
          IMAGES.push(new ScalableImage(img))
        img.src = e.target.result
      reader.readAsDataURL(f)
    )
  .on('dragover', (e) ->
      e.stopPropagation()
      e.preventDefault()
      e.originalEvent.dataTransfer.dropEffect = 'copy' #/ Explicitly show this is a copy.
    )

  $(document).on('keyup keydown', (e) ->
    shifted = e.shiftKey)

class ScalableImage
  constructor: (img) ->
    @img = new Kinetic.Image({
      x: 0,
      y: 0,
      image: img,
      width: img.width,
      height: img.height,
      offset:
        x: img.width / 2
        y: img.height / 2
      stroke: 'gray'
      strokeWidth: 2,
      strokeEnabled: no,
      dash: [10, 10]
    })
    PAPER.add(@img)
    PAPER.draw()

    @ratio = img.width / img.height
    @isEditing = no
    @img.on('click', @onClick)

  onClick: =>
    console.log 'click'
    console.log @img.offsetX()
    if not @isEditing
      @img.draggable(yes)
      @img.strokeEnabled(yes)
      @isEditing = yes
      @addEditControls()
      STAGE.add(@editLayer)
      @img.draw()
    else
      @removeEditControls()


  setControlsPosition: =>
    halfDiag = Math.sqrt(@img.width() * @img.width() + @img.height() * @img.height()) / 2
    degr = Math.atan(@img.height() / @img.width()) * 180 / Math.PI
    @rotate.x(@img.x() - halfDiag * Math.cos((@img.rotation() + degr) * Math.PI / 180))
    @rotate.y(@img.y() - halfDiag * Math.sin((@img.rotation() + degr) * Math.PI / 180))

    @resize.x(@img.x() + halfDiag * Math.cos((@img.rotation() + degr) * Math.PI / 180))
    @resize.y(@img.y() + halfDiag * Math.sin((@img.rotation() + degr) * Math.PI / 180))

  getTopLeftPoint: =>
    halfDiag = Math.sqrt(@img.width() * @img.width() + @img.height() * @img.height()) / 2
    degr = Math.atan(@img.height() / @img.width()) * 180 / Math.PI
    p =
      x: @img.x() - halfDiag * Math.cos((@img.rotation() + degr) * Math.PI / 180)
      y: @img.y() - halfDiag * Math.sin((@img.rotation() + degr) * Math.PI / 180)
    return p

  addEditControls: =>
    @editLayer = new Kinetic.Layer()
    @rotate = new Kinetic.Circle({
      radius: 10
      fill: 'gray',
      draggable: yes
    })
    @resize = new Kinetic.Circle({
      radius: 10
      fill: 'gray',
      draggable: yes
    })
    @setControlsPosition()

    @rotate.on('dragmove', =>
      console.log 'rotate'
      degr = Math.atan2(@img.width(), @img.height()) * 180 / Math.PI
      if shifted
        oldRotation = @img.rotation()
        newRotation = -Math.atan2(@img.x() - @rotate.x(), @img.y() - @rotate.y()) * 180 / Math.PI + degr
        @img.rotate((newRotation - oldRotation) * 0.01)
      else
        @img.rotation(-Math.atan2(@img.x() - @rotate.x(), @img.y() - @rotate.y()) * 180 / Math.PI + degr)
      @setControlsPosition()
      STAGE.draw()
    )
    @rotate.on('dragend', @removeEditControls)

    @resize.on('dragmove', =>
      console.log 'resize'
      p = @getTopLeftPoint()
      distX = (@resize.x() - p.x)
      distY = (@resize.y() - p.y)
      if (distX <= 20 || distY <= 20)
        @setControlsPosition()
        return
      @img.width(@ratio * distY)
      @img.height(@img.width() / @ratio)
      @img.offsetX(@img.width() / 2)
      @img.offsetY(@img.height() / 2)
      @setControlsPosition()
      STAGE.draw()
    )
    @resize.on('dragend', @removeEditControls)

    @editLayer.add(@rotate)
    @editLayer.add(@resize)
    @img.on('dragmove', =>
      @setControlsPosition()
      @editLayer.draw()
    )

  removeEditControls: =>
    @editLayer.remove()
    @img.strokeEnabled(no)
    @img.draggable(no)
    @isEditing = no
    STAGE.draw()
    @img.off('dragmove', @setControlsPosition)