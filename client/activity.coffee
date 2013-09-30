
Template.votableColumns.events(
  'click #votingToggle' : (event, template) ->
    Activities.update(@._id, $set:{'voting.enabled': event.target.checked})
  'click #sortToggle' : (event, template) ->
    Activities.update(@._id, $set:{'voting.sortByVotes': event.target.checked})    
)

Template.votableColumns.events(okCancelEvents(
  '#votesEach',
  {
    ok: (value, event) ->
      console.log "save votesEach"
      console.log @._id
      votes = event.target.value
      console.log votes
      Activities.update(@._id, $set:{'definition.votesEach': votes})
    cancel: () ->
      console.log "cancel votesEach"
      event.target.value = $(event.target).data('default')
  }))

Template.votableColumn.items = () ->
  activity_id = Session.get("activity_id")
  activity = Activities.findOne(activity_id)
  items = ActivityItems.find({activity_id: activity_id, type:@.type}).fetch()
  if activity.voting?.sortByVotes
    _.sortBy(items, (item) ->
      -1*item.votes.length
    )
  else
    return items

Template.votableColumn.relatedActivity = () ->
  Activities.findOne(parent_activity_item_id: @._id)?._id

Template.votableColumn.voteIcon = (hasVotesRemaining) ->
  for vote in @.votes
    if vote.user_id == Meteor.userId()
      return "icon-thumbs-up no-vote"
  if getMyVotesRemaining() > 0
    "icon-thumbs-up-alt yes-vote"
  else
    ""

Template.votableColumn.isVoting = () ->
  activity_id = Session.get("activity_id")
  if activity_id
    activity = Activities.findOne(activity_id)
    activity.voting?.enabled

Template.votableColumns.myHasVotesRemaining = () ->
  votes = getMyVotesRemaining()
  return votes > 0

Template.votableColumns.myVotesRemaining = () ->
  return getMyVotesRemaining()

getMyVotesRemaining = () ->
  activity = Activities.findOne(Session.get('activity_id'))
  if activity.votes and activity.votes[Meteor.userId()]
    votes = activity.votes[Meteor.userId()]
    return activity.definition.votesEach - votes
  return activity.definition.votesEach

Template.votableColumns.teamVotesRemaining = () ->
  activity = Activities.findOne(Session.get('activity_id'))
  retro = Retros.findOne(Session.get("retro_id"))
  if retro
    totalVotes = activity.definition.votesEach * retro.active_users.length
    totalVotes = totalVotes - activity.definition.votesEach
    if activity.votes
      voteCount = 0
      for user, votes of activity.votes
        if Meteor.userId()!=user
          voteCount+=votes
      return totalVotes - voteCount
    else
      totalVotes

Template.votableColumn.events(
  'click .newActivityItem' : (event, template) ->
    console.log event.target
    event.preventDefault()
    event.stopPropagation()
    $('#newActivityInput').removeClass("hidden")
  'submit .newActivityItemForm' : (event, template) ->
    input = event.target.elements[0]
    newName = input.value
    activity_id = Session.get("activity_id")
    type = $(input).data('activity-type')
    ActivityItems.insert({activity_id:activity_id, name: newName, type: type, votes: []})
    input.value=""
    return false
  'click .delete-activity' : (event, template) ->
    activity_item_id = $(event.target).data('pk')
    ActivityItems.remove(activity_item_id)
  'click .vote-activity' : (event, template) ->
    icon = $(event.target)
    console.log icon
    activity_item_id = icon.data('pk')
    counter = 1
    if icon.hasClass('yes-vote')
      console.log "voting"
      ActivityItems.update(activity_item_id, {$push:{votes:{date: new Date(), user_id: Meteor.userId()}}})
    else
      console.log "unvoting"
      ActivityItems.update(activity_item_id, $pull: votes: user_id: Meteor.userId())
      counter = -1
    key = 'votes.' + Meteor.userId()
    inc = {$inc: {}}
    inc['$inc'][key] = counter
    Activities.update(Session.get('activity_id'), inc)
  'mouseenter .activityItemRow' : (event, template) ->
    $(event.target).find('span.ai-actions').show()
  'mouseleave .activityItemRow' : (event, template) ->
    $(event.target).find('span.ai-actions').hide()
  'click .delete-activityItem' : (event, template) ->
    id = $(event.target).data('pk')
    ActivityItems.remove(id)
  'click .new-activity' : (event, template) ->
    retro_id = Session.get("retro_id")
    name = $(event.target).data('name')
    activity_item_id = $(event.target).data('pk')
    title = name.slice(0,15)
    $('#newActivityTitle').val(title)
    $('#newActivityParent').val(activity_item_id)
    $('#newActivityModal').modal('show')
  'click .ai-claim' : (event, template) ->
    activity_item_id = $(event.target).data('pk')
    ActivityItems.update(activity_item_id, $set: owner: Meteor.userId())
)

Template.votableColumn.rendered = () ->
  $(this.findAll('.activityItem')).editable( {
    showbuttons: false,
    success: (response, newName) ->
      console.log "edit activity item to: " + newName
      activity_item_id = $(this).data('pk')
      ActivityItems.update(activity_item_id, $set: {name: newName})
  })

Template.votableColumns.rendered = () ->
  $(this.find('#activityName')).editable( {
    showbuttons: false,
    success: (response, newName) ->
      activity_id = $(this).data('pk')
      Activities.update(activity_id, $set: {name: newName})
  })

Template.editActivity.events(    
  'submit #activityForm' : (event, template) ->
    console.log "save edit activity"
    activity_id = Session.get("activity_id")
    if activity_id
      title = template.find("#activityTitle").value
      Activities.update(activity_id, $set: {name: title})
    $('#activityModal').modal('hide')
    return false
)