Template.retroWelcome.rendered = () ->
  $('.drawer').toggleClass('open')

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

Template.retroNav.events(
  'click .delete' : (event, template) ->
    event.preventDefault()
    retro_id = $(event.target).data('id')
    Retros.remove(retro_id)
  'mouseenter .retroRow' : (event, template) ->
    $(event.target).find('i.delete').show()
  'mouseleave .retroRow' : (event, template) ->
    $(event.target).find('i.delete').hide()
)
Template.newRetro.events(
 'submit #newRetroForm' : (event, template) ->
    title = template.find("#newRetroTitle").value
    team_id = Meteor.user().session.current_team_id
    retro_id = Retros.insert({name: title, team_id: team_id, leader_id: Meteor.userId(), create_date: new Date()})
    console.log "look up just created retro"
    console.log Retros.findOne(retro_id)
    $('#newRetroModal').modal("hide")
    Router.go("/retro/#{retro_id}")
)

Template.newActivity.events(
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
    Router.go( "/activity/#{activity_id}" )
    return false
)