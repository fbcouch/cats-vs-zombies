# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

DEBUG = false

window.catsvzombies.ContextMenu = class CreatureContextMenu extends createjs.Container
  constructor: (@preload, @card, @player, @levelScreen) ->
    @initialize()

    @btn_attack = new catsvzombies.ToggleButton @preload, 'btn-attack-untoggled', 'btn-attack-toggled', card.is_attacking, card.toggle_attacking
    @btn_defend = new catsvzombies.ToggleButton @preload, 'btn-defend-untoggled', 'btn-defend-toggled', card.is_defending, card.toggle_defending

    @layout()

  layout: ->
    if @card.can_attack and not @card.tapped and @player is @levelScreen.current
      @addChild @btn_attack if not @btn_attack.parent?
    else
      @removeChild @btn_attack
    if @player isnt @levelScreen.current and @levelScreen.combat_mode and not @card.tapped
      @addChild @btn_defend if not @btn_defend.parent?
    else
      @removeChild @btn_defend

    {width: @width, height: @height} = @getBounds() if @children.length > 0

  update: (delta) ->
    @layout()
    child.update?() for child in @children