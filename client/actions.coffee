Template.actionItems.actionItems = () ->
  ActionItems.find(retro_id: Session.get("retro_id"))

Template.actionItems.events(
  'submit #newActionItemForm' : (event, template) ->
    input = event.target.elements[0]
    title = input.value
    retro_id = Session.get("retro_id")
    console.log "insert actionItem with title: #{title} to retro_id: #{retro_id}"
    ActionItems.insert({retro_id:retro_id, title: title})
    input.value=""
    return false
)