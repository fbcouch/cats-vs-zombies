# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

DEBUG = false

window.catsvzombies.CatsVsZombiesGame = class CatsVsZombiesGame
  constructor: () ->
    @players = []

    @players.push new catsvzombies.Player @, $ "#player_status"
    @players.push new catsvzombies.AIPlayer @, $ "#opponent_status"

    $('button:contains("End Turn")').click =>
      @players[0].curhp -= 5;
      @players[0].update();



