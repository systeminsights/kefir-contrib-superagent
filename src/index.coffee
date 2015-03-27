K = require 'kefir'

noopUnsub = ->

# :: SuperAgent.Response -> Kefir Error Response
#
# Convert a super agent response to a stream. If the response is a server error
# (5XX) it is converted to an `Error` and emitted as a stream error, otherwise
# the response object is emitted as a value.
#
responseToStream = (response) ->
  if response.serverError
    K.constantError(response.toError())
  else
    K.constant(response)

# :: (() -> SuperAgent.Request) -> Kefir Error Response
#
# Create a Kefir stream from a function returning an unsent SuperAgent request.
#
# The request will be sent on activation of the stream. Errors are emitted
# as stream errors and the response (including 5XX and 4XX) as values.
#
fromSuperAgent = (superRequest) ->
  K.fromBinder (emitter) ->
    superRequest() .end (err, res) ->
      if err then emitter.error(err) else emitter.emit(res)
      emitter.end()
    noopUnsub

# :: (() -> SuperAgent.Request) -> Kefir Error Response
#
# Similar to `fromSuperAgent` however if the response is a ServerError (5XX)
# it is converted to an `Error` and emitted as a stream error.
#
catchingServerErrors = (superRequest) ->
  fromSuperAgent(superRequest) .flatMap responseToStream

module.exports = {
  fromSuperAgent,
  catchingServerErrors
}

