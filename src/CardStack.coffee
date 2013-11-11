# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

window.catsvzombies.CardStack = class CardStack extends createjs.Container
  @DECK = 0
  @HAND = 1
  @MANA = 2
  @PERM = 3

  constructor: (@preload, @cards, @type, @callback) ->
    @initialize()

    @type or= @constructor.DECK

    @selected = null
    @selected_overlay = new createjs.Bitmap @preload.getResult 'active-overlay'

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
        if card is @selected
          @selected_overlay.x = card.x
          @selected_overlay.y = card.y
          @addChild @selected_overlay


    for c in [cards_to_add.length - 1..0]
      @addChild cards_to_add[c]

    {width: @width, height: @height} = @getBounds() if @children.length > 0

  card_clicked: (event, card) ->
    return if @type isnt @constructor.HAND and @type isnt @constructor.PERM

    if @selected isnt card
      @selected = card
    else
      @selected = null

  card_dblclicked: (event, card) ->
    return if @type isnt @constructor.HAND
    console.log 'dblclick'
    @callback? @parent, card