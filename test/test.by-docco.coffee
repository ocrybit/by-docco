fs = require('fs')
path = require('path')
async = require('async')
rimraf = require('rimraf')
mkdirp = require('mkdirp')
chai = require('chai')
Bystander = require('bystander')
should = chai.should()
ByDocco = require('../lib/by-docco')
ByCoffeeScript = require('by-coffeescript')
describe('ByDocco', ->
  GOOD_CODE = 'foo = 1'
  BAD_CODE = 'foo ==== 1'
  TMP = "#{__dirname}/tmp"
  FOO = "#{TMP}/foo"
  FOO2 = "#{TMP}/foo2"
  NODIR = "#{TMP}/nodir"
  NOFILE = "#{TMP}/nofile.coffee"
  HOTCOFFEE = "#{TMP}/hot.coffee"
  BLACKCOFFEE = "#{TMP}/black.coffee"
  ICEDCOFFEE = "#{FOO}/iced.coffee"
  ICEDJS = "#{FOO}/iced.js"
  BIN = "#{FOO}/iced.bin.coffee"
  BINJS = "#{FOO}/iced"
  TMP_BASE = path.basename(TMP)
  FOO_BASE = path.basename(FOO)
  FOO2_BASE = path.basename(FOO2)
  NODIR_BASE = path.basename(NODIR)
  NOFILE_BASE = path.basename(NOFILE)
  HOTCOFFEE_BASE = path.basename(HOTCOFFEE)
  BLACKCOFFEE_BASE = path.basename(BLACKCOFFEE)
  ICEDCOFFEE_BASE = path.basename(ICEDCOFFEE)
  LINT_CONFIG = {"no_tabs" : {"level" : "error"}}
  DOCCO_SOURCES = ["#{TMP}/foo/*"]
  MAPPER = {"**/foo/*" : [/\/foo\//,'/foo2/']}
  bystander = new Bystander()
  byDocco = new ByDocco()
  stats = {}
  beforeEach((done) ->
    mkdirp(FOO, (err) ->
      async.forEach(
        [HOTCOFFEE, ICEDCOFFEE],
        (v, callback) ->
          fs.writeFile(v, GOOD_CODE, (err) ->
            async.forEach(
              [FOO, HOTCOFFEE,ICEDCOFFEE,BLACKCOFFEE],
              (v, callback2) ->
                fs.stat(v, (err,stat) ->
                  stats[v] = stat
                  callback2()
                )
              ->
                callback()
            )
          )
        ->
          byDocco = new ByDocco({nolog:true, root: TMP, doccoSources: DOCCO_SOURCES})
          done()
      )
    )
  )

  afterEach((done) ->
    rimraf(TMP, (err) =>
      byDocco.removeAllListeners()
      done()
    )
  )

  describe('constructor', ->
    it('init test', ->
      ByDocco.should.be.a('function')
    )
    it('should instanciate', ->
      byDocco.should.be.a('object')
    )
    it('should set @doccoSources', () ->
      byDocco = new ByDocco()
      byDocco.doccoSources.should.be.empty
      byDocco = new ByDocco({doccoSources : DOCCO_SOURCES})
      byDocco.doccoSources.should.eql(DOCCO_SOURCES)
    )

  )

  describe('_setDoccoSources', ->
    it('should set @doccoSources', ->
      byDocco.doccoSources = []
      byDocco.doccoSources.should.be.empty
      byDocco._setDoccoSources(DOCCO_SOURCES)
      byDocco.doccoSources.should.eql(DOCCO_SOURCES)
    )
  )

  describe('_isDocco', ->
    it('check if a path matches the doccoSources', ->
      byDocco = new ByDocco({doccoSources : DOCCO_SOURCES})
      byDocco._isDocco(HOTCOFFEE).should.not.be.ok
      byDocco._isDocco(ICEDCOFFEE).should.be.ok
    )
  )
  describe('_removeSource', ->
    it('should remove a source from @doccoFiles', () ->
      byDocco.doccoFiles = [ICEDCOFFEE]
      byDocco.doccoFiles.should.include(ICEDCOFFEE)
      byDocco._removeSource(ICEDCOFFEE)
      byDocco.doccoFiles.should.not.include(ICEDCOFFEE)
    )
  )
  describe('document', ->
    it('generate documents', (done) ->
      byDocco = new ByDocco({doccoSources : DOCCO_SOURCES, nolog: true})
      byDocco.cp_docco.on('message', (data) =>
        data.err.should.not.be.ok
        done()
      )
      byDocco.document()
    )
  )
  describe('docco', ->
    it("doesn't proceed if @doccoFiles isn't empty", (done) ->
      byDocco = new ByDocco({doccoSources : DOCCO_SOURCES, nolog: true})
      byDocco.doccoFiles.push(ICEDCOFFEE)
      byDocco.cp_docco.on('message', (data) =>
        data.err.should.be.ok
        done()
      )
      byDocco.docco(ICEDCOFFEE)
      setTimeout(
        () =>
          done()
        1000
      )
    )
  )
  describe('_setDocco', ->
    it('should set a chld process to execute docco.document', () ->
      delete byDocco.cp_docco
      should.not.exist(byDocco.cp_docco)
      byDocco._setDocco()
      byDocco.cp_docco.should.be.a('object')
    )
  )

  describe('_setListeners', (done) ->
    beforeEach(->
      bystander = new Bystander(TMP,{nolog:true, plugins:['by-coffeescript']})
    )

    it('should listen to "compiled" and generate docco documents', (done) ->
      count = 0
      bystander.once('watchset', () ->
        byDocco._setListeners(bystander)
        byDocco.on('docco', (data) ->
            count += 1
            if count is 2
              byDocco.removeAllListeners()
              data.sources.should.eql(DOCCO_SOURCES)
              done()
        )
        fs.utimes(ICEDCOFFEE, Date.now(), Date.now())
      )
      bystander.run()

    )
  )
)