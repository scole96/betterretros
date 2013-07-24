
# Define Minimongo collections to match server/publish.js.
@Teams = new Meteor.Collection("teams")
@Retros = new Meteor.Collection("retros")
@Activities = new Meteor.Collection("activities")
@ActivityItems = new Meteor.Collection("activityItems")

Session.setDefault('retro_id', null)
Session.setDefault('activity_id', null)
Session.setDefault("page", "main")

Meteor.autosubscribe( () ->
  Meteor.subscribe("teams")
  #Meteor.subscribe("users")
  Meteor.subscribe("userData")
  Meteor.subscribe("allUserData");
)
Deps.autorun(() ->
  if Meteor.user()
    console.log "got a user"
    current_team_id = Meteor.user()?.session?.current_team_id
    if current_team_id
      console.log "got a team"
      team = Teams.findOne(current_team_id)
      if team.current_retro_id
        Session.set('retro_id', team.current_retro_id)
        retro = Retros.findOne(team.current_retro_id)
        if retro and retro.current_activity_id
          Session.set('activity_id', retro.current_activity_id)
)

Deps.autorun(() -> 
  teams = Meteor.user()?.teams
  if teams and teams.length >0
    Meteor.subscribe('retros', teams)
)  

Deps.autorun(() -> 
  retro_id = Session.get("retro_id")
  if retro_id
    Meteor.subscribe('activities', retro_id)
)  

Deps.autorun(() -> 
  activity_id = Session.get("activity_id")
  retro_id = Session.get("retro_id")
  if activity_id
    Meteor.subscribe('activityItems', retro_id, activity_id)

)

Handlebars.registerHelper('formatDate', (date, format) ->
  date = moment(date)
  date.format(format)
)

Handlebars.registerHelper('email', () ->
  if Meteor.user()
    if Meteor.user().emails
      return Meteor.user().emails[0].address
    else if Meteor.user().services and Meteor.user().services.google
      return Meteor.user().services.google.email
  return ""
)

Handlebars.registerHelper('getCurrentRetroName', () ->
  retro_id = Session.get("retro_id")
  if retro_id
    Retros.findOne(retro_id)?.name
  else
    ""
)
Handlebars.registerHelper('isRetroLeader', () ->
  retro_id = Session.get("retro_id")
  if retro_id and Meteor.userId()
    leader = Retros.findOne(retro_id)?.leader_id
    return leader == Meteor.userId()
  else 
    current_team_id = Meteor.user()?.session?.current_team_id
    if current_team_id
      team = Teams.findOne(current_team_id)
      if team and Meteor.userId() == team.leader
        return true
  false
)

Handlebars.registerHelper('getCurrentActivityName', () ->
  activity_id = Session.get("activity_id")
  if activity_id
    Activities.findOne(activity_id)?.name
  else
    ""
)

Handlebars.registerHelper('getUserName', (id) ->
  Meteor.users.findOne(id)?.profile.initials
)

Handlebars.registerHelper('isSpecial', () ->
  email = Meteor.user()?.services?.google?.email
  return email and email=="scole@wgen.net"
)

