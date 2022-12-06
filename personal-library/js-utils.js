String.prototype.toTitleCase = function () {
	const smallWords = /(?:a[stn]?|and|because|but|by|en|for|i[fn]|neither|nor|o[fnr]|only|over|per|so|some|tha[tn]|the|to|up(on)?|vs?\.?|versus|via|when|with(out)?|yet)/i;
	let capitalized = this.replace(/\w\S*/g, function (word) {
		if (smallWords.test(word)) return word.toLowerCase();
		if (word.toLowerCase() === "i") return "I";
		if (word.length < 3) return word.toLowerCase();
		return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase();
	});
	capitalized = capitalized.charAt(0).toUpperCase() + capitalized.slice(1).toLowerCase();
	return capitalized;
};
