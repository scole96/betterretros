@InviteRequests = new Meteor.Collection("inviteRequests")
@Invitations = new Meteor.Collection("invitations")

Accounts.onCreateUser((options, user) ->
  console.log "on create user"
  email = getEmail(user)

  invite = Invitations.findOne(email)
  if invite || email == "scole@wgen.net"
    Invitations.update(invite._id, $set: {joined: new Date()})
    return true
  else
    InviteRequests.insert({email:email, date: new Date(), method: "login"})
    throw new Meteor.Error(403, "You must be invited to join BetterRetros. We've put in a request for you. You should hear from us soon.")
  
  if email == 'scole@wgen.net' 
    user['rights'] = {'admin':true, 'leader':true}

  #We still want the default hook's 'profile' behavior.
  if options.profile
    user.profile = options.profile
    names = user.profile.name.split(" ")
    initials = ""
    for name in names
      initials = initials + name[0]
    user.profile.initials = initials
  user.teams = []
  teams = Teams.find({invites: email}).fetch()
  console.log "Found " + teams.length + " teams to add new user to"
  for team in teams
    console.log "Adding user to team:"
    console.log team
    user.teams.push team._id
    Teams.update(team._id, {$pull: {invites: email}})
    console.log "that team is now: "
    console.log team
  console.log "user.teams is: "
  console.log user.teams

  if user.teams.length==0
    console.log "Creating new team for new user"
    team_name = user.profile.name + "'s Team"
    team_id = Teams.insert({name: team_name, leader: user._id})
    user.teams.push  team_id
  else
    team_id = user.teams[0]

  user['session'] = {current_team_id: team_id}
  console.log "New user:"
  console.log user
  return user
)

Meteor.methods (
  inviteRequest: (email) ->
    InviteRequests.insert({email:email, date: new Date(), method: "request"})
  findUserByEmail : (email) ->
    user = Meteor.users.findOne({'services.google.email':email})
    if user
      console.log "Found user: "
      console.log user
      return user._id
    else
      throw new Meteor.Error(404, "User not found")
)

Accounts.loginServiceConfiguration.remove({
    service: "google"
})

profile = Meteor.settings.profile
if profile=="prod"
  console.log "Configuring google for retros.meteor.com"
  Accounts.loginServiceConfiguration.insert({
      service: "google",
      clientId: "357514018484-29gim4t4m5mn3g25j4sig8egkv0b9vm5.apps.googleusercontent.com",
      secret: "EHdEsVSkAXWJQbeYcuxsyu5D"
  })
else
  Accounts.loginServiceConfiguration.insert({
      service: "google",
      clientId: "357514018484-ecc29drjm0vgaebuu4q67grd36il8k3g.apps.googleusercontent.com",
      secret: "n4-T81HiQz_J-bEjHpFEaFlt"
  })
