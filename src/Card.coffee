# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

DEBUG = false

window.catsvzombies.Card = class Card extends createjs.Container
  constructor: (@preload, @proto, @faceup) ->
    @initialize()

    @counters = []
    @attached = []

    @front = new createjs.Bitmap @preload.getResult @proto.image
    @back = new createjs.Bitmap @preload.getResult 'card-back'

    @addChild if @faceup then @front else @back
    {width: @width, height: @height} = @getBounds()

    @addEventListener 'click', @clicked
    @addEventListener 'dblclick', @dblclicked

    @reset_states()

  update: (delta) ->

  get_strength: ->
    @proto.strength #TODO take into account counters and attached things

  get_toughness: ->
    @proto.toughness #TODO take into account counters and attached things

  flip: ->
    @removeChild if @faceup then @front else @back
    @faceup = not @faceup
    @addChild if @faceup then @front else @back

  clicked: (event) =>
    @parent?.card_clicked? event, @

  dblclicked: (event) =>
    @parent?.card_dblclicked? event, @

  reset_states: () =>
    @attacking = false

  is_attacking: =>
    @attacking

  toggle_attacking: =>
    @attacking = not @attacking