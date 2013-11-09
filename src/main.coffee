# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}
#catsvzombies = window.catsvzombies

manifest = [
  {id: 'cat-cards', src: 'assets/cat-cards.json'}
  {id: 'zombie-cards', src: 'assets/zombie-cards.json'}
  {id: 'grassy-bg', src: 'assets/grassy-bg.png'}
  {id: 'card-back', src: 'assets/card-back.png'}
  {id: 'mana-mouse', src: 'assets/mana-mouse.png'}
  {id: 'mana-bird', src: 'assets/mana-bird.png'}
  {id: 'mana-fish', src: 'assets/mana-fish.png'}
  {id: 'mana-grave', src: 'assets/mana-grave.png'}
  {id: 'mana-brain', src: 'assets/mana-brain.png'}
  {id: 'btn-play-card', src: 'assets/btn-play-card.png'}
  {id: 'btn-end-turn', src: 'assets/btn-end-turn.png'}
]

canvas = {}
stage = {}
canvasWidth = 0
canvasHeight = 0
preload = {}
progressbar = {}
messageField = {}
game = null

init = ->
  console.log 'game init'

  canvas = document.getElementById 'gameCanvas'
  canvas.style.background = '#000'
  stage = new createjs.Stage canvas

  # progress bar
  messageField = new createjs.Text 'Loading', 'bold 30px sans-serif', '#CCC'
  messageField.textAlign = 'center'

  stage.addChild messageField
  stage.update()

  preload = new createjs.LoadQueue()
  preload.addEventListener 'complete', ->
    images = []
    images.push {id: card.image, src: "assets/#{card.image}.png"} for card in preload.getResult 'cat-cards'
    images.push {id: card.image, src: "assets/#{card.image}.png"} for card in preload.getResult 'zombie-cards'
    preload.removeAllEventListeners 'complete'

    preload.addEventListener 'complete', ->
      # complete
      console.log 'complete'
      messageField.text = "Loading complete"
      stage.removeAllChildren()
      stage.update()
      start()

    preload.addEventListener 'progress', ->
      #progress
      console.log 'progress'
      messageField.text = "Loading #{preload.progress*100|0}%"
      stage.update()

    preload.loadManifest images

  preload.loadManifest manifest

  window.onresize = (event) ->
    # size should be entire browser window
    canvasWidth = canvas.width = document.documentElement.clientWidth
    canvasHeight = canvas.height = document.documentElement.clientHeight

    messageField.x = canvasWidth * 0.5
    messageField.y = canvasHeight * 0.5

    game?.resize canvasWidth, canvasHeight

  window.onresize(null)

start = ->
  console.log 'Start game...'
  stage.removeAllChildren()
  # create and load the game
  game = new window.catsvzombies.CatsVsZombiesGame stage, preload, canvasWidth, canvasHeight
  createjs.Ticker.addEventListener('tick', tick) if not createjs.Ticker.hasEventListener('tick')
  createjs.Ticker.setFPS 20

tick = (event) ->
  delta = event.delta / 1000
  return if not event.delta?

  game?.update delta
  stage.update()

init()
