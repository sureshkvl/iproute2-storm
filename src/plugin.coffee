util = require('util')
extend = require('util')._extend
exec = require('child_process').exec

#This plugin needs cleanup and code refactoring

@include = ->
    agent = @settings.agent
    unless agent?
        throw  new Error "this plugin requires to be running in the context of a valid StormAgent!"

    plugindir = @settings.plugindir
    plugindir ?= "/var/stormflash/plugins/netstats"   

    netemdata = require('./netem').netemdata
    setlinkchars = require('./netem').setLinkChars
    adddefaultgw = require('./netem').adddefaultgw

    getlinkstats = require('./statistics').getlinkstats
    getroutestats = require('./statistics').getroutestats
    
    @post '/linkconfig': ->
        util.log "linkconfig input " + JSON.stringify @body
        try         
            linkdata = new netemdata(null, @body )
        catch err
            util.log "invalid schema" + err
            return @send new Error "Invalid Input "
        finally 
            setlinkchars linkdata, (result)=>
                util.log "setlinkchars result " + result
                @send result

    @post '/defaultgw': ->
        util.log "defaultgw input " + JSON.stringify @body
        adddefaultgw @body.gateway, (result)=>
            @send result

    
    @get '/netstats/link': ->
        getlinkstats (result)=>
            @send result

    @get '/netstats/route': ->
        getroutestats (result)=>
            @send result