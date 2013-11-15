# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

DEBUG = false

window.catsvzombies.CatsVsZombiesGame = class CatsVsZombiesGame
  constructor: () ->
    @players = []

    cat_cards = preload.getResult 'cat-cards'
    zombie_cards = preload.getResult 'zombie-cards'

    # TODO load player and zombie cards

    @player = new catsvzombies.Player @, (@create_card cat_cards[Math.floor(Math.random() * cat_cards.length)] for i in [0...20]), $("#player_status"), $( ".player_cards")
    @players.push @player
    @players.push new catsvzombies.AIPlayer @, (@create_card zombie_cards[Math.floor(Math.random() * zombie_cards.length)] for i in [0...20]), $("#opponent_status"), $(".opponent_cards")

    @command_card =
      end_turn: $('button:contains("End Turn")')
      play_card: $('button:contains("Play Card")')
      attack: $('button:contains("Attack")')
      defend: $('button:contains("Defend")')

    @command_card.end_turn.click =>
      @end_turn_clicked()

    @command_card.play_card.click =>
      @play_card_clicked()

    @command_card.attack.click =>
      @attack_clicked()

    @command_card.defend.click =>
      @defend_clicked()

    @start_turn 0

  create_card: (card) ->
    c = JSON.parse JSON.stringify card
    c.uuid =
      (for j in [0...12]
        p = Math.random() * 36
        String.fromCharCode(if p < 10 then p + 48 else p + 55) ).join('')
    c

  update: (delta) ->
    player.update(delta) for player in @players

    # command card
    if @current_player() is @player
      @command_card.defend.removeClass('btn-primary') if @command_card.defend.hasClass('btn-primary')
      @command_card.end_turn.addClass('btn-primary') if not @command_card.end_turn.hasClass('btn-primary')
      if not @turn_state.attacked and not @turn_state.combat_mode
        @command_card.attack.addClass('btn-primary') if not @command_card.attack.hasClass('btn-primary')
      else
        @command_card.attack.removeClass('btn-primary') if @command_card.attack.hasClass('btn-primary')
    else
      @command_card.end_turn.removeClass('btn-primary') if @command_card.end_turn.hasClass('btn-primary')
      @command_card.attack.removeClass('btn-primary') if @command_card.attack.hasClass('btn-primary')
      if @turn_state.combat_mode
        @command_card.defend.addClass('btn-primary') if not @command_card.defend.hasClass('btn-primary')
      else
        @command_card.defend.removeClass('btn-primary') if @command_card.defend.hasClass('btn-primary')

    if @player.get_selected_card() and @can_play_card @player, @player.get_selected_card()
      @command_card.play_card.addClass('btn-primary') if not @command_card.play_card.hasClass('btn-primary')
    else
      @command_card.play_card.removeClass('btn-primary') if @command_card.play_card.hasClass('btn-primary')

  end_turn_clicked: ->
    if @current_player() is @player
      @end_turn()

  play_card_clicked: ->
    if @current_player() is @player
      card = @player.get_selected_card()
      return if not card?
      @play_card @player, card

  attack_clicked: ->
    if @current_player() is @player
      @attack @player

  defend_clicked: ->
    if @current_player() isnt @player and @turn_state.combat_mode
      @defend @player

  start_turn: (i) ->
    @turn_state =
      player: i
      mana_played: false
      attacked: false
      combat_mode: false

    @current_player().start_turn()
    console.log "Turn started for player #{i}"

  end_turn: () ->
    @start_turn (@turn_state.player + 1) % @players.length

  current_player: ->
    @players[@turn_state.player]

  can_play_card: (who, card) ->
    return false if who isnt @current_player() or not card?
    switch card.type
      when 'mana'
        return not @turn_state.mana_played
      when 'creature'
        # figure out if they have enough mana
        return (1 for key, val of card.requires when not who.mana_active[key]? or who.mana_active[key] < val).length is 0
    return false

  play_card: (who, card) ->
    return if not @can_play_card who, card
    @turn_state.mana_played = true if card.type is 'mana'
    who.play_card card

  attack: (who) ->
    return if who isnt @current_player() or @turn_state.attacked

    attackers = who.get_attackers()
    return if (1 for a in attackers when a?).length is 0

    @turn_state.attackers = attackers

    @turn_state.combat_mode = true
    @turn_state.attacked = true

    console.log "Player #{@players.indexOf(who)} attacks"

  defend: (who) ->
    return if who is @current_player() or not @turn_state.combat_mode

    @turn_state.defenders = who.get_defenders()

    console.log "Player #{@players.indexOf(who)} defends"

    @do_combat()

  do_combat: ->
    console.log 'combat'
    @turn_state.combat_mode = false

    console.log @turn_state
    attacker = @current_player()
    defender = @players[(@turn_state.player + 1) % @players.length]

    for i in [0...@turn_state.attackers.length]
      if @turn_state.attackers[i]?
        a = @turn_state.attackers[i]
        # something needs to happen
        if @turn_state.defenders[i]?
          d = @turn_state.defenders[i]
          defender.discard_creature d if a.strength >= d.toughness
          attacker.discard_creature a if d.strength >= a.toughness
          d.tapped = true
        else
          # hit the opposing player
          defender.curhp -= a.strength
        a.tapped = true
