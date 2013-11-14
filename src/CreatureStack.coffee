# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

catsvzombies.CreatureStack = class CreatureStack
  constructor: (@player, @game, @element, @responsive) ->
    @creatures = []
    @dirty = true

  update: (delta) ->
    if @dirty
      a = 1

      @dirty = false

  push: (obj) ->
    @creatures.push obj
    @dirty = true

  pop: () ->
    @dirty = true
    @creatures.pop()