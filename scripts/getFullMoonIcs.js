// Downloads a phases of the moon calendar and extracts the full moon events
// and writes it to a `astrocal.ics` that can be uploaded into any calendar

const fs = require('fs')
const https = require('https')
const ical2json = require('ical2json');

(async () => {
	const inputFile = './astrocal.ics'
	if (fs.existsSync(inputFile))
		fs.unlinkSync(inputFile)

	await new Promise((resolve) => {
		https.get('https://cantonbecker.com/astronomy-calendar/astrocal.ics', (res) => {
			const filePath = fs.createWriteStream(inputFile)
			res.pipe(filePath)
			filePath.on('finish', () => {
				filePath.close()
				resolve()
			})
		})
	})

	const input = fs.readFileSync(inputFile).toString()
	let cal = JSON.parse(Object.values(ical2json.convert(input)).join(''))

	let events = []
	for (const event of cal.VCALENDAR[0].VEVENT) {
		if (!event.SUMMARY.includes("Full Moon"))
			continue
		console.log(event.SUMMARY)
		event.SUMMARY = "Full Moon"
		events.push(event)
	}
	cal.VCALENDAR[0].VEVENT = events


	fs.writeFileSync(inputFile, ical2json.revert(cal), { flag: 'w' })
})()
