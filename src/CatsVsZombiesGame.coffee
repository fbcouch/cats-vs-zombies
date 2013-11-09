# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

window.catsvzombies.CatsVsZombiesGame = class CatsVsZombiesGame

  constructor: (@stage, @preload, @width, @height) ->
    @setScreen new LevelScreen @preload

  update: (delta) ->
    @screen?.update? delta

  resize: (@width, @height) ->
    @screen?.resize @width, @height

  setScreen: (screen) ->
    if @screen?
      @screen.hide?()
      @stage.removeAllChildren()

    @screen = screen
    @screen.show()          # show then resize (ie: layout)
    @resize @width, @height

    @stage.addChild @screen

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

  show: ->
    super()
    @bgimage = new createjs.Bitmap @preload.getResult 'grassy-bg'
    @addChild @bgimage

    # TODO load the actual player's deck
    # for now, just give the player 20 random cards
    all_cards = @preload.getResult 'cards'
    for i in [0...20]
      @player.deck.push new catsvzombies.Card @preload, all_cards[Math.floor(Math.random() * all_cards.length)]

    @player_deck = new catsvzombies.CardStack @player.deck
    @player_hand = new catsvzombies.CardStack @player.hand, catsvzombies.CardStack.HAND
    @player_discard = new catsvzombies.CardStack @player.discard


    @addChild @player_hand
    @addChild @player_discard
    @addChild @player_deck

    @draw_card @player for i in [0...4]

    @start_turn @player

  resize: (@width, @height) ->
    super(@width, @height)
    console.log @width
    @bgimage.x = (@width - @bgimage.image.width) * 0.5
    @bgimage.y = 0

    @player_deck.x = @bgimage.x
    @player_discard.x = @bgimage.x - @player_discard.width



    @player_deck.y = @player_hand.y = @player_discard.y = @height - @player_deck.height

  update: (delta) ->
    super(delta)

    @player_deck.update delta
    @player_discard.update delta
    @player_hand.update delta

    @player_hand.x = @bgimage.x + (@bgimage.image.width - @player_hand.width) * 0.5

  hide: ->
    super(hide)

  start_turn: (who) ->

  draw_card: (who) ->
    card = who.deck.pop()
    card.flip()
    who.hand.push card


window.catsvzombies.Card = class Card extends createjs.Container
  constructor: (@preload, @proto, @faceup) ->
    @initialize()

    @counters = []
    @attached = []

    @front = new createjs.Bitmap @preload.getResult @proto.image
    @back = new createjs.Bitmap @preload.getResult 'card-back'

    @addChild if @faceup then @front else @back
    {width: @width, height: @height} = @getBounds()

  update: (delta) ->

  get_strength: ->
    @proto.strength #TODO take into account counters and attached things

  get_toughness: ->
    @proto.toughness #TODO take into account counters and attached things

  flip: ->
    @removeChild if @faceup then @front else @back
    @faceup = not @faceup
    @addChild if @faceup then @front else @back

window.catsvzombies.CardStack = class CardStack extends createjs.Container
  @DECK = 0
  @HAND = 1

  constructor: (@cards, @type) ->
    @initialize()

    @type or= @constructor.DECK

    @update()

  update: (delta) ->
    @removeAllChildren()
    cards_to_add = []
    if @type is @constructor.DECK
      c = 0
      for i in [(if @cards.length >= 3 then @cards.length - 3 else 0)...@cards.length]
        # show the last 3 cards
        @cards[i].x = c * 10
        @cards[i].y = 0
        @addChild @cards[i]
        c++
    else if @type is @constructor.HAND
      for card, i in @cards
        cards_to_add.push card
        card.x = i * (card.width - 10)
        card.y = 0

    for c in [cards_to_add.length - 1..0]
      @addChild cards_to_add[c]

    {width: @width, height: @height} = @getBounds() if @children.length > 0







