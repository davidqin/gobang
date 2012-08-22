{Player} = require './player'
{Game}   = require './game'

class Room
  constructor: (id) ->
    @id        = id
    @turn      = 0
    @status    = 0
    @player_1  = null
    @player_2  = null
    @game      = null
    @watchers  = []

  removePerson: (player) ->
    if @status == 1
      if player == @player_1
        @player_1 = null

      if player == @player_2
        @player_2 = null

      position = player.position
      player.resetInfo()
      @gameOver()
      return position
    else
      if player == @player_1
        @player_1 = null
        player.resetInfo()
        return 1

      if player == @player_2
        @player_2 = null
        player.resetInfo()
        return 2

  playerReady: (player) ->
    player.status = 1
    player.socket.emit "readySuccess"

  roomStatus: ->
    p1_n = p2_n = p1_s = p2_s = null

    if @player_1
      p1_n = @player_1.nickname
      p1_s = @player_1.status
    if @player_2
      p2_n = @player_2.nickname
      p2_s = @player_2.status

    status =
      p1_name   : p1_n
      p2_name   : p2_n
      p1_status : p1_s
      p2_status : p2_s
      game      : @game
      turn      : @turn

  reFreshRoomStatus: ->
    @noticeEveryOne "roomStatus", @roomStatus()

  gameReady: ->
    return false unless @player_2 && @player_1
    @player_2.status == 1 && @player_1.status == 1

  noticeEveryOne: (actionName,json) ->
    @player_1.socket.emit actionName, json if @player_1
    @player_2.socket.emit actionName, json if @player_2

    for watcher in @watchers
      watcher.socket.emit actionName, json

  addPlayer: (player) ->
    if @player_1 == null
      @player_1 = player
      return 1
    else if @player_2 == null
      @player_2 = player
      return 2
    -1

  addWatcher: (watcher) ->
    @watchers.push watcher
    return 0

  addPerson: (player) ->
    if 0 <= @players() < 2
      position = @addPlayer(player)
    else
      position = @addWatcher(player)

    return position if position == -1
    player.position = position
    player.roomId   = @id
    position

  players: ->
    i = 0
    i++ if @player_1 != null
    i++ if @player_2 != null
    i

  gameStart: ->
    @turn     = 1
    @status   = 1
    @game     = new Game
    @noticeEveryOne 'gameStart'

  gameOver: ->
    @turn            = 0
    @status          = 0
    @player_1.status = 0 if @player_1
    @player_2.status = 0 if @player_2

  changeTurn: ->
    @turn = 3 - @turn

  putPiece: (position, x, y)->
    @game.gameMap[x][y] = position

exports.Room = Room