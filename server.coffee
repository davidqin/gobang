express      = require 'express'
routes       = require './routes'
http         = require 'http'
path         = require 'path'
connect      = require('connect')
#Session      = require('connect').middleware.session.Session
cookie       = require('cookie')
{Room}       = require './lib/room'
{Player}     = require './lib/player'
#sessionStore = new express.session.MemoryStore({reapInterval: 60000 * 10});
app = express()

app.configure ->
  app.set 'port', process.env.PORT || 1234
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()

#  app.use express.cookieParser()
#  app.use express.session(secret: 'davidqhr', key: 'express.sid', store:sessionStore)

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
  #更新客户端链接
  Connectors[socketId] = player
  ClientsCount++

  #登陆成功
  this.emit "loginSuccess",
    #ret     : 1
    userInfo: GetUserInfo(socketId)
    roomList: getRoomList()

  io.sockets.emit "roomList", roomList: getRoomList()

OnJoinRoom = (data) ->
  #data.roomId
  roomId   = data.roomId
  room     = Rooms[roomId]
  socketId = this.id
  player   = Connectors[socketId]
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

OnPutPiece = (data) ->
  #data.x
  #data.y
  socketId      = this.id
  player        = Connectors[socketId]
  room          = Rooms[player.roomId]
  return unless player.position == room.turn
  return unless room.game.gameMap[data.x][data.y] == 0

  room.game.gameMap[data.x][data.y] = player.position
  if room.game.win player.position
    room.noticeEveryOne "putPiece", x:data.x, y:data.y, position:player.position
    room.noticeEveryOne "gameOver", winner:player.nickname
    room.turn = 0
    room.status = 0
    room.player_1.status = 0
    room.player_2.status = 0
    io.sockets.emit "roomList", roomList: getRoomList()
  else
    room.turn = 3 - room.turn
    room.noticeEveryOne "putPiece", x:data.x, y:data.y, position:player.position
getRoomList = ->
  list = []

  for room in Rooms
    list.push id: room.id, status: room.status
  list

initRooms = (io) ->
  for i in [0...5] #  0 <= i < roomMax
    Rooms[i] = new Room(i)

startServer = ->
  initRooms()
  io = require('socket.io').listen server
  io.sockets.on 'connection', (socket) ->

    socket.on "OnLogin",     OnLogin
    socket.on "OnJoinRoom",  OnJoinRoom
    socket.on "OnLeaveRoom", OnLeaveRoom
    socket.on "OnReady",     OnReady
    socket.on "OnPutPiece",  OnPutPiece

startServer()


#断开
# socket.on("disconnect", OnClose);

# #登陆
# socket.on("login", OnLogin);

# #加入房间
# socket.on("joinRoom", OnJoinRoom);

# #离开房间
# socket.on("leaveRoom", OnLeaveRoom);

# #准备
# socket.on("ready", OnReady);

# #消息
# socket.on('message', OnMessage);

# #落子
# socket.on("drawChess", OnDrawChess);



   # script(type="text/coffeescript", src='/javascripts/game.coffee')


# socket.set 'authorization', (data, callback) ->
#   if !data.headers.cookie
#     callback 'nosession', false

#   signedCookies = cookie.parse data.headers.cookie
#   data.cookies  = connect.utils.parseSignedCookies signedCookies, 'davidqhr'
#   #console.log data
#   sessionStore.get data.cookies['express.sid'], (error, session) ->
#     if error || !session
#       callback 'socket.io: no found session.', false

#     data.session = session
#     #console.log session
#     if data.session
#       callback null, true
#     else
#       callback 'socket.io: no found session.user', false
