class PdfImport
  constructor: (file) ->
    @selectedPage = ko.observable null

    window = GUI.showWindow(GUI.template('pdfimport'))
    window.get('preview').css
      'background-image': 'url(res/loader.gif)'
      'background-size': '32px 32px'

    Pdf::readFile file, (pdf) =>
      window.get('pagesCount').text(pdf.pagesCount)
      @selectedPage.bind window.get('page'), (v) -> parseInt v

      @selectedPage.subscribe (v) =>
        if 0 < v <= pdf.pagesCount
          window.get('preview').css
            'background-image': 'url(res/loader.gif)'
            'background-size': '32px 32px'
          pdf.getPage v, (img) =>
            @img = img
            window.get('preview').css
              'background-image': 'url(' + img.src + ')'
              'background-size': ''
        else if v < 1
          @selectedPage 1
        else
          @selectedPage pdf.pagesCount

      @selectedPage 1

      window.get('import').on 'click', =>
        if @onImportPage?
          @onImportPage @img
        GUI.closeWindow()

      window.get('cancel').on 'click', -> GUI.closeWindow()