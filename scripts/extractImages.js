let imgs = []
setInterval(() => {
	let doms = document.querySelectorAll("body > reader-app > reader-main > div > reader-pages > reader-vertical-view > cdk-virtual-scroll-viewport > div.cdk-virtual-scroll-content-wrapper > ol > li > reader-page > reader-rendered-page > div > div.page > img")
	doms = Array.from(doms)
	doms.forEach((dom) => {
		console.log(dom.src)
		if (!imgs.includes(dom.src))
			imgs.push(dom.src)
	})
}, 300)
