# The GraphAnalyser class finds and analyses graphs and ultimately returns
# a set of coordinates that represents points on the graph.
# This is done by the analyse method, which does all tasks on its own.
# All 'find' methods are not meant to be called and are generally helper functions for analyse.

class GraphAnalyser
  constructor: (@parentDocument, @toleranceSettings = ToleranceSettings::default(),
                @environmentSettings = EnvironmentSettings::default(),
                @transectionSettings = TransectionSettings::default()) ->
    @graphColor = [0, 0, 0]

  findGraphInProximity: (origin) =>
    bgColor = @environmentSettings.backgroundColor;

    # Was the guess already on the graph? Return if so
    return origin if !@toleranceSettings.isTolerated(bgColor, @parentDocument.getPixel(origin))

    searchRadius = 0
    while origin.x - searchRadius > 0 and
          origin.x + searchRadius < @parentDocument.getWidth() and
          origin.y - searchRadius > 0 and
          origin.y + searchRadius < @parentDocument.getHeight()

      # Traverse all possible surrounding pixels in  the radius
      for i in [-1*searchRadius..searchRadius+1]
        for j in [-1*searchRadius..searchRadius+1]
          if !@toleranceSettings.isTolerated(bgColor, @parentDocument.getPixel(origin.x + i, origin.y + j))
            return new Coordinate(origin.x + i, origin.y + j)

      # The graph has yet not been found -> increase search radius
      searchRadius++

    # The algorithm could not find the graph -> return an invalid position
    return Coordinate::invalid()

  # Checks wether the pixel under 'origin' has roughly the graphColor
  isWithinGraph: =>
    point = switch arguments.length
      when 1 then arguments[0]
      when 2 then {x: arguments[0], y: arguments[1]}
    return @toleranceSettings.isTolerated(@graphColor, @parentDocument.getPixel point)

  # Used in 'findLeftMostBottomPoint
  seekToLeftBottom: (origin) =>
    if @isWithinGraph(origin.x - 1, origin.y + 1) # 1
      return new Coordinate(origin.x - 1, origin.y + 1)
    if @isWithinGraph(origin.x - 1, origin.y    ) # 2
      return new Coordinate(origin.x - 1, origin.y)
    if @isWithinGraph(origin.x - 1, origin.y - 1) # 3
      return new Coordinate(origin.x - 1, origin.y - 1)
    if @isWithinGraph(origin.x    , origin.y + 1) # 4
      return new Coordinate(origin.x, origin.y + 1)
    return Coordinate::invalid()

  findUpMost: (origin) =>
    while origin.y > 0 and @isWithinGraph({x: origin.x, y: origin.y-1})
      origin.y--
    return origin

  findLowest: (origin) =>
    documentHeight = @parentDocument.getHeight()
    while origin.y < documentHeight and @isWithinGraph({x: origin.x, y: origin.y+1})
      origin.y++
    return origin

  # This function seeks the leftest and most bottom point of the graph
  # under the passed position (origin). It uses the member variable 'graphColor'
  # to differentiate between graph and no graph
  findLeftMostBottomPoint: (origin) =>
    seekToLeftBottom = () =>
      if @isWithinGraph(origin.x - 1, origin.y + 1) # 1
        origin.x--
        origin.y++
      else if @isWithinGraph(origin.x - 1, origin.y    ) # 2
        origin.x--
      else if @isWithinGraph(origin.x - 1, origin.y - 1) # 3
        origin.x--
        origin.y--
      else if @isWithinGraph(origin.x    , origin.y + 1) # 4
        origin.y++
      else
        return false
      return true

    while origin.x > 0 and origin.y < @parentDocument.getHeight() and origin.y > 0
      if seekToLeftBottom(origin)
      else if @isWithinGraph({x: origin.x, y: origin.y - 1})
        # this is the last resort. There are still pixels above, so seek up
        origin.y = @findUpMost(origin).y
        previousX = origin.x
        seekToLeftBottom(origin)
        break if previousX is origin.x
      else
        break
      # console.log 'findLeftMostBottom: %d,%d', origin.x, origin.y
    return @findLowest(origin)

  findNextRight: (origin) =>
    if origin.x is (@parentDocument.getWidth() - 1)
      return origin

    max = @findUpMost(origin)
    y = origin.y
    while y >= max.y
      return {x: origin.x + 1, y: y} if @isWithinGraph({x: origin.x + 1, y: y})
      y--
    return origin

  # Separates the graph into several points
  transectGraph: (origin) =>
    set = []
    curPoint = origin
    count = 0
    nextPoint = new Coordinate(0, 0)
    docWidth = @parentDocument.getWidth()

    while true
      nextPoint = @findNextRight(curPoint)
      console.log 'transectGraph: %d/%d', nextPoint.x, nextPoint.y
      break if (nextPoint.x is curPoint.x and nextPoint.y is curPoint.y)

      mostUp = @findUpMost(nextPoint)
      lowest = @findLowest(nextPoint)

      # if count % (docWidth /  (docWidth * @transectionSettings.resolutionPermille / 1000)) == 0
      set.push {x: mostUp.x, y: (mostUp.y + lowest.y)/2}

      curPoint = lowest
      count++

    return set

  analyse: (origin) =>
    # Find graph near the specified point
    anyPointOfGraph = @findGraphInProximity origin

    # Has a point beend found? no?
    return undefined if anyPointOfGraph is Coordinate::invalid()

    # Get the graph color for further analysis
    @graphColor = @parentDocument.getPixel anyPointOfGraph

    # Find the beginning of the graph
    startingPoint = @findLeftMostBottomPoint anyPointOfGraph

    # Finally get an array of points that represent the graph
    return @transectGraph startingPoint


