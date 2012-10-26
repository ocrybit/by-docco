path = require('path')
cp = require('child_process')
minimatch = require('minimatch')
EventEmitter = require('events').EventEmitter
colors = require('colors')
module.exports = class ByDocco extends EventEmitter

  constructor: (@opts = {}) ->
    @doccoFiles = []
    @doccoSources = []
    @_setDoccoSources(@opts.doccoSources)
    @doccoOptions = {
      css: @opts.doccoCSS,
      output: @opts.doccoOutput,
      template: @opts.doccoTemplate
    }
    @_setDocco()
  _setListeners: (@bystander) ->
    @bystander.by.coffeescript.on('compiled', (data) =>
      if @doccoFiles.length isnt 0
        @_removeSource(data.file)
      else
        @docco(data.file)
    )
    @bystander.by.coffeescript.on('nofile', (data) =>
      if @doccoFiles.length isnt 0
        @_removeSource(data.file)
    )
    @bystander.by.coffeescript.on('compile error', (data) =>
      if @docgen.doccoFiles.length isnt 0
        @_removeSource(data.file)
    )
    @bystander.on('File found', (file) =>
      if @_isDocco(file) and path.extname(file) is '.coffee' and not @bystander.by.coffeescript._isNoCompile(file)
        # in case of coffee files, don't process any file until the initial rush is over, we process when @doccoFiles.length has counted down to 0
        @doccoFiles.push(file)
    )

  # #### Set sources for docco
  # `sources (Array)` : a list of sources
  _setDoccoSources: (sources) ->
    if sources?
      for v in sources
        @doccoSources.push(path.resolve(v))

  # #### Set a child process for docco operations
  _setDocco: () ->
    @cp_docco = cp.fork(__dirname + '/docco')
    @cp_docco.on('message', (data) =>
      if data.err
        unless @opts.nolog
          console.log('Docco: something went wrong!\n'.red)
      else
        unless @opts.nolog
          console.log('Docco: documents successfully generated!\n'.green)
      @emit('docco', data)
    )
    @cp_docco.on('error', (err) =>
      console.log('Docco: something went wrong!\n'.red)
      @_setDocco()
    )

  # #### See if the file should be a source of docco document
  # `filepath (String)` : a path to a file to check
  _isDocco: (filepath) ->
    if @doccoSources?
      for v in @doccoSources
        if minimatch(filepath, v, {dot:true})
          return @doccoSources
          break
      return false
    else
      return false

  # #### take off a file from @doccoFiles`
  _removeSource: (file) ->
    @doccoFiles = (v for v in @doccoFiles when v isnt file)
    if @doccoFiles.length is 0
      @document()

  # #### See if there is a need for docco generation
  # `filename (String)` : a path to the file to check
  docco: (filename) ->
    if @doccoSources? and @doccoFiles.length is 0 and filename? and @_isDocco(filename)
      @document()

  # #### Generate docco documents via a child process
  document: () ->
    # Allow a bit of time before generating docco docs. Auto-saved files such as '.#foo.coffee' will cause an error. These files are likely to be cleared instantly, and docco seems to list up these files, but fails to open them because those files are already gone by the time docco can open them. So don't let docco list up instantly disappearing files by giving it 500ms.
    setTimeout(
      =>
        @cp_docco.send({sources: @doccoSources, options: @doccoOptions})
      500
    )
    