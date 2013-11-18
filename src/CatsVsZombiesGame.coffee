# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

DEBUG = false

window.catsvzombies.CatsVsZombiesGame = class CatsVsZombiesGame
  constructor: (@player_info, @mission) ->
    @players = []

    cat_cards = preload.getResult 'cat-cards'
    zombie_cards = preload.getResult 'zombie-cards'
    decks = preload.getResult 'decks'
    # Player (starter) deck

    player_cards = []
    player_cards.push card for card in cat_cards when card.uuid is id for id in player_info.deck

    ai_cards = []
    ai_cards.push card for card in zombie_cards when card.uuid is id for id in decks[mission.opponent].cards

    console.log player_cards
    @player = new catsvzombies.Player @, (@create_card card for card in player_cards), $("#player_status"), $( ".player_cards")
    @players.push @player
    @players.push new catsvzombies.AIPlayer @, (@create_card card for card in ai_cards), $("#opponent_status"), $(".opponent_cards")

    @players[1].curhp = @players[1].maxhp = decks[mission.opponent].hp if decks[mission.opponent].hp?

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

    @gamestate = 1 # 1 = playing, 0 = over

  create_card: (card) ->
    c = JSON.parse JSON.stringify card
    c.uuid =
      (for j in [0...12]
        p = Math.random() * 36
        String.fromCharCode(if p < 10 then p + 48 else p + 55) ).join('')
    c

  update: (delta) ->
    player.update(delta) for player in @players

    if @gamestate is 1
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

      if @players[0].curhp <= 0
        @end_game false
      else if @players[1].curhp <= 0
        @end_game true
    else
      # game is over
      $('.creature_controls').addClass('hidden')
      $('#player_actions').addClass('hidden')

  end_game: (victory) ->
    @gamestate = 0

    if victory and not @mission.complete and @mission.rewards?
      added_cards = true
      @player_info.cards.push card for card in @mission.rewards

    @mission.complete = true if victory

    resultbox = $('#result').removeClass('hidden')

    resultbox.find('.result-title').html(if victory then 'Victory!' else 'Defeat!')
    resultbox.find('.result-info').html(if victory then 'You defeated the zombies!' + (if added_cards then '<br>Check out the new cards you can add to your deck!' else '') else 'You were defeated by the zombies!')

    resultbox.find('.btn:contains("World Overview")').click =>
      console.log 'to world view'
      sceneMgr.setOverworldScene()

    resultbox.find('.btn:contains("Change Deck")').click =>
      console.log 'change deck'
      sceneMgr.setDeckScene()

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
