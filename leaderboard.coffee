Players = new Meteor.Collection 'players'

reset_data = -> # Executes on both client and server.
  Players.remove {}
  names = [ 'Ada Lovelace',
            'Grace Hopper',
            'Marie Curie',
            'Carl Friedrich Gauss',
            'Nikola Tesla',
            'Claude Shannon',
            'Issac Newton',
          ]
  for name in names
    Players.insert
      name: name
      score: Math.floor(Math.random() * 10) * 5

if Meteor.is_client

  _.extend Template.navbar,
    events:
      'click .sort_by_name': -> Session.set 'sort_by_name', true
      'click .sort_by_score': -> Session.set 'sort_by_name', false
      'click .reset_data': -> reset_data()

  _.extend Template.leaderboard,
    players: ->
      sort = if Session.get('sort_by_name') then name: 1 else score: -1
      Players.find {}, sort: sort

    events:
      'click #add_button, keyup #player_name': (evt) ->
        return if evt.type is 'keyup' and evt.which isnt 13 # Key is not Enter.
        input = $('#player_name')
        if input.val()
          Players.insert
            name: input.val()
            score: Math.floor(Math.random() * 10) * 5
          input.val ''

  _.extend Template.player,
    events:
      'click .increment': -> Players.update @_id, $inc: {score: 5}
      'click .remove': -> Players.remove @_id
      'click': -> $('.tooltip').remove()  # To prevent zombie tooltips.

    enable_tooltips: ->
      # Update tooltips after the template has rendered.
      _.defer -> $('[rel=tooltip]').tooltip()
      ''

# On server startup, create some players if the database is empty.
if Meteor.is_server
  Meteor.startup ->
    reset_data() if Players.find().count() is 0
