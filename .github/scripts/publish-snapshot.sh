#!/usr/bin/env bash
# Publie le SNAPSHOT mobile fr.skullbox:customnameplates:<project_version>-SNAPSHOT (jar du plugin, pom sans
# dépendances) sur Reposilite (https://maven.skullbox.fr/snapshots). Lancé après le build, sur la branche par
# défaut. Rien n'est à remettre en état : la version de release passe par -Pproject_version, absente ici, donc
# le build publie la version committée de gradle.properties, suffixée -SNAPSHOT (project_version n'est pas un
# SNAPSHOT et une version fixe ne peut pas être republiée : HTTP 409).
#
# Seul le module :platforms:bukkit publie. Le module :api a une publication amont (repo.momirealms.net) : on ne
# lance jamais « ./gradlew publish » à la racine.
#
# Pas d'élagage : Reposilite ne garde que le dernier build horodaté d'une version -SNAPSHOT.
# Environnement : MAVEN_USERNAME/MAVEN_TOKEN (jeton d'écriture Reposilite, dépôt « Reposilite » de
#                 platforms/bukkit/build.gradle.kts).
set -euo pipefail

project_version=$(sed -n 's/^project_version=//p' gradle.properties | tr -d '[:space:]')
version="${project_version%-SNAPSHOT}-SNAPSHOT"
echo "Publication de fr.skullbox:customnameplates:$version"

./gradlew --console=plain :platforms:bukkit:publish -x test
