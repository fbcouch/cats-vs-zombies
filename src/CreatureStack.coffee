# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

catsvzombies.CreatureStack = class CreatureStack
  constructor: (@player, @game, @element, @responsive) ->
    @creatures = (null for i in [0...5])
    @dirty = true

  update: (delta) ->
    if @dirty
      @element.find('div').each( (i, elem) =>
        if @creatures[i]?
          $(elem).html("<img src=\"assets/#{@creatures[i].image}.png\">")
        else
          $(elem).html('')
      )

      @dirty = false

  push: (obj) ->
    @dirty = true
    for i in [0...@creatures.length]
      if not @creatures[i]?
        @creatures[i] = obj
        return

  pop: (i) ->
    return if not 0 <= i < 5
    @dirty = true
    @creatures.splice i, 1

  length: () ->
    (1 for creature in @creatures when creature?).length