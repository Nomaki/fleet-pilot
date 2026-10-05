# fleet-pilot

Site statique jouet de la flotte d'agents. Il valide le chemin complet : demande Telegram → PR d'agent → revue croisée → staging automatique → prod après approbation.

| Où | Quoi |
| --- | --- |
| https://nomaki.github.io/fleet-pilot/ | prod (`main`, après approbation de l'environnement `production`) |
| https://nomaki.github.io/fleet-pilot/pr-&lt;n&gt;/ | staging de la PR `<n>`, publié quand sa CI est verte |

- Tests : `node --test`
- Code du site : `site/`
- Instructions des agents : `AGENTS.md`
- Réglages du repo : `docs/pilot.md` du repo `fleet`
