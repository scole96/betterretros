##### Helpers for in-place editing #####

# Returns an event map that handles the "escape" and "return" keys and
# "blur" events on a text input (given by selector) and interprets them
# as "ok" or "cancel".
@okCancelEvents = (selector, callbacks) -> 
  ok = callbacks.ok || () -> 
  cancel = callbacks.cancel || () -> 
  events = {}
  events['keyup '+selector+', keydown '+selector+', focusout '+selector] = (evt) -> 
    if (evt.type == "keydown" && evt.which == 27) 
      # escape = cancel
      console.log "cancel event"
      cancel.call(this, evt)
    else if evt.type == "keyup" and evt.which == 13 or evt.type == "focusout"
      # blur/return/enter = ok/submit if non-empty
      value = String(evt.target.value || "")
      console.log "keyup for: " + value
      if (value)
        ok.call(this, value, evt)
      else
        cancel.call(this, evt)
  return events

@activateInput = (input) ->
  input.focus()
  input.select()

Meteor.startup(() ->
  $.fn.editable.defaults.mode = 'inline';
)
