class Observable
  constructor: (@value) ->
    @callbacks = []
    @elementBindings = []

    fn = (value) =>
      if value?
        old = @value
        @value = value
        callback(value, old) for callback in @callbacks
        b.fn(value, old) for b in @elementBindings
      return @value

    fn.subscribe = (callback) =>
      @callbacks.push(callback)
      return fn

    fn.bind = (element, converter) =>
      if not @id?
        @id = Date.now() + '_' + Math.floor(Math.random() * 100)

      update = ->
        if converter?
          fn converter element.val()
        else
          fn element.val()

      element.on 'input.' + @id, update
      element.on 'change.' + @id, update

      @elementBindings.push
        element: element
        fn: => element.val(@value)
        converter: converter

      element.val(@value)

      return fn

    fn.unbind = (element) =>
      if @id?
        element.off 'input.' + @id
        element.off 'change.' + @id

        @elementBindings = @elementBindings.filter (e) ->
          e.element.get(0) isnt element.get(0)

      return fn

    return fn

observable = (value) ->
  new Observable(value)
