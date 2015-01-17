STAGE = null
PAPER = null
IMAGES = []
AXES = observableArray()
POINTS = observableArray()
shifted = no

Layers =
  PAPER: new Kinetic.Layer()
  AXES: new Kinetic.Layer()
  POINTS: new Kinetic.Layer()

deselectAll = ->
  image.isEditing(no) for image in IMAGES when image.isEditing()
  axis.isEditing(no) for axis in AXES() when axis.isEditing()

deselectAllExcept = (except) ->
  image.isEditing(no) for image in IMAGES when image.isEditing() and image isnt except
  axis.isEditing(no) for axis in AXES() when axis.isEditing() and axis isnt except

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

  STAGE.add(bgLayer).add(Layers.PAPER).add(Layers.AXES).add(Layers.POINTS)

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
            IMAGES.push new ScalableImage(img)
          img.src = e.target.result
        reader.readAsDataURL(f)
      else if f.type == 'application/pdf'
        importer = new PdfImport(f)
        importer.onImportPage = (img) =>
          IMAGES.push(new ScalableImage(img))
      else
        alert 'Unsupported file type'
    )
  .on('dragover', (e) ->
      e.stopPropagation()
      e.preventDefault()
      e.originalEvent.dataTransfer.dropEffect = 'copy' #/ Explicitly show this is a copy.
    )

  $(document).on 'keyup keydown', (e) ->
    shifted = e.shiftKey
    return yes