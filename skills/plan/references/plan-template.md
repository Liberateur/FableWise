# Plan : <titre court>

> **Statut** : 🟡 en attente de validation · 🟢 validé · 🔄 en cours · ✅ terminé · 🔴 interrompu
> **Demande d'origine** : <verbatim de l'utilisateur>
> **Énoncé consolidé** : <demande après rechallenge Fable et arbitrages utilisateur>
> **Créé** : YYYY-MM-DD · **Rédigé par** : Fable (session /plan)
> **À exécuter après** : <chemin d'un plan préalable — ligne optionnelle ; si présente, /plan-run exige son statut ✅ terminé ou un GO explicite de l'utilisateur>
> **Conso cumulée** : conception ${n} · runs ${n} ({n} runs) · **total ${n}** · **dont Fable {n}k tokens** <!-- mise à jour par chaque commande fablewise touchant ce plan ; coût réel transcript si disponible, sinon estimation marquée ~ -->

## Contexte

<Synthèse d'exploration condensée : état du système touché, fichiers clés, conventions à respecter. Tout ce qu'un exécuteur doit savoir en commun.>

## Décisions & arbitrages

<Issues du rechallenge Fable et des réponses utilisateur. Une ligne par décision : choix retenu + pourquoi + alternatives écartées.>

## Contrat d'exécution

Ce plan est appliqué par une session **Sonnet** (`/plan-run`) qui suit les modes opératoires à la lettre et constate les critères sur pièces. Pour chaque tâche : application → constat des critères → si échec, 1 retry → si nouvel échec, Plan B s'il existe (`[risque: haut]`) → sinon **arrêt du run** : la session n'invente rien, écrit une `Synthèse de blocage` dans la tâche (nature, tentatives, pièces, options, champ `Directive de reprise` vide) et rend la main. L'utilisateur fait arbitrer la synthèse par **Fable**, reporte la décision dans `Directive de reprise`, puis relance `/plan-run`.

## Pre-mortem

<Incident report fictif de l'échec du plan, au passé, concret (fichiers/fonctions/causes plausibles) — rédigé par Fable ; chaque cause est convertie en critère supplémentaire ou Plan B sur la tâche concernée.>

## Tâches

<!-- Une section par tâche. Statuts : ⬜ à faire · 🔄 en cours · ✅ fait · ⏸ bloquée (synthèse écrite) · ❌ abandonnée. Toutes les tâches s'exécutent en Sonnet — pas d'assignation de modèle. -->

### T1 — <titre impératif> `[deps: —]` `[statut: ⬜]`

<!-- Tags : `[touche: chemins/assets exacts + ressources exclusives nommées]` OBLIGATOIRE (base du calcul de parallélisme ; ressource exclusive = tout système n'acceptant pas d'accès concurrents : `editor` pour un éditeur/moteur vivant, `db`, `device`, `dev-server`…) · `[groupe: X]` optionnel (tâches mécaniques cohésives exécutées ensemble) · `[risque: haut]` si Plan B pré-décidé · `[contexte: lourd]` si sortie volumineuse prévisible (audit visuel multi-captures, session capture d'un système vivant, build, tests verbeux) — /plan-run délègue OBLIGATOIREMENT ces tâches à un exécuteur, même seules. -->

- **Quoi** : <objectif de la tâche en 1-2 lignes>
- **Méthode** : <méthode retenue par Fable + alternative écartée et pourquoi>
- **Mode opératoire** : <étapes numérotées, prescriptives, autosuffisantes — chemins/signatures/assets exacts, ordre des opérations, commandes, constat attendu après chaque étape. La réflexion est mâchée ici : l'exécutant applique, il ne re-décide pas. Longueur libre.>
- **Contexte** : <fichiers concernés avec chemins, contraintes, conventions spécifiques à cette tâche — exécutable sans ré-explorer>
- **Rendu attendu** : <livrable concret : fichier, fonction, doc, config>
- **Critères de complétion (1-4, binaires, vérifiables)** : <liste — constat sur pièces, exécutable de préférence (commande/test + résultat attendu) ; si tests d'acceptation figés : « les tests X passent, non modifiés (diff vierge sur les fichiers de test) ». Jamais de « validation utilisateur » hors tâche gate — les validations visuelles/subjectives vivent dans des tâches gate dédiées, où un run autonome s'arrête proprement.>
- **Plan B** (seulement si `[risque: haut]`) : <méthode de repli pré-décidée par Fable, en mode opératoire condensé — appliquée après 2 échecs de la méthode principale, sans arrêter le run>
- **Journal** : <!-- rempli par /plan-run : CHECKPOINT, tentatives, écarts, constats des critères ; Synthèse de blocage le cas échéant -->

### T2 — <titre> `[deps: T1]` `[statut: ⬜]`

…

## Rapport de run

<!-- Rempli par /plan-run à chaque fin d'exécution : date, tâches faites/bloquées/gelées, retries et Plans B appliqués, écarts notables, reste à faire. -->
