@InviteRequests = new Meteor.Collection("inviteRequests")
@Invitations = new Meteor.Collection("invitations")

Accounts.onCreateUser((options, user) ->
  console.log "on create user"
  email = getEmail(user)

  invite = Invitations.findOne(email)
  teams = Teams.find({invites: email}).fetch()
  if invite
    Invitations.update(invite._id, $set: {joined: new Date()})

    # InviteRequests.insert({email:email, date: new Date(), method: "login"})
    # throw new Meteor.Error(403, "You must be invited to join BetterRetros. We've put in a request for you. You should hear from us soon.")

  #We still want the default hook's 'profile' behavior.
  if options.profile
    user.profile = options.profile
    names = user.profile.name.split(" ")
    initials = ""
    for name in names
      initials = initials + name[0]
    user.profile.initials = initials
  user.teams = []

  console.log "Found " + teams.length + " teams to add new user to"
  for team in teams
    console.log "Adding user to team: #{team.name} with id: #{team._id}"
    user.teams.push team._id
    Teams.update(team._id, {$pull: {invites: email}})

  if user.teams.length==0
    console.log "Creating new team for new user"
    team_name = user.profile.name + "'s Team"
    team_id = Teams.insert({name: team_name, leader: user._id, create_date: new Date()})
    user.teams.push team_id
  else
    team_id = user.teams[0]


  user.session = {current_team_id: team_id}

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

if Meteor.settings.google
  console.log "Configuring google auth based on settings file"
  Accounts.loginServiceConfiguration.insert({
      service: "google",
      clientId: Meteor.settings.google.clientId
      secret: Meteor.settings.google.secret
  })
else
  Accounts.loginServiceConfiguration.insert({
      service: "google",
      clientId: "357514018484-ecc29drjm0vgaebuu4q67grd36il8k3g.apps.googleusercontent.com",
      secret: "n4-T81HiQz_J-bEjHpFEaFlt"
  })
