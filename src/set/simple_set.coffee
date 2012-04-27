#= require ../enumerable

class Batman.SimpleSet
  constructor: ->
    @_storage = []
    @length = 0
    @add.apply @, arguments if arguments.length > 0

  Batman.extend @prototype, Batman.Enumerable

  has: (item) ->
    !!(~@_storage.indexOf item)

  add: (items...) ->
    addedItems = []
    for item in items when !~@_storage.indexOf item
      @_storage.push item
      addedItems.push item
    @length = @_storage.length
    if @fire and addedItems.length isnt 0
      @fire('change', this, this)
      @fire('itemsWereAdded', addedItems...)
    addedItems
  remove: (items...) ->
    removedItems = []
    for item in items when ~(index = @_storage.indexOf(item))
      @_storage.splice(index, 1)
      removedItems.push item
    @length = @_storage.length
    if @fire and removedItems.length isnt 0
      @fire('change', this, this)
      @fire('itemsWereRemoved', removedItems...)
    removedItems
  find: (f) ->
    for item in @_storage
      return item if f(item)
    return
  forEach: (iterator, ctx) ->
    container = this
    @_storage.slice().forEach (key) -> iterator.call(ctx, key, null, container)
  isEmpty: -> @length is 0
  clear: ->
    items = @_storage
    @_storage = []
    @length = 0
    if @fire and items.length isnt 0
      @fire('change', this, this)
      @fire('itemsWereRemoved', items...)
    items
  replace: (other) ->
    try
      @prevent?('change')
      @clear()
      @add(other.toArray()...)
    finally
      @allowAndFire?('change', this, this)
  toArray: -> @_storage.slice()
  merge: (others...) ->
    merged = new @constructor
    others.unshift(@)
    for set in others
      set.forEach (v) -> merged.add v
    merged
  indexedBy: (key) ->
    @_indexes ||= new Batman.SimpleHash
    @_indexes.get(key) or @_indexes.set(key, new Batman.SetIndex(@, key))
  indexedByUnique: (key) ->
    @_uniqueIndexes ||= new Batman.SimpleHash
    @_uniqueIndexes.get(key) or @_uniqueIndexes.set(key, new Batman.UniqueSetIndex(@, key))
  sortedBy: (key, order="asc") ->
    order = if order.toLowerCase() is "desc" then "desc" else "asc"
    @_sorts ||= new Batman.SimpleHash
    sortsForKey = @_sorts.get(key) or @_sorts.set(key, new Batman.Object)
    sortsForKey.get(order) or sortsForKey.set(order, new Batman.SetSort(@, key, order))
