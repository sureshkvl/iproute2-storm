util = require('util')
extend = require('util')._extend
exec = require('child_process').exec

getlinkstats = (callback)->
	command = "ip -s link"
	util.log "netstats executing #{command}..."
	exec command, (error, stdout, stderr) =>
		util.log "netstats: execute - Error : " + error
		util.log "netstats: execute - stdout : " + stdout
		util.log "netstats: execute - stderr : " + stderr
		String output = stdout.toString()
		tmparr = []
		tmparr = output.split "\n"            
		util.log "tmparr " + tmparr
		for i in tmparr
			util.log "i value " + i
		result = []
		ob = {}
		count = 1

		for i in tmparr
			tmpvars = [] 
			tmpvars = i.split(/[ ]+/)
			if count == 1       
				util.log "inside count 1 " + tmpvars          
				ob["interface"] = tmpvars[1]
				ob["status"]  = tmpvars[2]
				ob["mtu"] = tmpvars[4]
				ob["qdisc"] = tmpvars[6]
				ob["state"] = tmpvars[8]
				ob["mode"] = tmpvars[10]
				ob["group"] = tmpvars[12]
			else if count == 2
				util.log "inside count2 " + tmpvars
				ob["link"] = tmpvars[1]
				ob["brd"] = tmpvars[3]
			else if count == 4
				util.log "inside count4 "  + tmpvars
				ob["rxbytes"] = tmpvars[1]
				ob["rxpackets"] = tmpvars[2]
				ob["rxerror"] = tmpvars[3]
				ob["rxdropped"] = tmpvars[4]
				ob["rxoverrun"] = tmpvars[5]
				ob["rxmcast"] = tmpvars[6]
			else if count == 6
				util.log "inside count6 " + tmpvars
				ob["txbytes"] = tmpvars[1]
				ob["txpackets"] = tmpvars[2]
				ob["txerrors"] = tmpvars[3]
				ob["txdropped"] = tmpvars[4]
				ob["txcarrier"] = tmpvars[5]
				ob["txcollisions"] = tmpvars[6]
				result.push ob
				ob = {}
				count = 0
			else
				util.log "unknoiwn " + tmpvars
			count++
			util.log "count value is " + count			
			callback result

getroutestats = (callback)->
	command = "ip -s route"
	util.log "netstats executing #{command}..."
	exec command, (error, stdout, stderr) =>
		util.log "netstats: execute - Error : " + error
		util.log "netstats: execute - stdout : " + stdout
		util.log "netstats: execute - stderr : " + stderr
		String output = stdout.toString()
		tmparr = []
		tmparr = output.split "\n"            
		util.log "tmparr " + tmparr
		for i in tmparr
			util.log "i value " + i
		result = []
            
		count = 1

		for i in tmparr
			tmpvars = [] 
			tmpvars = i.split(/[ ]+/)
			count = 0
			ob = {}

			for vars in tmpvars
				util.log " count #{count} vars is #{vars} tmpvars - count #{tmpvars[count]} - value #{tmpvars[count+1]}"
				if count == 0
					util.log "destinametion takeing"
					ob["destination"] = tmpvars[count]
				else
					if vars is "via"                            
						ob["via"] = tmpvars[count+1]
						util.log "via"
					if vars is "dev"
						ob["dev"] = tmpvars[count+1]
						util.log "dev"
					if vars is "proto"
						ob["proto"] = tmpvars[count+1]
						util.log "proto"
					if vars is "scope"
						ob["scope"] = tmpvars[count+1]
						util.log "scope"
					if vars is "src"
						ob["src"] = tmpvars[count+1]
						util.log "src"
					if vars is "metric"
						ob["metric"] = tmpvars[count+1]
						util.log "metric"                    
			count++
			result.push ob
		callback result


module.exports.getlinkstats = getlinkstats
module.exports.getroutestats = getroutestats


