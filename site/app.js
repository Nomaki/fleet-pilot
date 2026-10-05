// Logique du site, sans dépendance ; testée par node --test (test/app.test.js).

export function greeting(date) {
  const hour = date.getHours();
  if (hour < 12) return "Bonjour !";
  if (hour < 18) return "Bel après-midi !";
  return "Bonsoir !";
}
