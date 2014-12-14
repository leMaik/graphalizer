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

  return group