@getEmail = (user) ->
  if user.emails
    email = user.emails[0].address
  else if user.services.google
    email = user.services.google.email
  email