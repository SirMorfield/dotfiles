const fs = require('fs')
const compressedPath = 'films_compressed'
const originalPath = 'films_original'
const deliveryPath = 'films_delivery'


const staging = !process.argv[2]
console.log(staging ? 'STAGING' : 'REAL')

function renameSyncSafe(oldPath, newPath) {
	newPath = newPath.replace(/\/*$/, '')
	if (newPath.includes('/')) {
		const dirsToCreate = newPath.split('/').slice(0, -1).join('/')
		if (!fs.existsSync(dirsToCreate))
			console.log('making  \t', dirsToCreate)
		if (!staging && !fs.existsSync(dirsToCreate))
			fs.mkdirSync(dirsToCreate, { recursive: true })
	}
	if (!staging)
		fs.renameSync(oldPath, newPath)
}

function walk(dir) {
	let results = []
	let list = fs.readdirSync(dir)
	for (let file of list) {
		file = dir + '/' + file
		let stat = fs.statSync(file)
		if (stat && stat.isDirectory()) // Recurse into a subdirectory
			results = results.concat(walk(file))
		else // Is a file
			results.push(file);
	}
	return results
}

function getSmallest(path1, path2) {
	if (!fs.existsSync(path1))
		return fs.existsSync(path2) ? path2 : null
	if (!fs.existsSync(path2))
		return fs.existsSync(path1) ? path1 : null
	const size1 = (fs.statSync(path1)).size
	const size2 = (fs.statSync(path2)).size
	return size1 < size2 ? path1 : path2
}

let filmsOriginal = walk(originalPath)
filmsOriginal = filmsOriginal.filter((filePath) => !filePath.split('/').at(-1).startsWith('.'))

for (const originalFilmPath of filmsOriginal) {
	const compressedFilmPath = originalFilmPath.replace(originalPath, compressedPath)
	const smallest = getSmallest(originalFilmPath, compressedFilmPath)
	if (smallest) {
		let newPath = smallest.split('/').slice(1)
		newPath.unshift(deliveryPath)
		newPath = newPath.join('/')

		renameSyncSafe(smallest, newPath)
		console.log('renaming\t', smallest, '-->', newPath)
	}
}
