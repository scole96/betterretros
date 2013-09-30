Template.activityNav.activities = () ->
  if this.retro._id
    Activities.find({retro_id:this.retro._id})

Template.activityNav.isActive = (id, id2) ->
  return "active" if id==id2

Template.retro.showActivity = (activity) ->
  template_name = activity.definition.template
  Template[template_name](activity)

Template.retro.events(
  'mouseenter #actionItemsPanel' : (event, template) ->
    if $('#actionItemsPanel').width()<200 and !$('#actionItemsPanel').hasClass("hide")
      $('#actionItemsPanel').removeClass("span2").addClass("span4")
      $('#mainPanel').removeClass("span10").addClass("span8")
  'mouseleave #actionItemsPanel' : (event, template) ->
    if $('#actionItemsPanel').hasClass("span4") and !$('#actionItemsPanel').hasClass("hide")
      $('#actionItemsPanel').removeClass("span4").addClass("span2")
      $('#mainPanel').removeClass("span8").addClass("span10")
  'click #actionItemsExpander': (event, template) ->
    $('#actionItemsExpander').addClass("hide")
    $('#actionItemsPanel').removeClass("hide")
    $('#mainPanel').removeClass("span12").addClass("span8")
    $('#actionItemsPanel').removeClass("span2").addClass("span4")
  'click .toggle-thumb' : (event, template) ->
    event.preventDefault()
    $('.drawer').toggleClass('open')
)

Template.retroNav.canManageRetros = () ->
  team_id = Meteor.user().session.current_team_id
  leader = Teams.findOne(team_id).leader
  return Meteor.userId()==leader

Template.newRetro.events(
 'submit #newRetroForm' : (event, template) ->
    title = template.find("#newRetroTitle").value
    team_id = Meteor.user().session.current_team_id
    retro_id = Retros.insert({name: title, team_id: team_id, leader_id: Meteor.userId(), create_date: new Date()})
    $('#newRetroModal').modal("hide")
    Router.go("/retro/#{retro_id}")
  'click .deleteRetro' : (event, template) ->
    retro_id = $(event.target).data('id')
    Retros.remove(retro_id)
)
