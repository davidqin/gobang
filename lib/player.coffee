class Player
  constructor: (nickname, socket, status, roomId, position) ->
    @nickname = nickname
    @socket   = socket
    @status   = status
    @roomId   = roomId
    @position = position

  playerInfo: ->
    "socketId" : @socket.id
    "nickname" : @nickname,
    "status"   : @status
    "roomId"   : @roomId
    "position" : @position

  resetInfo: ->
    @status   = 0
    @status   = -1
    @position = 0
    null

exports.Player = Player