/************************************************************************
* IALC2 2023-24 Project
* Binome : Junjie CHEN
*          Molla  Pablo
*
* Modèle : visits2.mod
*
* Description : 
	Le fichier visits1.mod vise à organiser l'emploi du temps d'une infirmière unique 
	travaillant dans un cabinet médical, en omettant initialement toute contrainte liée 
	aux horaires spécifiques des visites, telles que les délais nécessaires entre les 
	rendez-vous ou les périodes d'indisponibilité. L'objectif principal du modèle est 
	de réduire au minimum la durée totale de la journée de travail de l'infirmière, 
	depuis son départ du cabinet pour sa première visite jusqu'à la fin de ses 
	dernières tâches administratives après sa visite finale.
*
************************************************************************/

using CP;

string modelName = "visits1";

include "structures/instances.mod";
include "structures/inputs.mod";

Instance instance = ...;	


// Variables for storing the information from text files
{string} files = instance.files;
{Journee} journees = {};
Infirmiere nurses;
{Indisponibilite} indisponibilites = {};
{Adresse} addresses = {};
{Acte} actes = {};
{PatientTreatment} treatments = {};
{Contraintes} contraintes = {};

// Variables for storing the information from extract_BAN and osrm_table
{CadastreAddress} addresses_full_info = {};
{Durations} allDurations = {};

