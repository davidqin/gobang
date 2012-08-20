{Player} = require './player'
{Game}   = require './game'

class Room
  constructor: (id) ->
    @id       = id
    @turn     = 1
    @status   = 0
    @player_1 = null
    @player_2 = null
    @game     = null
    @watchers  = []

  removePerson: (watcher) ->

  playerReady: (player) ->
    player.status = 1
    player.socket.emit "readySuccess"

  roomStatus: ->
    p1_n = null
    p1_n = @player_1.nickname if @player_1
    p2_n = null
    p2_n = @player_2.nickname if @player_2
    p1_s = null
    p1_s = @player_1.status   if @player_1
    p2_s = null
    p2_s = @player_2.status   if @player_2
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

  removePlayer: (playerId) ->
    player = null
    if playerId == '1'
      player       = @player_1
      @player_1    = @player_2
      @player_1.id = 1
      @player_2    = null
    else
      player = @player_2
      @player_2 = null
    player

  checkOut: (playerId) ->
    player = @removePlayer playerId
    player.socket.emit "checkOut", date: "success"

  gameStart: ->
    @turn     = 1
    @status   = 1
    @game     = new Game
    @noticeEveryOne 'gameStart'

exports.Room = Room