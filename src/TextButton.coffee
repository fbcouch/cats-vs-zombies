# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

catsvzombies.TextButton = class TextButton extends createjs.Container
  constructor: (@preload, @text, @callback) ->
    @initialize()

    @background = new createjs.Bitmap @preload.getResult 'btn-generic'
    @addChild @background

    @text_ele = new createjs.Text @text, 'normal 32px sans-serif', '#000'
    @text_ele.textAlign = 'center'
#    @text_ele.verticalAlign = 'middle'
    @addChild @text_ele

    @addEventListener 'click', =>
      @callback()

  update: (delta) ->
    @text_ele.text = @text
    @text_ele.x = @background.image.width * 0.5
    @text_ele.y = (@background.image.height - @text_ele.getBounds()?.height) * 0.5

    { width: @width, height: @height } = @getBounds()