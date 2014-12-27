class Observable
  constructor: (@value) ->
    @callbacks = []

    fn = (value) =>
      if typeof value isnt "undefined"
        @value = value
        callback(value) for callback in @callbacks
      return @value

    fn.bind = (callback) =>
      @callbacks.push(callback)
      return fn

    return fn

observable = (value) -> new Observable(value)