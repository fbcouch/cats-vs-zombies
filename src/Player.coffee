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

    for key of @mana
      if not @mana_active[key]?
        @mana_active[key] = 0
      if not @mana_used[key]?
        @mana_used[key] = 0

    @hp_indicator.update()
    @mana_indicator.update()

  activate_mana: (key) ->
    #console.log key
    @mana_active[key] = 0 if not @mana_active[key]?
    @mana_used[key] = 0 if not @mana_used[key]?
    @mana_active[key]++ if @mana[key] > @mana_active[key] + @mana_used[key]
    #console.log @mana_active[key]

  deactivate_mana: (key) ->
    @mana_active[key]-- if @mana_active[key]? and @mana_active[key] > 0

  play_card: (card) ->
    switch card.type
      when 'mana'
        @hand.splice @hand.indexOf(card), 1
        for key, val of card.provides
          if @mana[key]? then @mana[key] += val else @mana[key] = val
        @discard.push card
#      when 'creature'
        #
    @update()

  draw_cards: (n) ->
    for i in [0...n]
      @hand.push @cards.splice(Math.floor(Math.random() * @cards.length), 1)[0]


window.catsvzombies.Player = class Player extends catsvzombies.AbstractPlayer
  constructor: (@game, @cards, @bindElement) ->
    super @game, @cards, @bindElement

    @mana_indicator = new catsvzombies.ManaIndicator @, @game, @element.find('.mana_indicator').eq(0), true
    @mana_active_indicator = new catsvzombies.ActiveManaIndicator @, @game, @element.find('.mana_active')

    @draw_cards(4)
    @hand_stack = new catsvzombies.HandIndicator @, @game, $ '.player_hand .card_stack'

  update: () ->
    super()
    @hand_stack.update()
    @mana_active_indicator.update()

  get_selected_card: () ->
    @hand_stack.get_selected_card()

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

  update: ->
    if @is_dirty()

      @element.find('tr:first-child').html(
        ("<td><img src=\"assets/mana-#{key}.png\"></td>" for key, val of @player.mana).join('\n')
      )
      if @responsive
        @element.find('tr:first-child td').each( (i, elem) =>
          $(elem).click (event) =>
            @clicked (key for key of @player.mana)[i]
        )

      @element.find('tr:last-child').html(
        ("<td><h1>#{val - (if @responsive then (@player.mana_active[key] + @player.mana_used[key]) else 0)}</h1></td>" for key, val of @player.mana).join('\n')
      )

      @mana[key] = @player.mana[key] - (if @responsive then (@player.mana_active[key] + @player.mana_used[key]) else 0) for key of @player.mana

  is_dirty: () ->
    if not @mana?
      @mana = []
      return true

    return (1 for key of @player.mana when @player.mana[key] isnt @mana[key]).length > 0 or (1 for key of @mana when @player.mana[key] isnt @mana[key]).length > 0 if not @responsive
    (1 for key of @player.mana when @player.mana[key] - @player.mana_active[key] - @player.mana_used[key] isnt @mana[key]).length > 0 or (1 for key of @mana when @player.mana[key] - @player.mana_active[key] - @player.mana_used[key] isnt @mana[key]).length > 0

  clicked: (key) ->
    return if not @responsive
    @player.activate_mana? key

catsvzombies.ActiveManaIndicator = class ActiveManaIndicator
  constructor: (@player, @game, @element) ->
    @update()

  update: ->
    if @is_dirty()
      @element.html(
        ("<li><img src=\"assets/mana-#{key}.png\"></li>" for i in [0...val] for key, val of @player.mana_active).join('\n')
      )

      @element.find('li').each( (i, elem) =>
        $(elem).click (event) =>
          @clicked (key for key of @player.mana)[i]
      )

      @mana[key] = val for key, val of @player.mana_active

  is_dirty: ->
    if not @mana
      @mana = []
      return true
    (1 for key of @player.mana_active when @player.mana_active[key] isnt @mana[key]).length > 0 or (1 for key of @mana when @player.mana_active[key] isnt @mana[key]).length > 0

  clicked: (key) ->
    @player.deactivate_mana? key

catsvzombies.HandIndicator = class HandIndicator
  constructor: (@player, @game, @element) ->
    @update()

  update: ->
    if @is_dirty()
      @element.html(
        ("<div><img src=\"assets/#{card.image}.png\"></div>" for card in @player.hand when card.image?).join('\n')
      )

      @element.find('div').each( (i, elem) =>
        $(elem).click =>
          @clicked elem
      )

      @hand = JSON.parse JSON.stringify @player.hand

  is_dirty: ->
    return true if not @hand?

    return true if @hand.length isnt @player.hand.length

    return (1 for i of @hand when @hand[i].uuid isnt @player.hand[i].uuid).length isnt 0

  clicked: (elem) ->
    if $(elem).hasClass 'selected'
      $(elem).removeClass 'selected'
    else
      @element.find('div').each( -> $(this).removeClass 'selected')
      $(elem).addClass 'selected'

  get_selected_card: () ->
    @player.hand[@element.find('div.selected').eq(0).index()]