
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
    getEmail Meteor.user()
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
  console.log "isRetroLeader: #{retro_id} and user: #{Meteor.userId()}"
  if retro_id and Meteor.userId()
    leader = Retros.findOne(retro_id)?.leader_id
    return leader == Meteor.userId()
  false
)

isRetroLeader = () ->
  retro_id = Session.get("retro_id")
  console.log "isRetroLeader: #{retro_id} and user: #{Meteor.userId()}"
  if retro_id and Meteor.userId()
    leader = Retros.findOne(retro_id)?.leader_id
    return leader == Meteor.userId()
  false

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

Handlebars.registerHelper('inspect', (object) ->
  console.log object
)

Template.main_body.main = (data) ->
  requested_page = Session.get("page")
  console.log "Changing page to: " + requested_page
  # if Meteor.user() == null && requested_page!="register" && requested_page!="forgotPassword"
  #   logger.warn "No user, redirecting to the login page"
  #   Session.set("current_page", "login")
  Template[requested_page](Session.get("data"))

Template.inviteRequest.events(
  'submit #emailForm' : (event, template) ->
    email = template.find("#email").value
    Meteor.call("inviteRequest", email)
    Meteor.Messages.sendSuccess("Thanks for your interest. We'll be in touch soon.")
)

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

