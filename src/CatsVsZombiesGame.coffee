# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

DEBUG = false

window.catsvzombies.CatsVsZombiesGame = class CatsVsZombiesGame

  constructor: (@stage, @preload, @width, @height) ->
    @setScreen new catsvzombies.LevelScreen @preload

  update: (delta) ->
    @screen?.update? delta

  resize: (@width, @height) ->
    @screen?.resize @width, @height

  setScreen: (screen) ->
    if @screen?
      @screen.hide?()
      @stage.removeAllChildren()

    @screen = screen
    @screen.show()          # show then resize (ie: layout)
    @resize @width, @height

    @stage.addChild @screen

