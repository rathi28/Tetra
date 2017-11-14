// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap.min
//= require select2.min
//= require moment
//= require bootstrap-datetimepicker
//= require jquery.timepicker.js
//= require_tree .



/*
	
	Prototype adjustment to add contains functionality for comparisons.

*/
Array.prototype.contains = function(item){
	for(i = 0; i < this.length; i++){
		if(this[i] === item){ 
			return true
		}
	}	
	return false;
}

/*
	scheduletype(testtype, type)

	Used for switching between daily, weekly, and one-time test running.

*/
function scheduletype(testtype, type){
	// Variables
    var option; 		// list of options for schedule type
    var wanted_type; 	// what option to be selected

    // This jquery is pulling all the scheduletype options from the select statement
    // It only pulls for the testtype chosen
    option = $("#scheduletype"+testtype+" option");

    // Go through each option and remove the selected attribute if present
    option.each(
      function(indexer){
      	// remove attributes
        option[indexer].removeAttribute('selected');
      }
      );

    // get the option you want to select using type
    wanted_type = $('#scheduletype' + testtype + ' option[value="' + type + '"]');
    // set it to be selected
    wanted_type.attr('selected','selected');
    // return true if successful
    return true;
  }

/*
	get_campaigns()

	Get the list of campaigns that match your current input selection.

*/
function get_campaigns(){
	// Variables
	// HTTP response
	var response;
	// whether you have found an existing selection
	var found_existing;
	// the campaign dropdown select
	var campaign_select;
	// the list of campaigns
	items = null; 
	// the campaign holding variable for the grcid for the current item from items
	var campaign;

	// Let ajax send and recieve the campaigns API call
	response = $.getJSON( 
		// The endpoint and brand query string key
		"/campaigns.json?brand=" 
		// The brand query string value
		+ $("select[name='brand']").val() 
		// The environment key
		+ "&environment="
		// The environment value
		+ $("select[name='server']").val() 
		// The platform key
		+ "&platform=" 
		// The platform value
		+ $("select[name='platform']").val()
		// The realm key
		+ "&realm=" 
		// The platform value
		+ $("select[name='realm']").val(),

		// The function call for the response from the json
		function() {

			// The dropdown for the campaign selector
			selected_campaign = $('select[name=\'campaign\']').val()
			
			// drop the select elements' options
			$('select[name=\'campaign\']').empty();

			// set found_existing as 0 so that if the campaign never matches anything it will select core as default
			found_existing = 0

			// pull out the response as json
			items = response.responseJSON;
	
			//  get the campaign selector dropdown
			campaign_select = $('select[name=\'campaign\']');

			// iterate through the items found in json
			for (var i = items.length - 1; i >= 0; i--) {

			// get the campaign GRCID code
			campaign = items[i].grcid;

			// If the campaign does not match an existing selected campaign
			if(campaign != selected_campaign){

				// add the campaign as a regular option
				campaign_select.append(
					'<option value="'+campaign+'">'+ campaign +'</option>'
				);
			}else{

				// set found existing to true so core isn't set as default
				found_existing = 1

				// add the existing selection
				campaign_select.append(
					'<option value="'+campaign+'">'+ campaign +'</option>'
					);

				// set the campaign dropdown to the existing selection 
				campaign_select.val(campaign)
			}

			// if the entire list is iterated through without finding the existing selection then...
			if(found_existing == 0){

				// ...select the core campaign
				campaign_select.val('core-campaign');
			}
		};

		// If the campaign dropdown is empty...
		if(campaign_select.children().length == 0){

			// ...remove the error message if present already...
			$('.missing-campaigns').remove();

			// ... and if the brand is all
			if($('select[name="brand"]').val() != "all"){
				$('#error-container').first().append(
					'<div class="missing-campaigns alert alert-danger alert-dismissible" role="alert">'+
					'	<button type="button" class="close" data-dismiss="alert" aria-label="Close">'+
					'		<span aria-hidden="true">&times;</span>'+
					'	</button>'+
					'	Brand/Environment pair does not have any campaigns'+
					'</div>'
					);
				$('input[name="commit"]')[0].disabled = true
			}else{
				campaign = 'core-campaign'
				campaign_select.append(
					'<option value="'+campaign+'">'+ campaign +'</option>'
					);
				campaign_select.val('core-campaign')
			}
		}else{
			$('.missing-campaigns').remove();
			$('input[name="commit"]')[0].disabled = false
		};
		$('[value="core-campaign"]').selected = true
	});
};

