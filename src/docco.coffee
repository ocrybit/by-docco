# * Listen to messages from a parent and generate docco documents
# * This script should be forked by the main process

docco = require('docco')
process.on('message',(data)=>
  docco.document(data.sources, data.options, (err) =>
      if err
        process.send({err: true, sources: data.sources})
      else
        process.send({err: false, sources: data.sources})
  )
)
