class AnalyzeValue
  constructor: (@x, @y) ->
    @kineticElement = new Kinetic.Circle
      radius: 5
      fill: 'orange'
      shadowColor: 'black'
      shadowBlur: 5
      shadowOpacity: 0.5
      x: @x
      y: @y
      draggable: yes
    @kineticElement.on 'dragmove', =>
      @x = @kineticElement.x()
      @y = @kineticElement.y()

  getValues: =>
    axis.valueAt(@x, @y) for axis in AXES()