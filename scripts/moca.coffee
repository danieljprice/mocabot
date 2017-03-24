# Description:
#   A start on some basic MoCA customisation 
#
# Notes:
#   they are pretty basic at the moment, please improve by reading the scripting documentation at:
#   https://github.com/github/hubot/blob/master/docs/scripting.md

module.exports = (robot) ->

   robot.hear /Michael Morgan/i, (res) ->
     res.send "Hail, Dear Leader"

   robot.hear /astro/i, (res) ->
     res.send "We love Astronomy!"

   coffeeReplies = ['I feel the need for caffeine...', 'I love the smell of coffee in the morning', 'Count me in', 'Caffeine me up!', 'Can we have tea?', 'Yahoo!!']

   robot.hear /coffee time/i, (res) ->
     res.send res.random coffeeReplies

   robot.hear /journal club/i, (res) ->
     res.send "I want pizza"
