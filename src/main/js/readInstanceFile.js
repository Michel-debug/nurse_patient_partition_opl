/**
 * 
 * @param {s} string with the line 
 * @returns  remove the space before and after the line
 */
function trim(s) {
  var start = 0;
  var end = s.length - 1;
  while (start < s.length && (s.charAt(start) == ' ' || s.charAt(start) == '\t')) {
      ++start;
  }
  while (end > start && (s.charAt(end) == ' ' || s.charAt(end) == '\t')) {
      --end;
  }
  return s.substring(start, end + 1);
}


/**
 * Converts a time string (e.g., "8h30") into a float (e.g., 8.5).
 * @param {string} timeStr - The time string to convert.
 * @returns {number} The time as a float.
 */
function string_to_float(timeStr) {
  var hourIndex = timeStr.indexOf('h');
  var hours = parseFloat(timeStr.substring(0, hourIndex));
  var minutes = parseFloat(timeStr.substring(hourIndex + 1)) || 0;
  var minutes_in_hours = parseFloat(minutes/60.0);
  return hours + minutes_in_hours;
}

/**
 * Converts a time string (e.g., "8h30") into minutes passed since 7 AM (e.g., "8h30" -> 90).
 * @param {string} timeStr - The time string to convert.
 * @returns {number} The time in minutes passed since 7 AM.
 */
function string_to_minutes_since_seven(timeStr) {
  var hourIndex = timeStr.indexOf('h');
  var hours = parseFloat(timeStr.substring(0, hourIndex));
  var minutes = parseFloat(timeStr.substring(hourIndex + 1)) || 0;

  // Calculate total minutes since midnight
  var totalMinutes = hours * 60 + minutes;

  // Calculate minutes since 7 AM (7 hours * 60 minutes/hour = 420 minutes)
  var minutesSinceSeven = totalMinutes - 420;

  return minutesSinceSeven;
}


/**
 * Converts a time float (e.g., 8.5) back into a string format (e.g., "08h30").
 * Ensures that both hours and minutes are always two digits.
 * @param {number} timeFloat - The time as a float.
 * @returns {string} The time in string format, formatted as "hh:mm".
 */
function float_to_string(timeFloat) {
  var hours = Math.floor(timeFloat);
  var minutes = Math.round((timeFloat - hours) * 60);
  var formattedHours = hours < 10 ? '0' + hours : hours.toString();  // Ensuring two digits for hours
  var formattedMinutes = minutes < 10 ? '0' + minutes : minutes.toString();  // Ensuring two digits for minutes
  return formattedHours + 'h' + formattedMinutes;
}





/**
 * Parses a constraint expression of the form "Xh<<Yh" to extract the numeric values of the lower and upper bounds.
 * @param {string} constraintExpression - The constraint string to parse.
 * @returns {Array} An array containing two elements: the lower bound and the upper bound as floats.
 */
function parseConstraint(constraintExpression) {
  // Use the "<<" as a delimiter to split the constraint expression into two parts.
  // The first part before "<<" will be the lower bound and the part after "<<" will be the upper bound.
  var lowerBound = constraintExpression.split("<<")[0];
  var upperBound = constraintExpression.split("<<")[1];

  var lower_hourIndex = lowerBound.indexOf('h');
  var upper_hourIndex = upperBound.indexOf('h');
  var lower_hours = parseFloat(lowerBound.substring(0, lower_hourIndex));
  var upper_hours = parseFloat(upperBound.substring(0, upper_hourIndex));
  
  // Return an array with the lower bound and upper bound.
  return new Array(lower_hours*60, upper_hours*60);
}




/**
 * Converts a descriptive time string into a formatted time range.
 * @param {string} timeDescriptor - The descriptive time ("matin", "midi", "apres-midi", "soiree").
 * @param {string} infJ - The start of the day (e.g., "7h").
 * @param {string} supJ - The end of the day (e.g., "20h").
 * @returns {Array} The time range as a string.
 */
function getTimeRange(timeDescriptor, infJ, supJ) {
  if (timeDescriptor == "matin") {
    return new Array(infJ, convertHourToMinutesSince7(11));  // Morning starts at infJ and goes until 11h
  }
  else if (timeDescriptor == "midi") {
    return new Array(convertHourToMinutesSince7(11), convertHourToMinutesSince7(15));      // Midday spans from 11h to 15h
  }
  else if (timeDescriptor == "apresmidi") {
    return new Array(convertHourToMinutesSince7(15), convertHourToMinutesSince7(19));      // Afternoon spans from 15h to 19h
  }
  else if (timeDescriptor == "soir") {
    return new Array(convertHourToMinutesSince7(19), supJ);  // Evening starts at 19h and goes until supJ
  }
  else if (timeDescriptor.charAt(0) == "[") {
    // Extract the range, assuming format like "[8h30-12h]"
    var cleaned_timeDescriptor = "";
    for (var i = 0; i < timeDescriptor.length; i++) {
        if (timeDescriptor.charAt(i) == '[' || (timeDescriptor.charAt(i) == ']')) {
            cleaned_timeDescriptor += "";
        }
        else 
          cleaned_timeDescriptor += timeDescriptor.charAt(i);
    }
    var times = cleaned_timeDescriptor.split("-");
    if (times.length == 2) {
      var startTime = string_to_minutes_since_seven(times[0]);  // Convert "8h30" to 90 min
      var endTime = string_to_minutes_since_seven(times[1]);    // Convert "12h" to 300 min
      return new Array(startTime, endTime);
    }
  }
}




