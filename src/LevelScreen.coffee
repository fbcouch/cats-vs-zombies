# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

DEBUG = false

window.catsvzombies.LevelScreen = class LevelScreen extends catsvzombies.Screen
  constructor: (@preload) ->
    super(@preload)

    # TODO load the actual player's deck
    # for now, just give the player 20 random cards
    cat_cards = @preload.getResult 'cat-cards'
    zombie_cards = @preload.getResult 'zombie-cards'
    pdeck = []
    odeck = []
    for i in [0...20]
      pdeck.push new catsvzombies.Card @preload, cat_cards[Math.floor(Math.random() * cat_cards.length)]
      odeck.push new catsvzombies.Card @preload, zombie_cards[Math.floor(Math.random() * zombie_cards.length)]

    # TODO load the actual opponent's deck

    @player = new catsvzombies.Player @preload, pdeck, @, @play_card_callback

    @opponent = new catsvzombies.AIPlayer @preload, odeck, @, @play_card_callback

    @mana_played = false
    @attacked = false
    @combat_mode = true
    @game_over = false

    @context_menu = null

  show: ->
    super()
    @bgimage = new createjs.Bitmap @preload.getResult 'grassy-bg'
    @addChild @bgimage

    @addChild @player
    @addChild @opponent

    @draw_card @player for i in [0...4]
    @draw_card @opponent for i in [0...4]

    @start_turn @player, true

  resize: (@width, @height) ->
    super(@width, @height)
    @bgimage.x = (@width - @bgimage.image.width) * 0.5
    @bgimage.y = 0

    @player.layout(@bgimage.image.width, @height * 0.45)
    @opponent.layout(@bgimage.image.width, @height * 0.45)

  end_game: (victory) ->
    @game_over = true
    # TODO go to game over screen

  update: (delta) ->
    super(delta)

    if @game_over
      @alpha -= delta
      console.log @alpha
      return

    if @player.curhp <= 0
      @end_game false
    else if @opponent.curhp <= 0
      @end_game true

    @player.update delta, @current is @player
    @opponent.update delta, @current is @opponent

    @player.x = @bgimage.x
    @player.y = @height - @player.height

    @opponent.scaleX = -1
    @opponent.scaleY = -1
    @opponent.x = @bgimage.x + @bgimage.image.width
    @opponent.y = @opponent.height

    if @player.creatures_stack.selected?
      @show_context_menu @player.creatures_stack.selected if @player.creatures_stack.selected isnt @last_selected
      @last_selected = @player.creatures_stack.selected
      if @player.creatures_stack.selected.tapped
        @hide_context_menu()
    else
      @hide_context_menu()
      @last_selected = null

    if @context_menu?
      @context_menu.update delta
      localcoords = @context_menu.card.localToLocal(@context_menu.card.width * 0.5, @context_menu.card.height, @)
      @context_menu.x = localcoords.x - @context_menu.getBounds()?.width * 0.5
      @context_menu.y = localcoords.y

  hide: ->
    super(hide)

  draw_card: (who) ->
    who.draw_card((who is @player))

  play_card_callback: (who, card) =>
    if @can_play who, card
      @play_card who, card

  play_card: (who, card) ->
    return if not @can_play who, card
    who.hand.splice who.hand.indexOf(card), 1
    if card.proto.type is 'mana'
      who.mana.push card
      @mana_played = true
    else if card.proto.type is 'creature'
      if @can_play who, card
        who.creatures.push card
        for key, val of card.proto.requires
          who.mana_used[key] += val
          who.mana_active[key] -= val

    card.flip() if not card.faceup

  can_play: (who, card) ->
    if card.proto.type is 'mana'
      return (not @mana_played and who is @current)
    else if card.proto.type is 'creature'
      return who is @current

    for key, val of card.proto.requires
      return false if who.mana_active[key] < val
    return true

  start_turn: (who, first) ->
    @current = who
    @mana_played = false
    @attacked = false
    @attackers = []
    @defenders = []
    @combat_mode = false

    who.untap()
    who.mana_indicator.reset_used()

    @draw_card who if not first

  end_turn: (who) ->
    return if who isnt @current

    if @current is @player
      @start_turn @opponent
    else
      @start_turn @player

  attack: (who) ->
    return if who isnt @current or @attacked

    @attackers = (card for card in who.creatures_stack.cards when card.attacking and not card.tapped)
    console.log @attackers
    if @attackers.length is 0
      @attackers = []
      return

    @attacked = true
    @combat_mode = true

  defend: (who) ->
    return if who is @current or not @combat_mode

    @defenders = (card for card in who.creatures_stack.cards when card.defending and not card.tapped)

    @do_combat_round()

  do_combat_round: ->
    # todo - allow defender to choose which cards defend which attackers
    for attacker, i in @attackers
      if @defenders.length > i
        # there is a defender!
        defender = @defenders[i]
        if defender.proto.strength >= attacker.proto.toughness
          @destroy_creature attacker
        if attacker.proto.strength >= defender.proto.toughness
          @destroy_creature defender
        defender.tapped = true
      else
        # there is no defender
        if @current is @player
          @opponent.curhp -= attacker.proto.strength if attacker.proto.strength > 0
        else
          @player.curhp -= attacker.proto.strength if attacker.proto.strength > 0
      attacker.tapped = true
    @combat_mode = false

  destroy_creature: (card) ->
    @player.discard_creature card
    @opponent.discard_creature card

  show_context_menu: (card) ->
    @hide_context_menu()
    switch card.proto.type
      when 'creature'
        @context_menu = new catsvzombies.ContextMenu @preload, card, @player, @
    @addChild @context_menu

  hide_context_menu: ->
    @removeChild @context_menu if @context_menu?.parent?