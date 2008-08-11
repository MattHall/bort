// --------------------------------------------------------------------------------------------------------------
// set up variables

var isSafari = false;
var isSafari3 = false;
var isIE = false;
var isIE7 = false;	

// --------------------------------------------------------------------------------------------------------------
// what to do on DOM ready
document.observe("dom:loaded", runOnDOMready);
// what to do when body loaded
Event.observe(window, 'load', function() { runOnLoaded(); });

function runOnDOMready() {
	
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ some simple browser testing */
	// Safari versioning
	isSafari = Prototype.Browser.WebKit;
	// are we on safari 3? add a class (it over anti aliases everything which causes padding issues)
	// http://www.hedgerwow.com/360/dhtml/detect-safari3-by-js-css.html
	if( window.devicePixelRatio && window.getMatchedCSSRules && !window.Opera){
		isSafari3 = !!window.getMatchedCSSRules(document.documentElement,'');
	}
	if (isSafari) {	
		$$('body').invoke('addClassName', 'isSafari');
		if (isSafari3) { $$('body').invoke('addClassName', 'isSafari3'); }
	}
	// (ok so theres an assumption that any Safari thats not Safari3 is Safari2 here)		
	// IE versioning
	isIE = Prototype.Browser.IE;
	if (typeof document.body.style.maxHeight != "undefined") { if (!isSafari) { isIE7 = true; } }
	if (isIE) {	
		$$('body').invoke('addClassName', 'isIE');
		if (isIE7) { $$('body').invoke('addClassName', 'isIE7'); }
	}
	/* http://gmatter.wordpress.com/2006/10/20/detecting-ie7-in-javascript/ */
	// ### ok so theres an assumption that any IE thats not IE7 is IE6 here	
	
	
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ set up some adding of classes to things */	
	
	setUpClasses();	
	
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ do some roll over events */
	
	// class="image" (for input type=image)
	$$('.image').each(function(el){
		el.observe('mouseover', function(event) {
			var element = Event.element(event);
			element.addClassName('hover');
		});
		el.observe('mouseout', function(event) {
			var element = Event.element(event);
			element.removeClassName('hover');
		});
	});
	
	// table cells and headers - makes the tr above it have a class
	$$('td', 'th').each(function(el){
		el.observe('mouseover', function(event) {
			var element = Event.element(event);
			element.up().addClassName('hover');
			element.up().up().up().addClassName('hover');
		});
		el.observe('mouseout', function(event) {
			var element = Event.element(event);
			element.up().removeClassName('hover');
			element.up().up().up().removeClassName('hover');
		});
	});
	
	// table caption
	$$('table caption').each(function(el){
		el.observe('mouseover', function(event) {
			var element = Event.element(event);
			element.up().addClassName('hover');
		});
		el.observe('mouseout', function(event) {
			var element = Event.element(event);
			element.up().removeClassName('hover');
		});
	});
	
	// links in table cells, other wise the focus moves from td to a and looses the td's roll over
	$$('td a').each(function(el){
		el.observe('mouseover', function(event) {
			var element = Event.element(event);
			element.up().up().addClassName('hover');
			element.up().up().up().up().addClassName('hover');
		});
		el.observe('mouseout', function(event) {
			var element = Event.element(event);
			element.up().up().removeClassName('hover');
			element.up().up().up().up().removeClassName('hover');
		});
	});
	
}

function runOnLoaded() {	
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ redoing for IE! */
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ set up some adding of classes to things */	
	if (isIE) {
		setUpClasses();	
	}
}

// --------------------------------------------------------------------------------------------------------------
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ application wide functions */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ (remember to test if the elements you are messing with exist) */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ( eg. if (($$('body.homepage'))!=""){ } ) */

function setUpClasses() {
	$$('input[type=submit]').invoke('addClassName', 'submit');
	$$('input[type=radio]').invoke('addClassName', 'radio');
	$$('input[type=checkbox]').invoke('addClassName', 'checkBox');
	$$('input[type=image]').invoke('addClassName', 'image');
	$$('input[type=file]').invoke('addClassName', 'file');	
	$$('tr:nth-child(even)').invoke('addClassName', 'even');
	$$('li:nth-child(even)').invoke('addClassName', 'even');	
	$$('li:first-child').invoke('addClassName', 'first');
	$$('li:last-child').invoke('addClassName', 'last');		
}

