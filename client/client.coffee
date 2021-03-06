Session.set 'team_id', null

Meteor.startup -> 
  
  # this will resubscribe when:
  #  a) current_user_id changes
  #  b) me changes
  Meteor.autosubscribe ->
    current_user_id = Session.get('current_user_id')
    me = Players.findOne(current_user_id)
    team_ids = (me.attributes.team_ids if me) || []
    
    # finds all players in team_ids _and_ me
    Meteor.subscribe 'players', team_ids, current_user_id
    Meteor.subscribe 'teams', current_user_id
    Meteor.subscribe 'games', team_ids
    
  
current_user = -> 
  Players.findOne(Session.get('current_user_id'))
  
current_team = ->
  Teams.findOne(Session.get 'team_id')
  
current_players = -> current_team().players() if current_team()
future_games = -> current_team().future_games().fetch() if current_team()


# Overlays are done in a more JQ way because otherwise I'll need to change a
# class on the body, which would require re-drawing the whole page.. which would
# be bad
open_overlays = -> 
  Session.set('show_overlays', true)
  $('body').addClass('overlays_open')

close_overlays = ->
  Session.set('show_overlays', false)
  $('body').removeClass('overlays_open')

show_overlays = -> Session.equals('show_overlays', true)

show_team_status = (team) ->
  open_overlays()
  Session.set('team_status_team_id', team.id)
team_status_team = ->
  Teams.findOne(Session.get 'team_status_team_id')