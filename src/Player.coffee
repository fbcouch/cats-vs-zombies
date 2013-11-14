# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

DEBUG = false

window.catsvzombies.AbstractPlayer = class AbstractPlayer
  constructor: (@game, @cards, @element) ->
    @curhp = 20
    @maxhp = 20
    @hand or= []
    @discard = []
    @mana = []
    @mana_active = []
    @mana_used = []
    @creatures = []

    @hp_indicator = new catsvzombies.HPIndicator @, @game, @element.find('.hp_indicator').eq(0)
    @mana_indicator = new catsvzombies.ManaIndicator @, @game, @element.find('.mana_indicator').eq(0)

  update: ->
    @hp_indicator.update()
    @mana_indicator.update()

  activate_mana: (key) ->
    @mana_active[key]++ if @mana[key] > @mana_active[key] + @mana_used[key]

  play_card: (card) ->

  draw_cards: (n) ->
    for i in [0...n]
      @hand.push @cards.splice(Math.floor(Math.random() * @cards.length), 1)[0]


window.catsvzombies.Player = class Player extends catsvzombies.AbstractPlayer
  constructor: (@game, @cards, @bindElement) ->
    super @game, @cards, @bindElement

    @mana_indicator = new catsvzombies.ManaIndicator @, @game, @element.find('.mana_indicator').eq(0), true

    @draw_cards(4)
    @hand_stack = new catsvzombies.HandIndicator @, @game, $ '.player_hand .card_stack'


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

catsvzombies.ManaIndicator = class ManaIndicator
  constructor: (@player, @game, @element, @responsive) ->
    @update()

    @mana = []

  update: ->
    if (1 for key of @player.mana when @player.mana[key] isnt @mana[key]).length > 0 or (1 for key of @mana when @player.mana[key] isnt @mana[key])

      @element.find('tr:first-child').html(
        ("<td><img src=\"assets/mana-#{key}.png\"></td>" for key, val of @player.mana).join('\n')
      )
      if @responsive
        @element.find('tr:first-child td').each( (i, elem) =>
          $(elem).click (event) =>
            @clicked (key for key of @player.mana)[i]
        )

      @element.find('tr:last-child').html(
        ("<td><h1>#{val}</h1></td>" for key, val of @player.mana).join('\n')
      )

      @mana[key] = @player.mana[key] for key of @player.mana

  clicked: (key) ->
    return if not @responsive
    @player.activate_mana? key

catsvzombies.HandIndicator = class HandIndicator
  constructor: (@player, @game, @element) ->
    @update()

  update: ->
    @element.html(
      ("<img src=\"assets/#{card.image}.png\">" for card in @player.hand when card.image?).join('\n')
    )

    @element.find('img').each( (i, elem) =>
      $(elem).click =>
        @clicked elem
    )

  clicked: (elem) ->
    $(elem).addClass 'selected'
