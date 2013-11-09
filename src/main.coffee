# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

canvas = {}
stage = {}
canvasWidth = canvasHeight = 0
preload = {}
progressbar = {}
messageField = {}
game = {}

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

  manifest = []

  preload = new createjs.LoadQueue()
  preload.addEventListener 'complete', ->
    # complete
    messageField.text = "Loading complete"
    stage.removeAllChildren()
    stage.update()
    start()

  preload.addEventListener 'progress', ->
    #progress
    messageField.text = "Loading #{preload.progress*100|0}%"
    stage.update()

  window.onresize = (event) ->
    # size should be entire browser window
    canvasWidth = canvas.width = document.documentElement.clientWidth
    canvasHeight = canvas.height = document.documentElement.clientHeight

    messageField.x = canvasWidth * 0.5
    messageField.y = canvasHeight * 0.5

  window.onresize(null)

start = ->
  console.log 'Start game...'
  # create and load the game

  createjs.Ticker.addEventListener('tick', tick) if not createjs.Ticker.hasEventListener('tick')
  createjs.Ticker.setFPS 20

tick = (event) ->
  delta = event.delta / 1000
  return if not event.delta?

  game?.update delta
  stage.update()

init()
