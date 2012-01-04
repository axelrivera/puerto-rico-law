// We're using a global variable to store the number of occurrences
var RLPuertoRicoLaw_SearchResultCount = 0;

// helper function, recursively searches in elements and their child nodes
function RLPuertoRicoLaw_HighlightAllOccurencesOfStringForElement(element,keyword) {
	if (element) {
		if (element.nodeType == 3) {        // Text node
			while (true) {
				var value = element.nodeValue;  // Search for keyword in text node
				var compareValue = stripaccents(value)
				var idx = compareValue.indexOf(stripaccents(keyword));
				
				if (idx < 0) break;             // not found, abort
				
				var span = document.createElement("span");
				var text = document.createTextNode(value.substr(idx,keyword.length));
				span.appendChild(text);
				span.setAttribute("class","RLPuertoRicoLawHighlight");
				span.style.backgroundColor="yellow";
				span.style.color="black";
				text = document.createTextNode(value.substr(idx+keyword.length));
				element.deleteData(idx, value.length - idx);
				var next = element.nextSibling;
				element.parentNode.insertBefore(span, next);
				element.parentNode.insertBefore(text, next);
				element = text;
				RLPuertoRicoLaw_SearchResultCount++;	// update the counter
			}
		} else if (element.nodeType == 1) { // Element node
			if (element.style.display != "none" && element.nodeName.toLowerCase() != 'select') {
				for (var i=element.childNodes.length-1; i>=0; i--) {
					RLPuertoRicoLaw_HighlightAllOccurencesOfStringForElement(element.childNodes[i],keyword);
				}
			}
		}
	}
}

// the main entry point to start the search
function RLPuertoRicoLaw_HighlightAllOccurencesOfString(keyword) {
	RLPuertoRicoLaw_RemoveAllHighlights();
	RLPuertoRicoLaw_HighlightAllOccurencesOfStringForElement(document.body, keyword.toLowerCase());
}

// helper function, recursively removes the highlights in elements and their childs
function RLPuertoRicoLaw_RemoveAllHighlightsForElement(element) {
	if (element) {
		if (element.nodeType == 1) {
			if (element.getAttribute("class") == "RLPuertoRicoLawHighlight") {
				var text = element.removeChild(element.firstChild);
				element.parentNode.insertBefore(text,element);
				element.parentNode.removeChild(element);
				return true;
			} else {
				var normalize = false;
				for (var i=element.childNodes.length-1; i>=0; i--) {
					if (RLPuertoRicoLaw_RemoveAllHighlightsForElement(element.childNodes[i])) {
						normalize = true;
					}
				}
				if (normalize) {
					element.normalize();
				}
			}
		}
	}
	return false;
}

// the main entry point to remove the highlights
function RLPuertoRicoLaw_RemoveAllHighlights() {
	RLPuertoRicoLaw_SearchResultCount = 0;
	RLPuertoRicoLaw_RemoveAllHighlightsForElement(document.body);
}

function stripaccents(str) {
	//str = str.replace(/^\s+|\s+$/g, ''); // trim
	str = str.toLowerCase();
	
	// remove accents, swap ñ for n, etc
	var from = "àáäâèéëêìíïîòóöôùúüûñç";
	var to   = "aaaaeeeeiiiioooouuuunc";
	for (var i=0, l=from.length ; i<l ; i++) {
		str = str.replace(new RegExp(from.charAt(i), 'g'), to.charAt(i));
	}
	
	//str = str.replace(/[^a-z0-9 -]/g, '') // remove invalid chars
    //.replace(/\s+/g, '-') // collapse whitespace and replace by -
    //.replace(/-+/g, '-'); // collapse dashes
	
	return str;
}