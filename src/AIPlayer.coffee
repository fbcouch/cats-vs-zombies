# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

window.catsvzombies.AIPlayer = class AIPlayer extends catsvzombies.AbstractPlayer
  constructor: (@game, @cards, @bindElement, @fieldElement) ->
    super @game, @cards, @bindElement, @fieldElement
    @timer = 0
    @time_between_moves = 0.5

  update: (delta) ->
    super delta

    @timer -= delta / 1000
    if @timer < 0
      @timer = @time_between_moves
    else
      return

    if (@game.current_player() is @) # AI's turn!
      console.log @timer
      for card in @hand
        if @game.can_play_card @, card
          @game.play_card @, card
          return

      @activate_mana(key) for i in [0...val] for key, val of @mana

      for card in @hand
        if @game.can_play_card @, card
#          p = Math.random()
#          if p < 0.7
          @game.play_card @, card
          return
#          else
#            console.log 'AI: failed roll ' + p

      @game.attack @ if not @game.turn_state.combat_mode
      if not @game.turn_state.combat_mode
        @game.end_turn()
    else if @game.turn_state.combat_mode # need to defend

      if not @set_defense()
        @game.defend @

  get_attackers: ->
    for i, creature of @creatures.creatures
      if not creature?.tapped
        p = Math.random()
        if p < 0.7
          creature
        else
#          console.log 'AI: failed roll ' + p
          null
      else
        null

  set_defense: ->
    holes = []
    for i, opp of @game.turn_state.attackers
      if opp? and (not @creatures.creatures[i]? or @creatures.creatures[i].tapped)
        holes.push i
    extras = []
    for i, creature of @creatures.creatures
      if creature? and not creature.tapped and not @game.turn_state.attackers[i]?
        extras.push i

    if Math.min(holes.length, extras.length > 0)
      @creatures.swap holes[0], extras[0]

    Math.min(holes.length, extras.length)

  get_defenders: ->
    (if not creature?.tapped then creature else null) for i, creature of @creatures.creatures