Handlebars.registerHelper('inspect', (object) ->
  console.log object
)
@definitions = {
  'plusesDeltas': {
    title: 'Pluses and Deltas',
    template: 'votableColumns',
    columnClass: 'span6',
    hasVotableColumn: true,
    votesEach: 3,
    columns: [
      {title:'Pluses',type:1, spawnable: true},
      {title:'Deltas', type:2, spawnable: true}]
  },
  'plusesDeltasKudos': {
    title: 'Pluses, Deltas, Kudos',
    template: 'votableColumns',
    columnClass: 'span4',
    hasVotableColumn: true,
    votesEach: 3,
    columns: [
      {title:'Pluses',type:1, spawnable: true},
      {title:'Deltas', type:2, spawnable: true},
      {title:'Kudos', type:3, spawnable: true}]
  },
  'madsSadsGlads': {
    title: 'Glads, Sads, Mads',
    template: 'votableColumns',
    columnClass: 'span4',
    hasVotableColumn: true,
    votesEach: 3,
    columns: [
      {title:'Glads',type:1, spawnable: true},
      {title:'Sads', type:2, spawnable: true},
      {title:'Mads', type:3, spawnable: true}]
  },
  'fiveWhys': {
    title: 'Five Whys',
    template: 'votableColumns',
    columnClass: 'span6',
    hasVotableColumn: false,
    columns: [
      {title:'Why, Why, Why?', type:1, spawnable: false}]
  },
  'rootCause': {
    title: 'Root Cause Analysis'
    template: 'votableColumns',
    columnClass: 'span6',
    hasVotableColumn: true,
    votesEach: 3,
    columns: [
      {title:'Root Cause Analysis', type:1, spawnable: false},
      {title:'Action Items', type:2, claimable: true, spawnable: false}]
  }
}

Template.main_body.main = (data) ->
  requested_page = Session.get("page")
  console.log "Changing page to: " + requested_page
  # if Meteor.user() == null && requested_page!="register" && requested_page!="forgotPassword"
  #   logger.warn "No user, redirecting to the login page"
  #   Session.set("current_page", "login")
  Template[requested_page](Session.get("data"))

Template.selection.retros = () ->
  teams = Meteor.user()?.teams
  if teams
    team_id = teams[0]
    if team_id
      Retros.find({team_id: team_id})

Template.selection.currentRetroName = () ->
  retro_id = Session.get("retro_id")
  if retro_id
    "Retrospective: " + Retros.findOne(retro_id)?.name
  else
    "Select Retrospective"

Template.selection.activities = () ->
  retro_id = Session.get("retro_id")
  if retro_id
    Activities.find({retro_id:retro_id})

Template.selection.currentActivity = () ->
  activity_id = Session.get("activity_id")
  if activity_id
    "Activity: " + Activities.findOne(activity_id)?.name
  else
    "Select Activity"

Template.selection.activity = () ->
  activity_id = Session.get("activity_id")
  if activity_id
    Activities.findOne(activity_id)

Template.selection.events(
  'click .retroLink' : (event, template) ->
    retro_id = event.target.dataset.id
    console.log "selected retro: " + retro_id
    Session.set("retro_id", retro_id)
    retro = Retros.findOne(retro_id)
    Teams.update(retro.team_id, $set:current_retro_id:retro_id)
    activity = Activities.find({retro_id:retro_id}, {}, sort: name: 1)
    if activity
      console.log "setting activity to: " + activity._id
      Session.set("activity_id", activity._id)
      Retros.update(retro_id, $set:current_activity_id:activity._id)
    Session.set("page", "main")
  'click .activityLink' : (event, template) ->
    activity_id = event.target.dataset.id
    console.log "selected activity: " + activity_id
    Session.set("activity_id", activity_id)
    activity = Activities.findOne(activity_id)
    Retros.update(activity.retro_id, $set:current_activity_id:activity._id)
    Session.set("page", "main")
  'submit #newRetroForm' : (event, template) ->
    title = template.find("#newRetroTitle").value
    team_id = Meteor.user().session.current_team_id
    retro_id = Retros.insert({name: title, team_id: team_id, leader_id: Meteor.userId(), create_date: new Date()})
    Session.set("retro_id", retro_id)
    Session.set("activity_id", null)
    team = Teams.findOne(team_id)
    team.current_retro_id = retro_id
    $('#newRetroModal').modal('hide')
    return false
  'submit #retroForm' : (event, template) ->
    title = template.find("#retroTitle").value
    retro_id = Session.get("retro_id")
    Retros.update(retro_id, $set: {name: title})
    $('#retroModal').modal('hide')
    return false
  'submit #newActivityForm' : (event, template) ->
    console.log "save new activity"
    retro_id = Session.get("retro_id")
    title = template.find("#newActivityTitle").value
    type = template.find("#newActivityType").value
    definition = definitions[type]
    activity_id = Activities.insert({retro_id:retro_id, name: title, definition: definition, create_date: new Date()})
    Retros.update(retro_id, $set:current_activity_id:activity_id)
    Session.set("activity_id", activity_id)
    $('#newActivityModal').modal('hide')
    Session.set("page", "main")
    return false
  'submit #activityForm' : (event, template) ->
    console.log "save edit activity"
    activity_id = Session.get("activity_id")
    if activity_id
      title = template.find("#activityTitle").value
      Activities.update(activity_id, $set: {name: title})
    $('#activityModal').modal('hide')
    return false
  'click #startNewRetro' : (event, template) ->
    title = "New Retrospective"
    team_id = Meteor.user().session.current_team_id
    retro_id = Retros.insert({name: title, team_id: team_id, leader_id: Meteor.userId(), create_date: new Date()})
    Teams.update(team_id, $set:current_retro_id:retro_id)
    Session.set("retro_id", retro_id)
    Session.set("activity_id", null)
    #Session.set("page", "startRetro")
)
Template.active_users.getActiveUsers = () ->
  retro_id = Session.get("retro_id")
  retro = Retros.findOne(retro_id)
  if retro and retro.active_users
    Meteor.users.find(_id: $in: retro.active_users).fetch()
    