/* 

validate_email

This method checks that the entire list of emails is valid
If it finds an invalid email it will block the test from being passed to the controller

*/
function validate_email(event){
	// variables
	var array_emails;
	var list;
	var regex; // regular expression for email validation
	var valid;

	// to start, remove the has-error class from the email form element...
	$('#email_form_' + event.getAttribute('testtype')).removeClass('has-error');

	// ...and remove the bad email error message.
	$('.bademail').remove();

	// store regular expression as value
	regex = RegExp(/^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/);

	// get the event value from the element that fired the action
	list = event.value

	// store emails
	array_emails = list.trim().split(/[;\s]/);

	// for each email...
	array_emails = array_emails.map.call(

		// ...in the array...
		array_emails, 

		// ...call this function.
		function(exstring){

			// pull the string out and remove the extra whitespace
			exstring = exstring.trim();

			// if the string is empty
			if(exstring == ''){

				// exit the loop and return no value to the slot
				return
			}

			// otherwise return this string
			return exstring;
		}
	);

	// pull out any undefined values
	array_emails = array_emails.filter(function(n){ return n != undefined }); 

	// Set a tracking variable for validity
	var valid = true;

	// Iterate through emails...
	array_emails.forEach(

		// ...with this function...
		function(string_to_test){

			// ...and if the string is invalid...
			if(regex.test(string_to_test) == false){

				// ...set the validitity of the whole array as false,...
				valid = false;

			}else{
				// otherwise do nothing and continue looping
			}
		}
	);

	// if all the elements are validated as correct...
	if(valid){
		// ...enable the submit button...
		$('input[name="commit"]')[0].disabled = false

		
	}else{
		// ...add the error style to the form input
		$('#email_form_' + event.getAttribute('testtype')).addClass('has-error');

		// get the relevent form element and add an error message for the bad email warning.
		$('#email_form_' + event.getAttribute('testtype')).first().append(
			'<div class="bademail alert alert-danger" role="alert">'+
			'The Email list entered is not formatted properly.' +
			'</div>'
			);
		
		// ...and disable the submit button.
		$('input[name="commit"]')[0].disabled = true
	}
}


/*

	check_compatibility()

	checks that platform matches driver.

*/
function check_compatiblity(){
	// variables for the type of platform and browser selected
	var typeofplatform;
	var typeofbrowser;

	// move existing error flash messages
	$('.mismatch-platform').remove();
	// get the platform type
	typeofplatform = $("select[name='platform']").val() == "Mobile"
	// get the browser type
	typeofbrowser = $("select[name='browser']").val().includes("iphone")

	// remove existing error classes
	$('#browserform').removeClass('has-error')
	$('#platformform').removeClass('has-error')

	// switch the existing class for the submit button to primary
	$('input[name="commit"]').removeClass('btn-danger')
	$('input[name="commit"]').addClass('btn-primary')

	// if the browser and platform are not compatible...
	if(typeofplatform != typeofbrowser){

		// ...add the error flash to the browserform element...
		$('#browserform').first().append(
			'<div class="mismatch-platform alert alert-danger alert-dismissible" role="alert">' +
			'	<button type="button" class="close" data-dismiss="alert" aria-label="Close">' +
			'		<span aria-hidden="true">' +
			'		&times;' +
			'		</span>' +
			'	</button>' +
			'	This browser and platform combo is abnormal, proceed with caution.' +
			'</div>');

		// ...add error classes,...
		$('#browserform').addClass('has-error')
		$('#platformform').addClass('has-error')

		// ... and switch the submit button class to btn-danger.
		$('input[name="commit"]').addClass('btn-danger')
		$('input[name="commit"]').removeClass('btn-primary')
	}
	// ...otherwise you are done checking the compatibility.
}