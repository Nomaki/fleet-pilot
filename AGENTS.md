# fleet-pilot

Site statique jouet de la flotte : il sert à vérifier le chemin complet demande → PR d'agent → revue croisée → staging → prod approuvée.

## Projet

- Langage, version (fichier qui la fixe) : HTML, CSS et JavaScript sans dépendance ; Node pour les tests (`.nvmrc`)
- Installer : rien à installer
- Tests : `node --test` (site) et `test/publish.test.sh` (publication sur gh-pages) ; lint : aucun
- Où vit le code, où vivent les tests : le site dans `site/` (publié tel quel), les tests dans `test/`
- Conventions propres au repo :
  - la logique va dans `site/app.js`, en fonctions pures exportées, chacune testée dans `test/app.test.js` ;
  - `.github/` (workflows, scripts de publication, CODEOWNERS) n'est jamais modifié par un agent ;
  - le staging d'une PR est publié sur `https://<propriétaire>.github.io/fleet-pilot/pr-<n>/`, la prod à la racine.

<!-- fleet:common:start — bloc commun de la flotte, copié depuis kit/AGENTS.md.template ; le modifier là-bas -->
## Règles de la flotte

Tu es un agent de la flotte. Ces règles valent quel que soit le harness (Claude Code, Codex, Hermes) et le mode de permissions ; des garde-fous les imposent. Détail et conduite à tenir en cas de refus : skill `fleet-guardrails`.

1. **Jamais la prod** : pas de `terraform apply`/`destroy`, pas de `kubectl delete`, rien sur un contexte ou un profil prod. La prod passe par la CI, avec approbation humaine.
2. **Jamais sur `main`** : une branche par tâche (`agent/<sujet>`), un push de cette branche, une PR. Pas de push forcé, pas de `gh pr merge`.
3. **Jamais de secret** : ne lis, ne copie ni ne source aucun fichier `.env*` ; pas de Trousseau, pas de `doppler` hors `doppler run --token`. N'écris aucun secret dans le code, un log ou un message.
4. **Une worktree par tâche** : reste dans ton dossier de travail ; ne touche pas aux dossiers de config des harness (`~/.claude*`, `~/.codex`, `~/.hermes`).
5. **Test d'abord** : toute modification passe par un test ; la suite complète doit passer avant le commit.
6. **Rapport** : termine par ce qui a changé, la commande de test et son résultat, ce qui reste ouvert, et tout refus de garde-fou rencontré.
7. **Pas de nouvelle dépendance** sans que la demande le dise.
<!-- fleet:common:end -->
