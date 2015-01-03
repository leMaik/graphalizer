#helper functions for commonly used kinetic stuff

ImageCircle = (config) ->
  group = new Kinetic.Group
    width: config.size
    height: config.size
    draggable: yes
    x: config.x
    y: config.y

  .add new Kinetic.Circle
    radius: config.size / 2
    fill: 'white'
    shadowColor: 'black'
    shadowBlur: 5
    shadowOpacity: 0.5

  img = new Image()
  img.onload = =>
    group.add new Kinetic.Image
      image: img
      width: config.size - 2
      height: config.size - 2
      offset:
        x: config.size / 2 - 1
        y: config.size / 2 - 1

    group.draw()
  img.src = config.image

  if config.tooltip?
    tooltip = new Kinetic.Label
      x: 0
      y: 15
      opacity: 0.75

    tooltip.add new Kinetic.Tag
      fill: 'black'
      pointerDirection: 'up'
      pointerWidth: 10
      pointerHeight: 5
      shadowColor: 'black'
      shadowBlur: 10
      shadowOffset:
        x: 2
        y: 2
      shadowOpacity: 0.5

    tooltip.add new Kinetic.Text
      text: config.tooltip
      fontFamily: 'Ubuntu'
      fontSize: 12
      padding: 5
      fill: 'white'

    group.on 'mouseenter', =>
      group.add(tooltip).draw()
    group.on 'mouseout', =>
      tooltip.remove()
      STAGE.draw()

  return group