Template.startRetro.retro = () ->
  retro_id = Session.get("retro_id")
  retro = Retros.findOne(retro_id)

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

Template.main.ShowActivity = (data) ->
  template_name = data.definition.template
  Template[template_name](data)

Template.main.activity = () ->
  activity_id = Session.get("activity_id")
  if activity_id
    Activities.findOne(activity_id)

Template.votableColumns.events(
  'click #votingToggle' : (event, template) ->
    Activities.update(@._id, $set:{'voting.enabled': event.target.checked})
  'click #sortToggle' : (event, template) ->
    Activities.update(@._id, $set:{'voting.sortByVotes': event.target.checked})    
)

Template.votableColumns.events(okCancelEvents(
  '#votesEach',
  {
    ok: (value, event) ->
      console.log "save votesEach"
      console.log @._id
      votes = event.target.value
      console.log votes
      Activities.update(@._id, $set:{'definition.votesEach': votes})
    cancel: () ->
      console.log "cancel votesEach"
      event.target.value = $(event.target).data('default')
  }))

Template.votableColumn.items = () ->
  activity_id = Session.get("activity_id")
  activity = Activities.findOne(activity_id)
  items = ActivityItems.find({activity_id: activity_id, type:@.type}).fetch()
  if activity.voting?.sortByVotes
    _.sortBy(items, (item) ->
      -1*item.votes.length
    )
  else
    return items

Template.votableColumn.relatedActivity = () ->
  Activities.findOne(parent_activity_item_id: @._id)?._id

Template.votableColumn.voteIcon = (hasVotesRemaining) ->
  for vote in @.votes
    if vote.user_id == Meteor.userId()
      return "icon-thumbs-up no-vote"
  if getMyVotesRemaining() > 0
    "icon-thumbs-up-alt yes-vote"
  else
    ""

Template.votableColumn.isVoting = () ->
  activity_id = Session.get("activity_id")
  if activity_id
    activity = Activities.findOne(activity_id)
    activity.voting?.enabled

Template.votableColumns.myHasVotesRemaining = () ->
  votes = getMyVotesRemaining()
  return votes > 0

Template.votableColumns.myVotesRemaining = () ->
  return getMyVotesRemaining()

getMyVotesRemaining = () ->
  activity = Activities.findOne(Session.get('activity_id'))
  if activity.votes and activity.votes[Meteor.userId()]
    votes = activity.votes[Meteor.userId()]
    return activity.definition.votesEach - votes
  return activity.definition.votesEach

