
bool validEmail (String entry) => RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(entry);

bool validPassword (String entry) => (entry.length >= 6);

bool validPhone (String entry) => RegExp(r'^\+?\d{1,3}-?\d{3}-?\d{3}-?\d{4}$').hasMatch(entry);

