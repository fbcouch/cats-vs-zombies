# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

catsvzombies.DeckEditor = class DeckEditor
  constructor: (@player) ->
    @dirty = true

  update: (delta) ->
    if @dirty
      totals = {}
      for card in @player.cards when card < 9000
        if totals[card]?
          totals[card]++
        else
          totals[card] = 1

      in_hand = {}
      for card in @player.deck
        if in_hand[card]?
          in_hand[card]++
        else
          in_hand[card] = 1

      $('#statusArea').html(
        (
          for key, val of in_hand when key > 9000
            @create_card key, val
        ).join('\n')
      )

      $('.deck_picker').eq(1).html(
        (
          for key, val of in_hand when key < 9000
            @create_card key, val
        ).join('\n')
      )

      @dirty = false

  create_card: (id, in_hand, total) ->
    cards = preload.getResult 'cat-cards'
    card = null
    for c in cards when c.uuid is parseInt(id)
      card = c
      console.log c
    "<div class=\"card\">
      <img src=\"./assets/#{card.image}.png\">
      <span class=\"lead\">#{if total? then in_hand + ' / ' + total else 'x ' + in_hand}</span>
      <button type=\"button\" class=\"btn minus\"><span class=\"glyphicon glyphicon-minus\"></span></button>
      <button type=\"button\" class=\"btn plus\"><span class=\"glyphicon glyphicon-plus\"></span></button>
    </div>"