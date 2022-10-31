// This script renames all the files in the ./projects folder to a standard format

import fs from 'fs'
import path from 'path'

const descriptionFile = 'description.json'
enum FileType {
	UnparsedPhoto,
	UnparsablePhoto,
	DisplayPhotom,
	ProcessPhoto,
	DescriptionFile,
	InvalidFile,
}

function identifyFile(filepath: string): FileType {
	filepath = path.basename(filepath)
	if (filepath.match(/^\d\d\d\d-?\d\d-?\d\d(\d|\.|\ |_)+\.(png|jpg|svg)$/))
		return FileType.UnparsedPhoto
	if (filepath.match(/^display_\d\d_\d\d\d\d-?\d\d-?\d\d\.(png|jpg|svg)$/))
		return FileType.DisplayPhotom
	if (filepath.match(/^process_\d\d_\d\d\d\d-?\d\d-?\d\d\.(png|jpg|svg)$/))
		return FileType.ProcessPhoto

	if (!filepath.match(/^.+\.(png|jpg|svg)$/))
		return FileType.UnparsablePhoto
	if (filepath === descriptionFile)
		return FileType.DescriptionFile
	return FileType.InvalidFile
}

// returns year of the project
function normalizeName(filepath: string, index: number) {
	const fileType: FileType = identifyFile(filepath)
	if (fileType === FileType.ProcessPhoto || fileType === FileType.DisplayPhotom)
		return

	const file: string = path.basename(filepath)

	// get all digits in the string
	const digits = file.split('').filter(c => c.match(/\d/)).join('')

	// extract the date from the digits
	const newName = `f${index.toString().padStart(2, '0')}-${digits.substring(0, 4)}-${digits.substring(4, 6)}-${digits.substring(6, 8)}${path.extname(file)}`
	const newFilepath = path.join(path.dirname(filepath), newName)

	if (path.normalize(newFilepath) !== path.normalize(filepath)) {
		console.log(filepath, '-->', path.join(path.dirname(filepath), newName))
		fs.renameSync(filepath, newFilepath)
	}
	const year: number = parseInt(digits.substring(0, 4))
	return year
}

const projects: string[] = fs.readdirSync('./projects/')
for (const project of projects) {
	const projectPath = path.join('./projects', project)
	const files = fs.readdirSync(projectPath).sort()

	for (const file of files) {
		if (identifyFile(file) === FileType.InvalidFile)
			console.error(`Invalid file "${file}" in project ${project}`)
	}
	if (!files.find(f => identifyFile(f) === FileType.DescriptionFile)) {
		console.log(`Creating description file ${descriptionFile} for project ${project}`)
		// fs.writeFileSync(path.join(projectPath, descriptionFile), JSON.stringify({}))
	}

	let imageIndex = 0;
	for (const file of files) {

		if (identifyFile(file) === FileType.UnparsedPhoto) {
			// normalizeName(path.join(projectPath, file), imageIndex)
			imageIndex++
		}
	}

}


// TODO: prefix directories with year
