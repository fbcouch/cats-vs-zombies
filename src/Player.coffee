# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

DEBUG = false

window.catsvzombies.AbstractPlayer = class AbstractPlayer extends createjs.Container
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

    @hp_indicator = new createjs.Text "HP: #{@curhp}/#{@maxhp}", 'normal 28px sans-serif', '#fff'

    @addChild @deck_stack
    @addChild @hand_stack
    @addChild @discard_stack
    @addChild @creatures_stack
    @addChild @mana_indicator
    @addChild @active_mana

    @addChild @hp_indicator

  layout: (@width, @height) ->
    @deck_stack.x = 0
    @deck_stack.y = @height - @deck_stack.height

    @discard_stack.x = @deck_stack.x + @deck_stack.width
    @discard_stack.y = @deck_stack.y

    @hand_stack.x = (@width - @hand_stack.width) * 0.5
    @hand_stack.y = @discard_stack.y

    @creatures_stack.x = (@width - @creatures_stack.width) * 0.5
    @creatures_stack.y = 0

    @active_mana.x = (@width - @active_mana.width) * 0.5
    @active_mana.y = @hand_stack.y + (@creatures_stack.y + @deck_stack.height - @hand_stack.y - @active_mana.height) * 0.5

    @hp_indicator.x = @width - @hp_indicator.getBounds().width
    @hp_indicator.y = @height - @hp_indicator.getBounds().height

    @mana_indicator.y = @hp_indicator.y - @mana_indicator.height - 10
    @mana_indicator.x = @width - @mana_indicator.width

  update: (delta, is_turn) ->
    @hp_indicator.text = "HP: #{@curhp}/#{@maxhp}"
    @deck_stack.update delta
    @hand_stack.update delta
    @discard_stack.update delta
    @creatures_stack.update delta
    @mana_indicator.update delta
    @active_mana.update delta

    @layout @width, @height

  draw_card: (flip) ->
    card = @deck.pop()
    card.flip() if flip
    @hand.push card

  get_selected_card: () ->
    @hand_stack.selected

window.catsvzombies.Player = class Player extends catsvzombies.AbstractPlayer
  constructor: (@preload, @deck, @levelScreen, @play_card_callback) ->
    super @preload, @deck, @levelScreen, @play_card_callback

    @mana_indicator.clickable = true
    @active_mana.clickable = true

    @btnPlayCard = new createjs.Bitmap @preload.getResult 'btn-play-card'
    @btnPlayCard.addEventListener 'click', =>
      @play_card_callback @player, @player.get_selected_card() if @get_selected_card()?
    @addChild @btnPlayCard

    @btnEndTurn = new createjs.Bitmap @preload.getResult 'btn-end-turn'
    @btnEndTurn.addEventListener 'click', =>
      if @current is @player
        @levelScreen.end_turn()
    @addChild @btnEndTurn

  layout: (@width, @height) ->
    super @width, @height

    @btnEndTurn.x = @width - @btnEndTurn.image.width
    @btnEndTurn.y = @height - @btnEndTurn.image.height - 75

    @btnPlayCard.x = @btnEndTurn.x
    @btnPlayCard.y = @btnEndTurn.y - @btnPlayCard.image.height