/**
 * Removes all commas from a given address string using charAt for character access.
 * This method is useful in programming environments where direct string indexing is not supported.
 * @param {string} address - The address string to be cleaned.
 * @return {string} The cleaned address string without any commas.
 *
 * @example
 * var cleanedAddress = removeCommas("7 Rue Jubé de la Perelle, Dourdan");
 * // cleanedAddress will be "7 Rue Jubé de la Perelle Dourdan"
 */
function removeCommas(address) {
  var cleanedAddress = "";
  for (var i = 0; i < address.length; i++) {
      if (address.charAt(i) != ',') {
          cleanedAddress += address.charAt(i); // Add character to cleanedAddress if it's not a comma
      }
  }
  return cleanedAddress;
}



/**
 * 
 * @param {*} s 
 * @returns  remplacer all the space with a space
 */
// Converts multiple blankspaces into single blankspace
function normalizeSpaces(s) {
  var result = "";
  var inSpace = false;
  for (var i = 0; i < s.length; ++i) {
      if (s.charAt(i) == ' ' || s.charAt(i) == '\t') {
          if (!inSpace) {
              result += ' ';
              inSpace = true;
          }
      } else {
          result += s.charAt(i);
          inSpace = false;
      }
  }
  return result;
}


/**
 * @param {string} address - The original address string containing whitespaces.
 * @return {string} The modified address string with whitespaces replaced by plus signs.
 * 
 * @example
 * var formattedAddress = replaceWhitespaceWithPlus("2 rue de Paris, 91400 Orsay");
 * // formattedAddress will be "2+rue+de+Paris,+91400+Orsay"
 */
function replaceWhitespaceWithPlus(address) {
	// Split the input string into an array of substrings using the space character as the delimiter.
	var parts = address.split(" ");
  
	// Join the array of substrings back into a single string, inserting a plus sign between each substring.
	return parts.join("+");
}


/**
 * Converts an hour within the 7h to 20h timeframe into minutes since 7h.
 * 
 * @param {number} hour - The hour to be converted, should be between 7 and 20.
 * @return {number} The number of minutes past 7h.
 * 
 * @example
 * var minutes = convertHourToMinutesSince7(8); // returns 60
 * var minutes = convertHourToMinutesSince7(11); // returns 240
 * var minutes = convertHourToMinutesSince7(12); // returns 300
 */
function convertHourToMinutesSince7(hour) {
    // Calculate minutes since 7h
    return Math.round((hour - 7) * 60);
}

/**
 * Formats a set of coordinates into a single string with each latitude and longitude
 * pair separated by commas and each pair separated by semicolons.
 * @param {set} coordinatesSet - A set of tuples where each tuple contains latitude and longitude.
 * @return {string} A single string containing all formatted coordinates.
 *
 * @example
 * var coordinatesSet = [
 *   {latitude: 48.697, longitude: 2.1853},
 *   {latitude: 48.697, longitude: 2.1853},
 *   {latitude: 48.697, longitude: 2.1853},
 *   {latitude: 48.697, longitude: 2.1853}
 * ];
 * var formattedCoordinates = formatCoordinates(coordinatesSet);
 * // formattedCoordinates will be "48.697,2.1853;48.697,2.1853;48.697,2.1853;48.697,2.1853"
 */
function formatCoordinates(coordinatesSet) {
    var concatenatedCoordinates = "";
    var isFirst = 1; // Flag to help with the format (1 is true)

    for (var i in coordinatesSet) {
        var address = i;
        var formattedCoordinates = coordinates_formatter(address.longitude, address.latitude);

        if (isFirst == 1) {
            concatenatedCoordinates += formattedCoordinates;
            isFirst = 0; // Set flag to false (0)
        } else {
            concatenatedCoordinates += ";" + formattedCoordinates;
        }
    }

    return concatenatedCoordinates;
}

/**
 * Helper function to format individual latitude and longitude into a string.
 * @param {float} latitude - The latitude to format.
 * @param {float} longitude - The longitude to format.
 * @return {string} Formatted string of the coordinates.
 */
function coordinates_formatter(latitude, longitude) {
    return latitude.toString() + "," + longitude.toString();
}




function convertMinutesToHourSince7(minutes) {
  if (minutes < 0 || minutes > 17 * 60) {
      return 'Minutes must be within the range of 0 to 1020 (equivalent to 17 hours).';
  }

  // Calculate the total hours since 7 AM
  var totalHoursSince7 = minutes / 60;

  // Calculate the hour part
  var hour = 7 + Math.floor(totalHoursSince7);

  // Calculate the minutes part
  var remainingMinutes = minutes % 60;

  // Ensure minute format is always two digits
  var formattedMinutes = remainingMinutes < 10 ? '0' + remainingMinutes : remainingMinutes;

  return hour + ':' + formattedMinutes;
}


