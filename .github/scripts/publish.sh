#!/usr/bin/env bash
# Publie un dossier sur la branche gh-pages (servie par GitHub Pages).
#   publish.sh <dossier-source> <cible>   cible = « . » (prod, racine) ou « pr-<n> » (staging)
#   publish.sh --remove pr-<n>            retire le staging d'une PR fermée
# La racine garde les dossiers pr-* ; un staging ne touche que son dossier.
# Toujours lancé depuis la copie de main (code de confiance) : il copie les fichiers d'une PR,
# il ne les exécute jamais. Le jeton vient de GITHUB_TOKEN (variable GH_TOKEN).
set -euo pipefail

remove=false
if [[ "${1:-}" == "--remove" ]]; then remove=true; shift; fi
if $remove; then src=""; target="${1:?cible manquante}"; else src="${1:?source manquante}"; target="${2:?cible manquante}"; fi
[[ "$target" == "." || "$target" =~ ^pr-[0-9]+$ ]] || { echo "cible invalide : $target" >&2; exit 1; }

work="$(mktemp -d)"
remote="https://x-access-token:${GH_TOKEN:?GH_TOKEN manquant}@github.com/${GITHUB_REPOSITORY:?}.git"
if git ls-remote --exit-code --heads "$remote" gh-pages >/dev/null 2>&1; then
  git clone --quiet --depth 1 --branch gh-pages "$remote" "$work"
else
  git -C "$work" init --quiet -b gh-pages
  git -C "$work" remote add origin "$remote"
fi
touch "$work/.nojekyll"

if $remove; then
  rm -rf "${work:?}/$target"
elif [[ "$target" == "." ]]; then
  rsync -a --delete --exclude '.git' --exclude '.nojekyll' --exclude 'pr-*/' "$src/" "$work/"
else
  mkdir -p "$work/$target"
  rsync -a --delete "$src/" "$work/$target/"
fi

cd "$work"
git add -A
if git diff --cached --quiet; then echo "gh-pages : rien à publier"; exit 0; fi
git -c user.name="github-actions[bot]" -c user.email="41898282+github-actions[bot]@users.noreply.github.com" \
  commit --quiet -m "Publication ${target} (${GITHUB_SHA:0:7})"
git push --quiet origin gh-pages
echo "gh-pages : ${target} publié"
