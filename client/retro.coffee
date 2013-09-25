Template.activityTab.activities = () ->
  if this.retro._id
    Activities.find({retro_id:this.retro._id})

Template.activityTab.isActive = (id, id2) ->
  return "active" if id==id2

Template.retros.events(
 'submit #newRetroForm' : (event, template) ->
    title = template.find("#newRetroTitle").value
    team_id = Meteor.user().session.current_team_id
    retro_id = Retros.insert({name: title, team_id: team_id, leader_id: Meteor.userId(), create_date: new Date()})
  'click .deleteRetro' : (event, template) ->
    retro_id = $(event.target).data('id')
    Retros.remove(retro_id)
)
