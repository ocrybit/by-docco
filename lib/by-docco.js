// Generated by CoffeeScript 1.3.3
(function() {
  var ByDocco, EventEmitter, colors, cp, minimatch, path,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  path = require('path');

  cp = require('child_process');

  minimatch = require('minimatch');

  EventEmitter = require('events').EventEmitter;

  colors = require('colors');

  module.exports = ByDocco = (function(_super) {

    __extends(ByDocco, _super);

    function ByDocco(opts) {
      this.opts = opts != null ? opts : {};
      this.doccoFiles = [];
      this.doccoSources = [];
      this._setDoccoSources(this.opts.doccoSources);
      this.doccoOptions = {
        css: this.opts.doccoCSS,
        output: this.opts.doccoOutput,
        template: this.opts.doccoTemplate
      };
      this._setDocco();
    }

    ByDocco.prototype._setListeners = function(bystander) {
      var _this = this;
      this.bystander = bystander;
      this.bystander.by.coffeescript.on('compiled', function(data) {
        if (_this.doccoFiles.length !== 0) {
          return _this._removeSource(data.file);
        } else {
          return _this.docco(data.file);
        }
      });
      this.bystander.by.coffeescript.on('nofile', function(data) {
        if (_this.doccoFiles.length !== 0) {
          return _this._removeSource(data.file);
        }
      });
      this.bystander.by.coffeescript.on('compile error', function(data) {
        if (_this.docgen.doccoFiles.length !== 0) {
          return _this._removeSource(data.file);
        }
      });
      return this.bystander.on('File found', function(file) {
        if (_this._isDocco(file) && path.extname(file) === '.coffee' && !_this.bystander.by.coffeescript._isNoCompile(file)) {
          return _this.doccoFiles.push(file);
        }
      });
    };

    ByDocco.prototype._setDoccoSources = function(sources) {
      var v, _i, _len, _results;
      if (sources != null) {
        _results = [];
        for (_i = 0, _len = sources.length; _i < _len; _i++) {
          v = sources[_i];
          _results.push(this.doccoSources.push(path.resolve(v)));
        }
        return _results;
      }
    };

    ByDocco.prototype._setDocco = function() {
      var _this = this;
      this.cp_docco = cp.fork(__dirname + '/docco');
      this.cp_docco.on('message', function(data) {
        if (data.err) {
          if (!_this.opts.nolog) {
            console.log('Docco: something went wrong!\n'.red);
          }
        } else {
          if (!_this.opts.nolog) {
            console.log('Docco: documents successfully generated!\n'.green);
          }
        }
        return _this.emit('docco', data);
      });
      return this.cp_docco.on('error', function(err) {
        console.log('Docco: something went wrong!\n'.red);
        return _this._setDocco();
      });
    };

    ByDocco.prototype._isDocco = function(filepath) {
      var v, _i, _len, _ref;
      if (this.doccoSources != null) {
        _ref = this.doccoSources;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          v = _ref[_i];
          if (minimatch(filepath, v, {
            dot: true
          })) {
            return this.doccoSources;
            break;
          }
        }
        return false;
      } else {
        return false;
      }
    };

    ByDocco.prototype._removeSource = function(file) {
      var v;
      this.doccoFiles = (function() {
        var _i, _len, _ref, _results;
        _ref = this.doccoFiles;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          v = _ref[_i];
          if (v !== file) {
            _results.push(v);
          }
        }
        return _results;
      }).call(this);
      if (this.doccoFiles.length === 0) {
        return this.document();
      }
    };

    ByDocco.prototype.docco = function(filename) {
      if ((this.doccoSources != null) && this.doccoFiles.length === 0 && (filename != null) && this._isDocco(filename)) {
        return this.document();
      }
    };

    ByDocco.prototype.document = function() {
      var _this = this;
      return setTimeout(function() {
        return _this.cp_docco.send({
          sources: _this.doccoSources,
          options: _this.doccoOptions
        });
      }, 500);
    };

    return ByDocco;

  })(EventEmitter);

}).call(this);
