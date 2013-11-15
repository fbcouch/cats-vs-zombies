# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

DEBUG = false

window.catsvzombies.AbstractPlayer = class AbstractPlayer
  constructor: (@game, @cards, @element, @field_element) ->
    @curhp = 20
    @maxhp = 20
    @hand or= []
    @discard = []
    @mana = []
    @mana_active = []
    @mana_used = []
#    console.log @field_element
    @creatures = new catsvzombies.CreatureStack @, @game, @field_element.find('.creatures')

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
    @creatures.update()

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
      when 'creature'
        for key, val of card.requires
          @mana_used[key] += val
          @mana_active[key] -= val
        if @creatures.length() < 5
          @hand.splice @hand.indexOf(card), 1
          @creatures.push card


  start_turn: () ->
    @cards.push card for card in @hand
    creature?.tapped = false for creature in @creatures.creatures
    @hand = []
    @reset_mana()
    @draw_cards(4)

  draw_cards: (n) ->
    for i in [0...n]
      @hand.push @cards.splice(Math.floor(Math.random() * @cards.length), 1)[0]

  reset_mana: () ->
    for key of @mana
      @mana_active[key] = 0
      @mana_used[key] = 0

  discard_creature: (card) ->
    @creatures.remove card
    @discard.push card
    card.tapped = false

  get_attackers: () ->
    # implement this in subclass

  get_defenders: () ->
    # implement this in subclass


window.catsvzombies.Player = class Player extends catsvzombies.AbstractPlayer
  constructor: (@game, @cards, @bindElement, @fieldElement) ->
    super @game, @cards, @bindElement, @fieldElement

    @mana_indicator = new catsvzombies.ManaIndicator @, @game, @element.find('.mana_indicator').eq(0), true
    @mana_active_indicator = new catsvzombies.ActiveManaIndicator @, @game, @element.find('.mana_active')

    @hand_stack = new catsvzombies.HandIndicator @, @game, $ '.player_hand .card_stack'

    @creatures = new catsvzombies.CreatureStack @, @game, @field_element.find('.creatures'), true

  update: () ->
    super()
    @hand_stack.update()
    @mana_active_indicator.update()

  get_selected_card: () ->
    @hand_stack.get_selected_card()

  get_attackers: () ->
    @creatures.get_attackers()
