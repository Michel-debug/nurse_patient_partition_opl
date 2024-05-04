// Ces structures vont modéliser les différents éléments décrits, tels que les horaires de journée, les informations sur les infirmières, les indisponibilités, les soins, les adresses, et les actes.

// Structure pour les horaires de la journée en float - DONE
tuple Journee{
  int infJ;
  int supJ;
}

// Structure pour les infirmières - DONE
tuple Infirmiere {
  string name;
  int inf;
  int sup;
}

// Structure pour les indisponibilités - DONE
tuple Indisponibilite {
  string nom;
  int inf;
  int sup;
}


// Structure pour les adresses - DONE
tuple Adresse {
  string patient; // Peut être "cabinet" pour l'adresse du cabinet
  string adresse;
}

// Structure pour les actes - DONE
tuple Acte {
  string code;
  int duree;
  string description;
}

// Structure pour les traitements - DONE
tuple PatientTreatment {
  string name;
  string treatment;  // Treatment code
  int infJ;         
  int supJ;
  int duration;       
}

// Structure pour les contraintes espacements - DONE
tuple Contraintes {
  string name;  
  string treatment1;
  int duree1;
  string treatment2;
  int duree2;
  int lowerBound;     // Lower bound time limit
  int upperBound;     // Upper bound time limit
}


// Structure for durations
tuple Durations {
  string From;
  string To;
  int duration;
}


