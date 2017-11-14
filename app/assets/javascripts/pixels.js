// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/

// function validate_urls(){
// 	for(url in urls){
// 		try{
// 			url_value = $('#' + url + '_url_string input').val()
// 			append_value = $('#' + url + '_append_string input').val()
// 		}catch(err){
// 			console.error(err);
// 		}
// 	}
// }

/* updates the edited url API */

function update_url_api(params, id){
        var response = $.ajax(
            {
                url: '/api/testurls/'+id,
                type: 'post',
                data: params
            }
        )
        .done(function(result){
                    if(result){
                        console.log('Updated Test URL #' + id)
                    }
                    console.debug(result);
                })
        .fail(function(result){
                    console.error(result)
                    console.error('Failed to update url - Reason: ' + result['statusText'])
                });
    }

/* update pixels that have been changed */

function update_pixel_api(element){
    console.debug('checking state')
    var state = (element.checked ? 1 : 0)
    var id = element.dataset.id

    var datareq = { 
        pixel_data:
        {
            expected_state: state
        }
    }
    var response = $.ajax(
        {
            url: '/api/pixeldata/' + id,
            type: 'post',
            data: datareq
        }
    )
    .done(function(result){
            console.debug('complete')
                if(result){
                    console.log('Updated Pixel #' + id)
                }
                console.debug(result);
            })
    .fail(function(result){
                console.error(result)
                console.error('Failed to update pixel - Reason: ' + result['statusText'])
            });
}

/* update url field */
function update_url(updated_element){
    try{
         change = updated_element.dataset
         field = change.name
        params = {}
        params.test_url = {}
        params.test_url[field] = updated_element.value
        var id = change.id;
        update_url_api(params, id);
    }catch(err){
        console.error(err)
        updated_element.value = 'FAILED TO UPDATE'
    }

}

/* removes all pixels mapped to a test_url */
function removePixelByUrl(flag, urlid){
    var response = $.ajax(
                {
                    url: '/api/pixeldata/url/' + urlid,
                    type: 'delete',
                }
            )
            .done(function(result){
                if(result){
                    console.log('Deleted Pixels')
                }
                console.debug(result);
            })
            .fail(function(result){
                        console.error(result)
                        console.error('Failed to delete pixel - Reason: ' + result['statusText'])
                    });
}

function removePixelByUrl(flag, urlid){
    var response = $.ajax(
                {
                    url: '/api/pixeldata/url/' + urlid + '/' + flag,
                    type: 'delete',
                }
            )
            .done(function(result){
                if(result){
                    console.log('Deleted Pixel - ' + urlid + ' ' + flag)
                }
                console.debug(result);
            })
            .fail(function(result){
                        console.error(result)
                        console.error('Failed to delete pixel - Reason: ' + result['statusText'])
                    });
}

