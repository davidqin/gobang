express      = require 'express'
http         = require 'http'
routes       = require './routes'
path         = require 'path'
connect      = require('connect')
{Room}       = require './lib/room'
{Player}     = require './lib/player'

app = express()

app.configure ->
  app.set 'port', process.env.PORT || 1234
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()

  app.use app.router
  app.use express.static path.join __dirname, 'public'

app.configure 'development', ->
  app.use express.errorHandler dumpExceptions: true, showStack: true

app.get '/', routes.index
app.get '/game', routes.game

#server = app.listen app.get 'port'
server = http.createServer(app).listen app.get('port'), ->
  console.log "Express server listening on port " + app.get('port')

roomMax      = 5
Rooms        = []

ClientsCount = 0
Connectors   = [] #用户管理

io           = null

#获取用户信息
GetUserInfo = (socketId) ->
  Connectors[socketId].playerInfo()

OnLogin = (data) ->
  #data.nickname
  ret = 0
  socketId = this.id
  player = new Player(data.nickname,    this,      0,     -1,       -1)
                    #(      nickname, socket, status, roomId, position)

  Connectors[socketId] = player
  ClientsCount++


  this.emit "loginSuccess",
    userInfo: GetUserInfo(socketId)
    roomList: getRoomList()

  io.sockets.emit "roomList", roomList: getRoomList()

OnJoinRoom = (data) ->
  #data.roomId
  roomId        = data.roomId
  room          = Rooms[roomId]
  socketId      = this.id
  player        = Connectors[socketId]
  player.roomId = roomId

  position = room.addPerson(player)

  if position == -1
    this.emit "joinRoomFailed"
    return
  else
    this.emit "joinRoomSuccess",
      roomId   : roomId
      userInfo : GetUserInfo(socketId)
      position : position

  io.sockets.emit "roomList", roomList: getRoomList()
  room.reFreshRoomStatus()

OnLeaveRoom = (data) ->
  #null
  socketId      = this.id
  player        = Connectors[socketId]
  room          = Rooms[player.roomId]
  player.roomId = -1

  room.removePerson(player)
  this.emit "leaveRoomSuccess"
  room.reSendPersonList()

OnReady = (data) ->
  #null
  socketId      = this.id
  player        = Connectors[socketId]
  room          = Rooms[player.roomId]

  room.playerReady(player)
  room.reFreshRoomStatus()

  if room.gameReady()
    room.gameStart()
    io.sockets.emit "roomList",   roomList: getRoomList()
    room.noticeEveryOne "noticeTurn", turn: room.turn

OnPutPiece = (data) ->
  #data.x
  #data.y
  socketId      = this.id
  player        = Connectors[socketId]
  room          = Rooms[player.roomId]
  return unless player.position == room.turn
  return unless room.game.gameMap[data.x][data.y] == 0

  room.putPiece(player.position, data.x, data.y)

  if room.game.win player.position
    room.gameOver()
    room.noticeEveryOne "putPiece", x:data.x, y:data.y, position:player.position
    room.noticeEveryOne "gameOver", winner:player.nickname, reason: null
    room.player_1.socket.emit 'resetFunctions'
    room.player_2.socket.emit 'resetFunctions'
    io.sockets.emit "roomList", roomList: getRoomList()
  else
    room.changeTurn()
    room.noticeEveryOne "putPiece", x:data.x, y:data.y, position:player.position
    room.noticeEveryOne "noticeTurn", turn: room.turn

getRoomList = ->
  list = []

  for room in Rooms
    list.push id: room.id, status: room.status
  list

initRooms = (io) ->
  for i in [0...5] #  0 <= i < roomMax
    Rooms[i] = new Room(i)

OnExitRoom = (data) ->
  #null
  socketId      = this.id
  player        = Connectors[socketId]
  room          = Rooms[player.roomId]

  roomStatusBeforeRemove = room.status
  position = room.removePerson(player)
  if room.status == 0 && roomStatusBeforeRemove == 1
    winner = null
    if position == 1
      winner = room.player_2
    else
      winner = room.player_1
    winner.socket.emit 'resetFunctions'
    room.noticeEveryOne "gameOver", winner:winner.nickname, reason: "#{player.nickname} Exit!"

  io.sockets.emit "roomList", roomList: getRoomList()
  room.reFreshRoomStatus()

  player.socket.emit "exitRoomSuccess"

Disconnect = ->
  console.log  "sdfsdfsdfsdfsdfsdfsdfsf"
  socketId      = this.id
  player        = Connectors[socketId]
  return unless player
  room          = Rooms[player.roomId]
  return unless room

  roomStatusBeforeRemove = room.status
  position = room.removePerson(player)
  if room.status == 0 && roomStatusBeforeRemove == 1
    winner = null
    if position == 1
      winner = room.player_2
    else
      winner = room.player_1
    winner.socket.emit 'resetFunctions'
    room.noticeEveryOne "gameOver", winner:winner.nickname, reason: "#{player.nickname} Exit!"

  io.sockets.emit "roomList", roomList: getRoomList()
  room.reFreshRoomStatus()


startServer = ->
  initRooms()
  io = require('socket.io').listen server
  io.sockets.on 'connection', (socket) ->

    socket.on "OnLeaveRoom",      OnLeaveRoom
    socket.on "LoginRequest",     OnLogin
    socket.on "JoinRoomRequest",  OnJoinRoom
    socket.on "ExitRoomRequest",  OnExitRoom
    socket.on "ReadyRequest",     OnReady
    socket.on "PutPieceRequest",  OnPutPiece

    socket.on "disconnect",       Disconnect

startServer()