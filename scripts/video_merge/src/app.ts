type FilePath = string
interface VideoHash {
	path: FilePath,
	first: Buffer,
	last: Buffer,
}

import * as fs from 'fs'
const util = require('util')
const exec = util.promisify(require('child_process').exec)

const path = require('path')
const vidsPath = 'vids/001'
const bmpHeaderSize = 138

async function imageToRaw(bmpImg: FilePath): Promise<Buffer> {
	const imgSize = 100
	await exec(`convert ${bmpImg} -resize ${imgSize} ${bmpImg}`)
	let rawImage = await fs.promises.readFile(bmpImg)

	// rawImage = rawImage.slice(offset, rawImage.length)
	return rawImage
}


async function getHashes(vidPath: FilePath): Promise<VideoHash> {
	const firstFramePath = `${vidPath}_first.bmp`
	const lastFramePath = `${vidPath}_last.bmp`
	await exec(`ffmpeg -i ${vidPath} -vframes 1 ${firstFramePath}`)
	await exec(`ffmpeg -sseof -3 -i ${vidPath} -update 1 ${lastFramePath}`)
	const result = {
		path: vidPath,
		first: await imageToRaw(firstFramePath),
		last: await imageToRaw(lastFramePath),
	}
	await fs.promises.unlink(firstFramePath)
	await fs.promises.unlink(lastFramePath)
	return result
}

function getMatchScore(hashA: Buffer, hashB: Buffer): number {
	let score = 0

	for (let i = bmpHeaderSize; i < hashA.length; i++) {
		score += Math.abs(hashA[i] - hashB[i])
	}
	const maxDifference = 255 * (hashA.length - bmpHeaderSize)
	score = 1 - (score / maxDifference)
	return score
}

interface VideoMatch {
	input: FilePath,
	matchScore: number,
	matchVideo: FilePath,
}
// compare first frame of hash with all last frame of hashes
function getBestMatch(hashIn: VideoHash, hashes: VideoHash[]): VideoMatch {
	let bestMatch = 0
	let bestVid = ''
	for (const hash of hashes) {
		if (hash.path == hashIn.path) continue
		let matchScore = getMatchScore(hashIn.first, hash.last)
		if (matchScore > bestMatch) {
			bestMatch = matchScore
			bestVid = hash.path
		}
	}
	return { input: hashIn.path, matchVideo: bestVid, matchScore: bestMatch }
}

function matchesToOrderedList(matches: VideoMatch[]): FilePath[] {
	let first = matches.sort((a, b) => a.matchScore - b.matchScore)[0]
	let paths = [first.input]

	while (paths.length < matches.length) {
		let current = matches.find((match, i) => i != 0 && match.matchVideo == paths[paths.length - 1])
		if (!current) {
			console.log('missed', matches.length - paths.length)
			return paths
		}
		paths.push(current.input)
	}
	return paths
}

(async () => {

	let paths: FilePath[] = fs.readdirSync(vidsPath)
	paths = paths.map((vid) => path.join(vidsPath, vid))
	paths = paths.filter((path) => !path.includes('.bmp'))

	console.log('number of vids', paths.length)
	let hashes: VideoHash[] = await Promise.all(paths.map(getHashes))
	let matches: VideoMatch[] = hashes.map((hash) => getBestMatch(hash, hashes))
	console.log(matches.sort((a, b) => a.matchScore - b.matchScore))
	let videosOrdered = matchesToOrderedList(matches)
	console.log(videosOrdered)
	let forFfmpeg = videosOrdered.map((path) => `file './${path}'\n`)
	fs.writeFileSync('results.txt', forFfmpeg.join(''))
	await exec(`ffmpeg -y -f concat -safe 0 -i results.txt -c copy output.wmv`)
})()

// convert source.jpg -colorspace Gray destination.jpg