execute {  
	// Including external JS files directly
    includeScript("../js/readInstanceFile.js");
    includeScript("../../libs/js/files.js");
    includeScript("../../libs/js/simpleJSONParser.js");
    includeScript("../../libs/js/geoServices.js");

    // Defining the variables needed to call the API of OSRM
    // (Latitude, Longitude)
    var serverAddress = "router.project-osrm.org";
    var option_duration = "?annotations=duration";

    // Reading each text file link from .dat file
    for(var filePath in files){
        
        // First Reading - Looking for journee
        var f = new IloOplInputFile(filePath);
        if(f.exists){
            //writeln("\n\n-------------------------------------------------------");
            //writeln("FIRST TIME - Reading file : ", filePath);
            while (!f.eof) {
                var line = f.readline();
                var parts = normalizeSpaces(line).split(" ");
                if (parts[0]=="journee"){
                    if (parts.length > 2) {
                        var infJ = parts[1];
                        var supJ = parts[2];
                        journees.add(string_to_minutes_since_seven(infJ), string_to_minutes_since_seven(supJ));
                    }
                }// Case: Actes - DONE
                else if(parts[0]=="acte"){
                    var parts = normalizeSpaces(line).split(" "); 
                    var code = parts[1]
                    var duree = parts[2]
                    var descp = trim(line.substring(line.indexOf(parts[3]),line.length))
                    actes.add(code, duree, descp);
                }// Case: Infirmiere - DONE  only one nurse
                else if(parts[0]=="infirmiere"){
                     var parts = line.split(" ");
                    if (parts.length == 4) {
                        var name = parts[1];
                        var startTime = string_to_float(parts[2]);
                        var endTime = string_to_float(parts[3]);
                        //infirmieres.add(name, startTime, endTime);
						nurses.name = name;
						nurses.inf = startTime;
						nurses.sup = endTime;
                    }
                    //for those who only have name
                    else{
                        var name = parts[1];
                        nurses.name = name;
						nurses.inf = 0;
						nurses.sup = 840;
                        for(var i in journees){
                           //  infirmieres.add(name, i.infJ,i.supJ);
						    nurses.name = name;
							nurses.inf = i.infJ;
							nurses.sup = i.supJ;
                        }
                    }
                }
                
	        }
            //writeln("\nIs `journee` found? ", Opl.card(journees), " (0: Not Found, 1: Found)");
            //writeln("-------------------------------------------------------");
        }
        f.close(); // Closing file   
	}
     for(var filePath in files){   
        // Second Reading - Extracting all information
        var f = new IloOplInputFile(filePath);
        if (f.exists) {
            //writeln("\n\n-------------------------------------------------------");
            //writeln("SECOND TIME - Reading file : ", filePath);
            //writeln("\nExtracting all information...")
            //writeln("-------------------------------------------------------");
            while (!f.eof) {
                var line = f.readline();
                var parts = normalizeSpaces(line).split(" ");

        	    if (Opl.card(journees) == 0) {
                    var inf_J = "7h";
                    var sup_J = "21h";
                    journees.add(string_to_minutes_since_seven(inf_J), string_to_minutes_since_seven(sup_J));
                }

                // Case: Addresse - DONE
                else if (parts[0] == "adresse") {
                    // Find the index of the first character after the keyword "adresse"
                    // there are some wrong string espace, pay attention
                    var start = line.indexOf("adresse") + "adresse".length;
                    while (line.charAt(start) == ' ' || line.charAt(start) == '\t') { // Skip all spaces
                        start++;
                    }
                    // Find the position of the first space after the name
                    var end = start;
                    while ((line.charAt(end) != ' ' && line.charAt(end) != '\t') && end < line.length) {
                        end++;
                    }
                    // Extract the patient's name
                    var patient = line.substring(start, end);
                    // The remaining part of the line is the address
                    var adresse = trim(line.substring(end));
                    // Add the patient and address to the addresses map
                    addresses.add(patient, adresse);           
                }
                
                
                // Case: Indisponibilite - DONE
                else if(parts[0]=="indisponibilite"){
                    var parts = normalizeSpaces(line).split(" ");
                    if (parts.length >= 4) {
                        var name = parts[1];
                        var startTime = string_to_minutes_since_seven(parts[2]);
                        var endTime = string_to_minutes_since_seven(parts[3]);
                        indisponibilites.add(name, startTime, endTime);
                    }
                }
            

                // Case: Soins - DONE
                else if(parts[0]=='soins'){

                    // Name of patient
                    var patient = parts[1];

                    // Indicators
                    var splitIndex = parts[2].indexOf(':'); 
                    var split_2_inf = parts[2].indexOf("<<"); 
                    
                    // Case 1: Soins sans contraintes espacements
                    if (splitIndex != -1) {
                        for (var i = 2; i < parts.length; i++) {
                            var splitIndex = parts[i].indexOf(':'); 
                            var part = parts[i];
                            if (part.length != 0) {
                                var treatment_Part = part.substring(0, splitIndex); // TSA+MD1 or PS1
                                var timeSlot_Part = part.substring(splitIndex + 1);

                                var plusIndex = treatment_Part.indexOf("+");
                                if (plusIndex == -1) {
                                    for(var j in journees){
                                        //chercher la duree de treatment_part in acte
                                        for(var a in actes){
                                            if (a.code == treatment_Part){
                                                 treatments.add(patient, treatment_Part, getTimeRange(timeSlot_Part, j.infJ, j.supJ)[0], getTimeRange(timeSlot_Part, j.infJ, j.supJ)[1],a.duree);
                                            }
                                        }
                                       
                                    }
                                }
                                else if (plusIndex != -1) {
                                    var treatment1 = treatment_Part.substring(0, plusIndex);
                                    var treatment2 = treatment_Part.substring(plusIndex + 1);
                                    for(var j in journees){
                                        //pareil, look for these two treatements separately
                                        for(var a in actes){
                                            if (a.code == treatment1){
                                                treatments.add(patient, treatment1, getTimeRange(timeSlot_Part, j.infJ, j.supJ)[0], getTimeRange(timeSlot_Part, j.infJ, j.supJ)[1],a.duree);
                                            }else if(a.code == treatment2){
                                                treatments.add(patient, treatment2, getTimeRange(timeSlot_Part, j.infJ, j.supJ)[0], getTimeRange(timeSlot_Part, j.infJ, j.supJ)[1],a.duree);
                                            }
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                    // Case 2: Soins avec contraintes espacements and ajoute patientTreatment ... 0 780 ....
                    var patientName = parts[1];
                    var previousTreatment = "";
                    var currentTreatment = "";
                    var lowerBound = "";
                    var upperBound = "";
                    var duree1=0;
                    var duree2=0;
                    // Indicators
                    var splitIndex = parts[2].indexOf(':'); 

                    // If ":" does not appear then contraintes espacements case
                    if (splitIndex == -1) {
                        for (var i = 2; i < parts.length; i++) {
                            var part = parts[i];

                            // Check if part is not the constraint (it is the treatment)
                            if (part.indexOf("<<") != -1) {

                                // Adding the previous information
                                if (previousTreatment != "") {
                                    for(var a in actes){
                                        if(a.code==previousTreatment){
                                            duree1 = a.duree;
                                        }else if(a.code==currentTreatment){
                                            duree2 = a.duree;
                                        }
                                    }
                                    contraintes.add(patientName,
                                                    previousTreatment, 
                                                    duree1,
                                                    currentTreatment,
                                                    duree2,
                                                    constraintDetails[0], 
                                                    constraintDetails[1]);
                                    treatments.add(patientName,previousTreatment,0,nurses.sup,duree1);
                                    treatments.add(patientName,currentTreatment,0,nurses.sup,duree2);
                                }

                                // Parse the constraint details - recomputing contraintes espacements
                                var constraintDetails = parseConstraint(part);
                                
                                // Update previous treatment for next round
                                previousTreatment = currentTreatment;
                                currentTreatment = "";  // Reset current treatment after setting a constraint
                            } 
                            else {
                                // No constraint found, this part is a treatment
                                if (currentTreatment == "") {
                                    currentTreatment = part;  // Set current treatment if not already set
                                }
                            }
                        }

                        // Add last constraint if end of parts is another treatment
                        if (currentTreatment != "" && previousTreatment != "") {
                             for(var a in actes){
                                        if(a.code==previousTreatment){
                                            duree1 = a.duree;
                                        }else if(a.code==currentTreatment){
                                            duree2 = a.duree;
                                        }
                                    }
                                    contraintes.add(patientName,
                                                    previousTreatment, 
                                                    duree1,
                                                    currentTreatment,
                                                    duree2,
                                                    constraintDetails[0], 
                                                    constraintDetails[1]);
                                    treatments.add(patientName,previousTreatment,0,nurses.sup,duree1);
                                    treatments.add(patientName,currentTreatment,0,nurses.sup,duree2);
                        }

                    }
                }

            }

            // End of Reading

        }
        f.close(); // Closing file
    
    
    }


        // Obtaining Cadastre from extracted information - Adresses - Using extract_BAN
        // Call the extract BAN function from geoServices.js
        writeln("\n\n\n------------------------------------ START - BAN API CALLING ------------------------------------\n");
        
        // Original Example
        //var jsonBAN = extract_BAN("2 Rue de Paris 91400 Orsay");

        // Loop to obtain the full information from the addresses extracted in the text files
        for (addresse in addresses) {
            var cleaned_address = removeCommas(addresse.adresse);

            var jsonBAN = extract_BAN(cleaned_address);

            // Check if the parsing was successful (at least not empty)
            if (jsonBAN) {

                for(var attribut in jsonBAN){
                    // Definition of variables
                    var features = jsonBAN.features;
                    var query = jsonBAN.query;
                    
                    // Access and process the 'features' data
                    if (attribut == "features"){
                        for(var features_index = 0 ; features_index < features.length; features_index++ ){                             
                            for(var att_feat in features[features_index]){

                                // Case: Type
                                if(att_feat == "type" || att_feat == "toString")
                                    continue;

                                // Case: Geometry
                                else if(att_feat == "geometry"){
                                    for(var att_geo in features[features_index][att_feat]) {

                                        if (att_geo == "type")
                                            continue;
                                        
                                        else if(att_geo == "coordinates") {
                                            var longitude = features[features_index][att_feat][att_geo][0];
                                            var latitude = features[features_index][att_feat][att_geo][1];
                                        }
                                    }
                                }
                                
                                // Case: Properties
                                else if(att_feat == "properties"){
                                    for(var att_prop in features[features_index][att_feat]) {
                                        // Case: Postal Code
                                        if (att_prop == "postcode") {
                                            var postalCode = features[features_index][att_feat][att_prop];
                                        }

                                        else if (att_prop == "city") {
                                            var city = features[features_index][att_feat][att_prop];
                                        }
                                    }
                                }
                            }
                        }
                    }

                    else if (attribut == "query") {
                        var place = addresse.patient;
                    }
                    else if (attribut == "attribution" || attribut == "licence" || attribut == "limit") {
                        continue;
                    }
                }
                
                // Storing the information
                addresses_full_info.add(latitude, longitude, place, postalCode, city, "France");
            } 
            else {
                writeln("Failed to parse JSON");
            }
        }

        writeln("\n------------------------------------ END - BAN API CALLING ------------------------------------\n\n");


        


    // Obtaining durations between places from extracted information - allDurations - Using osrm_table

    // Call the OSRM API table function from geoServices.js
    writeln("\n\n------------------------------------ START - OSRM API CALLING ------------------------------------\n");

    var concatenatedCoordinates = formatCoordinates(addresses_full_info) // Instead of latitude,longitude the API needs longitude,latitude

    // Loop to obtain the full information from the addresses extracted in the text files
    var jsonOSRM_durations = osrm_table(concatenatedCoordinates, serverAddress, option_duration);

    // Processing of jsonOSRM_durations

    // Check if the parsing was successful and the response code is 'Ok'
    if (jsonOSRM_durations.code == "Ok") {

        for(var attribut in jsonOSRM_durations){
            // Définition des variables des attributs
            var destinations = jsonOSRM_durations.destinations;
            var durations = jsonOSRM_durations.durations;
            
            // Access and process the 'destinations' data in order to extract the fields name, latitude, longitude
            // Access and process the 'durations' data
            
            // durations: [
            // [0,729.8,288.8,645.1],
            // [729.8,0,897.2,475.1],
            // [276.3,898.3,0,711.9],
            // [654.2,468.4,725.7,0] ]
            
            // duration[0][0] = 0 secondes pour de déplacer du point 0 au point 0: (2.036030,48.5224235)
            // duration[0][1] = 729.8 secondes pour se déplacer de (2.036030,48.5224235) (index 0) au premier point (2.121720,48.554347) (index 1)
        
            // Sometimes the name is empty in the JSON extraction - I don't know why
            // I checked by cleaning the name of the place (removing commas) but doesn't change the outcome
            
            for(var i = 0; i < destinations.length; i++) {
                for(var j = 0; j < destinations.length; j++) {
                    if(i != j){
                        // Access and process the 'durations' data
                        var durationValue = Math.round(durations[i][j] / 60.0); // Duration from point i to point j
                        
                        
                        if (destinations[i].name == "") {
                            var counter = 0;
                            for (addresse in addresses_full_info) {
                                if (counter == i) {
                                    var temp_name_1 = addresse.place;
                                }
                                counter +=1;
                            }
                            var counter =0;
                            for (addresse in addresses_full_info) {
                                if (counter == j) {
                                    var name_2 = addresse.place;
                                }
                                counter +=1;
                            }
                            allDurations.add(temp_name_1, name_2, durationValue);
                        }
                        else if (destinations[j].name == "") {
                            var counter = 0;
                            for (addresse in addresses_full_info) {
                                if (counter == j) {
                                    var temp_name_2 = addresse.place;
                                }
                                counter +=1;
                            }
                            var counter = 0;
                            for (addresse in addresses_full_info) {
                                if (counter == i) {
                                    var name_1 = addresse.place;
                                }
                                counter +=1;
                            }
                            allDurations.add(name_1, temp_name_2, durationValue);
                        }
                        else 
                            var counter = 0;
                            for (addresse in addresses_full_info) {
                                if (counter == i) {
                                    var name_1 = addresse.place;
                                }
                                counter +=1;
                            }
                            var counter =0;
                            for (addresse in addresses_full_info) {
                                if (counter == j) {
                                    var name_2 = addresse.place;
                                }
                                counter +=1;
                            }

                            // Storing the information
                            allDurations.add(name_1, name_2, durationValue);
                    }
                }
            }        
        }
    } 
    else {
        writeln("Failed to parse JSON or response code is not 'Ok'");
    }
}


/************************************************************************
* Preprocessing on instance data 
************************************************************************/

{string} patientNames = {travel.From | travel in allDurations}; // DONE
int countPatient = card(patientNames); // Number of unique patients + cabinet // DONE
int travel_times[patientNames][patientNames] = [ travel.From : [travel.To : travel.duration] | travel in allDurations];
range rangeMinutes = nurses.inf..nurses.sup;  //define the work time according to the nurse
int duree_transmission = 2*(countPatient -1);  //calcul how many patients who needed to treat

/************************************************************************
* Decision variables
************************************************************************/

// Decision variables
dvar interval treatmentIntervals[pt in treatments] in 
    ((nurses.inf > pt.infJ)?nurses.inf:pt.infJ) .. ((nurses.sup < pt.supJ)?nurses.sup:pt.supJ) size pt.duration;

dvar int workStart in rangeMinutes;
dvar int workEnd in rangeMinutes;
dvar interval transDonnees in rangeMinutes size duree_transmission;

// 定义 step function
stepFunction forbiddenTimes[i in indisponibilites] = stepwise{ 1->i.inf; 0->i.sup; 1 };

/************************************************************************
* Contraints and Objective					(NB : cannot be shared)
************************************************************************/

minimize workEnd - workStart;

// Constraints
subject to {

       // ******************************* START ANSWER 2 *************************************

    // Determine the start and end of work based on scheduled treatments
    workStart == min(pt in treatments) (startOf(treatmentIntervals[pt]) - travel_times["cabinet"][pt.name]);
    workEnd == endOf(transDonnees);

    // Ensure no overlapping treatments for any patient
    noOverlap(treatmentIntervals);

    // travel time
    forall (i, j in treatments : i != j){
		  endOf(treatmentIntervals[i])  + travel_times[i.name][j.name] <= startOf(treatmentIntervals[j]) 
      || endOf(treatmentIntervals[j]) + travel_times[i.name][j.name] <= startOf(treatmentIntervals[i]);
	  }

    // Déplacement pour les transmissions
	  forall (i in treatments) {
		  endOf(treatmentIntervals[i])  + travel_times[i.name]["cabinet"] <= startOf(transDonnees);
	  }


    // Contraintes d'espacements    
    forall(e in contraintes) {
      forall(p1,p2 in treatments:p1!=p2) {
        if (p1.name == e.name && p2.name == e.name && p1.treatment == e.treatment1 && p2.treatment == e.treatment2) {
                  (endBeforeStart(treatmentIntervals[p1],treatmentIntervals[p2],e.lowerBound));
                  //(endBeforeStart(treatmentIntervals[p2],treatmentIntervals[p1],e.lowerBound));
        }
      }
    }

    
    
    // appliquer step functions pour indisponibilites patient
    forall(pt in treatments) {
        forall(ind in indisponibilites: pt.name == ind.nom) {
            forbidStart(treatmentIntervals[pt], forbiddenTimes[ind]);
            forbidEnd(treatmentIntervals[pt], forbiddenTimes[ind]);
        }
    }

    // pour nurse indispo
    forall(pt in treatments) {
        forall(ind in indisponibilites: nurses.name == ind.nom) {
                forbidStart(treatmentIntervals[pt], forbiddenTimes[ind]);
                forbidEnd(treatmentIntervals[pt], forbiddenTimes[ind]);
                 workStart>=ind.sup || workStart <= ind.inf;
            }
    }
    // ******************************* END ANSWER 2 *************************************
}

/************************************************************************
* Flux Control (if required)
************************************************************************/

/* TODO */

/************************************************************************
* PostTreatement
************************************************************************/

execute{
     // Construct the new output file path
    outputPath = "../../../results/" + instance.name + "_visits2.dat";
    var output = new IloOplOutputFile(outputPath);
	output.writeln("Début de la journée : ", convertMinutesToHourSince7(workStart));
	output.writeln("Fin de la journée : ", convertMinutesToHourSince7(workEnd));
	for (var i in treatments){
		output.writeln("Soin pour le patient ", i.name, " : ", i.treatment, " de ", convertMinutesToHourSince7(Opl.startOf(treatmentIntervals[i])), " à ", convertMinutesToHourSince7(Opl.endOf(treatmentIntervals[i])), " | Original window: [", convertMinutesToHourSince7(i.infJ), ",", convertMinutesToHourSince7(i.supJ), "]", " | ", "Treatment Duration: ", i.duration, " minutes");
    }
    for (var j in indisponibilites) {
            //writeln("j ", j.nom, " i ", i.name)
            if (j.nom == i.name)
            output.writeln(" | ", "Unvailability Window for ",j.nom,":  [", convertMinutesToHourSince7(j.inf), ",", convertMinutesToHourSince7(j.sup), "]");
            else if(j.nom == nurses.name)
            output.writeln(" | ", "Unvailability Window for ",j.nom,":  [", convertMinutesToHourSince7(j.inf), ",", convertMinutesToHourSince7(j.sup), "]");
        }
    output.writeln("Transmission des données de ", convertMinutesToHourSince7(Opl.startOf(transDonnees)), " à ", convertMinutesToHourSince7(Opl.endOf(transDonnees)));
	output.close();
     //remove the tmp file
    var answer_tmp_file = "answer_ban.json";
    IloOplExec("rm " + answer_tmp_file);
}
