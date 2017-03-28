# Description:
#   A start on some basic MoCA customisation
#
# Notes:
#   they are pretty basic at the moment, please improve by reading the scripting documentation at:
#   https://github.com/github/hubot/blob/master/docs/scripting.md

module.exports = (robot) ->

   robot.hear /astro/i, (res) ->
     res.send "We love Astronomy!"

   coffeeReplies = ['I feel the need for caffeine...', 'I love the smell of caffeine in the morning', 'Count me in', 'Caffeine me up!', 'Can we have tea?', 'I have been waiting all morning for this']

   robot.hear /coffee time/i, (res) ->
     res.send res.random coffeeReplies

   robot.hear /journal club/i, (res) ->
     res.send "I want pizza"

   robot.hear /pizza/i, (res) ->
     res.send "Did somebody mention pizza?"

   robot.hear /seminar/i, (res) ->
     res.send "Did somebody mention free lunch?"

   robot.hear /email/i, (res) ->
     res.send "We don't use email anymore!"
