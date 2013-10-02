
# Define Minimongo collections to match server/publish.js.
@Teams = new Meteor.Collection("teams")
@Retros = new Meteor.Collection("retros")
@Activities = new Meteor.Collection("activities")
@ActivityItems = new Meteor.Collection("activityItems")
@ActionItems = new Meteor.Collection("actionItems")

Session.setDefault('retro_id', null)
Session.setDefault('activity_id', null)

Meteor.autosubscribe( () ->
  Meteor.subscribe("teams")
  Meteor.subscribe("userData")
  Meteor.subscribe("allUserData");
)

Deps.autorun(() -> 
  retro_id = Session.get("retro_id")
  if retro_id
    Meteor.subscribe('activities', retro_id)
    Meteor.subscribe('actionItems', retro_id)
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

Handlebars.registerHelper('email', (user) ->
  if user
    getEmail user
)

Handlebars.registerHelper('getCurrentRetroName', () ->
  retro_id = Session.get("retro_id")
  if retro_id
    Retros.findOne(retro_id)?.name
  else
    ""
)
Handlebars.registerHelper('getCurrentActivityName', () ->
  activity_id = Session.get("activity_id")
  if activity_id
    Activities.findOne(activity_id)?.name
  else
    ""
)
Handlebars.registerHelper('isRetroLeader', () ->
  retro_id = Session.get("retro_id")
  if retro_id and Meteor.userId()
    leader = Retros.findOne(retro_id)?.leader_id
    return leader == Meteor.userId()
  false
)

@isRetroLeader = () ->
  retro_id = Session.get("retro_id")
  if retro_id and Meteor.userId()
    leader = Retros.findOne(retro_id)?.leader_id
    return leader == Meteor.userId()
  false

Handlebars.registerHelper('isTeamLeader', (team_id) ->
  if Meteor.userId() and team_id
    return Teams.findOne(team_id).leader == Meteor.userId()
  false
)

Handlebars.registerHelper('getTeamName', (id) ->
  Teams.findOne(id)?.name
)
Handlebars.registerHelper('getUserName', (id) ->
  Meteor.users.findOne(id)?.profile.name
)

Handlebars.registerHelper('inspect', (object) ->
  console.log object
)

Template.inviteRequest.events(
  'submit #emailForm' : (event, template) ->
    email = template.find("#email").value
    Meteor.call("inviteRequest", email)
    FlashMessages.sendSuccess("Thanks for your interest. We'll be in touch soon.")
)


##### Tracking selected list in URL #####
Router.configure
  layout: "layout"
  notFoundTemplate: "notFound"
  loadingTemplate: "loading"


Router.map ->
  @route "teamManagement", path: "/team"
  @route "admin", path: "/admin"
  @route "retro", path: "/retro/:retro_id", controller: "RetroController"
  @route "retro", path: "/activity/:activity_id", controller: "RetroController"
  @route "retro", path: "/", controller: "RetroController"

class @RetroController extends RouteController 
  template: 'retro'
  
  waitOn: ->
    result = []
    if Meteor.user()?.teams?.length>0
      Meteor.subscribe('retros', Meteor.user().teams)
  
  data: -> 
    console.log "in data with retroId: #{@params.retro_id} and activityId: #{@params.activity_id}"
    data = {}
    data.retros = Retros.find({}, sort: {create_date: 0}).fetch()

    retro_id = @params.retro_id
    activity_id = @params.activity_id

    if retro_id
      data.retro = Retros.findOne retro_id
    if activity_id
      data.activity = Activities.findOne activity_id
      data.retro = Retros.findOne data.activity.retro_id


    if !data.retro and data.retros.length >0
      data.retro = data.retros[0]
    else if !data.retro
      console.log "No retro"
    if !data.activity
      data.activity = Activities.findOne( retro_id: data.retro._id)

    console.log data
    Session.set("retro_id", data.retro._id)
    if data.activity
      Session.set("activity_id", data.activity._id)
      
    return data


