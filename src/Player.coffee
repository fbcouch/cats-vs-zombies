# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

DEBUG = false

window.catsvzombies.AbstractPlayer = class AbstractPlayer
  constructor: (@game, @element) ->
    @curhp = 20
    @maxhp = 20
    @hand = []
    @discard = []
    @mana = []
    @mana_active = []
    @mana_used = []
    @creatures = []

    @hp_indicator = new HPIndicator @, @game, @element.find('.hp_indicator').eq(0)

  update: ->
    @hp_indicator.update()

window.catsvzombies.Player = class Player extends catsvzombies.AbstractPlayer
  constructor: (@game, @bindElement) ->
    super @game, @bindElement


catsvzombies.HPIndicator = class HPIndicator
  constructor: (@player, @game, @element) ->
    @update()

  update: ->
    if @player.curhp isnt @curhp or @player.maxhp isnt @maxhp
      div = @element.find('div')
      pct = @player.curhp / @player.maxhp * 100
      div.animate({'width': "#{@player.curhp / @player.maxhp * 100}%"}, 1)
      if pct > 50
        div.addClass 'progress-bar-success'
        div.removeClass 'progress-bar-warning'
        div.removeClass 'progress-bar-danger'
      else if pct > 25
        div.removeClass 'progress-bar-success'
        div.addClass 'progress-bar-warning'
        div.removeClass 'progress-bar-danger'
      else
        div.removeClass 'progress-bar-success'
        div.removeClass 'progress-bar-warning'
        div.addClass 'progress-bar-danger'

      @element.find('span').html("HP: #{@player.curhp} / #{@player.maxhp}")
      @curhp = @player.curhp
      @maxhp = @player.maxhp
    @