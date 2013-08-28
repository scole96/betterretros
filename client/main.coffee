
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

