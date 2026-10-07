#!/usr/bin/env bash
# Publie le SNAPSHOT mobile fr.skullbox:customnameplates:<project_version>-SNAPSHOT (jar du plugin, pom sans
# dépendances) sur GitHub Packages, après avoir élagué. Lancé après le build, sur la branche par défaut. Rien
# n'est à remettre en état : la version de release passe par -Pproject_version, absente ici, donc le build
# publie la version committée de gradle.properties, suffixée -SNAPSHOT (project_version n'est pas un SNAPSHOT
# et une version fixe ne peut pas être republiée : HTTP 409).
#
# Seul le module :platforms:bukkit publie. Le module :api a une publication amont (repo.momirealms.net) : on ne
# lance jamais « ./gradlew publish » à la racine.
#
# Élagage : chaque publication AJOUTE des fichiers horodatés (customnameplates-3.0.37-AAAAMMJJ.hhmmss-N.*) à la
# MÊME version -SNAPSHOT du paquet ; l'API ne permet pas d'en supprimer un seul. Quand le compteur de
# publications (buildNumber de maven-metadata.xml) atteint SNAPSHOT_MAX, on supprime donc le paquet entier
# (derniers fichiers compris), puis on republie : il repart à 1 publication.
# Quota : 500 Mo pour toute l'org ; on vise ~20 Mo pour ce dépôt : SNAPSHOT_MAX = floor(20 Mo / taille d'une
# publication), plafonné à 10, fixé par l'environnement de l'étape dans ci.yml.
# Environnement : GH_TOKEN (packages: write), MAVEN_USERNAME/MAVEN_TOKEN (auth du dépôt « GitHubPackages » de
#                 platforms/bukkit/build.gradle.kts), GITHUB_REPOSITORY ; SNAPSHOT_MAX (défaut 10).
set -euo pipefail
max="${SNAPSHOT_MAX:-10}"
org="${GITHUB_REPOSITORY%%/*}"
registry="https://maven.pkg.github.com/$GITHUB_REPOSITORY"
# groupId:artifactId de la publication de platforms/bukkit/build.gradle.kts
packages=(fr.skullbox:customnameplates)

project_version=$(sed -n 's/^project_version=//p' gradle.properties | tr -d '[:space:]')
version="${project_version%-SNAPSHOT}-SNAPSHOT"

for p in "${packages[@]}"; do
  group="${p%%:*}"; artifact="${p##*:}"
  meta="$registry/${group//.//}/$artifact/$version/maven-metadata.xml"
  n=$(curl -sS -u "x:$GH_TOKEN" "$meta" | sed -n 's#.*<buildNumber>\([0-9]*\)</buildNumber>.*#\1#p' | head -1)
  n="${n:-0}"
  echo "$group.$artifact $version : $n publication(s) depuis la création de la version"
  if [ "$n" -ge "$max" ]; then
    echo "Élagage : suppression du paquet $group.$artifact (seuil $max)"
    gh api -X DELETE "orgs/$org/packages/maven/$group.$artifact"
  fi
done

./gradlew --console=plain :platforms:bukkit:publish -x test
