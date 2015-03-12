
class ProgressHandler
  constructor: (@progress, @start, @status) ->
    @maxValue = 1

  onProgress: (value) ->
    if @progress?
      @progress(value, @maxValue)

  onStart: (maxVal) ->
    @maxValue = maxVal
    if @start?
      @start @maxValue

  onStatus: (someStatusString) ->
    if @status?
      @status someStatusString


ConsoleProgressHandler = new ProgressHandler(
  (value, maxValue) =>
    console.log "Progress: %d/%d", value, maxValue
  ,
  (maxValue) =>
    console.log "Start: %d", maxValue
  ,
  (status) =>
    console.log "Status: %s", status
)
