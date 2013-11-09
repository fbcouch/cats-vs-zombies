# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

DEBUG = false

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
      mana: []
      creatures: []

    @opponent =
      curhp: 20
      maxhp: 20
      hand: []
      deck: []
      discard: []
      mana: []
      creatures: []

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
    @player_creatures = new catsvzombies.CardStack @player.creatures

    @player_mana = new catsvzombies.ManaIndicator @preload, @player.mana
    @active_mana = new catsvzombies.ActiveMana @preload, @player_mana.active

    @addChild @player_hand
    @addChild @player_discard
    @addChild @player_deck
    @addChild @player_creatures

    @addChild @player_mana
    @addChild @active_mana

    @opponent_deck = new catsvzombies.CardStack @opponent.deck
    @opponent_hand = new catsvzombies.CardStack @opponent.hand, catsvzombies.CardStack.HAND
    @opponent_discard = new catsvzombies.CardStack @opponent.discard
    @opponent_creatures = new catsvzombies.CardStack @opponent.creatures

    @addChild @opponent_hand
    @addChild @opponent_discard
    @addChild @opponent_deck
    @addChild @opponent_creatures

    @draw_card @player for i in [0...4]
    @draw_card @opponent for i in [0...4]

    @start_turn @player

  resize: (@width, @height) ->
    super(@width, @height)
    console.log @width
    @bgimage.x = (@width - @bgimage.image.width) * 0.5
    @bgimage.y = 0

    @player_deck.x = @bgimage.x
    @player_discard.x = @player_deck.x + @player_deck.width
    @player_deck.y = @player_hand.y = @player_discard.y = @height - @player_deck.height

    @player_mana.x = @bgimage.x + 10
    @active_mana.y = @player_hand.y - 50

    @opponent_deck.x = @bgimage.x + @bgimage.image.width - @opponent_deck.width
    @opponent_discard.x = @opponent_deck.x - @opponent_discard.width

    @opponent_deck.y = @opponent_hand.y = @opponent_discard.y = 0

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

  hide: ->
    super(hide)

  start_turn: (who) ->

  draw_card: (who) ->
    card = who.deck.pop()
    card.flip() if who is @player or DEBUG
    who.hand.push card

  play_card_callback: (card) =>
    @play_card @player, card

  play_card: (who, card) ->
    who.hand.splice who.hand.indexOf(card), 1
    if card.proto.type is 'mana'
      who.mana.push card
    else if card.proto.type is 'creature'
      who.creatures.push card


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

    @callback? card

window.catsvzombies.ManaIndicator = class ManaIndicator extends createjs.Container
  constructor: (@preload, @mana_pool) ->
    @initialize()
    @totals =
      mouse: 0
      bird: 0
      fish: 0
      grave: 0
      brain: 0

    @icons = []
    @texts = []

    for key of @totals
      @icons[key] = new createjs.Bitmap @preload.getResult "mana-#{key}"
      @texts[key] = new createjs.Text "0", 'normal 28px sans-serif', '#FFF'

      @icons[key].key = key
      @icons[key].addEventListener 'click', (event) ->
        event.currentTarget.parent.clicked? event.currentTarget.key

      @texts[key].key = key
      @texts[key].addEventListener 'click', (event) ->
        event.currentTarget.parent.clicked? event.currentTarget.key

    @active =
      mouse: 0
      bird: 0
      fish: 0
      grave: 0
      brain: 0

    @used =
      mouse: 0
      bird: 0
      fish: 0
      grave: 0
      brain: 0

  update: ->
    @removeAllChildren()
    for key of @totals
      @totals[key] = 0


    for mana in @mana_pool
      @totals[key] += val for key, val of mana.proto.provides

    for key of @active
      @totals[key] = @totals[key] - @active[key] - @used[key]

    y = 0
    for key, val of @totals when val > 0
      @icons[key].x = 0
      @texts[key].x = @icons[key].image.width + 5
      @icons[key].y = y
      @texts[key].y = y
      @texts[key].text = val
      y += @icons[key].image.height + 10
      @addChild @icons[key]
      @addChild @texts[key]

    {width: @width, height: @height} = @getBounds() if @children.length > 0

  clicked: (key) ->
    @active[key]++ if @totals[key] > 0

  reset_used: () ->
    @used[key] = 0 for key of @used

window.catsvzombies.ActiveMana = class ActiveMana extends createjs.Container
  constructor: (@preload, @active_mana) ->
    @initialize()

    @icons = []
    @last = {}

  update: ->
    # update only when dirty
    dirty = false
    dirty = true for key of @active_mana when @active_mana[key] isnt @last[key]
    @last[key] = @active_mana[key] for key of @active_mana
    if dirty
      @removeAllChildren()
      x = 0
      for key, val of @active_mana when val > 0
        for i in [0...val]
          icon = new createjs.Bitmap @preload.getResult "mana-#{key}"
          icon.key = key
          icon.addEventListener 'click', (event) ->
            event.currentTarget.parent.clicked event.currentTarget.key

          icon.x = x
          x += icon.image.width + 5
          icon.y = 0
          @addChild icon

      {width: @width, height: @height} = @getBounds() if @children.length > 0

  clicked: (key) ->
    @active_mana[key]-- if @active_mana[key] > 0