# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

catsvzombies.ManaIndicator = class ManaIndicator
  constructor: (@player, @game, @element, @responsive) ->
    @update()

  update: ->
    if @is_dirty()

      @element.find('tr:first-child').html(
        ("<td><img src=\"assets/mana-#{key}.png\"></td>" for key, val of @player.mana).join('\n')
      )
      if @responsive
        @element.find('tr:first-child td').each( (i, elem) =>
          $(elem).click (event) =>
            @clicked (key for key of @player.mana)[i]
        )

      @element.find('tr:last-child').html(
        ("<td><h1>#{val - (if @responsive then (@player.mana_active[key] + @player.mana_used[key]) else 0)}</h1></td>" for key, val of @player.mana).join('\n')
      )

      @mana[key] = @player.mana[key] - (if @responsive then (@player.mana_active[key] + @player.mana_used[key]) else 0) for key of @player.mana

  is_dirty: () ->
    if not @mana?
      @mana = []
      return true

    return (1 for key of @player.mana when @player.mana[key] isnt @mana[key]).length > 0 or (1 for key of @mana when @player.mana[key] isnt @mana[key]).length > 0 if not @responsive
    (1 for key of @player.mana when @player.mana[key] - @player.mana_active[key] - @player.mana_used[key] isnt @mana[key]).length > 0 or (1 for key of @mana when @player.mana[key] - @player.mana_active[key] - @player.mana_used[key] isnt @mana[key]).length > 0

  clicked: (key) ->
    return if not @responsive
    @player.activate_mana? key