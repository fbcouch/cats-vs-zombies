# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

catsvzombies.ActiveManaIndicator = class ActiveManaIndicator
  constructor: (@player, @game, @element) ->
    @update()

  update: ->
    if @is_dirty()
      @element.html(
        (
          for key, val of @player.mana_active
            (for i in [0...val]
              "<li><img src=\"assets/mana-#{key}.png\"></li>").join('\n')
        ).join('\n')
      )

      @element.find('li').each( (i, elem) =>
        $(elem).click (event) =>
          j = 0
          for key, val of @player.mana_active
            @clicked key if j <= i < j + val
            j += val
      )

      @mana[key] = val for key, val of @player.mana_active

  is_dirty: ->
    if not @mana
      @mana = []
      return true
    (1 for key of @player.mana_active when @player.mana_active[key] isnt @mana[key]).length > 0 or (1 for key of @mana when @player.mana_active[key] isnt @mana[key]).length > 0

  clicked: (key) ->
    console.log key
    @player.deactivate_mana? key