Ces structures vont modéliser les différents éléments décrits, tels que les horaires de journée, les informations sur les infirmières, les indisponibilités, les soins, les adresses, et les actes.
// Structure pour les horaires de la journée
tuple Journee{
  string infJ;
  string supJ;
}

// Structure pour les infirmières 
tuple Infirmiere {
  string nom;
  string inf;
  string sup;
}

// Structure pour les indisponibilités
tuple Indisponibilite {
  string nom;
  string inf;
  string sup;
}


// Structure pour les soins
// Pour représenter les soins avec les contraintes d’espacement et les créneaux horaires optionnels, on utilise deux tuples, l'un pour les soins et l'autre pour les contraintes d’espacement, et les lier à chaque patient :
tuple Soin {
  string patient;
  string codeSoin; // Peut contenir plusieurs codes séparés par des "+"
  string creneau; // Optionnel, peut être une chaîne vide
  // Structure pour les contraintes d'espacement
  string inf;  
  string sup; 
}



// Structure pour les adresses 
tuple Adresse {
  string patient; // Peut être "cabinet" pour l'adresse du cabinet
  string adresse;
}

// Structure pour les actes
tuple Acte {
  string code;
  int duree;
  string description;
}
