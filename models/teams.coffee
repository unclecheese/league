Teams = new Meteor.Collection 'teams'
# { name: "Tom's Fault", players_required: 5, player_ids: [...] }

class Team extends Model
  @_collection: Teams
  constructor: (attrs) ->
    super(attrs)
    @attributes.player_ids ||= []
  
  valid: ->
    @errors = {}
    
    # Obviously we'd prefer rails style class-level validators
    unless @attributes.name? and @attributes.name != ''
      @errors.name = 'must not be empty'
    
    unless @attributes.players_required? and parseInt(@attributes.players_required) > 0
      @errors.players_required = 'must be a positive number'
    
    unless @players().length > 0
      @errors.players  = 'must not be empty'
    
    _.isEmpty(@errors)
  
  # many-many association. TODO: generalize this I guess
  players: ->
    Players.find({_id: {$in: @attributes.player_ids}}).map (player_attrs) ->
      new Player(player_attrs)
  
  add_player: (player) ->
    # add player to this
    player.save() unless player.persisted()
    @update_attribute('player_ids', _.union(@attributes.player_ids, [player.id]))
    
    # add this to player
    player.update_attribute('team_ids', _.union(player.attributes.team_ids, [@id]))
    
    this
  
  remove_player: (player) ->
    # remove player from this
    @update_attribute('player_ids', _.without(@attributes, player.id))
    
    # remote this from player
    player.update_attribute('team_ids', _.without(player.attributes.team_ids, @id))
    
    this
  
  create_game: (attributes) ->
    @save() unless @persisted()
    
    attributes.team_id = this.id
    Game.create(attributes)