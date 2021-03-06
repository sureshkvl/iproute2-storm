// Generated by CoffeeScript 1.7.1
(function() {
  var exec, extend, util;

  util = require('util');

  extend = require('util')._extend;

  exec = require('child_process').exec;

  this.include = function() {
    var adddefaultgw, agent, getlinkstats, getroutestats, netemdata, plugindir, setlinkchars;
    agent = this.settings.agent;
    if (agent == null) {
      throw new Error("this plugin requires to be running in the context of a valid StormAgent!");
    }
    plugindir = this.settings.plugindir;
    if (plugindir == null) {
      plugindir = "/var/stormflash/plugins/netstats";
    }
    netemdata = require('./netem').netemdata;
    setlinkchars = require('./netem').setLinkChars;
    adddefaultgw = require('./netem').adddefaultgw;
    getlinkstats = require('./statistics').getlinkstats;
    getroutestats = require('./statistics').getroutestats;
    this.post({
      '/linkconfig': function() {
        var err, linkdata;
        util.log("linkconfig input " + JSON.stringify(this.body));
        try {
          return linkdata = new netemdata(null, this.body);
        } catch (_error) {
          err = _error;
          util.log("invalid schema" + err);
          return this.send(new Error("Invalid Input "));
        } finally {
          setlinkchars(linkdata, (function(_this) {
            return function(result) {
              util.log("setlinkchars result " + result);
              return _this.send(result);
            };
          })(this));
        }
      }
    });
    this.post({
      '/defaultgw': function() {
        util.log("defaultgw input " + JSON.stringify(this.body));
        return adddefaultgw(this.body.gateway, (function(_this) {
          return function(result) {
            return _this.send(result);
          };
        })(this));
      }
    });
    this.get({
      '/netstats/link': function() {
        return getlinkstats((function(_this) {
          return function(result) {
            return _this.send(result);
          };
        })(this));
      }
    });
    return this.get({
      '/netstats/route': function() {
        return getroutestats((function(_this) {
          return function(result) {
            return _this.send(result);
          };
        })(this));
      }
    });
  };

}).call(this);
