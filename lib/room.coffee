{Player} = require './player'
{Game}   = require './game'

class Room
  constructor: (id) ->
    @id       = id
    @turn     = 1
    @socket   = null
    @player_1 = null
    @player_2 = null
    @game     = null
    @watchers  = []
    #when a player enter a room ,he is considered as a person.
    #                            he is considered as a player when he join the game.
  addWatcher: (watcher) ->
    @watchers.push watcher

  removePerson: (watcher) ->

  reSendPersonList: ->

  addPerson: (person) ->
    if 0 <= room.players() < 2
      userInfo = room.addPlayer(player)
    else
      userInfo = room.addWatcher(player)

  players: ->
    i = 0
    i++ if @player_1 != null
    i++ if @player_2 != null
    i
  removePlayer: (playerId) ->
    player = null
    console.log playerId
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

  checkIn: (playerName, socket) ->
    console.log "checkIn player: " + playerName
    if !@player_1
      @player_1 = new Player(1, playerName, socket)
    else
      @player_2 = new Player(2, playerName, socket)

    socket.emit "checkIn", roomId: @index, playerId: @players()

    if @players() == 2
      @gameStart()

  gameStart: ->
    @turn     = 1
    @player_1.socket.emit 'gameStart', roomId: @index, playerId: 1
    @player_2.socket.emit 'gameStart', roomId: @index, playerId: 2

    socket_1 = @player_1.socket
    socket_2 = @player_2.socket

    @game = new Game

exports.Room = Room