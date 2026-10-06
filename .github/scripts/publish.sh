#!/usr/bin/env bash
# Publie un dossier sur la branche gh-pages (servie par GitHub Pages).
#   publish.sh <dossier-source> <cible>   cible = « . » (prod, racine) ou « pr-<n> » (staging)
#   publish.sh --remove pr-<n>            retire le staging d'une PR fermée
# La racine garde les dossiers pr-* ; un staging ne touche que son dossier.
# Toujours lancé depuis la copie de main (code de confiance) : il copie les fichiers d'une PR,
# il ne les exécute jamais. Le jeton vient de GITHUB_TOKEN (variable GH_TOKEN).
# Prod, staging et nettoyage ont chacun leur groupe de concurrence : si un autre push passe
# entre-temps, la publication est refaite sur la nouvelle tête de gh-pages (5 essais).
set -euo pipefail

remove=false
if [[ "${1:-}" == "--remove" ]]; then remove=true; shift; fi
if $remove; then src=""; target="${1:?cible manquante}"; else src="$(cd "${1:?source manquante}" && pwd)"; target="${2:?cible manquante}"; fi
[[ "$target" == "." || "$target" =~ ^pr-[0-9]+$ ]] || { echo "cible invalide : $target" >&2; exit 1; }

# PUBLISH_REMOTE : dépôt de test (test/publish.test.sh) ; sinon le repo GitHub du workflow.
remote="${PUBLISH_REMOTE:-https://x-access-token:${GH_TOKEN:?GH_TOKEN manquant}@github.com/${GITHUB_REPOSITORY:?}.git}"

publish_once() {
  local work
  work="$(mktemp -d)"
  if git ls-remote --exit-code --heads "$remote" gh-pages >/dev/null 2>&1; then
    git clone --quiet --depth 1 --branch gh-pages "$remote" "$work" || return 1
  else
    git -C "$work" init --quiet -b gh-pages
    git -C "$work" remote add origin "$remote"
  fi
  touch "$work/.nojekyll"

  if $remove; then
    rm -rf "${work:?}/$target"
  elif [[ "$target" == "." ]]; then
    rsync -a --checksum --delete --exclude '.git' --exclude '.nojekyll' --exclude 'pr-*/' "$src/" "$work/" || return 1
  else
    mkdir -p "$work/$target"
    rsync -a --checksum --delete "$src/" "$work/$target/" || return 1
  fi

  git -C "$work" add -A
  if git -C "$work" diff --cached --quiet; then echo "gh-pages : rien à publier"; return 0; fi
  git -C "$work" -c user.name="github-actions[bot]" -c user.email="41898282+github-actions[bot]@users.noreply.github.com" \
    commit --quiet -m "Publication ${target} (${GITHUB_SHA:0:7})" || return 1
  git -C "$work" push --quiet origin gh-pages
}

for attempt in 1 2 3 4 5; do
  if publish_once; then echo "gh-pages : ${target} publié"; exit 0; fi
  echo "gh-pages : push refusé (essai $attempt), nouvelle tentative" >&2
  sleep $((attempt * 3))
done
echo "gh-pages : publication de ${target} impossible" >&2
exit 1
