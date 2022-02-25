const fs = require('fs')
const path = require('path')
const child_process_exec = require('util').promisify(require('child_process').exec)


const dryRun = false
const inputDir = path.join(__dirname, 'dirl/')
const workers = 4

async function onFile({ fullPath, file }) {
	if (!file.match(/\.rar$/))
		return
	const saveDir = path.join('', `${file.replace(/.rar/, '')}/`)
	await exec(`mkdir -p "${saveDir}"`)
	await exec(`unrar x -r "${fullPath}" "${saveDir}"`)
}

async function exec(cmd) {
	console.log(cmd)
	if (!dryRun) {
		try {
			await child_process_exec(cmd)
		} catch (err) {
			console.error(err)
		}
	}
}

let files = fs.readdirSync(inputDir)
function getNewFile() {
	for (let i = 0; i < files.length; i++) {
		if (files[i]) {
			const ret = files[i]
			files[i] = null
			return ret
		}
	}
	return null
}

async function worker(cmd) {
	const file = getNewFile()
	if (!file) return
	const fullPath = path.join(inputDir, file)
	await cmd({ fullPath, file })
	worker(cmd)
}

for (let i = 0; i < workers; i++) {
	worker(onFile)
}
