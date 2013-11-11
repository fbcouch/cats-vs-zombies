# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

DEBUG = false

window.catsvzombies.Card = class Card extends createjs.Container
  constructor: (@preload, @proto, @faceup) ->
    @initialize()

    @counters = []
    @attached = []

    @front = new createjs.Bitmap @preload.getResult @proto.image
    @back = new createjs.Bitmap @preload.getResult 'card-back'

    @addChild if @faceup then @front else @back
    {width: @width, height: @height} = @getBounds()

    @addEventListener 'click', @clicked
    @addEventListener 'dblclick', @dblclicked

  update: (delta) ->

  get_strength: ->
    @proto.strength #TODO take into account counters and attached things

  get_toughness: ->
    @proto.toughness #TODO take into account counters and attached things

  flip: ->
    @removeChild if @faceup then @front else @back
    @faceup = not @faceup
    @addChild if @faceup then @front else @back

  clicked: (event) =>
    @parent?.card_clicked? event, @

  dblclicked: (event) =>
    @parent?.card_dblclicked? event, @

window.catsvzombies.CardStack = class CardStack extends createjs.Container
  @DECK = 0
  @HAND = 1
  @MANA = 2
  @PERM = 3

  constructor: (@cards, @type, @callback) ->
    @initialize()

    @type or= @constructor.DECK

    @selected = null

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
        card.y = (if @callback? and @selected is @cards[i] then -25 else 0)
    else if @type is @constructor.PERM
      for card, i in @cards
        card.x = i * (card.width + 25)
        card.y = 0
        @addChild card


    for c in [cards_to_add.length - 1..0]
      @addChild cards_to_add[c]

    {width: @width, height: @height} = @getBounds() if @children.length > 0

  card_clicked: (event, card) ->
    return if @type isnt @constructor.HAND

    if @selected isnt card
      @selected = card
    else
      @selected = null

  card_dblclicked: (event, card) ->
    return if @type isnt @constructor.HAND

    @callback? @, card