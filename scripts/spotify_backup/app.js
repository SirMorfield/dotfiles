var fetch = require('node-fetch');

fetch('https://api.spotify.com/v1/me/tracks', {
	headers: {
		'Accept': 'application/json',
		'Content-Type': 'application/json',
		'Authorization': 'Bearer '
	}
});
