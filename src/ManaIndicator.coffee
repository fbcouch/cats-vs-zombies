# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

window.catsvzombies.ManaIndicator = class ManaIndicator extends createjs.Container
  constructor: (@preload, @player) ->
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

    @active = @player.mana_active
    @used = @player.mana_used
    for key of @totals
      @active[key] = 0
      @used[key] = 0

    @clickable = false

  update: ->
    @removeAllChildren()
    for key of @totals
      @totals[key] = 0


    for mana in @player.mana
      @totals[key] += val for key, val of mana.proto.provides

    for key of @active
      @totals[key] = @totals[key] - @active[key] - @used[key]

    x = 0
    for key, val of @totals when val > 0
      @icons[key].x = x
      @texts[key].x = x + @icons[key].image.width + 5
      @icons[key].y = 0
      @texts[key].y = 0
      @texts[key].text = val
      x = @texts[key].x + @texts[key].getBounds().width + 10
      @addChild @icons[key]
      @addChild @texts[key]

    {width: @width, height: @height} = @getBounds() if @children.length > 0

  clicked: (key) ->
    @active[key]++ if @totals[key] > 0 if @clickable

  reset_used: () ->
    @used[key] = 0 for key of @used

  activate_all: () ->
    @active[key] = val - @used[key] for key, val of @totals