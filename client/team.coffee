
Template.active_users.getActiveUsers = () ->
  retro_id = Session.get("retro_id")
  retro = Retros.findOne(retro_id)
  if retro and retro.active_users
    Meteor.users.find(_id: $in: retro.active_users).fetch()
    
Template.team.current = () ->
  current_team_id = Meteor.user()?.session?.current_team_id
  Teams.findOne(current_team_id)

Template.team.userHasMultipleTeams = () ->
  Meteor.user()?.teams?.length > 1

Template.team.isOwner = () ->
  this.leader == Meteor.userId()

Template.team.isCurrentTeamId = (id) ->
  current = Meteor.user()?.session?.current_team_id
  if current == id
      return "checked"
  return ""

Template.team.usersTeams = () ->
  teams = Meteor.user()?.teams
  console.log "teams: " + teams
  if teams
    Teams.find({_id: {$in:teams}})

Template.team.teamToEdit = () ->
  team_id = Meteor.user().session.current_team_id
  Teams.findOne(team_id)

Template.team.events (
 'click #createTeam' : (event, template) ->
    team_id = Teams.insert({name: "My Team", leader: Meteor.userId()})
    Meteor.users.update(Meteor.userId(), {$set:{'session.current_team_id': team_id}, $push: {teams: team_id}})
    Session.set("page", "teamManagement")
    Session.set("retro_id", null)
    Session.set("activity_id", null)
  'click #editTeam' : (event, template) ->
    Session.set("page", "teamManagement")
    Session.set("retro_id", null)
    Session.set("activity_id", null)
  'click .teamRadio' : (event, template) ->
    team_id = event.target.getAttribute('data-teamId')
    team_name = event.target.getAttribute('data-teamName')
    Meteor.users.update(Meteor.userId(), $set: {"session.current_team_id": team_id})
    Session.set("retro_id", null)
    Session.set("activity_id", null)
)

Template.teamManagement.current = () ->
  current_team_id = Meteor.user()?.session?.current_team_id
  Teams.findOne(current_team_id)

Template.teamManagement.teamMembers = () ->
  team_id = this._id
  users = Meteor.users.find({teams: team_id})
  console.log "loading teamMembers"
  console.log users.count()
  console.log users.fetch()
  return users

Template.teamManagement.events (
  'submit #addMember' : (event, template) ->
    email = template.find("#newMember").value
    console.log "new member: " + email
    team_id = Meteor.user().session.current_team_id
    console.log "team_id: " + team_id
    Meteor.call('findUserByEmail', email, (err, user_id) ->
      console.log "findUserByEmail results:"
      console.log err
      console.log user_id
      if user_id
        Meteor.users.update(user_id, $push: {teams:team_id})
      else
        Teams.update(team_id, $push: {invites: email})
    )
    return false
)

Template.teamManagement.rendered = () ->
  $(this.find('#teamName')).editable( {
    showbuttons: false,
    success: (response, newName) ->
      console.log "edit team name to: " + newName
      team_id = $(this).data('pk')
      Teams.update(team_id, $set: {name: newName})
  })
