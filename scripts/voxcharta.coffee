# Description:
#   Get Vox Charta

cheerio = require('cheerio')

module.exports = (robot) ->
    robot.hear /voxcharta/i, (msg) ->
        msg.http('http://moca.voxcharta.org').get() (error, response, body) ->
            # Load page
            page = cheerio.load(body)
            # Get papers on the agenda
            papers = page('.votemicrotext')
            text = []
            text.push '*Papers on the Journal Club agenda this week:*'
            text.push ''
            # Iterate over papers
            papers.each (elem) ->
                # First entry is title, second entry is voters
                title = page(this).children().first().text()
                link = page(this).children().first().attr('href')
                text.push '-- ' + title
                text.push '   ' + link
                text.push ''
            text.push 'Vote for a paper here: http://moca.voxcharta.org'
            msg.send text.join('\n')
