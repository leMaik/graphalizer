class ObservableVariable
  constructor: (@value) ->
    @callbacks = []
    @elementBindings = []

    fn = (value) =>
      if typeof value isnt "undefined"
        old = @value
        @value = value
        @notifySubscribers(value, old)
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

  notifySubscribers: (value, old) =>
    callback(value, old) for callback in @callbacks
    b.fn(value, old) for b in @elementBindings

class ObservableArray extends ObservableVariable
  constructor: ->
    fn = super([])

    fn.push = (value) =>
      @value.push(value)
      @notifySubscribers @value

    fn.removeAll = =>
      @value = []
      @notifySubscribers @value

    fn.remove = (value) =>
      @value.splice(@value.indexOf(value), 1)
      @notifySubscribers @value

    return fn

class Observable
  constructor: ->
    @changed = no
    @callbacks = []
  setChanged: (changed) =>
    @changed = changed
  notifyObservers: (force) =>
    if force or @changed
      callback(@) for callback in @callbacks
      @changed = no
  subscribe: (callback) =>
    @callbacks.push callback

observable = (value) ->
  new ObservableVariable(value)

observableArray = (value) ->
  new ObservableArray(value)