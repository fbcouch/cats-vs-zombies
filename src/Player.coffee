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