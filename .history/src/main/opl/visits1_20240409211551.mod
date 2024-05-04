/************************************************************************
* IALC2 2023-24 Project
* Binome : Junjie CHEN
*          Molla  Pablo
*
* Modèle : visits1.mod
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

{Journee} journee = ...;
{Infirmiere} infirmieres = ...;
{Indisponibilite} indisponibilites = ...;
{Soin} soins = ...;
{Espacement} espacements = ...; 
{Adresse} adresses = ...; // Structure pour les adresses 
{Acte} actes = ...;  // Structure pour les actes

execute {  
	includeScript("../js/readInstanceFile.js");		
			// includes script within script blocs - typically script functions
	file
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

