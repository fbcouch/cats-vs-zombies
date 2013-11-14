# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

game = null

init = ->
  console.log 'game init'
  game = new catsvzombies.CatsVsZombiesGame()

init()