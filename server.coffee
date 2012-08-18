express      = require 'express'
routes       = require './routes'
http         = require 'http'
path         = require 'path'
io           = require 'socket.io'
connect      = require('connect')
Session      = require('connect').middleware.session.Session
cookie       = require('cookie')
{Room}       = require './lib/room'
sessionStore = new express.session.MemoryStore({reapInterval: 60000 * 10});
app = express()

app.configure ->
  app.set 'port', process.env.PORT || 3001
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()

  app.use express.cookieParser()
  app.use express.session(secret: 'davidqhr', key: 'express.sid', store:sessionStore)

  app.use app.router
  app.use express.static path.join __dirname, 'public'

app.configure 'development', ->
  app.use express.errorHandler dumpExceptions: true, showStack: true

app.get '/', routes.index
app.get '/game', routes.game

#server = app.listen app.get 'port'
server = http.createServer(app).listen app.get('port'), ->
  console.log "Express server listening on port " + app.get('port')

rooms = []
roomMax = 5

roomList = ->
  list = []

  for room in rooms
    list.push id: room.index, status: room.status
  list

createToken = (i) ->
  return "room token of room No." + i

initRooms = (callback) ->
  for i in [0...5] #  0 <= i < roomMax
    token = createToken(i)
    rooms[i] = new Room(i, token)
  callback()

initRooms ->
  io = require('socket.io').listen server
  io.sockets.on 'connection', (socket) ->
    socket.on "roomList", (data) ->
      socket.emit "roomList", roomList: roomList()

    socket.on "checkIn", (data) ->
      roomIndex  = data.roomId
      room       = rooms[roomIndex]
      playerName = data.playerName

      if room.status < 2
        room.checkIn(playerName, socket)

      io.sockets.emit 'roomList', roomList: roomList()

    socket.on "checkOut", (data) ->
      roomIndex   = data.roomId
      room        = rooms[roomIndex]
      playerId    = data.playerId
      playerToken = data.playerToken

      if room.status > 0
        room.checkOut(playerId, playerToken)

      io.sockets.emit 'roomList', roomList: roomList()

    socket.on 'click_info', (data) ->
      roomIndex   = data.roomId
      room        = rooms[roomIndex]
      playerId    = data.playerId
      anotherId   = 3 - playerId

      return if room.turn != playerId
      row = data.row
      col = data.col
      return if room.game.gameMap[row][col] != 0
      room.game.gameMap[row][col] = playerId

      room.turn = anotherId

      color = "#00FF00"
      color = "#0000FF" if playerId == 1

      room.player_1.socket.emit 'click_success', row: row, col: col, color: color
      room.player_2.socket.emit 'click_success', row: row, col: col, color: color

      if room.game.win(playerId)
        winner = null
        loser  = null
        if playerId == 1
          winner = room.player_1
          loser = room.player_2
        else
          winner = room.player_2
          loser = room.player_1
        winner.socket.emit 'win'
        loser.socket.emit 'lose'




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
