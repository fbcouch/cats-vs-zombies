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

    @active = null
    @mana_played = false
    @attacked = false

  show: ->
    super()
    @bgimage = new createjs.Bitmap @preload.getResult 'grassy-bg'
    @addChild @bgimage

    @addChild @player
    @addChild @opponent

    @btnPlayCard = new createjs.Bitmap @preload.getResult 'btn-play-card'
    @btnPlayCard.addEventListener 'click', =>
      @play_card_callback @player, @player.get_selected_card() if @current is @player and @player.get_selected_card()?
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

    @player.layout(@bgimage.image.width, @height * 0.45)
    @opponent.layout(@bgimage.image.width, @height * 0.45)

    @btnEndTurn.x = @bgimage.x + @bgimage.image.width - @btnEndTurn.image.width
    @btnEndTurn.y = @height - @btnEndTurn.image.height

    @btnPlayCard.x = @btnEndTurn.x
    @btnPlayCard.y = @btnEndTurn.y - @btnPlayCard.image.height

  update: (delta) ->
    super(delta)

    @player.update delta
    @opponent.update delta, @current is @opponent

    @player.x = @bgimage.x
    @player.y = @height - @player.height

    @opponent.rotation = 180
    @opponent.x = @bgimage.x + @bgimage.image.width
    @opponent.y = @opponent.height

  hide: ->
    super(hide)

  draw_card: (who) ->
    who.draw_card((who is @player))

  play_card_callback: (who, card) =>
    if @can_play who, card
      @play_card who, card

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

    card.flip() if not card.faceup

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

    who.mana_indicator.reset_used()

    @draw_card who if not first

  end_turn: () ->
    if @current is @player
      @start_turn @opponent
    else
      @start_turn @player