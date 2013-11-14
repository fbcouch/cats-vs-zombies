# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

catsvzombies.HandIndicator = class HandIndicator
  constructor: (@player, @game, @element) ->
    @update()

  update: ->
    if @is_dirty()
      @element.html(
        ("<div><img src=\"assets/#{card.image}.png\"></div>" for card in @player.hand when card.image?).join('\n')
      )

      @element.find('div').each( (i, elem) =>
        $(elem).click =>
          @clicked elem
      )

      @hand = JSON.parse JSON.stringify @player.hand

  is_dirty: ->
    return true if not @hand?

    return true if @hand.length isnt @player.hand.length

    return (1 for i of @hand when @hand[i].uuid isnt @player.hand[i].uuid).length isnt 0

  clicked: (elem) ->
    if $(elem).hasClass 'selected'
      $(elem).removeClass 'selected'
    else
      @element.find('div').each( -> $(this).removeClass 'selected')
      $(elem).addClass 'selected'

  get_selected_card: () ->
    @player.hand[@element.find('div.selected').eq(0).index()]