# Description:
#   Get Vox Charta

cheerio = require('cheerio')

module.exports = (robot) ->
    robot.listen /voxcharta/i, (msg) ->
        msg.http('http://moca.voxcharta.org').get() (error, response, body) ->
            # Load page
            page = cheerio.load(body)
            # Get papers on the agenda
            papers = page('.votemicrotext')
            text = []
            text.push '*Papers on the discussion agenda this week:*'
            text.push ''
            # Iterate over papers
            papers.each (elem) ->
                # First entry is title, second entry is voters
                title = page(this).children().first().text()
                link = page(this).children().first().attr('href')
                text.push '-- ' + title
                text.push link
                text.push ''
            details = page('.disc-details p')
            details.each (elem) ->
                text.push page(this).text()
            msg.send text.join('\n')
