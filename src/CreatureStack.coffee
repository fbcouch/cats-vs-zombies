# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

catsvzombies.CreatureStack = class CreatureStack
  constructor: (@player, @game, @element, @responsive) ->
    @creatures = (null for i in [0...5])
    @dirty = true

    if @responsive
      @element.parent().find('.creature_controls > div').each (i, elem) =>
        $(elem).find('.controls .glyphicon-arrow-left').click =>
          @move_left i
        $(elem).find('.controls .glyphicon-arrow-right').click =>
          @move_right i

        $(elem).find('.controls .attack').click ->
          if $(this).hasClass('toggled')
            $(this).removeClass('toggled').addClass('untoggled')
          else
            $(this).removeClass('untoggled').addClass('toggled')

        $(elem).find('.controls .defend').click ->
          if $(this).hasClass('toggled')
            $(this).removeClass('toggled').addClass('untoggled')
          else
            $(this).removeClass('untoggled').addClass('toggled')

  update: (delta) ->

    if @dirty
      @element.find('div').each( (i, elem) =>
        if @creatures[i]?
          $(elem).html("<img src=\"assets/#{@creatures[i].image}.png\"><span class=\"status-icon\"></span>")
        else
          $(elem).html('')
      )
      @dirty = false

    if not @responsive
      if @game.turn_state.combat_mode is true
        for i of @creatures
          if @creatures[i] in @game.turn_state.attackers
            @element.find('div').eq(i).find('span.status-icon').addClass('icon-attack')
      else
        @element.find('div span.status-icon').removeClass('icon-attack')


    @element.find('div').each (i, elem) =>
      if @creatures[i]?
        if @creatures[i].tapped
          $(elem).find('img').addClass('tapped')
        else
          $(elem).find('img').removeClass('tapped')
    if @responsive
      @element.parent().find('.creature_controls > div').each (i, elem) =>
        if @creatures[i]? and not @creatures[i].tapped
          $(elem).find('.controls').removeClass 'hidden' if $(elem).find('.controls').hasClass 'hidden'

#          if (@game.current_player() is @player) isnt @was_turn
          inactive = if @game.current_player() is @player then '.controls .defend' else '.controls .attack'
          active = if @game.current_player() is @player then '.controls .attack' else '.controls .defend'
          $(elem).find(inactive).addClass('hidden') if not $(elem).find(inactive).hasClass('hidden')
          e = $(elem).find(active)
          e.removeClass('hidden') if e.hasClass('hidden')

        else
          $(elem).find('.controls').addClass 'hidden'
    @was_turn = @game.current_player() is @player


  push: (obj) ->
    @dirty = true
    for i in [0...@creatures.length]
      if not @creatures[i]?
        @creatures[i] = obj
        return

  pop: (i) ->
    return if not 0 <= i < 5
    @dirty = true
    creature = @creatures[i]
    @creatures[i] = null
    creature

  remove: (card) ->
    for creature, i in @creatures
      @creatures[i] = null if creature is card
    @dirty = true

  length: () ->
    (1 for creature in @creatures when creature?).length

  move_left: (i) =>
    if @creatures[i]? and i > 0
      save = @creatures[i - 1]
      @creatures[i - 1] = @creatures[i]
      @creatures[i] = save
      @dirty = true

  move_right: (i) =>
    if @creatures[i]? and i < @creatures.length - 1
      save = @creatures[i + 1]
      @creatures[i + 1] = @creatures[i]
      @creatures[i] = save
      @dirty = true

  get_attackers: () ->
    for i in [0...@creatures.length]
      @creatures[i] if @creatures[i]? and not @creatures[i].tapped and @is_toggled('attack', i)

  get_defenders: () ->
    for i in [0...@creatures.length]
      @creatures[i] if @creatures[i]? and not @creatures[i].tapped and @is_toggled('defend', i)

  is_toggled: (classname, i) ->
    @element.parent().find(".creature_controls > div .controls .#{classname}").eq(i).hasClass('toggled')

  reset_controls: ->
    @element.parent().find('.creature_controls > div .controls .attack').each ->
      $(this).removeClass('toggled').addClass('untoggled')

    @element.parent().find('.creature_controls > div .controls .defend').each ->
      $(this).removeClass('toggled').addClass('untoggled')