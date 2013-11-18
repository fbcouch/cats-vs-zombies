# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

catsvzombies.Overworld = class Overworld
  constructor: (@player) ->
    # TODO keep track of status over time...

    @missions = @player.missions

    $('#gameArea').html(
      (for mission, i in @missions when mission.complete
          (if i < @missions.length - 1 then @createLine(@missions[i], @missions[i+1]) else "")
      ).join('\n') +
      (for mission, i in @missions when i is 0 or @missions[i-1].complete
        "<div class=\"battle-point\" style=\"left: #{mission.left}px; top: #{mission.top}px;\"><span class=\"glyphicon #{if not mission.complete then 'glyphicon-warning-sign' else 'glyphicon-ok'}\"></span><span class=\"tooltip-left\">#{mission.name}</span></div>"
      ).join('\n')
    )

    $('#gameArea .battle-point').each (i, elem) =>
      $(elem).click =>
        if not $(elem).hasClass('selected')
          $('#gameArea .battle-point').each (i, elem) -> $(elem).removeClass('selected')
          $(elem).addClass('selected')
        else
          $(elem).removeClass('selected')

    div = $('#statusArea .progress .progress-bar')
    pct = (1 for mission in @missions when mission.complete).length / @missions.length * 100
    div.width("#{pct}%")

    if pct is 100
      sceneMgr.setVictoryScene()
      return

    $('.btn:contains("Start Battle")').click =>
      mission = @missions[$('#gameArea .battle-point.selected').index() / 2]  # JC note: need /2  here because the tooltips are sibilings (so there are 2 elements per mission)
      sceneMgr.setBattleScene mission if mission?

    $('.btn:contains("Edit Deck")').click =>
      sceneMgr.setDeckScene()

  createLine: (first, second) ->
    length = Math.sqrt Math.pow((second.left - first.left), 2) + Math.pow((second.top - first.top), 2)
    angle = Math.atan2(second.top - first.top, second.left - first.left) * 180/Math.PI
    $('<div>').addClass('battle-line').css({'transform': "rotate(#{angle}deg)"}).width(length).offset({left: first.left, top: first.top}).prop('outerHTML')