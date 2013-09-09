Template.actionItems.actionItems = () ->
  ActionItems.find(retro_id: Session.get("retro_id"))

Template.actionItems.events(
  'click #collapse' : (event, template) ->
    $('#actionItemsPanel').toggleClass("hide")
    $('.actionItemsExpander').toggleClass("hide")
    $('#mainPanel').removeClass("span10").removeClass("span8").addClass("span12")
  'click .delete' : (event, template) ->
    _id = $(event.target).data('pk')
    ActionItems.remove(_id)    
  'mouseenter .activityItemRow' : (event, template) ->
    $(event.target).find('span.ai-actions').show()
  'mouseleave .activityItemRow' : (event, template) ->
    $(event.target).find('span.ai-actions').hide()
  'click .claim' : (event, template) ->
    action_id = $(event.target).data('pk')
    ActionItems.update(action_id, $set: owner: {id: Meteor.userId(), name:Meteor.user().profile.name, initials: Meteor.user().profile.initials})
  'submit #newActionItemForm' : (event, template) ->
    input = event.target.elements[0]
    title = input.value
    retro_id = Session.get("retro_id")
    console.log "insert actionItem with title: #{title} to retro_id: #{retro_id}"
    ActionItems.insert({retro_id:retro_id, title: title})
    input.value=""
    return false
)
Template.actionItems.rendered = () ->
  $(this.findAll('.activityItem')).editable( {
    showbuttons: false,
    success: (response, newName) ->
      console.log "edit action item to: " + newName
      _id = $(this).data('pk')
      ActionItems.update(_id, $set: {title: newName})
  })