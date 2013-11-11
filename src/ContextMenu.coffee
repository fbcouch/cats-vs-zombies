# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

DEBUG = false

window.catsvzombies.ContextMenu = class CreatureContextMenu extends createjs.Container
  constructor: (@preload, @card) ->
    @initialize()

    @btn_attack = new catsvzombies.ToggleButton @preload, 'btn-attack-untoggled', 'btn-attack', card.is_attacking, card.toggle_attacking

    @layout()

  layout: ->
    @removeAllChildren()

    @addChild @btn_attack

    {width: @width, height: @height} = @getBounds() if @children.length > 0

  update: (delta) ->
    child.update?() for child in @children