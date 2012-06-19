connect = require 'connect'
express = require 'express'
jade = require 'jade'

app = express.createServer express.logger()

app.configure ->
  app.set 'view engine', 'jade'
  app.set 'views', "#{__dirname}/views"
  app.set 'view options', layout: false
  app.use require('connect-assets')()

app.get '/', (request, response) ->
  response.render 'flock', locals: title: 'Flock'

port = process.env.PORT || 5000;
app.listen port, -> console.log "Listening on #{port}"
