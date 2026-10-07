# Custom-Nameplates

![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/Xiao-MoMi/Custom-Nameplates)
<a href="https://mo-mi.gitbook.io/xiaomomi-plugins/plugin-wiki/customnameplates" alt="GitBook">
<img src="https://img.shields.io/badge/docs-gitbook-brightgreen" alt="Gitbook"/>
</a>
[![Scc Count Badge](https://sloc.xyz/github/Xiao-MoMi/Custom-Nameplates/?category=codes)](https://github.com/Xiao-MoMi/Custom-Nameplates/)
![Code Size](https://img.shields.io/github/languages/code-size/Xiao-MoMi/Custom-Nameplates)
![bStats Servers](https://img.shields.io/bstats/servers/16649)
![bStats Players](https://img.shields.io/bstats/players/16649)
![GitHub](https://img.shields.io/github/license/Xiao-MoMi/Custom-Nameplates)

## How to Build

#### Command Line
Install JDK 17 & 21. \
Start terminal and change directory to the project folder.\
Execute ".\gradlew build" and get the artifact under /target folder

#### IDE
Import the project and execute gradle build action. \
Get the artifact under /target folder

## How to Contribute

#### Translations
Clone this project and create a new language file in the /backend/src/main/resources/translations directory. \
Once your changes are ready, open a pull request for review. We appreciate your works!

## Support the Developer

Polymart: https://polymart.org/resource/customnameplates.2543/ \
BuiltByBit: https://builtbybit.com/resources/customnameplates.36359/ \
Afdian: https://afdian.com/@xiaomomi/

## CustomNameplates API

```kotlin
repositories {
    maven("https://repo.momirealms.net/releases/")
}
```
```kotlin
dependencies {
    compileOnly("net.momirealms:custom-nameplates:3.0.19")
}
```

## Compiler en local (fork Skull-box)

Prérequis : JDK 17 **et** 21 (le module `:api` compile avec une toolchain 17, la plateforme Bukkit avec une 21 ;
Gradle les retrouve s'ils sont installés, il ne les télécharge pas). Le wrapper Gradle est dans le dépôt, rien
d'autre à installer. Aucune dépendance privée : pas de jeton à fournir.

```bash
./gradlew clean build
```

Le jar du plugin, celui qu'on dépose sur un serveur, est `target/CustomNameplates-Bukkit-<project_version>.jar`
(`project_version` de `gradle.properties`). Les modules `:api`, `:backend` et `:platforms:bukkit:compatibility`
sont embarqués dans ce jar. Pour construire sous une autre version (c'est ce que fait la CI) :
`./gradlew clean build -Pproject_version=1.2.3` ; le `plugin.yml` du jar la porte.

## CI/CD (fork Skull-box)

Fichiers : `.github/workflows/ci.yml`, `.github/scripts/`, `.releaserc.json`. Runner `blacksmith-2vcpu-ubuntu-2404`.

- **Chaque push et PR** : `./gradlew clean build` (tests compris). Une PR ne publie rien.
- **Push sur `main`** : release GitHub par [semantic-release](https://github.com/semantic-release/semantic-release)
  (`feat:` = mineure, `fix:` = correctif, `feat!:` ou `BREAKING CHANGE` = majeure ; `ci:`, `build:`, `docs:`, `chore:`
  ne produisent aucune release). La Release porte `CustomNameplates-Bukkit-<version>.jar` ; son `plugin.yml` porte la
  même version, injectée au build du runner (`-Pproject_version`), jamais committée. La première Release
  (`v3.0.37`) a été créée d'après `project_version`. L'historique d'un fork ne suit pas les conventional commits :
  peu de versions sortent seules après une synchronisation avec l'amont.
- **Push sur `main`, aussi** : le jar du plugin est publié en SNAPSHOT mobile `fr.skullbox:customnameplates:<project_version>-SNAPSHOT`
  sur `https://maven.pkg.github.com/Skull-box/Custom-Nameplates` (pom sans dépendances transitives). Élagage : au
  `SNAPSHOT_MAX`-ième dépôt (voir `ci.yml`) le paquet est supprimé puis republié.
- **Toute autre branche** : prérelease GitHub glissante `build-<branche>` (titre = nom de la branche), écrasée à
  chaque push, supprimée avec la branche.
