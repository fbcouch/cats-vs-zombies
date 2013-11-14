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
    @player = new catsvzombies.Player @, (cat_cards[Math.floor(Math.random() * cat_cards.length)] for i in [0...20]), $ "#player_status"
    @players.push @player
    @players.push new catsvzombies.AIPlayer @, (zombie_cards[Math.floor(Math.random() * cat_cards.length)] for i in [0...20]), $ "#opponent_status"

    $('button:contains("End Turn")').click =>
      @end_turn_clicked()

    $('button:contains("Play Card")').click =>
      @play_card_clicked()

    $('button:contains("Attack")').click =>
      @attack_clicked()

    $('button:contains("Defend")').click =>
      @defend_clicked()

    @start_turn 0

  update: (delta) ->
    player.update(delta) for player in @players

  end_turn_clicked: ->
    if @current_player() is @player
      @end_turn()

  play_card_clicked: ->
    if @current_player() is @player
      card = @player.get_selected_card()
      return if not card?
      @play_card @player, card

  attack_clicked: ->

  defend_clicked: ->

  start_turn: (i) ->
    @turn_state =
      player: i
      mana_played: false
      attacked: false
      combat_mode: false

    console.log "Turn started for player #{i}"

  end_turn: () ->
    @start_turn (@turn_state.player + 1) % @players.length

  current_player: ->
    @players[@turn_state.player]

  can_play_card: (who, card) ->
    return false if who isnt @current_player()
    switch card.type
      when 'mana'
        return not @turn_state.mana_played
      when 'creature'
        # figure out if they have enough mana
        return false
    return false

  play_card: (who, card) ->
    return if not @can_play_card who, card
    @turn_state.mana_played = true if card.type is 'mana'
    who.play_card card


