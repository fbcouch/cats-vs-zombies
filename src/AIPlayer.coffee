# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

window.catsvzombies.AIPlayer = class AIPlayer extends catsvzombies.AbstractPlayer
  constructor: (@game, @cards, @bindElement, @fieldElement) ->
    super @game, @cards, @bindElement, @fieldElement

  update: (delta) ->
    super delta

    if (@game.current_player() is @) # AI's turn!
      @game.play_card @, card for card in @hand
      @activate_mana(key) for i in [0...val] for key, val of @mana
      for card in @hand
        if @game.can_play_card @, card
          p = Math.random()
          if p < 0.5
            @game.play_card @, card
          else
#            console.log 'AI: failed roll ' + p
      @game.attack @ if not @game.turn_state.combat_mode
      if not @game.turn_state.combat_mode
        @game.end_turn()
    else if @game.turn_state.combat_mode # need to defend
      @game.defend @

  get_attackers: ->
    for i, creature of @creatures.creatures
      if not creature?.tapped
        p = Math.random()
        if p < 0.5
          creature
        else
#          console.log 'AI: failed roll ' + p
          null
      else
        null

  get_defenders: ->
    (if not creature?.tapped then creature else null) for i, creature of @creatures.creatures