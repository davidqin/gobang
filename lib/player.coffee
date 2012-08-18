class Player
  constructor: (id, name, token, socket) ->
    @id     = id
    @name   = name
    @token  = token
    @socket = socket
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