do ->

  Game = (canvasId) ->
    canvas = document.getElementById(canvasId)
    screen = canvas.getContext('2d')
    gameSize = 
      x: canvas.width
      y: canvas.height
    # var arrColors = [ "red", "blue", "green", "orange", "aqua", "violet" ];
    # var color = "white";
    @bodies = createInvaders(this).concat([ new Player(this, gameSize) ])
    self = this

    tick = ->
      self.update gameSize
      self.draw screen, gameSize
      requestAnimationFrame tick
      return

    tick()
    return

  Game.prototype =
    update: (gameSize) ->
      bodies = @bodies

      notCollidingWithAnything = (b1) ->
        `var i`
        bodies.filter((b2) ->
          colliding b1, b2
        ).length == 0

      @bodies = @bodies.filter(notCollidingWithAnything)
      i = 0
      while i < @bodies.length
        if @bodies[i].position.y < 0 or @bodies[i].position.y > gameSize.y
          @bodies.splice i, 1
        i++
      i = 0
      while i < @bodies.length
        @bodies[i].update()
        i++
      return
    draw: (screen, gameSize) ->
      clearCanvas screen, gameSize
      i = 0
      while i < @bodies.length
        drawRect screen, @bodies[i]
        i++
      return
    addBody: (body) ->
      @bodies.push body
      return
    invadersBelow: (invader) ->
      @bodies.filter((b) ->
        b instanceof Invader and b.position.y > invader.position.y and b.position.x - (invader.position.x) < invader.size.width
      ).length > 0

  Invader = (game, position) ->
    @game = game
    @size =
      width: 16
      height: 16
    @position = position
    @patrolX = 0
    @speedX = 1
    return

  Invader.prototype = update: ->
    if @patrolX < 0 or @patrolX > 450
      @speedX = -@speedX
    @position.x += @speedX
    @patrolX += @speedX
    if Math.random() < 0.2 and !@game.invadersBelow(this)
      bullet = new Bullet({
        x: @position.x + @size.width / 2 - (3 / 2)
        y: @position.y + @size.height / 2
      },
        x: Math.random() - 0.5
        y: 2)
      @game.addBody bullet
    return

  Player = (game, gameSize) ->
    @game = game
    @bullets = 0
    @timer = 0
    @size =
      width: 16
      height: 16
    @position =
      x: gameSize.x / 2 - (@size.width / 2)
      y: gameSize.y / 2 - (@size.height / 2) + 250
    @keyboarder = new Keyboarder
    return

  Player.prototype = update: ->
    if @keyboarder.isDown(@keyboarder.KEYS.LEFT)
      @position.x -= 2
    if @keyboarder.isDown(@keyboarder.KEYS.RIGHT)
      @position.x += 2
    if @keyboarder.isDown(@keyboarder.KEYS.SPACE)
      if @bullets < 1
        bullet = new Bullet({
          x: @position.x + @size.width / 2 - (3 / 2)
          y: @position.y - 4
        },
          x: 0
          y: -6)
        @game.addBody bullet
        @bullets++
    @timer++
    if @timer % 12 == 0
      @bullets = 0
    return

  Bullet = (position, velocity) ->
    color = @size =
      width: 3
      height: 3
    @position = position
    @velocity = velocity
    return

  Bullet.prototype = update: ->
    @position.x += @velocity.x
    @position.y += @velocity.y
    return

  Keyboarder = ->
    keyState = {}

    window.onkeydown = (e) ->
      keyState[e.keyCode] = true
      return

    window.onkeyup = (e) ->
      keyState[e.keyCode] = false
      return

    @isDown = (keyCode) ->
      keyState[keyCode] == true

    @KEYS =
      LEFT: 37
      RIGHT: 39
      SPACE: 32
    return

  createInvaders = (game) ->
    invaders = []
    i = 0
    while i < 24
      x = 30 + i % 8 * 40
      y = 30 + i % 3 * 40
      invaders.push new Invader(game,
        x: x
        y: y)
      i++
    invaders

  colliding = (b1, b2) ->
    !(b1 == b2 or b1.position.x + b1.size.width / 2 < b2.position.x - (b2.size.width / 2) or b1.position.y + b1.size.height / 2 < b2.position.y - (b2.size.height / 2) or b1.position.x - (b1.size.width / 2) > b2.position.x + b2.size.width / 2 or b1.position.y - (b1.size.height / 2) > b2.position.y + b2.size.height / 2)

  drawRect = (screen, body) ->
    screen.fillRect body.position.x, body.position.y, body.size.width, body.size.height
    return

  clearCanvas = (screen, gameSize) ->
    screen.clearRect 0, 0, gameSize.x, gameSize.y
    return

  window.onload = ->
    new Game('screen')
    return

  return
