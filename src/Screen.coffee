# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

DEBUG = false

window.catsvzombies.Screen = class Screen extends createjs.Container

  constructor: (@preload) ->
    @initialize()

  show: ->

  resize: (@width, @height) ->

  update: (delta) ->

  hide: ->