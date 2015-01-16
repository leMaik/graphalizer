# The GraphAnalyser class finds and analyses graphs and ultimately returns
# a set of coordinates that represents points on the graph.
# This is done by the analyse method, which does all tasks on its own.
# All 'find' methods are not meant to be called and are generally helper functions for analyse.

class GraphAnalyser
  constructor: (@parentDocument, @toleranceSettings = defaultToleranceSettings(),
                @environmentSettings = defaultEnvironmentSettings(),
                @transectionSettings = defaultTransectionSettings()) ->

  findGraphInProximity: (origin) ->
    # Was the guess already on the graph? Return if so
    return origin if @toleranceSettings.isTolerated @parentDocument.getPixel(origin.x, origin.y)

    searchRadius = 0
    while origin.x - searchRadius > 0 and
          origin.x + searchRadius < @parentDocument.getWidth() and
          origin.y - searchRadius > 0 and
          origin.y + searchRadius < @parentDocument.getHeight()

      searchRadius++
