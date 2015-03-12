class ProgressHandler
  constructor: (@handlers) ->
    @maxValue = 1

  onProgress: (value) ->
    if @handlers.onProgressChanged?
      @handlers.onProgressChanged value, @maxValue, value / @maxValue * 100

  onStart: (maxVal) ->
    @maxValue = maxVal
    if @handlers.onStart?
      @handlers.onStart @maxValue

  onStatus: (someStatusString) ->
    if @handlers.onStatusChanged?
      @handlers.onStatusChanged someStatusString


ConsoleProgressHandler = new ProgressHandler(
  onProgressChanged: (value, maxValue, progress) =>
    console.log "Progress: %d%%", progress
  onStart: (maxValue) =>
    console.log "Start: %d", maxValue
  onStatusChanged: (status) =>
    console.log "Status: %s", status
)