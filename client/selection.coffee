
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
    if isRetroLeader()
      Teams.update(retro.team_id, $set:current_retro_id:retro_id)
      activity = Activities.find({retro_id:retro_id}, {}, sort: name: 1)
      if activity
        console.log "setting activity to: " + activity._id
        Session.set("activity_id", activity._id)
        Retros.update(retro_id, $set:current_activity_id:activity._id)
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
)

Template.activityTab.activities = () ->
  retro_id = Session.get("retro_id")
  if retro_id
    Activities.find({retro_id:retro_id})

Template.activityTab.isActive = (id) ->
  return "active" if Session.get("activity_id")==id

Template.activityTab.events(
  'click .activityLink' : (event, template) ->
    event.preventDefault()
    activity_id = event.target.dataset.id
    console.log "selected activity: " + activity_id
    if isRetroLeader()
      activity = Activities.findOne(activity_id)
      Retros.update(activity.retro_id, $set:current_activity_id:activity._id)
    Session.set("activity_id", activity_id)
    Session.set("page", "main")
)