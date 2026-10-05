@AGENTS.md

## Spécificités Claude Code

- Les skills de la flotte (`fleet-task`, `fleet-guardrails`) sont installées dans le dossier de compte ; utilise `fleet-task` pour toute tâche confiée.
- Un refus qui commence par `fleet guard :` vient du hook commun : ne le contourne pas, signale-le.
- Les commandes shell tournent dans la sandbox (fichiers limités à la worktree, réseau sur liste blanche) ; un échec réseau ou d'écriture hors worktree est voulu.
