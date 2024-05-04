using CP;

string modelName = "visits1";

include "structures/instances.mod"

Instance instance = ...;	

include "structures/inputs.mod";


{Journee} journee = ...;

execute {   
    includeScript("../js/readInstanceFile.js");
    	 
}