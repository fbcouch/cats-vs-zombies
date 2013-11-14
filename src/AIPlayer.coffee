# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

window.catsvzombies.AIPlayer = class AIPlayer extends catsvzombies.AbstractPlayer
  constructor: (@game, @hand, @bindElement, @fieldElement) ->
    super @game, @hand, @bindElement, @fieldElement

  update: (delta) ->
    super delta

    if (@game.current_player() is @) # AI's turn!
      @game.end_turn()