# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

catsvzombies.CreatureStack = class CreatureStack
  constructor: (@player, @game, @element, @responsive) ->
    @creatures = (null for i in [0...5])
    @dirty = true

  update: (delta) ->
    # TODO need to check tapped vs untapped
    if @dirty or (@game.current_player() is @player) isnt @was_turn
      @element.find('div').each( (i, elem) =>
        if @creatures[i]?
          $(elem).html("<img src=\"assets/#{@creatures[i].image}.png\">")
          if @creatures[i].tapped
            $(elem).find('img').addClass('tapped')
          else
            $(elem).find('img').removeClass('tapped')
        else
          $(elem).html('')
      )

      if @responsive
        @element.parent().find('.creature_controls > div').each (i, elem) =>
          if @creatures[i]? and not @creatures[i].tapped
            $(elem).find('.controls').removeClass 'hidden'
            $(elem).find('.controls .glyphicon-arrow-left').click =>
              @move_left i
            $(elem).find('.controls .glyphicon-arrow-right').click =>
              @move_right i

            $(elem).find(if @game.current_player() is @player then '.controls .defend' else '.controls .attack').addClass('hidden')
            e = $(elem).find(if @game.current_player() is @player then '.controls .attack' else '.controls .defend')
            e.removeClass('hidden').click =>
              if e.hasClass('toggled')
                e.removeClass('toggled').addClass('untoggled')
              else
                e.removeClass('untoggled').addClass('toggled')

          else
            $(elem).find('.controls').addClass 'hidden'

      @was_turn = @game.current_player() is @player
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
      @creatures[i] if @creatures[i]? and not @creatures[i].tapped and @is_attack_toggled('defend', i)

  is_toggled: (classname, i) ->
    @element.parent().find(".creature_controls > div .controls .#{classname}").eq(i).hasClass('toggled')