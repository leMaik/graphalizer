# The tolerance determines how much colors may vary for the algorithm's edge detection
class ToleranceSettings
  constructor: (@redTolerance = 10, @greenTolerance = 10, @blueTolerance = 10) ->

  isTolerated: (shouldRgb, isRgb) =>
    Util::within(shouldRgb[0], isRgb[0], @redTolerance) and
    Util::within(shouldRgb[1], isRgb[1], @greenTolerance) and
    Util::within(shouldRgb[2], isRgb[2], @blueTolerance)

  default: -> new ToleranceSettings()

# The default background color is white, but should be pickable from the gui
class EnvironmentSettings
  constructor: (@backgroundColor = [255, 255, 255]) ->

  default: -> new EnvironmentSettings()

# The default resolution is still plenty of values
class ReductionSettings
  constructor: (@resolutionPermille = 50, @circularSearchSkip = 1) ->

  default: -> new ReductionSettings()

HeuristicTypes =
  mean : 0
  median: 1
  gravity: 2 # not yet supported

# Contains toggle switches for algorithms that improve the analysis, but come at decent a cost of runtime
class QualitySettings
  constructor: (@heuristic = HeuristicTypes.median, @markingFinderTolerance = 10, @eliminatePoints = no, @skimmingFactor = 0.09, @regressiveAutoAdjust = no) ->

  default: -> new QualitySettings()
