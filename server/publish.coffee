@Teams = new Meteor.Collection("teams")
Meteor.publish('teams', () -> 
  Teams.find()
)

@Retros = new Meteor.Collection("retros")
Meteor.publish('retros', () -> 
  user = Meteor.users.findOne(this.userId)
  if user?.session?.current_team_id
    Retros.find({team_id: user.session.current_team_id})
)

@ActionItems = new Meteor.Collection("actionItems")
Meteor.publish('actionItems', (retro_id) ->
  ActionItems.find({retro_id: retro_id})
)

@Activities = new Meteor.Collection("activities")
Meteor.publish('activities', (retro_id) ->
  this.onStop( () ->
    console.log "Activities onStop"
    console.log this.userId
  )
  this.session?.socket.on("close", () ->
    console.log "Activities socket close"
    console.log Meteor.userId()
    Retros.update(retro._id, $pull:active_users:Meteor.userId())
  )
  console.log "publish activities for retro: " + retro_id
  console.log "user: " + this.userId
  Retros.update(retro_id, $addToSet:active_users:this.userId)
  Activities.find({retro_id: retro_id})
)

@ActivityItems = new Meteor.Collection("activityItems")
Meteor.publish('activityItems', (retro_id, activity_id) ->
  ActivityItems.find({activity_id: activity_id})
)

Meteor.publish('allUserData', () ->
  Meteor.users.find({}, {fields:{'teams':1, 'profile':1, 'services.google.email':1}})
)

Meteor.publish("userData", () ->
  Meteor.users.find({_id: this.userId}, {fields: {'rights': 1, 'session':1, 'teams':1, 'services.google.email':1}})
)


###
Security
###
Teams.allow(
  insert: (user_id, retro) ->
    return true
  update: (user_id, retro, fieldnames, modifier) ->
    #Owner, collaborator
    #return retro.user_id == user_id or _.some(retro.collaborators, (user) -> user == user_id)
    return true
  remove: (user_id, doc) ->
    #Owner or admin
    return retro.user_id == user_id or Meteor.user().rights.admin? == true
)

Retros.allow(
  insert: (user_id, retro) ->
    return true
  update: (user_id, retro, fieldnames, modifier) ->
    #Owner, collaborator
    #return retro.user_id == user_id or _.some(retro.collaborators, (user) -> user == user_id)
    return true
  remove: (user_id, retro) ->
    #Owner or admin
    return retro.user_id == user_id or Meteor.user().rights.admin? == true
)

Activities.allow(
  insert: (user_id, activity) ->
    #retro = Retros.findOne(activity.retro_id)
    #return retro.user_id == user_id or _.some(retro.collaborators, (user) -> user == user_id)
    return true
  update: (user_id, activity, fieldnames, modifier) ->
    #retro = Retros.findOne(activity.retro_id)
    #return retro.user_id == user_id or _.some(retro.collaborators, (user) -> user == user_id)
    return true;
  remove: (user_id, doc) ->
    #Only admins can remove rights
    return Meteor.user().rights.admin? == true
)

Meteor.users.allow(
  update: (userId, modifier) ->
    #if Meteor.user.rights.admin
     # return true
    return true
)