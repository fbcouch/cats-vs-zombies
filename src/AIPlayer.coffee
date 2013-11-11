# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

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