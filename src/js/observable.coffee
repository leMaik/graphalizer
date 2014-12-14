class Observable
  constructor: (@value) ->
    @callbacks = []

    fn = (value) =>
      if value?
        @value = value
        callback(value) for callback in @callbacks
      return @value
    fn.bind = @bind

    return fn

  bind: (callback) =>
    @callbacks.push(callback)

observable = (value) -> new Observable(value)