# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

DEBUG = false

window.catsvzombies.Screen = class Screen extends createjs.Container

  constructor: (@preload) ->
    @initialize()

  show: ->

  resize: (@width, @height) ->

  update: (delta) ->

  hide: ->

window.catsvzombies.LevelScreen = class LevelScreen extends Screen

  constructor: (@preload) ->
    super(@preload)

    @player =
      curhp: 20
      maxhp: 20
      hand: []
      deck: []
      discard: []
      mana: []
      mana_active: []
      mana_used: []
      creatures: []

    @opponent =
      curhp: 20
      maxhp: 20
      hand: []
      deck: []
      discard: []
      mana: []
      mana_active: []
      creatures: []

    @active = null
    @mana_played = false
    @attacked = false

  show: ->
    super()
    @bgimage = new createjs.Bitmap @preload.getResult 'grassy-bg'
    @addChild @bgimage

    # TODO load the actual player's deck
    # for now, just give the player 20 random cards
    cat_cards = @preload.getResult 'cat-cards'
    zombie_cards = @preload.getResult 'zombie-cards'
    for i in [0...20]
      @player.deck.push new catsvzombies.Card @preload, cat_cards[Math.floor(Math.random() * cat_cards.length)]
      @opponent.deck.push new catsvzombies.Card @preload, zombie_cards[Math.floor(Math.random() * zombie_cards.length)]

    # TODO load the actual opponent's deck

    @player_deck = new catsvzombies.CardStack @player.deck
    @player_hand = new catsvzombies.CardStack @player.hand, catsvzombies.CardStack.HAND, @play_card_callback
    @player_discard = new catsvzombies.CardStack @player.discard
    @player_creatures = new catsvzombies.CardStack @player.creatures, catsvzombies.CardStack.PERM

    @player_mana = new catsvzombies.ManaIndicator @preload, @player.mana
    @active_mana = new catsvzombies.ActiveMana @preload, @player_mana.active
    @player.mana_active = @player_mana.active
    @player.mana_used = @player_mana.used

    @addChild @player_hand
    @addChild @player_discard
    @addChild @player_deck
    @addChild @player_creatures

    @addChild @player_mana
    @addChild @active_mana

    @opponent_deck = new catsvzombies.CardStack @opponent.deck
    @opponent_hand = new catsvzombies.CardStack @opponent.hand, catsvzombies.CardStack.HAND
    @opponent_discard = new catsvzombies.CardStack @opponent.discard
    @opponent_creatures = new catsvzombies.CardStack @opponent.creatures, catsvzombies.CardStack.PERM

    @addChild @opponent_hand
    @addChild @opponent_discard
    @addChild @opponent_deck
    @addChild @opponent_creatures

    @btnPlayCard = new createjs.Bitmap @preload.getResult 'btn-play-card'
    @btnPlayCard.addEventListener 'click', =>
      if @current is @player and @player_hand.selected
        @play_card_callback @player_hand.selected
    @addChild @btnPlayCard

    @btnEndTurn = new createjs.Bitmap @preload.getResult 'btn-end-turn'
    @btnEndTurn.addEventListener 'click', =>
      if @current is @player
        @end_turn()
    @addChild @btnEndTurn

    @draw_card @player for i in [0...4]
    @draw_card @opponent for i in [0...4]

    @start_turn @player, true

  resize: (@width, @height) ->
    super(@width, @height)
    @bgimage.x = (@width - @bgimage.image.width) * 0.5
    @bgimage.y = 0

    @player_deck.x = @bgimage.x
    @player_discard.x = @player_deck.x + @player_deck.width
    @player_deck.y = @player_hand.y = @player_discard.y = @height - @player_deck.height

    @player_mana.x = @bgimage.x + 10


    @opponent_deck.x = @bgimage.x + @bgimage.image.width - @opponent_deck.width
    @opponent_discard.x = @opponent_deck.x - @opponent_discard.width

    @opponent_deck.y = @opponent_hand.y = @opponent_discard.y = 0

    @btnEndTurn.x = @bgimage.x + @bgimage.image.width - @btnEndTurn.image.width
    @btnEndTurn.y = @height - @btnEndTurn.image.height

    @btnPlayCard.x = @btnEndTurn.x
    @btnPlayCard.y = @btnEndTurn.y - @btnPlayCard.image.height

  update: (delta) ->
    super(delta)

    @player_deck.update delta
    @player_discard.update delta
    @player_hand.update delta
    @player_creatures.update delta

    @player_mana.update delta
    @active_mana.update delta

    @player_hand.x = @bgimage.x + (@bgimage.image.width - @player_hand.width) * 0.5

    @player_mana.y = @player_deck.y - @player_mana.height - 10 if @player_mana.height?
    @active_mana.x = @bgimage.x + (@bgimage.image.width - @active_mana.width) * 0.5

    @opponent_deck.update delta
    @opponent_discard.update delta
    @opponent_hand.update delta
    @opponent_creatures.update delta

    @opponent_hand.x = @bgimage.x + (@bgimage.image.width - @opponent_hand.width) * 0.5

    @player_creatures.x = @bgimage.x + (@bgimage.image.width - @player_creatures.width) * 0.5
    @player_creatures.y = @height * 0.66 - @player_deck.height * 0.5

    @active_mana.y = @player_hand.y + (@player_creatures.y + @player_deck.height - @player_hand.y - @active_mana.height) * 0.5

    if @current is @opponent
      @end_turn()

  hide: ->
    super(hide)

  draw_card: (who) ->
    card = who.deck.pop()
    card.flip() if who is @player or DEBUG
    who.hand.push card

  play_card_callback: (card) =>
    if @can_play @player, card
      @play_card @player, card

  play_card: (who, card) ->
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

  can_play: (who, card) ->
    if card.proto.type is 'mana'
      return not @mana_played

    for key, val of card.proto.requires
      return false if who.mana_active[key] < val
    return true

  start_turn: (who, first) ->
    @current = who
    @mana_played = false
    @attacked = false

    if who is @player
      @player_mana.reset_used()
    else
      #@opponent_mana.reset_used()

    @draw_card who if not first

  end_turn: () ->
    if @current is @player
      @start_turn @opponent
    else
      @start_turn @player