# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

catsvzombies.DeckEditor = class DeckEditor
  constructor: (@player) ->
    @dirty = true

    @saved_hand = JSON.parse JSON.stringify @player.deck

  update: (delta) ->
    if @dirty
      @totals = {}

      for card in @player.cards when card < 9000
        if @totals[card]?
          @totals[card]++
        else
          @totals[card] = 1

      @in_hand = {}
      for card in @player.deck
        if @in_hand[card]?
          @in_hand[card]++
        else
          @in_hand[card] = 1
      total = 0
      total += val for key, val of @in_hand
      $('#statusArea').html(
        (
          for key in ["9003", "9004"]
            @create_card key, @in_hand[key] or 0
        ).join('\n') + "<div id=\"player_actions\" class=\"pull-bottom\"><span class=\"lead\">#{total} cards total</span><button type=\"button\" class=\"btn btn-lg btn-primary\">Save</button></div>"
      )

      $('.deck_picker').eq(1).html(
        (
          for key of @totals when key < 9000
            @create_card key, @in_hand[key] or 0, @totals[key]
        ).join('\n')
      )

      $('.card > .minus').each (i, elem) =>
        $(elem).click (obj) =>
          @minus_clicked $(obj.currentTarget).attr('data-id')
      $('.card > .plus').each (i, elem) =>
        $(elem).click (obj) =>
          @plus_clicked $(obj.currentTarget).attr('data-id')

      $('#player_actions button:contains("Save")').click =>
        sceneMgr.setOverworldScene()

      @dirty = false

  minus_clicked: (id) ->
    i = @player.deck.indexOf(parseInt(id))
    if i >= 0
      @player.deck.splice i, 1
      @dirty = true

  plus_clicked: (id) ->
    if @totals[id] > (@in_hand[id] or 0) or parseInt(id) > 9000
      @player.deck.push parseInt(id)
      @dirty = true

  create_card: (id, in_hand, total) ->
    cards = preload.getResult 'cat-cards'
    card = null
    for c in cards when c.uuid is parseInt(id)
      card = c
    "<div class=\"card\">
      <img src=\"./assets/#{card.image}.png\">
      <span class=\"lead\">#{if total? then in_hand + ' / ' + total else 'x ' + in_hand}</span>
      <button type=\"button\" class=\"btn minus\" data-id=\"#{id}\"><span class=\"glyphicon glyphicon-minus\"></span></button>
      <button type=\"button\" class=\"btn plus\" data-id=\"#{id}\"><span class=\"glyphicon glyphicon-plus\"></span></button>
    </div>"