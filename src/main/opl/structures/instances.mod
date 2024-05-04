// ------------------------ Structures  ------------------------------------

// -----------------------  Instances Descriptions --------------------------
tuple Instance {
    string name;			// name of the instance
    {string} files;			// set of file paths with raw data describing the instance 
}


// -------------- Geocoding Data extracted from the cadastre registry -------------------

tuple CadastreAddress {
	float	latitude;
	float	longitude;
	string	place;
	int 	postalCode;
	string	city;
	string	country;
}
