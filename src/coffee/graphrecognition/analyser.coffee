# The GraphAnalyser class finds and analyses graphs and ultimately returns
# a set of coordinates that represents points on the graph.
# This is done by the analyse method, which does all tasks on its own.
# All 'find' methods are not meant to be called and are generally helper functions for analyse.

class GraphAnalyser
  constructor: (@parentDocument, @toleranceSettings = ToleranceSettings::default(),
                @environmentSettings = EnvironmentSettings::default(),
                @reductionSettings = ReductionSettings::default(),
                @qualitySettings = QualitySettings::default()) ->
    @graphColor = [0, 0, 0]

  findAnyMarkedRegion: (gridSize = 10) ->
    x = 0
    y = 0
    while x < @parentDocument.getWidth()
      while y < @parentDocument.getHeight()
        if @parentDocument.isMarked(x, y)
          return {x: x, y: y}
        y += gridSize
      x += gridSize
    return Coordinate::invalid()

  findGraphInProximity: (origin, maximumRadius = 100) =>
    bgColor = @environmentSettings.backgroundColor;

    isNotBackground = (point) =>
      return !@toleranceSettings.isTolerated(bgColor, @parentDocument.getPixel(point))

    # Was the guess already on the graph? Return if so
    return origin if isNotBackground origin

    skip = @reductionSettings.circularSearchSkip;
    if skip <= 0
      skip = 1

    radius = 0
    dOuter = 0
    dInner = 0
    circleRadius = 0

    loopUpdate = () =>
      circleRadius = 1 + 2 * skip * radius
      dInner = radius * skip
      dOuter = 1 + (skip + 1) * radius
      return true

    while loopUpdate() and
          origin.x + dOuter < @parentDocument.getWidth() and
          origin.y + dOuter < @parentDocument.getHeight() and
          origin.x - dOuter > 0 and
          origin.y - dOuter > 0
      break if (radius >= maximumRadius)

      # Sides:
      startPointA = {x: origin.x - dOuter, y: origin.y - dInner} # move positive y
      startPointB = {x: origin.x - dInner, y: origin.y - dOuter} # move positive x
      startPointC = {x: origin.x + dOuter, y: origin.y + dInner} # move negative y
      startPointD = {x: origin.x + dInner, y: origin.y + dOuter} # move negative x

      for i in [0..circleRadius]
        return startPointA if isNotBackground startPointA
        return startPointB if isNotBackground startPointB
        return startPointC if isNotBackground startPointC
        return startPointD if isNotBackground startPointD

        startPointA.y++
        startPointB.x++
        startPointC.y--
        startPointD.x--

      # Now Corners:
      An = 1 + skip * radius
      Bn = (1 + skip) * radius

      RT = {x: An  + origin.x, y: -Bn + origin.y}
      LT = {x: -Bn + origin.x, y: -An + origin.y}
      LB = {x: -An + origin.x, y: Bn  + origin.y}
      RB = {x: Bn  + origin.x, y: An  + origin.y}

      for i in [0..radius]
        return RT if isNotBackground RT
        return LT if isNotBackground LT
        return RB if isNotBackground RB
        return LT if isNotBackground LT

        RT.x++
        RT.y++

        LB.x--
        LB.y--

        RB.x--
        RB.y++

        LT.x++
        LT.x--

      radius++

    return Coordinate::invalid()


  # Checks wether the pixel under 'origin' has roughly the graphColor
  isWithinGraph: =>
    point = switch arguments.length
      when 1 then arguments[0]
      when 2 then {x: arguments[0], y: arguments[1]}
    return not @toleranceSettings.isTolerated(@environmentSettings.backgroundColor, @parentDocument.getPixel point)

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
    return new Coordinate(origin) # deep copy

  findLowest: (origin) =>
    documentHeight = @parentDocument.getHeight()
    while origin.y < documentHeight and @isWithinGraph({x: origin.x, y: origin.y+1})
      origin.y++
    return new Coordinate(origin) # deep copy

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
    return @findLowest(origin)

  findNextRight: (origin) =>
    if origin.x is (@parentDocument.getWidth() - 1)
      return origin

    for i in [0..10]
      return {x: origin.x + 1, y: origin.y + i} if @isWithinGraph({x: origin.x + 1, y: origin.y + i})
      return {x: origin.x + 1, y: origin.y - i} if @isWithinGraph({x: origin.x + 1, y: origin.y - i})
    return undefined

  # performs an initial removal of points
  initialClean: (origin) ->

  findUpMostMarked: (origin) ->
    while origin.y > 0 and @parentDocument.isMarked {x: origin.x, y: origin.y-1}
      origin.y--
    return new Coordinate(origin) # deep copy

  findLowestMarked: (origin) ->
    documentHeight = @parentDocument.getHeight()
    while origin.y < documentHeight and @parentDocument.isMarked {x: origin.x, y: origin.y+1}
      origin.y++
    return new Coordinate(origin) # deep copy

  getCenterOfMass: (origin) ->
    upMost = @findUpMostMarked origin
    lowest = @findLowestMarked origin

    posAccum = []
    for y in [upMost.y .. lowest.y]
      if @isWithinGraph new Coordinate(origin.x, y)
        posAccum.push y

    if @qualitySettings.heuristic == HeuristicTypes.median
      posAccum.sort()
      if posAccum.length() == 0
        return 0
      else
        return posAccum[posAccum.length() / 2]
    else # mean and unimplemented (mean is fallback)
      return Util.mean posAccum

  gatherGraphPoints: (origin) ->
    list = []
    originalOrigin = new Coordinate(origin)
    while origin.x < @parentDocument.getWidth() and @parentDocument.isMarked origin
      origin.y = @getCenterOfMass origin
      list.push origin
      ++origin.x

    origin = originalOrigin
    while origin.x > 0 and @parentDocument.isMarked origin
      origin.y = @getCenterOfMass origin
      list.push origin
      --origin.x

    return list

  # Separates the graph into several points
  transectGraph: (origin) =>
    set = []
    curPoint = origin
    count = 0
    nextPoint = new Coordinate(0, 0)
    docWidth = @parentDocument.getWidth()

    while true
      nextPoint = @findNextRight(curPoint)
      break if nextPoint is undefined

      console.log 'transectGraph: %d/%d', nextPoint.x, nextPoint.y
      break if (nextPoint.x is curPoint.x and nextPoint.y is curPoint.y)

      mostUp = @findUpMost(nextPoint)
      lowest = @findLowest(nextPoint)
      lowest.y--

      if count % (docWidth /  (docWidth * @reductionSettings.resolutionPermille / 1000)) == 0
        set.push {x: mostUp.x, y: (mostUp.y + lowest.y)/2}

      curPoint = lowest
      count++

    return set

  analyse: =>
    # Find marked region
    anyMarkedPoint = @findAnyMarkedRegion()

    console.log anyMarkedPoint

    # Has a point beend found? no?
    return undefined if anyMarkedPoint is Coordinate::invalid()

    # Removes points from graph
    if @qualitySettings.eliminatePoints
      @initialClean anyMarkedPoint

    result = @gatherGraphPoints anyMarkedPoint

    return result

    # Get the graph color for further analysis
    # @graphColor = @parentDocument.getPixel anyPointOfGraph

    # Find the beginning of the graph
    # startingPoint = @findLeftMostBottomPoint anyPointOfGraph

    # Finally get an array of points that represent the graph
    # return @transectGraph startingPoint


