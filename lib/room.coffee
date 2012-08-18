{Player} = require './player'
{Game}   = require './game'

createPlayerToken = (i) ->
  return "player token of player No." + i

class Room
  constructor: (index, token) ->
    @index    = index
    @token    = token
    @status   = 0
    @turn     = 1
    @socket   = null
    @player_1 = null
    @player_2 = null
    @game     = null
  players: ->
    i = 0
    i++ if @player_1
    i++ if @player_2
    i
  addPlayer: (player) ->
    if !@player_1
      @player_1 = player
      return
    if !@player_2
      @player_2 = player
  removePlayer: (playerId) ->
    player = null
    if @player_1 && @player_1.id.toString() == playerId
      player = @player_1
      @player_1 = null
    else if @player_2 && @player_2.id.toString() == playerId
      player = @player_2
      @player_2 = null
    player

  checkOut: (playerid, playerToken) ->
    player = @removePlayer playerid
    @status--
    player.socket.emit "checkOut", date: "success"

  checkIn: (playerName, socket) ->
    console.log "checkIn player: " + playerName
    if @status < 2
      playerToken = createPlayerToken @players()
      @addPlayer new Player(@players() + 1, playerName, playerToken, socket)
      @status++
      roomReady = false
      roomReady = true if @status == 2
      data = roomId: @index,roomToken: @token, roomReady: roomReady, playerid: @players(), playerToken: playerToken
      socket.emit("checkIn", data);

    if @status == 2
      @gameStart()

  gameStart: ->
    @player_1.socket.emit 'gameStart', roomId: @index, playerId: 1
    @player_2.socket.emit 'gameStart', roomId: @index, playerId: 2

    socket_1 = @player_1.socket
    socket_2 = @player_2.socket

    @game = new Game

exports.Room = Room