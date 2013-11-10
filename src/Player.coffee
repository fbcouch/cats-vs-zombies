# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

DEBUG = false

window.catsvzombies.Player = class Player
  constructor: (@preload, @deck) ->
    @curhp = 0
    @maxhp = 0
    @hand = []
    @discard = []
    @mana = []
    @mana_active = []
    @mana_used = []
    @creatures = []


window.catsvzombies.ManaIndicator = class ManaIndicator extends createjs.Container
  constructor: (@preload, @mana_pool) ->
    @initialize()
    @totals =
      mouse: 0
      bird: 0
      fish: 0
      grave: 0
      brain: 0

    @icons = []
    @texts = []

    for key of @totals
      @icons[key] = new createjs.Bitmap @preload.getResult "mana-#{key}"
      @texts[key] = new createjs.Text "0", 'normal 28px sans-serif', '#FFF'

      @icons[key].key = key
      @icons[key].addEventListener 'click', (event) ->
        event.currentTarget.parent.clicked? event.currentTarget.key

      @texts[key].key = key
      @texts[key].addEventListener 'click', (event) ->
        event.currentTarget.parent.clicked? event.currentTarget.key

    @active =
      mouse: 0
      bird: 0
      fish: 0
      grave: 0
      brain: 0

    @used =
      mouse: 0
      bird: 0
      fish: 0
      grave: 0
      brain: 0

  update: ->
    @removeAllChildren()
    for key of @totals
      @totals[key] = 0


    for mana in @mana_pool
      @totals[key] += val for key, val of mana.proto.provides

    for key of @active
      @totals[key] = @totals[key] - @active[key] - @used[key]

    y = 0
    for key, val of @totals when val > 0
      @icons[key].x = 0
      @texts[key].x = @icons[key].image.width + 5
      @icons[key].y = y
      @texts[key].y = y
      @texts[key].text = val
      y += @icons[key].image.height + 10
      @addChild @icons[key]
      @addChild @texts[key]

    {width: @width, height: @height} = @getBounds() if @children.length > 0

  clicked: (key) ->
    @active[key]++ if @totals[key] > 0

  reset_used: () ->
    @used[key] = 0 for key of @used

window.catsvzombies.ActiveMana = class ActiveMana extends createjs.Container
  constructor: (@preload, @active_mana) ->
    @initialize()

    @icons = []
    @last = {}

  update: ->
    # update only when dirty
    dirty = false
    dirty = true for key of @active_mana when @active_mana[key] isnt @last[key]
    @last[key] = @active_mana[key] for key of @active_mana
    if dirty
      @removeAllChildren()
      x = 0
      for key, val of @active_mana when val > 0
        for i in [0...val]
          icon = new createjs.Bitmap @preload.getResult "mana-#{key}"
          icon.key = key
          icon.addEventListener 'click', (event) ->
            event.currentTarget.parent.clicked event.currentTarget.key

          icon.x = x
          x += icon.image.width + 5
          icon.y = 0
          @addChild icon

      {width: @width, height: @height} = @getBounds() if @children.length > 0

  clicked: (key) ->
    @active_mana[key]-- if @active_mana[key] > 0