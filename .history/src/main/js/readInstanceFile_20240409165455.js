function lireInstanceFichier(fichier) {
    var file = new File(fichier);
    var reader = new FileReader();
    reader.onload = function(e) {
        var contents = e.target.result;
        alert(contents);
    };
    reader.readAsText(file);
}