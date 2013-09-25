
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
  teams = Meteor.user()?.teams
  if teams and teams.length >0
    Meteor.subscribe('retros', teams)
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

Handlebars.registerHelper('getCurrentActivityName', () ->
  activity_id = Session.get("activity_id")
  if activity_id
    Activities.findOne(activity_id)?.name
  else
    ""
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

Template.retro.events(
  'mouseenter #actionItemsPanel' : (event, template) ->
    if $('#actionItemsPanel').width()<200 and !$('#actionItemsPanel').hasClass("hide")
      $('#actionItemsPanel').removeClass("span2").addClass("span4")
      $('#mainPanel').removeClass("span10").addClass("span8")
  'mouseleave #actionItemsPanel' : (event, template) ->
    if $('#actionItemsPanel').hasClass("span4") and !$('#actionItemsPanel').hasClass("hide")
      $('#actionItemsPanel').removeClass("span4").addClass("span2")
      $('#mainPanel').removeClass("span8").addClass("span10")
  'click .actionItemsExpander': (event, template) ->
    $('.actionItemsExpander').addClass("hide")
    $('#actionItemsPanel').removeClass("hide")
    $('#mainPanel').removeClass("span12").addClass("span8")
    $('#actionItemsPanel').removeClass("span2").addClass("span4")
)

Template.inviteRequest.events(
  'submit #emailForm' : (event, template) ->
    email = template.find("#email").value
    Meteor.call("inviteRequest", email)
    FlashMessages.sendSuccess("Thanks for your interest. We'll be in touch soon.")
)

Template.retro.showActivity = (activity) ->
  template_name = activity.definition.template
  Template[template_name](activity)


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
  @route "retros", path: "/", data: -> retros: Retros.find()
  @route "retros", path: "/retros", data: -> retros: Retros.find {}, sort: {create_date: 0}

class @RetroController extends RouteController 
  template: 'retro'
  
  data: -> 
    console.log "in data with retroId: #{@params.retro_id} and activityId: #{@params.activity_id}"
    data = {}
    retro_id = @params.retro_id
    activity_id = @params.activity_id

    if !retro_id and !activity_id
      data.retro = Retros.findOne()
    else if activity_id
      data.activity = Activities.findOne activity_id
    else if retro_id
      data.retro = Retros.findOne retro_id

    if !data.retro and !data.activity
      console.log "trouble, we got neither retros or activity"
    else if !data.activity
      data.activity = Activities.findOne( retro_id: data.retro._id)
    else if !data.retro
      data.retro = Retros.findOne data.activity.retro_id

    Session.set("retro_id", data.retro._id)
    if data.activity
      Session.set("activity_id", data.activity._id)
    
    return data


