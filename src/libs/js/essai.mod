// Use an execute block to include external JavaScript files

execute {
    // Assuming you have a way to include external JS files directly
    includeScript("files.js");
    includeScript("simpleJSONParser.js");
    includeScript("geoServices.js");
    
    // Now, call a function defined in the included files
    var coordinates = "2.036030,48.5224235;2.121720,48.554347;2.014160,48.523597;2.057541,48.5634484"; // 3 places
    var serverAddress = "router.project-osrm.org";
    
    // Call the OSRM table function from geoServices.js
    var jsonData = osrm_table(coordinates, serverAddress);
    writeln(jsonData);
    writeln("\n\n-----------------------------------------------------")
    for (var val in jsonData) {
        var matrix = val;
        writeln(val)        
    }


    // Check if the parsing was successful and the response code is 'Ok'
    if (jsonData.code == "Ok") {
        writeln("INSIDE")

        // Access and process the 'destinations' data
        var destinations = jsonData.destinations;
        for(var attribut in jsonData){  // retirer all the attribut like destinations, durations, code, sources,  
        //tostring() et tostring() is a fonction when we call item, it's automatique, we dont care it
          //  writeln("attribut ",attribut," ",jsonData[attribut]);  //il faut utiliser  [expression] !!!!!!!!!!!!, attribut juste string, pas objet!!!!!!!!!!!!!!!!!!
            if (attribut == "destinations"){// destinations is an array objet
                for(var index = 0 ; index < jsonData[attribut].length; index++ ){ // on ne peut pas utiliser  a in b, c pas correct
                    writeln("\ndestinations ",index);
                    writeln("=================================");
                    for(var d in jsonData[attribut][index]){  // for each item, it's a array, we should read array with expression like t[expression] pour extraire les donnes !!!!!!  
                        if(d == "toString") continue; // on s'en fous
                        else if(d == "location"){  // location is a array in destination[index], so we should iterative it,ifnot he will return object
                            write(d," : ");
                            for(var dindex = 0; dindex < jsonData[attribut][index][d].length; dindex++){
                                 write(jsonData[attribut][index][d][dindex]," ");
                            }
                            writeln();
                        }
                        else{
                            writeln(d," : ",jsonData[attribut][index][d]);  // we use this item to ask
                        }
                    }
                      writeln("=================================");
                }
            }
            else if (attribut == "sources"){// sources is an array objet
                for(var index = 0 ; index < jsonData[attribut].length; index++ ){ // on ne peut pas utiliser  a in b, c pas correct
                    writeln("\nsources ",index); 
                    writeln("=================================");
                    for(var d in jsonData[attribut][index]){  // for each item, it's a array, we should read array with expression like t[expression] pour extraire les donnes !!!!!!  
                        if(d == "toString") continue; // on s'en fous
                        else if(d == "location"){  // location is a array in destination[index], so we should iterative it,ifnot he will return object
                            write(d," : ");
                            for(var dindex = 0; dindex < jsonData[attribut][index][d].length; dindex++){
                                 write(jsonData[attribut][index][d][dindex]," ");
                            }
                            writeln();
                        }
                        else{
                            writeln(d," : ",jsonData[attribut][index][d]);  // we use this item to ask
                        }
                    }
                      writeln("=================================");
                }
            }
            else if(attribut == "durations"){       
                for(var index = 0 ; index < jsonData[attribut].length; index++ ){ // on ne peut pas utiliser  for(a in b),  pas correct,
                      writeln("\ndurations",index);
                      writeln("=================================");
                     for(var iindex = 0 ; iindex < jsonData[attribut][index].length; iindex++){
                              writeln(jsonData[attribut][index][iindex]);
                     }
                      writeln("=================================");
                }
            }
            writeln();
        }
        
    } 
    else {
        console.log("Failed to parse JSON or response code is not 'Ok'");
    }
   }