# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

DEBUG = false

window.catsvzombies.Player = class Player extends createjs.Container
  constructor: (@preload, @deck, @levelScreen, @play_card_callback) ->
    @initialize()

    @curhp = 20
    @maxhp = 20
    @hand = []
    @discard = []
    @mana = []
    @mana_active = []
    @mana_used = []
    @creatures = []

    @deck_stack = new catsvzombies.CardStack @preload, @deck
    @hand_stack = new catsvzombies.CardStack @preload, @hand, catsvzombies.CardStack.HAND, @play_card_callback
    @discard_stack = new catsvzombies.CardStack @preload, @discard
    @creatures_stack = new catsvzombies.CardStack @preload, @creatures, catsvzombies.CardStack.PERM

    @mana_indicator = new catsvzombies.ManaIndicator @preload, @
    @active_mana = new catsvzombies.ActiveMana @preload, @mana_active

    @addChild @deck_stack
    @addChild @hand_stack
    @addChild @discard_stack
    @addChild @creatures_stack
    @addChild @mana_indicator
    @addChild @active_mana

  layout: (@width, @height) ->
    @deck_stack.x = 0
    @deck_stack.y = @height - @deck_stack.height

    @discard_stack.x = @deck_stack.x + @deck_stack.width
    @discard_stack.y = @deck_stack.y

    @hand_stack.x = (@width - @hand_stack.width) * 0.5
    @hand_stack.y = @discard_stack.y

    @creatures_stack.x = (@width - @creatures_stack.width) * 0.5
    @creatures_stack.y = 0

    @mana_indicator.y = @deck_stack.y - @mana_indicator.height - 10
    @mana_indicator.x = 10

    @active_mana.x = (@width - @active_mana.width) * 0.5
    @active_mana.y = @hand_stack.y + (@creatures_stack.y + @deck_stack.height - @hand_stack.y - @active_mana.height) * 0.5


  update: (delta, is_turn) ->
    @layout @width, @height

    @deck_stack.update delta
    @hand_stack.update delta
    @discard_stack.update delta
    @creatures_stack.update delta
    @mana_indicator.update delta
    @active_mana.update delta

  draw_card: (flip) ->
    card = @deck.pop()
    card.flip() if flip
    @hand.push card

  get_selected_card: () ->
    @hand_stack.selected

window.catsvzombies.AIPlayer = class AIPlayer extends catsvzombies.Player
  constructor: (@preload, @deck, @levelScreen, play_card_callback) ->
    super(@preload, @deck, @levelScreen)

    @play_card_callback = play_card_callback

  update: (delta, is_turn) ->
    super(delta, is_turn)
    return if not is_turn

    # TODO improve AI

    @play_card_callback @, card if @parent?.can_play @, card for card in @hand
    @mana_indicator.activate_all()
    @play_card_callback @, card if @parent?.can_play @, card for card in @hand

    @parent?.end_turn()


window.catsvzombies.ManaIndicator = class ManaIndicator extends createjs.Container
  constructor: (@preload, @player) ->
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

    @active = @player.mana_active
    @used = @player.mana_used
    for key of @totals
      @active[key] = 0
      @used[key] = 0

  update: ->
    @removeAllChildren()
    for key of @totals
      @totals[key] = 0


    for mana in @player.mana
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

  activate_all: () ->
    @active[key] = val - @used[key] for key, val of @totals

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