const execSync = require('child_process').execSync
const fs = require('fs')
let saved = []
while (true) {
	let out = execSync('nmcli -c no --get-values ssid,mode,security,rsn-flags,chan,rate device wifi')
	out = out.toString().split('\n')
	let wifis = out.map((line) => {
		const [ssid, mode, security, rsnFlags, chan, rate] = line.split(':')
		return {
			ssid, mode, security, rsnFlags, chan, rate
		}
	})
	let change = false
	for (const wifi of wifis) {
		if (!saved.find((save) => save.ssid == wifi.ssid)) {
			change = true
			saved.push(wifi)
		}
	}
	if (change) {
		fs.writeFileSync('out.json', JSON.stringify(saved))
	}
}
