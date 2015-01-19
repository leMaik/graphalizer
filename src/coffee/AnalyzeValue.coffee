class AnalyzeValue extends Observable
  constructor: (x, y) ->
    super()
    @kineticElement = new Kinetic.Circle
      radius: 5
      fill: 'orange'
      shadowColor: 'black'
      shadowBlur: 5
      shadowOpacity: 0.5
      x: x
      y: y
      draggable: yes
    @subscribe GUI.updateAllValues
    @kineticElement.on 'dragmove', =>
      @notifyObservers(yes)
  getValues: =>
    axis.valueAt(@kineticElement.x(), @kineticElement.y()) for axis in AXES()