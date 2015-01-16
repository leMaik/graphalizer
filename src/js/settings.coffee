# The tolerance determines how much colors may vary for the algorithm's edge detection
class ToleranceSettings
  constructor: (@redTolerance = 10, @greenTolerance = 10, @blueTolerance = 10) ->

  isTolerated: (shouldRgb, isRgb) =>
    Util::within(shouldRgb[0], isRgb[0], @redTolerance) and
    Util::within(shouldRgb[1], isRgb[1], @greenTolerance) and
    Util::within(shouldRgb[2], isRgb[2], @blueTolerance)

# The default background color is white, but should be pickable from the gui
class EnvironmentSettings
  constructor: (@backgroundColor = [255, 255, 255]) ->

# The default resolution is still plenty of values
class TransectionSettings
  constructor: (@resolutionPermille = 100)

defaultToleranceSettings() ->
  return new ToleranceSettings()

defaultEnvironmentSettings() ->
  return new EnvironmentSettings()

defaultTransectionSettings() ->
  return new TransectionSettings()