Template.votableColumns.teamVotesRemaining = () ->
  activity = Activities.findOne(Session.get('activity_id'))
  retro = Retros.findOne(Session.get("retro_id"))
  if retro
    totalVotes = activity.definition.votesEach * retro.active_users.length
    totalVotes = totalVotes - activity.definition.votesEach
    if activity.votes
      voteCount = 0
      for user, votes of activity.votes
        if Meteor.userId()!=user
          voteCount+=votes
      return totalVotes - voteCount
    else
      totalVotes

Template.votableColumn.events(
  'click .newActivityItem' : (event, template) ->
    console.log event.target
    event.preventDefault()
    event.stopPropagation()
    $('#newActivityInput').removeClass("hidden")
  'submit .newActivityItemForm' : (event, template) ->
    input = event.target.elements[0]
    newName = input.value
    activity_id = Session.get("activity_id")
    type = $(input).data('activity-type')
    ActivityItems.insert({activity_id:activity_id, name: newName, type: type, votes: []})
    input.value=""
    return false
  'click .delete-activity' : (event, template) ->
    activity_item_id = $(event.target).data('pk')
    ActivityItems.remove(activity_item_id)
  'click .vote-activity' : (event, template) ->
    icon = $(event.target)
    console.log icon
    activity_item_id = icon.data('pk')
    counter = 1
    if icon.hasClass('yes-vote')
      console.log "voting"
      ActivityItems.update(activity_item_id, {$push:{votes:{date: new Date(), user_id: Meteor.userId()}}})
    else
      console.log "unvoting"
      ActivityItems.update(activity_item_id, $pull: votes: user_id: Meteor.userId())
      counter = -1
    key = 'votes.' + Meteor.userId()
    inc = {$inc: {}}
    inc['$inc'][key] = counter
    Activities.update(Session.get('activity_id'), inc)
  'mouseenter .activityItemRow' : (event, template) ->
    $(event.target).find('span.ai-actions').show()
  'mouseleave .activityItemRow' : (event, template) ->
    $(event.target).find('span.ai-actions').hide()
  'click .delete-activityItem' : (event, template) ->
    id = $(event.target).data('pk')
    ActivityItems.remove(id)
  'click .new-activity' : (event, template) ->
    retro_id = Session.get("retro_id")
    name = $(event.target).data('name')
    activity_item_id = $(event.target).data('pk')
    title = "Root Cause for: " + name
    def = definitions['rootCause']
    activity_id = Activities.insert({retro_id:retro_id, name: title, definition: def, parent_activity_item_id: activity_item_id, create_date: new Date()})
    Retros.update(retro_id, $set:current_activity_id:activity_id)
    Session.set("activity_id", activity_id)
  'click .open-activity' : (event, template) ->
    retro_id = Session.get("retro_id")
    activity_id = $(event.target).data('pk')
    console.log "switch to activity: " + activity_id
    Retros.update(retro_id, $set:current_activity_id:activity_id)
    Session.set("activity_id", activity_id)
  'click .ai-claim' : (event, template) ->
    activity_item_id = $(event.target).data('pk')
    ActivityItems.update(activity_item_id, $set: owner: Meteor.userId())
)

Template.votableColumn.rendered = () ->
  $(this.findAll('.activityItem')).editable( {
    showbuttons: false,
    success: (response, newName) ->
      console.log "edit activity item to: " + newName
      activity_item_id = $(this).data('pk')
      ActivityItems.update(activity_item_id, $set: {name: newName})
  })

##### Tracking selected list in URL #####

RetrosRouter = Backbone.Router.extend(
  routes: 
    "retro/:retro_id":  "retro"
    "retro/:retro_id/activity/:activity_id": "activity"
  retro: (retro_id) -> 
    Session.set("retro_id", retro_id)
    Session.set("activity_id", null)
  activity: (retro_id, activity_id) ->
    Session.set("retro_id", retro_id)
    Session.set("activity_id", activity_id)
)

@Router = new RetrosRouter()

Meteor.startup () -> 
  Backbone.history.start(pushState: true)

