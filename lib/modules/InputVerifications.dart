bool validEmail(String entry) => RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(entry);

bool validPassword(String entry) => (entry.length >= 6);

bool validPhone(String entry) => RegExp(r'(\+44\s?7\d{3}|\(?07\d{3}\)?)\s?\d{3}\s?\d{3}').hasMatch(entry);

bool validHour(int hour) => hour >= 0 && hour < 24;
