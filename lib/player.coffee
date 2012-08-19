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
    # socket.on("cueBall", function(data) {
    #   console.log(data);
    #   currentPlayer = data.playerid;
    #   toPlayer = currentPlayer === 0 ? players[1] : players[0];
    #   console.log(toPlayer);
    #    toPlayer.emit("cueBall", data);
    #     });
    #     socket.on('disconnect', function () {
    #         //io.sockets.emit('user disconnected');
    #     });

exports.Player = Player