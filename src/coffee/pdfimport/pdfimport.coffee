class PdfImport
  constructor: (file) ->
    @selectedPage = ko.observable()
    @pageCount = ko.observable(0)
    @isLoading = ko.observable yes
    @imageData = ko.observable()

    window = GUI.showWindow(GUI.template('pdfimport'))
    ko.applyBindings(this, window.root())
    window.get('preview').css
      'background-image': 'url(res/loader.gif)'
      'background-size': '32px 32px'

    Pdf::readFile file, (pdf) =>
      @pageCount pdf.pagesCount
      @selectedPage.subscribe =>
        @isLoading yes
        pdf.getPage parseInt(@selectedPage()), (img) =>
          @img = img
          @imageData img.src
          @isLoading no
      @selectedPage 1

  importPage: =>
    if @img? and @onImportPage?
      @onImportPage @img
    GUI.closeWindow()

  cancel: -> GUI.closeWindow()