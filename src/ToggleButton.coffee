# Cats vs Zombies
# (c) 2013 Jami Couch
# Apache 2.0 license

window.catsvzombies or= {}

window.catsvzombies.ToggleButton = class ToggleButton extends createjs.Container
  constructor: (@preload, img_untoggled, img_toggled, @is_toggled, @toggle) ->
    @initialize()

    @untoggled = new createjs.Bitmap @preload.getResult img_untoggled
    @toggled = new createjs.Bitmap @preload.getResult img_toggled

    @addChild @untoggled

    @addEventListener 'click', =>
      @toggle()

  update: (delta) ->
    if @is_toggled() and not @was_toggled
      @was_toggled = true
      @removeChild @untoggled
      @addChild @toggled

    if not @is_toggled() and @was_toggled
      @was_toggled = false
      @addChild @untoggled
      @removeChild @toggled

    {width: @width, height: @height} = @getBounds() if @children.length > 0