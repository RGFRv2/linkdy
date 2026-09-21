# Changelog

## [1.9.0+29] - 2026-09-21

Implémentation du support des bookmark bundles demandé dans
[JGeek00/linkdy#35](https://github.com/JGeek00/linkdy/issues/35).

- Base : [`master` à `14edb61`](https://github.com/RGFRv2/linkdy/commit/14edb61d817e73bfdde89a1614f588df7fabfdb6)
- Dernier commit fonctionnel : [`dc5f902`](https://github.com/RGFRv2/linkdy/commit/dc5f902edf0d224e1dffbbf011fc05318ee5a154)
- [Diff fonctionnel avec `master`](https://github.com/RGFRv2/linkdy/compare/14edb61d817e73bfdde89a1614f588df7fabfdb6...dc5f902edf0d224e1dffbbf011fc05318ee5a154)

### Compatibilité

- Nécessite Linkding 1.41 ou une version plus récente.
- Un serveur ne disposant pas de l'endpoint `/bundles/` affiche un message de
  compatibilité dédié.

### Fonctionnalités ajoutées

- Ajout d'une entrée **Bundles** dans le menu principal des bookmarks.
- Ajout des routes `/bundles` et `/bundles/:id`.
- Affichage des bundles triés selon leur champ `order`.
- Affichage d'un résumé des règles de chaque bundle : recherche, tags
  facultatifs, tags obligatoires et tags exclus.
- Création et modification d'un bundle depuis une feuille modale.
- Validation obligatoire du nom du bundle.
- Autocomplétion des tags existants et gestion des tags sous forme de chips.
- Suppression d'un bundle avec confirmation et retour visuel du résultat.
- Réorganisation des bundles par glisser-déposer.
- Mise à jour optimiste de l'ordre, sauvegarde côté serveur et restauration de
  l'ordre précédent en cas d'échec.
- Ouverture d'un bundle dans l'écran partagé des bookmarks filtrés.
- Chargement, rafraîchissement et pagination des bookmarks appartenant à un
  bundle.
- Rafraîchissement du contenu d'un bundle après une modification d'un bookmark
  susceptible de changer son appartenance au bundle.
- États dédiés pour le chargement, les erreurs, l'absence de bundles et
  l'absence de bookmarks correspondants.

### API et modèles

- Ajout des modèles `BookmarkBundlesResponse`, `BookmarkBundle` et
  `SetBookmarkBundleData`.
- Prise en charge des champs `search`, `any_tags`, `all_tags`,
  `excluded_tags`, `filter_unread`, `filter_shared`, `order`, `date_created`
  et `date_modified`.
- Ajout des appels API suivants :
  - `GET /bundles/`
  - `GET /bundles/{id}/`
  - `POST /bundles/`
  - `PATCH /bundles/{id}/`
  - `DELETE /bundles/{id}/`
- Ajout du paramètre `bundle` à `GET /bookmarks/`.
- Extension du mode de filtrage existant avec `FilteredBookmarksMode.bundle`.
- Centralisation de la pagination des vues par tag, bundle, bookmarks partagés
  et bookmarks archivés.

### Correctifs

- Le contenu d'un bundle se charge maintenant dès l'ouverture de l'écran,
  sans nécessiter de pull-to-refresh manuel.
- L'état « aucun bookmark » n'est affiché qu'après la fin du chargement initial.
- Une route de bundle incomplète redirige vers la liste des bundles au lieu de
  laisser un écran invalide.

### Traductions

Ajout de toutes les chaînes propres aux bundles dans les langues déjà prises
en charge par l'application :

- anglais ;
- espagnol ;
- tchèque ;
- turc.

Les fichiers Dart générés par Slang ont également été actualisés. Ils sont
nécessaires à l'exécution de l'application et ne constituent pas des fichiers
de développement temporaires.

### Version

- Version de départ sur `master` : `1.8.2+26`.
- Version finale : `1.9.0+29`.

### Validation iOS

- Validation du chargement initial des bundles sans rafraîchissement manuel.
- Compilation d'une application iOS release non signée.
- Installation par sideload et lancement confirmés sur un iPhone physique.

### Périmètre final du merge

Le diff final ne contient pas :

- le dossier `test/` ;
- de changement Xcode, CocoaPods ou Swift Package Manager ;
- d'identifiant d'équipe Apple ou de profil de signature ;
- de changement `.env` ou Sentry par rapport à `master` ;
- de changement `pubspec.lock` ou `analysis_options.yaml` ;
- d'IPA ou d'autre artefact de compilation ;
- de nouvelle dépendance.

### Commits associés

| Commit | Version | Rôle |
| --- | --- | --- |
| [`6459df9`](https://github.com/RGFRv2/linkdy/commit/6459df98f9381aaff3ba20f283ca924e98af1fa6) | `1.9.0+27` | Ajout initial des modèles, appels API, écrans, formulaires, routes et traductions des bundles. |
| [`d12e16a`](https://github.com/RGFRv2/linkdy/commit/d12e16a51ad0e581b79770e571ff5e9526f1cc0d) | `1.9.0+28` | Correction du chargement initial du contenu d'un bundle. |
| [`2bcd431`](https://github.com/RGFRv2/linkdy/commit/2bcd431fc40b0cfbe7235511cc492d5dc1ca9aca) | `1.9.0+29` | Commit intermédiaire du workflow de test iOS. Ses changements `.env` et Sentry ont été neutralisés dans l'état final ; seul le numéro de version reste pertinent. |
| [`dc5f902`](https://github.com/RGFRv2/linkdy/commit/dc5f902edf0d224e1dffbbf011fc05318ee5a154) | `1.9.0+29` | Nettoyage du diff final : retrait des tests et configurations de développement, puis réalignement sur `master` hors fonctionnalité Bundles. |
