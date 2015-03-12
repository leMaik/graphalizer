# The GraphAnalyser class finds and analyses graphs and ultimately returns
# a set of coordinates that represents points on the graph.
# This is done by the analyse method, which does all tasks on its own.
# All 'find' methods are not meant to be called and are generally helper functions for analyse.

class GraphAnalyser
  constructor: (@parentDocument, @analyserProgressCallback = ConsoleProgressHandler,
                @toleranceSettings = ToleranceSettings::default(),
                @environmentSettings = EnvironmentSettings::default(),
                @reductionSettings = ReductionSettings::default(),
                @qualitySettings = QualitySettings::default()) ->
    @graphColor = [0, 0, 0]

  findAnyMarkedRegion: (gridSize = 10) ->
    x = 0
    y = 0
    while x < @parentDocument.getWidth()
      y = 0
      while y < @parentDocument.getHeight()
        if @parentDocument.isMarked(x, y)
          return new Coordinate(x, y)
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

  findUpMostMarked: (origin) ->
    while origin.y > 0 and @parentDocument.isMarked {x: origin.x, y: origin.y-1}
      origin.y--
    return new Coordinate(origin) # deep copy

  findLowestMarked: (origin) ->
    documentHeight = @parentDocument.getHeight()
    while origin.y < documentHeight and @parentDocument.isMarked {x: origin.x, y: origin.y+1}
      origin.y++
    return new Coordinate(origin) # deep copy

  findNextMarked: (origin, offset) ->
    x = origin.x + offset

    upSeek = Math.max(origin.y - @qualitySettings.markingFinderTolerance, 0);
    downSeek = Math.min(origin.y + @qualitySettings.markingFinderTolerance, @parentDocument.getHeight())

    while upSeek > 0 && @parentDocument.isMarked(x, upSeek)
      --upSeek
    while downSeek < @parentDocument.getHeight() && @parentDocument.isMarked(x, downSeek)
      ++downSeek

    markedRegions = []
    up = 0
    curGraphContainmet = 0
    markedState = no

    for y in [upSeek..downSeek]
      if @isWithinGraph(x, y)
        curGraphContainment++

      if not markedState and @parentDocument.isMarked(x, y)
        up = y
        curGraphContainment = 0
        markedState = yes

      if markedState and not @parentDocument.isMarked(x, y)
        markedRegions.push {up: up, down: y - 1, graphContainment: curGraphContainment}
        markedState = no

    if markedState
      markedRegions.push {up: up, down: downSeek - 1, graphContainment: curGraphContainment}

    if markedRegions.length == 0
      return Coordinate::invalid()

    markedRegions.sort((a, b) ->
      return b.graphContainment - a.graphContainment
    )

    return new Coordinate(x, (markedRegions[0].up + markedRegions[markedRegions.length - 1].down)/2)

  getCenterOfMass: (origin, upMost, lowest, heuristic) ->
    posAccum = []

    # gather all points that are not the background (supposedly within graph)
    for y in [upMost.y .. lowest.y]
      if @isWithinGraph new Coordinate(origin.x, y)
        posAccum.push y

    if posAccum.length == 0
      return null

    upGraph = posAccum[0]
    downGraph = posAccum[posAccum.length - 1]

    # calculate center point based on heuristic
    if heuristic == HeuristicTypes.median
      return [StochasticHelpers.median(posAccum), upGraph, downGraph]
    else if heuristic == HeuristicTypes.top
      return [upGraph, upGraph, downGraph]
    else if heuristic == HeuristicTypes.bottom
      return [downGraph, upGraph, downGraph]
    else if heuristic == HeuristicTypes.mean
      return [StochasticHelpers.mean(posAccum), upGraph, downGraph]
    else
      throw "invalid heuristic"

  gatherGraphPoints: (origin) ->
    list = []
    position = new Coordinate(origin)
    progress = 0

    inLoop = (offset) =>
      up = @findUpMostMarked(position)
      down = @findLowestMarked(position)

      heur = @qualitySettings.heuristic
      if (@qualitySettings.eliminatePoints)
        heur = HeuristicTypes.bottom

      infoTriplet = @getCenterOfMass(position, up, down, heur)
      if infoTriplet?
        list.push [new Coordinate(position.x, infoTriplet[0]), infoTriplet[2] - infoTriplet[1]]
        # console.log new Coordinate(position.x, infoTriplet[0])
        @analyserProgressCallback.onProgress(++progress)

      position = @findNextMarked(position, offset)
      return not (position.x == -1 and position.y == -1)

    continue while position.x < @parentDocument.getWidth() and inLoop(1)

    position = origin
    continue while position.x > 0 and inLoop(-1)

    return list

  # this function reduces the amount of points in "points" by "1-resolutionPermille" in "reductionSettings"
  rarify: (points) ->
    if (points.length == 0)
      return []

    result = []
    prev = points[0]
    i = 1
    while i < points.length
      if points[i].x - prev.x >= (@parentDocument.getWidth() / (@reductionSettings.resolutionPermille * @parentDocument.getWidth() / 1000))
        result.push points[i]
        prev = points[i]
      ++i
    return result

  lineHeightAverage: (heightList) ->
    iterations = @qualitySettings.eliminationQuality # the higher the better
    RANSAC = new LinearRansac(heightList.length * 0.2, 1.1, 0)
    line = RANSAC.compute(heightList, heightList.length * 0.7, iterations, true)

    return line.coefficients[0]

  # uses RANSAC to get average height and then eliminates all outliers
  ransacErrorCorrect: (graphInfoStructure) ->
    lWidth = []
    for i in graphInfoStructure
      lWidth.push {x: i[0].x, y: i[1]}

    averageHeight = @lineHeightAverage(lWidth)

    for i in [1..graphInfoStructure.length - 1]
      previous = new Coordinate(graphInfoStructure[i-1][0])
      if (Math.abs(graphInfoStructure[i][1] - averageHeight) > @qualitySettings.averageDelta) # is outlier?
        position = new Coordinate(graphInfoStructure[i][0])

        up = @findUpMostMarked(position)
        down = @findLowestMarked(position)

        ys = []
        for y in [up.y..down.y-1]
          if @isWithinGraph(position.x, y)
            newY = findLowest(new Coordinate(position.x, y)).y
            ys.push((y + newY) / 2)
            y = newY

        minYDelta = @parentDocument.getHeight()
        minY = 0
        for y in ys
          delta = abs(y - previous.y)
          if delta < minYDelta
            minY = y
            minYDelta = delta

        graphInfoStructure[i][0] = minY
      else
        position = new Coordinate(graphInfoStructure[i][0])

        up = @findUpMostMarked(position)
        down = @findLowestMarked(position)

        mid = @getCenterOfMass(position, up, down, @qualitySettings.heuristic)
        if mid?
          graphInfoStructure[i][0].y = mid[0]
    return graphInfoStructure

  # does the whole thing
  analyse: (startingPoint) =>
    @analyserProgressCallback.onStatus("finding any marked point");

    # use starting point if given, search one otherwise
    # if startingPoint?
    #   anyMarkedPoint = new Coordinate(startingPoint)
    # else
    anyMarkedPoint = @findAnyMarkedRegion()

    # Has a point beend found? no?
    if anyMarkedPoint.isInvalid()
      console.log "no marked region found"
      return []

    @analyserProgressCallback.onStatus("starting graph analysis");
    @analyserProgressCallback.onStart(@parentDocument.getWidth())

    # gather points within marked region
    graphInfo = @gatherGraphPoints anyMarkedPoint

    @analyserProgressCallback.onStatus("graph analysis complete");

    result = []

    # Reduce noise caused by points and other graphs
    if @qualitySettings.eliminatePoints
      @analyserProgressCallback.onStatus("starting error elimination");
      graphInfo = @ransacErrorCorrect graphInfo
      @analyserProgressCallback.onStatus("error elimination complete");

    for i in graphInfo
      result.push i[0]

    # reduce amounts of points to a reasonable amount
    if @reductionSettings.resolutionPermille != 1000
      @analyserProgressCallback.onStatus("start rarefaction of point list")
      result = @rarify(result)

    console.log "result incoming"
    console.log result

    return result


