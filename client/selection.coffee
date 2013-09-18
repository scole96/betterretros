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
    # eyes on me
    # if isRetroLeader()
    #   Teams.update(retro.team_id, $set:current_retro_id:retro_id)
    #   activity = Activities.find({retro_id:retro_id}, {}, sort: name: 1)
    #   if activity
    #     console.log "setting activity to: " + activity._id
    #     Session.set("activity_id", activity._id)
    #     Retros.update(retro_id, $set:current_activity_id:activity._id)
  'submit #newRetroForm' : (event, template) ->
    title = template.find("#newRetroTitle").value
    team_id = Meteor.user().session.current_team_id
    retro_id = Retros.insert({name: title, team_id: team_id, leader_id: Meteor.userId(), create_date: new Date()})    
    team = Teams.findOne(team_id)
    team.current_retro_id = retro_id
    $('#newRetroModal').modal('hide')
    Router.go( Router.path("retro", {retro_id: retro_id, activity_id: null}))
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
    parent = Session.get("new-activity")?.parent
    activity_id = Activities.insert({retro_id:retro_id, name: title, definition: definition, parent_activity_item_id: parent, create_date: new Date()})
    Retros.update(retro_id, $set:current_activity_id:activity_id)
    $('#newActivityModal').modal('hide')
    Router.go( Router.path("retro", {retro_id: retro_id, activity_id: activity_id}))
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


    # eyes on me
    # activity_id = event.target.dataset.id
    # console.log "selected activity: " + activity_id
    # if isRetroLeader()
    #   activity = Activities.findOne(activity_id)
    #   Retros.update(activity.retro_id, $set:current_activity_id:activity._id)
    # Session.set("activity_id", activity_id)