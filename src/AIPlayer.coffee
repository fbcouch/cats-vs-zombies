# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

window.catsvzombies.AIPlayer = class AIPlayer extends catsvzombies.AbstractPlayer
  constructor: (@preload, @deck, @levelScreen, play_card_callback) ->
    super(@preload, @deck, @levelScreen)

    @play_card_callback = play_card_callback

    @mana_indicator.scaleX = -1
    @mana_indicator.scaleY = -1

    @hp_indicator.scaleX = -1
    @hp_indicator.scaleY = -1

  update: (delta, is_turn) ->
    super(delta, is_turn)

    if is_turn

      # TODO improve AI
      if not @levelScreen.combat_mode
        @play_card_callback @, card if @parent?.can_play @, card for card in @hand
        @mana_indicator.activate_all()
        @play_card_callback @, card if @parent?.can_play @, card for card in @hand

      if not @levelScreen.attacked and @creatures.length > 0
        card.attacking = true for card in @creatures when not card.tapped and card.can_attack

        @levelScreen.attack @ if not @levelScreen.combat_mode

      @levelScreen.end_turn @ if not @levelScreen.combat_mode

    else if @levelScreen.combat_mode
      # need to defend

      card.defending = true for card in @creatures_stack.cards when not card.tapped
      @levelScreen.defend @

    @hp_indicator.x = @width
    @hp_indicator.y = @height

    @mana_indicator.x = @width
    @mana_indicator.y = @hp_indicator.y - @hp_indicator.getBounds().height - 10