/* add pixel to url */
function addPixelViaAPI(flag, expected, urlid){
    var response = $.ajax(
                {
                    url: '/api/pixeldata',
                    type: 'post',
                    data: 
                    {
                        pixel_data: 
                        {
                            pixel_handle: flag,
                            expected_state: expected,
                            test_url_id: urlid
                        } 
                    }

                }
            )
            .done(function(result){
                if(result){
                    console.log('Added Pixel')
                }
                console.debug(result);
                // add new pixel to each url
                var pixel_input = $('#pixelInputTemplate').html();
                var rendered_cell = pixel_input
				                    	.replace(/{{pixel_handle}}/g, result.pixel_handle)
				                    	.replace(/{{pixel_id}}/g, result.id);
                $(rendered_cell).insertBefore($('.' + urlid + '_url .delete_url_cell'));
            })
            .fail(function(result){
                        console.error(result)
                        console.error('Failed to add pixel - Reason: ' + result['statusText'])
                    });
}
/* update suite with data */
function updateSuiteViaAPI(params, pixel_suite_id){
    var response = $.ajax(
                {
                    url: '/api/pixeltest/' + pixel_suite_id,
                    type: 'post',
                    data: 
                    {
                        pixel_test: params
                    }

                }
            )
            .done(function(result){
                if(result){
                    console.log('modified test')
                }
                console.debug(result);
            })
            .fail(function(result){
                        console.error(result)
                        console.error('Failed to modify test - Reason: ' + result['statusText'])
                    });
}
/* add pixels to all urls */
function addPixel(){
    var newpixelname = prompt('New Pixel? \n Pixel Flag:')
    // add the pixels to the database
    //for(url in urls){
        //addPixelViaAPI(newpixelname, 0, url);
    //}
        for(url in urls){
        if (newpixelname === "") {
            return false;
        } else if (newpixelname) {
            addPixelViaAPI(newpixelname, 0, url);
        }
    }
	// Get current last pixel header
	var option_header = $('#option_header');

	// add new pixel to headers
	var pixel_header = $('#pixelHeaderTemplate').html();
	var rendered_header_cell = pixel_header
                                .replace(/{{newpixelname}}/g, newpixelname);
      //                          .replace(/{{newpixelid}}/g, newpixelid);
	$(rendered_header_cell).insertBefore(option_header);

	// // add new pixel to each url
	// var pixel_input = $('#pixelInputTemplate').html();
	// var rendered_cell = pixel_input.replace(/{{pixel_handle}}/g, newpixelname);
	// $(rendered_cell).insertBefore($('.delete_url_cell'));

	// add new pixel removal_button
	var pixel_delete = $('#pixelDeleteTemplate').html();
	var rendered_delete_cell = pixel_delete.replace(/{{pixel_handle}}/g, newpixelname);
	$(rendered_delete_cell).insertBefore($('.add_pixel_cell'));

	// add to pixel variable
	pixels.push(newpixelname)
	
}
/* remove url completely */
function removeURL(urlindex){
    var confident = confirm('Do you want to delete this URL?');
    if(confident){
        var response = $.ajax(
            {
                url: '/api/testurls/' + urlindex + '.json',
                type: 'delete',
            }
        )
        .done(function(result){
                    if(result[urlindex]){
                        console.log('Deleted Test URL with ID ' + urlindex)
                    }
                    // remove url from UI
                    $("." + urlindex + "_url").remove()
                    for (var i = 0; i < pixels.length; i++) {
                        removePixelByUrl(pixels[i], urlindex)
                    }

                    //console.debug(result);
                })
        .fail(function(result){
                    //console.error(result)
                    console.error('Failed to delete url - Reason: ' + result['statusText'])
                });
		
    }
}
/* delete pixel from all urls */
function deletePixel(pixel, id){
    for(url in urls){
        removePixelByUrl(pixel, url)
    }
	
	// remove pixel from UI
	$(".pixel_" + id).remove()

	// remove pixel from js variable
	pixels.splice(pixels.indexOf(pixel), 1);
}
/* add url to list */
function addURL(suite){
    var user_input = prompt('New URL?')
	if(user_input){
        try{
            var response = $.ajax(
                {
                    url: '/api/testurls',
                    type: 'post',
                    data: 
                    {
                        test_url: 
                        {
                            url: user_input,
                            pixel_test_id: suite
                        } 
                    }

                }
            )
            .done(function(result){
                if(result){
                    console.log('Added Test URL')
                }
                console.debug(result);
            
    			var new_row = $('#newUrlTemplate').html();
    			new_row = new_row.replace(/{{url}}/g, user_input).replace(/{{newindex}}/g, result.id)
    			$(new_row).insertBefore($('.modify_row'))
    			for (var i = 0; i < pixels.length; i++) {
    				addPixelViaAPI(pixels[i], 0, result.id);
    			};
                urls[result.id] = result.url
            })
            .fail(function(result){
                        console.error(result)
                        console.error('Failed to add url - Reason: ' + result['statusText'])
                    });
		}catch(err){
			console.log(err)
		}
    }
}