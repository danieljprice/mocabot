# Description:
#   Search today's postings on astro-ph

cheerio = require('cheerio')

String::strip = -> if String::trim? then @trim() else @replace /^\s+|\s+$/g, ""

module.exports = (robot) ->
    robot.respond /arxiv (.*)/i, (msg) ->
        text = []
        keyWords = msg.match[1].split(' ')
        text.push "Today's astro-ph postings for: " + keyWords.join(', ')
        text.push ""
        msg.http('https://arxiv.org/list/astro-ph/new').get() (error, response, body) ->
            # Load page
            page = cheerio.load(body)
            # Ignore children function
            page.fn.ignore = (sel) ->
                @clone().find(sel or '>*').remove().end()
            # Get papers on the agenda
            papers = page('span.list-identifier')
            gotNone = true
            papers.each (elem) ->
                # Scrape text
                listing     = page(this).parent()
                url         = 'https://arxiv.org' + listing.children('span.list-identifier').children('a').first().attr('href')
                title       = listing.next().children('div.meta').children('div.list-title').ignore('span').text()
                authors     = listing.next().children('div.meta').children('div.list-authors').ignore('span').text()
                abstract    = listing.next().children('div.meta').children('p').text()
                searchText  = title + abstract
                # Check if keywords in text
                inText = (word) ->
                    searchText.includes(word)
                if keyWords.every(inText)
                    gotNone = false
                    text.push '*' + title.strip() + '*'
                    text.push '_' + authors.strip().replace(/(\r\n|\n|\r)/gm,"") + '_'
                    text.push abstract.strip().replace(/(\r\n|\n|\r)/gm," ")
                    text.push url.strip()
                    text.push ''
            if gotNone
                text.push "Nothing found :'("
            msg.send text.join('\n')
