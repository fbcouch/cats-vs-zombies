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
    player_hand = (cat_cards[Math.floor(Math.random() * cat_cards.length)] for i in [0...20])

    @players.push new catsvzombies.Player @, player_hand, $ "#player_status"
    @players.push new catsvzombies.AIPlayer @, (zombie_cards[Math.floor(Math.random() * cat_cards.length)] for i in [0...20]), $ "#opponent_status"

    $('button:contains("End Turn")').click =>
      @players[0].curhp -= 5;
      @players[0].update();



