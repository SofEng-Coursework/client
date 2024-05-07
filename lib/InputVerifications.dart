
bool validEmail (String entry) {return RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(entry);}

bool validPassword (String entry) {return (entry.length >= 6);}

bool validPhone (String entry) {return RegExp(r'^\+?\d{1,3}-?\d{3}-?\d{3}-?\d{4}$').hasMatch(entry);}

