#!/usr/bin/env bash
# Release initiale : à lancer UNE fois, sur la branche par défaut, tant qu'aucun tag v* n'existe.
# Numérotée d'après project_version de gradle.properties sans -SNAPSHOT, complétée à 3 composants
# (3.0.37 -> v3.0.37), avec le jar construit par ce run. semantic-release prend ensuite le relais à partir de ce
# tag (sans cela, il commencerait à 1.0.0). No-op si un tag v* existe déjà.
# Usage : initial-release.sh <sha>     Environnement : GH_TOKEN, GITHUB_REPOSITORY
# Écrit .release-version si la release a été créée (même contrat que le prepareCmd de semantic-release).
set -euo pipefail
sha="${1:?usage: initial-release.sh <sha>}"

if [ -n "$(git tag -l 'v[0-9]*')" ]; then
  echo "Un tag v* existe déjà : pas de release initiale"
  exit 0
fi

# Version du projet : la valeur committée (un -P sur la ligne de commande n'est pas passé ici). Le projet est
# multi-modules : « gradlew properties » ne donnerait que « unspecified » pour la racine.
project_version=$(sed -n 's/^project_version=//p' gradle.properties | tr -d '[:space:]')
base="${project_version%-SNAPSHOT}"
version=$(awk -F. '{ printf "%d.%d.%d\n", $1, ($2==""?0:$2), ($3==""?0:$3) }' <<<"$base")
tag="v$version"
echo "Version du projet $project_version -> release initiale $tag"

bash "$(dirname "$0")/build.sh" "$version"

gh release create "$tag" \
  "target/CustomNameplates-Bukkit-$version.jar" \
  --target "$sha" --title "$tag" --latest \
  --notes "Release initiale, numérotée d'après la version du projet ($project_version). Les suivantes sont calculées par semantic-release à partir des commits."
echo "$version" > .release-version
