# Plan : <titre court>

> **Statut** : 🟡 en attente de validation · 🟢 validé · 🔄 en cours · ✅ terminé · 🔴 interrompu
> **Demande d'origine** : <verbatim de l'utilisateur>
> **Énoncé consolidé** : <demande après rechallenge Fable et arbitrages utilisateur>
> **Créé** : YYYY-MM-DD · **Budget escalades Fable** : 5 · **Consommées** : 0
> **À exécuter après** : <chemin d'un plan préalable — ligne optionnelle ; si présente, /plan-run exige son statut ✅ terminé ou un GO explicite de l'utilisateur>
> **Conso cumulée (volumétrie hors cache)** : conception ${n} · runs ${n} ({n} runs) · **total ${n}** · **dont Fable {n}k tokens** <!-- mise à jour par chaque commande fablewise touchant ce plan ; « dont Fable » = tokens in+out Fable cumulés, la ressource contingentée -->

## Contexte

<Synthèse d'exploration condensée : état du système touché, fichiers clés, conventions à respecter. Tout ce qu'un exécuteur doit savoir en commun.>

## Décisions & arbitrages

<Issues du rechallenge Fable et des réponses utilisateur. Une ligne par décision : choix retenu + pourquoi + alternatives écartées.>

## Politique d'escalade

Pour chaque tâche : exécution → vérification contre le critère → si échec, 1 retry par l'exécuteur avec le feedback du vérifieur → si nouvel échec, blocage ou choix non couvert par le plan : brief synthétique à `fable-advisor` (décrémenter le budget) → application de sa directive par l'exécuteur → si toujours bloqué : statut `⏸`, brief archivé dans le Journal, passer à la tâche suivante non dépendante. Budget épuisé = arrêt du run, main à l'utilisateur.

## Pre-mortem

<Incident report fictif de l'échec du plan, au passé, concret (fichiers/fonctions/causes plausibles) — rédigé par l'architecte ; chaque cause est convertie en critère supplémentaire ou Plan B sur la tâche concernée.>

## Tâches

<!-- Une section par tâche. Statuts : ⬜ à faire · 🔄 en cours · ✅ fait · ⏸ bloquée-reportée · ❌ abandonnée -->

### T1 — <titre impératif> `[modèle: sonnet]` `[deps: —]` `[statut: ⬜]`

<!-- Tags : `[touche: chemins/assets exacts + ressources exclusives nommées]` OBLIGATOIRE (déclaré par le développeur — base du calcul de parallélisme ; ressource exclusive = tout système n'acceptant pas d'accès concurrents : `editor` pour un éditeur/moteur vivant, `db`, `device`, `dev-server`…) · `[groupe: X]` optionnel (micro-tâches mécaniques cohésives exécutées par un seul agent) · `[vérif: sonnet]` si analyse visuelle · `[risque: haut]` si Plan B pré-décidé. -->

- **Quoi** : <objectif de la tâche en 1-2 lignes, hérité du squelette Fable>
- **Méthode** : <méthode retenue par l'architecte + alternative écartée et pourquoi — recopiée du squelette, jamais réécrite>
- **Mode opératoire** : <étapes numérotées, prescriptives, autosuffisantes — chemins/signatures/assets exacts, ordre des opérations, commandes, constat attendu après chaque étape. L'exécutant suit à la lettre, ne décide rien. Longueur libre.>
- **Contexte** : <fichiers concernés avec chemins, contraintes, conventions spécifiques à cette tâche>
- **Rendu attendu** : <livrable concret : fichier, fonction, doc, config>
- **Critères de complétion (1-4, binaires, vérifiables)** : <liste — chaque critère jugé séparément par le vérifieur ; exécutable de préférence (commande/test + résultat attendu), constatable sur pièces sinon ; si tests d'acceptation figés : « les tests X passent, non modifiés (diff vierge sur les fichiers de test) »>
- **Plan B** (seulement si `[risque: haut]`) : <méthode de repli pré-décidée par l'architecte, en mode opératoire condensé — appliquée après 2 échecs de la méthode principale, sans consommer d'escalade>
- **Journal** : <!-- rempli par /plan-run : bloc CHECKPOINT de l'exécuteur, tentatives, écarts, escalades, tokens -->

### T2 — <titre> `[modèle: haiku]` `[deps: T1]` `[statut: ⬜]`

…

## Rapport de run

<!-- Rempli par /plan-run à chaque fin d'exécution : date, tâches faites/bloquées, escalades consommées, tokens par tâche, écarts notables, reste à faire, taux par modèle (tâches, PASS 1er coup, retries, Plans B, escalades — la base des réassignations futures). -->
