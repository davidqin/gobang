
/*
 * GET home page.
 */

exports.index = function(req, res){
  res.render('index', { title: 'Express' });
};

exports.game = function(req, res){
  res.render('game', { title: 'Express' });
};
