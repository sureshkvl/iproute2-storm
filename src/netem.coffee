util = require('util')
extend = require('util')._extend
exec = require('child_process').exec
StormData = require('stormdata')

#Delay
#1.
#  tc qdisc add dev eth0 root netem delay 100ms
#2.
#Real wide area networks show variability so it is possible to add random variation.
#tc qdisc change dev eth0 root netem delay 100ms 10ms
#3.
#This causes the added delay to be 100ms ± 10ms. Network delay variation isn't purely random, so to emulate
# that there is a correlation value as well
# tc qdisc change dev eth0 root netem delay 100ms 10ms 25%
#tc qdisc add dev <interface> root netem delay <delay in ms> <delay variation in ms>  <delay variation correlation %>



#Delay distribution
#1. tc qdisc change dev eth0 root netem delay 100ms 20ms distribution normal


#packet loss
 # tc qdisc change dev eth0 root netem loss 0.1%
 #packetloss co-rrelation
 # tc qdisc change dev eth0 root netem loss 0.3% 25%


 #packet duplication
# tc qdisc change dev eth0 root netem loss 0.3% 25%

 #packet corruption
#tc qdisc change dev eth0 root netem corrupt 0.1% 

 #packet re-ordering
#tc qdisc change dev eth0 root netem gap 5 delay 10ms
#tc qdisc change dev eth0 root netem delay 10ms reorder 25% 50%
#
# tc qdisc change dev eth0 root netem delay 100ms 75ms

# tc qdisc change dev eth0 root netem
#                                       delay
#                                       loss
#	                                    corrupt

#final commands
#reference:
#http://www.linuxfoundation.org/collaborate/workgroups/networking/netem
#  tc qdisc add dev eth0 root handle 1:0 netem delay 100ms
# tc qdisc add dev eth0 parent 1:1 handle 10: tbf rate 256kbit buffer 1600 limit 3000



#delay routine

class netemData extends StormData
    Schema =
        name: "netem"
        type: "object"
        required: true
        properties:
            ifname:  {"type":"string", "required":false}        
            bandwidth:  {"type":"string", "required":false}
            latency:  {"type":"string", "required":false}
            jitter:  {"type":"string", "required":false}
            pktloss:  {"type":"string", "required":false}
            
    constructor: (id, data) ->
        super id, data, Schema


setDelayLoss = (data , callback)->	
	#return callback false unless data instanceof netemData
	ifname =  data.ifname
	latency = data.latency
	distribution = "normal"
	variation = data.jitter
	correlation = "10%"
	loss = data.pktloss
	correlation = "10%"

	command = "tc qdisc add dev #{ifname} root handle 1:0  netem delay #{latency} #{variation} #{correlation} distribution #{distribution} loss #{loss} #{correlation}" 
	util.log "netstats executing #{command}..."
	exec command, (error, stdout, stderr) =>
    	util.log "netstats: execute - Error : " + error if error?
		util.log "netstats: execute - stdout : " + stdout if stdout?
		util.log "netstats: execute - stderr : " + stderr if stderr?
		callback(true)
            
###
setLoss = (data, callback)->
#loss routine
# tc qdisc change dev eth0 root netem loss 0.1%
	#return callback false unless data instanceof netemData
	ifname = data.ifname
	loss = data.pktloss
	correlation = "10%"
	command = "tc qdisc change dev #{ifname} root netem loss #{loss} #{correlation}"
	util.log "netstats executing #{command}..."
	exec command, (error, stdout, stderr) =>
		util.log "netstats: execute - Error : " + error if error?
		util.log "netstats: execute - stdout : " + stdout if stdout?
		util.log "netstats: execute - stderr : " + stderr if stderr?
		callback(true)
###

setBandwidth = (data, callback)->
	#bandwidth routine
	# tc qdisc add dev eth1 root handle 1: cbq avpkt 1000 bandwidth 10Mbit
	#return callback false unless data instanceof netemData
	ifname = data.ifname
	avgpkt = "1000"
	bandwidth = data.bandwidth
	command = "tc qdisc add dev #{ifname} parent 1:1 handle 10: tbf rate  #{bandwidth} buffer 1600 limit 3000"
	# tc qdisc add dev eth0 parent 1:1 handle 10: tbf rate 256kbit buffer 1600 limit 3000
	util.log "netstats executing #{command}..."
	exec command, (error, stdout, stderr) =>
		util.log "netstats: execute - Error : " + error if error?
		util.log "netstats: execute - stdout : " + stdout if stdout?
		util.log "netstats: execute - stderr : " + stderr if stderr?
		callback(true)

#order of execution
#delay,
#loss,
#bandwidth

setLinkChars = (data, callback) ->
	return callback false unless data instanceof netemData
	callback true
	util.log "setLinkChars dat " + JSON.stringify data.data
	setDelayLoss data.data , (result)=>
		util.log "setDelay result" + result
		#setLoss data.data, (result)=>
		#	util.log "setLoss result" + result
		setBandwidth data.data, (result)=>
			util.log "setBandwidth result " + result
	


#ip route add default via 192.168.99.254
addDefaultGw = (gwip, callback) ->
	command = "ip route add default via #{gwip}"
	# tc qdisc add dev eth0 parent 1:1 handle 10: tbf rate 256kbit buffer 1600 limit 3000
	util.log "netstats executing #{command}..."
	exec command, (error, stdout, stderr) =>
		util.log "netstats: execute - Error : " + error if error?
		util.log "netstats: execute - stdout : " + stdout if stdout?
		util.log "netstats: execute - stderr : " + stderr if stderr?
		callback(true)

addStaticRoute = (data, callback)->






module.exports.netemdata =  netemData
module.exports.setLinkChars = setLinkChars
module.exports.adddefaultgw = addDefaultGw


