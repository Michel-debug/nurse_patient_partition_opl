tuple Etape {
	string infirmiere;
	int	etape;			// numéro d'étape pour le tour de l'infirmière (0 pour la premier passage au cabinet)
	string visite;		// Nom Patient ou "cabinet" (au début et à la fin)
	string adresse; 	// Adresse (au format string) du patient ou du cabinet
	float latitude; 	// Latitude de l'adresse 
	float longitude;	// Longitude de l'adresse 
	string description;	// codes de soins ou "Depart Bureau" ou "Transmissions"
	int debut;      	// horaire (en mn) du début des soins (entier compris entre 0 et 1439)
	int duree;      	// (en mn) ou  0 ou duréeTransmissions
	int fin;      		// horaire (en mn) du début des soins (entier compris entre 0 et 1439)
	int transit; 		// vers l'étape suivante (O si c'est la dernière étape)
}

tuple GeoPoint {
	float latitude;
	float longitude;
}