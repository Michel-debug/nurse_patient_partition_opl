
//-----------------------------------------------------------------
// Functions related to OSRM
//-----------------------------------------------------------------

// may be called on osrm standard demo server : router.project-osrm.org
// or on local server 

/** performs a table query on some osrm router 
 * @param {string} serie - A serie of geoCoordinates separated by ";"
 * @param {string} the osrm server address
 * @example osrm_table("3.388860,52.517037;13.397634,52.529407;13.428555,52.523219","router.project-osrm.org")
 * @return {Object} The server answer (if sucessful) as a script Object
 */
function osrm_table(serie, server, option) {
	// 	Query construction
	var service = "http://" + server + "/table/v1/driving/";
	var query = service + serie + option;
	
	//query answer is stored in a temporary file
	var answer_tmp_file = "answer_osrm.json";
	var fullquery = "curl '" + query + "' >" + answer_tmp_file;
	//writeln("INFO : fullquery = ", fullquery);
	// Calling subprocess 
	IloOplExec("curl '" + query + "' >" + answer_tmp_file);

	// get the result 
	var answerString = file_to_string(answer_tmp_file);
	// writeln("\nFILE: \n", answerString)

	// Parse the JSON string as a script Object
	var answer = parseSimpleJSON(answerString);
	//writeln("\nANSWER: \n", answer)

	if (typeof answer == "undefined") {
		writeln("ERROR : unable to convert OSMR answer.");
			// toto - wait for a while and try again
	} else if (answer["code"] != "Ok") {
		writeln("WARNING : unable to retrieve durations from OSMR answer");		
		writeln("DEBUG : answer[\"code\"] = ",answer["code"]);		
		
			// toto - wait for a while and try again
	} 
	// Removes the temporary file
	IloOplExec("rm  " + answer_tmp_file);

	return answer;

}




//-----------------------------------------------------------------
// Functions for geocoding from BAN
//-----------------------------------------------------------------

/**
 * Fetches geocoding information for a given textual address using the BAN API.
 * @param {string} address - The textual address to geocode.
 * @return {Object} The server response as a script Object, if successful.
 */

function extract_BAN(address) {
    // Construct the query for the BAN API
    var service = "https://api-adresse.data.gouv.fr/search/?q=";
    var formattedAddress = replaceWhitespaceWithPlus(address);
    var query = service + formattedAddress;
    
    // Store the query answer in a temporary file
    var answer_tmp_file = "answer_ban.json";
    var fullquery = "curl '" + query + "' >" + answer_tmp_file;
    //writeln("INFO : fullquery = ", fullquery);
    
    // Call subprocess to execute the query
    IloOplExec(fullquery);

    // Retrieve the result from the file
    var answerString = file_to_string(answer_tmp_file);
    //writeln("\nFILE: \n", answerString);

    // Parse the JSON string into a script Object
    var answer = parseSimpleJSON(answerString);
    //writeln("\nANSWER: \n", answer);

    if (typeof answer == "undefined") {
        writeln("ERROR : unable to convert BAN answer.");
        // Optionally retry the query after a delay
    } else if (answer["type"] != "FeatureCollection") {
        writeln("WARNING : unexpected response type from BAN answer");
        writeln("DEBUG : answer[\"type\"] = ", answer["type"]);        
        // Optionally retry the query after a delay
    }

    // Remove the temporary file, we put it in the visit file
   // IloOplExec("rm " + answer_tmp_file);

    return answer;
}







//-----------------------------------------------------------------
// Functions for geocoding from  Nominatim  (TODO if you want)
//-----------------------------------------------------------------

/**
 * Performs geocoding of a textual address using the Nominatim service.
 * @param {string} address - The textual address to geocode.
 * @param {string} server - The Nominatim API server address.
 * @example nominatim_geocode("2 rue de Paris, 91400 Orsay", "nominatim.org")
 * @return {Object} The server answer (if successful) as a script Object.
 */
function extract_nominatim(address) {
    // Query construction with output format specified as JSON

	// https://nominatim.openstreetmap.org/search?addressdetails=1&q=bakery+in+berlin+wedding&format=jsonv2&limit=1
    var service = "https://nominatim.openstreetmap.org/search?";
    var formattedAddress = replaceWhitespaceWithPlus(address);
    var query = service + "addressdetails=1&q=" + formattedAddress + "&format=jsonv2&limit=1";

    // Query answer is stored in a temporary file
    var answer_tmp_file = "answer_nominatim.json";
    var fullquery = "curl '" + query + "' >" + answer_tmp_file;
    // writeln("INFO : fullquery = ", fullquery);

    // Calling subprocess
    IloOplExec(fullquery);

    // Get the result
    var answerString = file_to_string(answer_tmp_file);
    writeln("\nFILE: \n", answerString);

    // Parse the JSON string as a script Object
    var answer = parseSimpleJSON(answerString);
    // writeln("\nANSWER: \n", answer);

    // Check if the answer could be parsed
    if (typeof answer == "undefined" || answer.length == 0) {
        writeln("ERROR: unable to convert Nominatim answer or no results found.");
    } else {
        // Assuming the first result is the most relevant
        writeln("Geocoding result: ", answer[0]);
    }

    // Removes the temporary file
    IloOplExec("rm " + answer_tmp_file);

    return answer[0]; // Returning the first result
}


//-----------------------------------------------------------------
// Functions for geocoding from  local base of cadastre (Useful to save time)
//-----------------------------------------------------------------


//-----------------------------------------------------------------
// Functions related to local base of cadastre (Useful to save time)
//-----------------------------------------------------------------
