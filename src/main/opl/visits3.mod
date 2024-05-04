/************************************************************************
* IALC2 2023-24 Project
* Binome : Nom1 Nom 2 	(TODO)
*
* Modèle : visits3.mod
*
* Description : (TODO)
*
************************************************************************/

using CP;

string modelName = "visits3";

/************************************************************************
* Solver parameter tuning
************************************************************************/

/* TODO */

/************************************************************************
* Instance data
************************************************************************/

include "structures/instances.mod"

Instance instance = ...;		/* instance de problème à résoudre */

/************************************************************************
* Reading instance content
************************************************************************/

include "structures/inputs.mod";

execute {  
	includeScript("../js/readInstanceFile.js");		
			// includes script within script blocs - typically script functions
	
	// TODO - call a script function that is able to open the .txt
	// files describing instance data... read their content 
	// and store those information into appropriate OPL structures, 
	// defined on purpose
	
	// Part of it can be shared among models	
}

/************************************************************************
* Preprocessing on instance data 
************************************************************************/

/* TODO 
	Define more convenient structures for describing instance data
	(if required) 
	and pre-process data for feeding the model.

	// Part of it can be shared among models	
*/


/************************************************************************
* Decision variables
************************************************************************/

/* TODO */

/************************************************************************
* Contraints and Objective					(NB : cannot be shared)
************************************************************************/

/* TODO */


/************************************************************************
* Flux Control (if required)
************************************************************************/

/* TODO */

/************************************************************************
* PostTreatement
************************************************************************/

/* TODO */

