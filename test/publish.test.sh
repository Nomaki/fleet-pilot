#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2329 # vérifications passées à eval, évaluées dans check
# Test de .github/scripts/publish.sh contre un dépôt git local (aucun réseau) :
# prod à la racine, staging dans pr-<n>, prod qui garde les pr-*, retrait d'un staging.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
publish="$here/../.github/scripts/publish.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
git init --quiet --bare "$tmp/remote.git"
export PUBLISH_REMOTE="file://$tmp/remote.git" GITHUB_SHA=0123456789abcdef
mkdir -p "$tmp/v1" "$tmp/v2" "$tmp/pr"
echo v1 > "$tmp/v1/index.html"; echo v2 > "$tmp/v2/index.html"; echo pr > "$tmp/pr/index.html"
fail=0
check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }
show() { git --git-dir="$tmp/remote.git" show "gh-pages:$1" 2>/dev/null; }

"$publish" "$tmp/v1" . >/dev/null
check "prod publiée à la racine" '[[ "$(show index.html)" == v1 ]]'
"$publish" "$tmp/pr" pr-7 >/dev/null
check "staging dans pr-7" '[[ "$(show pr-7/index.html)" == pr ]]'
"$publish" "$tmp/v2" . >/dev/null
check "nouvelle prod" '[[ "$(show index.html)" == v2 ]]'
check "la prod garde les pr-*" '[[ "$(show pr-7/index.html)" == pr ]]'
"$publish" --remove pr-7 >/dev/null
check "staging retiré" '! show pr-7/index.html >/dev/null'
check "cible invalide refusée" '! "$publish" "$tmp/v1" ../x 2>/dev/null'

exit $fail
