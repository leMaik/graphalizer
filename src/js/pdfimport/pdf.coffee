class Pdf
  constructor: (@pdf) ->
    @pagesCount = @pdf.numPages

  getPage: (page, callback) =>
    @pdf.getPage(page).then((page) =>
      #create an off-screen canvas for rendering the pdf
      canvas = document.createElement('canvas')
      ctx = canvas.getContext('2d')

      #get pdf size and set canvas size accordingly
      viewport = page.getViewport(2.0) #2.0 is the zoom level
      canvas.width = viewport.width
      canvas.height = viewport.height

      #render the page and put it into an image
      page.render({canvasContext: ctx, viewport: viewport}).then ->
        data = canvas.toDataURL()
        canvas.remove()
        img = new Image()
        img.onload = ->
          callback img
        img.src = data
    )

  #static method to create a Pdf from a file
  readFile: (file, callback) ->
    reader = new FileReader()
    reader.onload = (e) ->
      PDFJS.getDocument(e.target.result).then (pdf) ->
        callback new Pdf(pdf)
    reader.readAsArrayBuffer(file)