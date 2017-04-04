# Description:
#   Search today's postings on astro-ph

parser = require('parse-rss')

module.exports = (robot) ->
    robot.respond /arxiv (.*)/i, (msg) ->
        keyWords = msg.match[1].split(' ')
        url = 'http://export.arxiv.org/rss/astro-ph'
        parser url, (err,rss)->
            text = []
            text.push "Today's astro-ph postings for: " + keyWords.join(', ')
            text.push ""
            gotNone = true
            for i, paper of rss
                title = paper['title']
                link = paper['link']
                description = paper['description'].replace(/<(?:.|\n)*?>/gm, '')

                searchText = (title + description).toLowerCase()
                inText = (word) ->
                    searchText.includes(word.toLowerCase())

                if keyWords.every(inText)
                    text.push '*' + title + '*'
                    text.push link
                    text.push description
                    gotNone = false
            if gotNone
                text.push "Nothing found :'("
            msg.send text.join('\n')
