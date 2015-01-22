class AnalyzeValue extends Observable
  constructor: (x, y) ->
    super()

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

      @isRemoved = yes
      @notifyObservers(yes)

    @isEditing = observable(no).subscribe (v) =>
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
      @notifyObservers(yes)

      if @isEditing()
        @controls.deleteBtn.x(@kineticElement.x() + 10).y(@kineticElement.y() + 10)
        Layers.POINTS.draw()
        Layers.PAPER.draw()
    .on 'click', =>
      @isEditing !@isEditing()

    @subscribe GUI.updateAllValues

  getValues: =>
    axis.valueAt(@kineticElement.x(), @kineticElement.y()) for axis in AXES()