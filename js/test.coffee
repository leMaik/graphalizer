STAGE = null
PAPER = null
IMAGES = []
shifted = no

#http://stackoverflow.com/questions/12092633/pdf-js-rendering-a-pdf-file-using-a-base64-file-source-instead-of-url
BASE64_MARKER = ';base64,'
convertDataURIToBinary = (dataURI) ->
  base64Index = dataURI.indexOf(BASE64_MARKER) + BASE64_MARKER.length;
  base64 = dataURI.substring(base64Index);
  raw = window.atob(base64);
  rawLength = raw.length;
  array = new Uint8Array(new ArrayBuffer(rawLength));

  for i in [0..rawLength-1]
    array[i] = raw.charCodeAt(i)

  return array

deselectAll = ->
  image.removeEditControls() for image in IMAGES when image.isEditing

$ ->
  STAGE = new Kinetic.Stage({
    container: 'canvas',
    width: window.innerWidth,
    height: window.innerHeight
  });

  bgLayer = new Kinetic.Layer()
  bgLayer.add(new Kinetic.Text({
    x: 15,
    y: 15,
    text: 'Drop images here.',
    fontSize: 20,
    fontFamily: 'sans-serif',
    fill: 'gray'
  }))
  bgLayer.on('click', deselectAll)
  STAGE.add(bgLayer)

  PAPER = new Kinetic.Layer()
  STAGE.add(PAPER)

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
            pdf.getPage(parseInt(p)).then((page) =>
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

  $(document).on('keyup keydown', (e) ->
    shifted = e.shiftKey)

class ScalableImage
  constructor: (img) ->
    @img = new Kinetic.Image({
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
      shadowBlur: 2
      shadowOpacity: 0.5
    })
    PAPER.add(@img)
    PAPER.draw()

    @resize = null
    @rotate = null

    @isEditing = no
    @img.on('mousedown', =>
      @img.draggable(yes))
    @img.on('click', =>
      if @isEditing then @removeEditControls() else @startEdit()
    )
    @img.on('dragmove', =>
      if @isEditing
        @setControlsPosition()
        @resize.draw()
        @rotate.draw()
      else
        @startEdit()
    )

  startEdit: =>
    deselectAll()
    @img.draggable(yes)
    @img.shadowBlur(15)
    @isEditing = yes
    @addEditControls()
    @img.draw()
    @resize.draw()
    @rotate.draw()

  setControlsPosition: =>
    halfDiag = Math.sqrt(@img.width() * @img.width() + @img.height() * @img.height()) / 2
    degr = Math.atan(@img.height() / @img.width()) * 180 / Math.PI
    @rotate.x(@img.x() - halfDiag * Math.cos((@img.rotation() + degr) * Math.PI / 180))
    @rotate.y(@img.y() - halfDiag * Math.sin((@img.rotation() + degr) * Math.PI / 180))

    @resize.x(@img.x() + halfDiag * Math.cos((@img.rotation() + degr) * Math.PI / 180))
    @resize.y(@img.y() + halfDiag * Math.sin((@img.rotation() + degr) * Math.PI / 180))

  getTopLeftPoint: =>
    halfDiag = Math.sqrt(@img.width() * @img.width() + @img.height() * @img.height())
    degr = Math.atan(@img.height() / @img.width())
    p =
      x: @img.x() - halfDiag * Math.cos(@img.rotation() * Math.PI / 180 + degr) / 2
      y: @img.y() - halfDiag * Math.sin(@img.rotation() * Math.PI / 180 + degr) / 2
    return p

  addEditControls: =>
    @rotate = new Kinetic.Group({
      width: 20
      height: 20
      draggable: yes
    })
    @rotate.add(new Kinetic.Circle({
      radius: 12
      fill: 'white'
      shadowColor: 'black'
      shadowBlur: 5
      shadowOpacity: 0.5
    }))
    rotateImg = new Image()
    rotateImg.onload = =>
      @rotate.add(new Kinetic.Image({
        image: rotateImg
        width: 20
        height: 20
        offset:
          x: 10
          y: 10
      }))
      @rotate.draw()
    rotateImg.src = 'res/rotate.svg'

    @resize = new Kinetic.Group({
      width: 20
      height: 20
      draggable: yes
    })
    @resize.add(new Kinetic.Circle({
      radius: 12
      fill: 'white'
      shadowColor: 'black'
      shadowBlur: 5
      shadowOpacity: 0.5
    }))
    resizeImg = new Image()
    resizeImg.onload = =>
      @resize.add(new Kinetic.Image({
        image: resizeImg
        width: 20
        height: 20
        offset:
          x: 10
          y: 10
      }))
      @resize.draw()
    resizeImg.src = 'res/scale.svg'
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

      @img.width(width)
      @img.height(height)
      @img.offsetX(@img.width() / 2)
      @img.offsetY(@img.height() / 2)

      #rearrange controls and repaint
      @setControlsPosition()
      @rotate.draw()
      @resize.draw()
    )
    #@resize.on('dragend', @removeEditControls)

    PAPER.add(@rotate)
    PAPER.add(@resize)

  removeEditControls: =>
    @rotate.remove()
    @resize.remove()
    @img.shadowBlur(2)
    @img.draggable(no)
    @isEditing = no
    STAGE.draw()