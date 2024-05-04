// ------------------ EmacsScript function on files -----------------

/** Reads a file and returns its content as a string 
 * @param {string} a file path
 * @return {string} the content of the file as s string
 */
function file_to_string(file) {
	var f = new IloOplInputFile(file);
    if (f.exists) {
 //     writeln("INFO - Reading file : ", fichier );
      var s = "";
      while (!f.eof) {
        s = s  + f.readline() +"\n";
      }
      f.close();	// Closing file
    }
    else
      writeln("\nWARNING : the file ", fichier," doesn't exist");
	return s;
}
module.exports.file_to_string = file_to_string;


