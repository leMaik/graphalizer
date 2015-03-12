class AnalyzeValue
  constructor: (x, y) ->
    @x = ko.observable x
    @y = ko.observable y

    @controls = {}
    @controls.deleteBtn = ImageCircle
      size: 20
      image: 'res/delete.svg'
      x: x + 10
      y: y + 10
      tooltip: 'Löschen'
    .on 'click', =>
      @controls.deleteBtn.remove()
      Layers.PAPER.draw()
      @remove()
      Layers.POINTS.draw()

    @isEditing = ko.observable(no)
    @isEditing.subscribe (v) =>
      if v
        @controls.deleteBtn.x(@kineticElement.x() + 10).y(@kineticElement.y() + 10)
        Layers.PAPER.add(@controls.deleteBtn).draw()
      else
        @controls.deleteBtn.remove()
        @kineticElement.remove()
        Layers.PAPER.draw()

    @kineticElement = new Kinetic.Circle
      radius: 5
      fill: 'orange'
      shadowColor: 'black'
      shadowBlur: 5
      shadowOpacity: 0.5
      x: x
      y: y
      draggable: yes
    .on 'dragmove', =>
      @x @kineticElement.x()
      @y @kineticElement.y()

      if @isEditing()
        @controls.deleteBtn.x(@kineticElement.x() + 10).y(@kineticElement.y() + 10)
        Layers.POINTS.draw()
        Layers.PAPER.draw()
    .on 'click', =>
      @isEditing !@isEditing()

    Layers.POINTS.add(@kineticElement).draw()

    @values = ko.computed(=> axis.valueAt(@x(), @y()) for axis in AXES()).extend({rateLimit: 500})

  remove: =>
    @kineticElement.remove()
    POINTS.remove @