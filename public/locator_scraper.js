function gatherLocatorsT3(){
	var kits 	= $('.kitType .sasKits li[class][id]');
	var gifts 	= $('.selectGift .sasKits li[class][id]');
	var variant = $('.selectVariant .sasKits li[class][id]');
	var upsell 	= $('.upsellInline .sasKits li[class][id]');
	var code = renderBlock("T3",[kits, gifts, variant, upsell], ['Kits', 'Gift', 'Shade', 'Supply']);
}
function gatherLocatorsT4(){
	var kits 	= $('.kitType .sasKits li[class][id]');
	var gifts 	= $('.selectGift .sasKits li[class][id]');
	var variant = $('.selectVariant .sasKits li[class][id]');
	var upsell 	= $('.upsellInline .sasKits li[class][id]');
	var code = renderBlock("T4",[kits, gifts, variant, upsell], ['Kits', 'Gift', 'Shade', 'Supply']);
}

function gatherLocatorsT5(){
	var kits 	= $('.kitType .sasKits li[class][id]');
	var gifts 	= $('.selectGift .sasKits li[class][id]');
	var variant = $('.selectVariant .sasKits li[class][id]');
	var upsell 	= $('.upsellInline .sasKits li[class][id]');
	var code = renderBlock("T5",[kits, gifts, variant, upsell], ['Kits', 'Gift', 'Shade', 'Supply']);
}

function gatherLocatorsRealmTwo(){
	hooks = $('[data-pid]');
	lengthhook = hooks.length;
	var kits = [];
		var gifts = [];
		var upsell = [];
		var valuepack = [];
		var unidentified = [];
		var variant = [];
	for( var i = 0; i < lengthhook; i++){
		console.log('collecting data-pid locators');
		
		if(hooks[i]){
			found = 0
			if(hooks[i].getAttribute('data-pid').includes('kit')){
				found = 1
	 			kits.push( "[data-pid=" + hooks[i].getAttribute('data-pid') + "]");
	 		}
	 		if(hooks[i].getAttribute('data-pid').includes('gift')){
	 			found = 1
	 			gifts.push( "[data-pid=" + hooks[i].getAttribute('data-pid') + "]");
	 		}
	 		if(hooks[i].getAttribute('data-pid').includes('supply')){
	 			found = 1
	 			upsell.push( "[data-pid=" + hooks[i].getAttribute('data-pid') + "]");
	 		}
	 		if(hooks[i].getAttribute('data-pid').includes('valuepack')){
	 			found = 1
	 			valuepack.push( "[data-pid=" + hooks[i].getAttribute('data-pid') + "]");
	 		}
	 		if(found != 1){
	 			unidentified.push( "[data-pid=" + hooks[i].getAttribute('data-pid') + "]");
	 		}
	 	}
	 }
	 console.log(kits);
	var code = renderBlockRealmTwo("RealmTwo",[kits, gifts, valuepack, variant, upsell, unidentified], ['Kits', 'Gift', 'ValuePack', 'Shade', 'Supply', 'unidentified']);
}



function renderBlockRealmTwo(title, array_of_objects, arrayOfTitles){
	console.log(array_of_objects)
	var code = "\
	<div>\
	<h1>"+title+"</h1>\
	</div>\
	<table style='border-collapse:collapse;'>\
	<thead>\
	<th>CSS</th>\
	<th>Step</th>\
	<th>Brand</th>\
	<th>Offer</th>\
	</thead>\
	"

	for(var i = 0; i < array_of_objects.length; i++){
		for(var k = 0; k < array_of_objects[i].length; k++){
			element = array_of_objects[i][k];
			code += "<tr>";
			code += TableGen.cell(element); // css
			code += TableGen.cell(arrayOfTitles[i]); // step	
			code += TableGen.cell(""); // brand
			code += TableGen.cell(""); // offer
			code += "</tr>";
		}
	}
	code += "</table>"
	scraper = window.open("", "", "");
	scraper.document.write(code); 
	return code;
}




function renderBlock(title, array_of_objects, arrayOfTitles){
	var code = "\
	<div>\
	<h1>Template: "+title+"</h1>\
	</div>\
	<table style='border-collapse:collapse;'>\
	<thead>\
	<th>CSS</th>\
	<th>Step</th>\
	<th>Brand</th>\
	<th>Offer</th>\
	</thead>\
	"

	for(var i = 0; i < array_of_objects.length; i++){
		for(var k = 0; k < array_of_objects[i].length; k++){
			element = array_of_objects[i][k];
			var css = ""
			for(var j = 0; j < element.classList.length; j++){
				if(element.classList[j] != 'active' && element.classList[j] != '90-Day' && element.classList[j] != '30-Day'){
					css += "." + element.classList[j];
				}
			} 
			if(element.classList.length != 0){
				css += " ";
			}
			if(element.id){
				css += "#" + element.id;
			}
			code += "<tr>";
			code += TableGen.cell(css); // css
			code += TableGen.cell(arrayOfTitles[i]); // step	
			code += TableGen.cell(mmBrand); // brand
			code += TableGen.cell(""); // offer
			code += "</tr>";
		}
	}
	code += "</table>"
	scraper = window.open("", "", "");
	scraper.document.write(code); 
	return code;
}
TableGen = {}
TableGen.cell = function(content){
	return '<td style="border: 1px solid black;">' + content +"</td>"
}