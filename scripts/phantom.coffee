# Description:
#   PhantomSPH

module.exports = (robot) ->
   robot.hear /is phantom broken/i, (msg) ->
      msg.http('http://users.monash.edu.au/~dprice/phantom/nightly/').get() (error, response, body) ->
         text = []
         failcount = (body.match(/FAILED/g) || []).length
         if failcount > 5
            text.push "Yep. It's a total disaster! :fearful:"
         else if failcount > 0
            text.push "Yep."
         else
            text.push "Nope."
         if failcount > 0
            text.push "http://users.monash.edu.au/~dprice/phantom/nightly/"
         msg.send text.join('\n')
