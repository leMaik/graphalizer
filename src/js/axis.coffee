# Code for axes
class Axis
  constructor: ->
    @scale = 10

    AXES.add(@line = @getLine()).draw()

class HorizontalAxis extends Axis
  getLine: ->
    line = new Kinetic.Line
      points: [0, 0, STAGE.width() - 100, 0]
      stroke: 'red'
      strokeWidth: 5
      draggable: yes
      x: 50
      y: 50
    .on 'dragmove', =>
      @line.x(50)
      console.log 'dragmove'
    .on 'mouseenter', -> $('body').css('cursor', 'row-resize')
    .on 'mouseleave', -> $('body').css('cursor', '')

class VerticalAxis extends Axis
  getLine: ->
    new Kinetic.Line
      points: [0, 0, 0, STAGE.height() - 100]
      stroke: 'red'
      strokeWidth: 5
      draggable: yes
      x: 50
      y: 50
    .on 'dragmove', =>
        @line.y(50)
        console.log 'dragmove'
    .on 'mouseenter', -> $('body').css('cursor', 'col-resize')
    .on 'mouseleave', -> $('body').css('cursor', '')