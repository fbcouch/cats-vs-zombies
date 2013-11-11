# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

window.catsvzombies.ActiveMana = class ActiveMana extends createjs.Container
  constructor: (@preload, @active_mana) ->
    @initialize()

    @icons = []
    @last = {}

    @clickable = false

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
    @active_mana[key]-- if @active_mana[key] > 0 if @clickable