# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

screen = null
player = null

manifest = [
  {id: 'cat-cards', src: 'assets/cat-cards.json'}
  {id: 'zombie-cards', src: 'assets/zombie-cards.json'}
  {id: 'decks', src: 'assets/decks.json'}
  {id: 'missions', src: 'assets/missions.json'}
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
    player =
      missions: JSON.parse JSON.stringify preload.getResult 'missions'
      deck: JSON.parse JSON.stringify preload.getResult('decks')['default'].cards
      cards: (JSON.parse JSON.stringify card for card in preload.getResult('decks')['default'].cards when card.uuid < 9000)

    window.sceneMgr = new catsvzombies.SceneManager(player)
#    sceneMgr.setDeckScene()
    sceneMgr.setIntroScene()
#    loadScreenTemplate './battleScreen.html', =>
#      game = new catsvzombies.CatsVsZombiesGame()

#    loadScreenTemplate './overworld.html', =>
#      overworld = new catsvzombies.Overworld()

window.loadScreenTemplate = (url, callback) ->
  $.ajax(url).done (data) =>
    $('#game').html(data)
    callback?()

catsvzombies.SceneManager = class SceneManager
  constructor: (@player) ->
    createjs.Ticker.setFPS 20
    createjs.Ticker.addEventListener 'tick', (event) =>
      @scene?.update? event.delta

    @scene = null

  setIntroScene: ->
    loadScreenTemplate './intro.html', =>
      @scene = new catsvzombies.Intro @introCallback

  introCallback: =>
    @setBattleScene(@player.missions[0])

  setBattleScene: (mission) ->
    loadScreenTemplate './battleScreen.html', =>
      @scene = new catsvzombies.CatsVsZombiesGame @player, mission

  setOverworldScene: () ->
    loadScreenTemplate './overworld.html', =>
      @scene = new catsvzombies.Overworld @player

  setDeckScene: () ->
    loadScreenTemplate './deck.html', =>
#      @scene = new catsvzombies.DeckEditor @player

  setVictoryScene: () ->
    loadScreenTemplate './victory.html', =>
      @scene = null
      $('.btn:contains("Play Again")').click =>
        location.reload() # TODO fix this dirty hack

catsvzombies.Intro = class Intro
  constructor: (@callback) ->
    @bubbles = [
      { x: 100, y: 100, text: "All was normal at the Phi Lambda Nu house..." }
      { x: 367, y: 250, text: "...as the cats partied the night away..." }
      { x: 633, y: 400, text: "...until suddenly..." }
      { x: 900, y: 550, text: "ZOMBIES!", "class": "intro-zombies" }
    ]

    $('.row').html(
      (for b in @bubbles
        "<div class=\"chat-bubble hidden\" style=\"left: #{b.x}px; top: #{b.y}px;\">#{b.text}</div>"
      ).join('\n') +
      "<button type=\"button\" class=\"btn btn-lg btn-primary\">Play Game</button>"
    )

    @timer = 0
    @bubble = 0

    $('.row > button').click =>
      @callback?()

  update: (delta) ->

    if @bubble < @bubbles.length
      @timer += delta / 1000
      if @timer > 2
        $('.row').removeClass('intro').addClass(@bubbles[@bubble].class) if @bubbles[@bubble].class?
        $('.row .chat-bubble').eq(@bubble).removeClass 'hidden'
        @bubble += 1
        @timer -= 2

init()