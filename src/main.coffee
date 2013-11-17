# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

game = null

manifest = [
  {id: 'cat-cards', src: 'assets/cat-cards.json'}
  {id: 'zombie-cards', src: 'assets/zombie-cards.json'}
  {id: 'decks', src: 'assets/decks.json'}
#  {id: 'grassy-bg', src: 'assets/grassy-bg.png'}
#  {id: 'card-back', src: 'assets/card-back.png'}
#  {id: 'mana-mouse', src: 'assets/mana-mouse.png'}
#  {id: 'mana-bird', src: 'assets/mana-bird.png'}
#  {id: 'mana-fish', src: 'assets/mana-fish.png'}
#  {id: 'mana-grave', src: 'assets/mana-grave.png'}
#  {id: 'mana-brain', src: 'assets/mana-brain.png'}
#  {id: 'btn-play-card', src: 'assets/btn-play-card.png'}
#  {id: 'btn-end-turn', src: 'assets/btn-end-turn.png'}
#  {id: 'btn-attack', src: 'assets/btn-attack.png'}
#  {id: 'btn-attack-untoggled', src: 'assets/btn-attack-untoggled.png'}
#  {id: 'btn-defend', src: 'assets/btn-defend.png'}
#  {id: 'btn-defend-untoggled', src: 'assets/btn-defend-untoggled.png'}
#  {id: 'active-overlay', src: 'assets/active-overlay.png'}
]


init = ->
  console.log 'game init'

  window.preload = new createjs.LoadQueue()

  preload.loadManifest manifest
  preload.addEventListener 'complete', =>
    game = new catsvzombies.CatsVsZombiesGame()
    start = null
    createjs.Ticker.setFPS 20
    createjs.Ticker.addEventListener 'tick', (event) =>
      game.update(event.delta)

init()