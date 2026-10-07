#!/usr/bin/env bash
# Build Gradle (tests compris) en injectant la version de release : le jar du plugin et son plugin.yml portent
# <version>. Rien n'est committé : la version passe par -Pproject_version, qui l'emporte sur gradle.properties
# (les build.gradle.kts et le plugin.yml la lisent tous par rootProject.properties["project_version"]).
# Le jar du plugin est écrit dans target/ (hors de build/, donc hors de « clean ») : on le vide ici pour qu'un
# seul CustomNameplates-Bukkit-<version>.jar y reste (les globs de release et d'assets en dépendent).
# Usage : build.sh <version>
set -euo pipefail
version="${1:?usage: build.sh <version>}"

rm -f target/CustomNameplates-Bukkit-*.jar
./gradlew --console=plain clean build -Pproject_version="$version"
