---
name: plan-prompt
description: Version légère de /plan pour une tâche unique, dans une session Fable - même intelligence de cadrage (exploration ciblée déléguée, rechallenge éclair par Fable) mais rend UNIQUEMENT un prompt prêt à exécuter avec le modèle recommandé (haiku/sonnet/opus), sans créer de fichier plan. Déclencher avec "/plan-prompt" suivi de la demande, "fais-moi un prompt optimisé pour", "prompt + modèle pour cette tâche". Propose ensuite d'exécuter le prompt via un agent au modèle recommandé.
---

# /plan-prompt — Un prompt optimal, le bon modèle, rien d'autre (session Fable)

Pour les tâches uniques qui ne justifient pas un fichier plan : produire UN prompt autoporteur et le modèle recommandé pour l'exécuter. Aucun fichier créé, aucune exécution automatique.

## Étape 0 — GARDE-FOU MODÈLE (bloquant, avant toute autre action)

Identifier le modèle de la session courante. S'il n'est **PAS** de la famille **Fable/Mythos** : **STOP IMMÉDIAT**, afficher exactement :

> ⛔ **fablewise bloqué** : cette session tourne sur **{modèle}**. Le cadrage fablewise exige le jugement du modèle frontier. Relance `/plan-prompt` depuis une session **Fable**.

Sinon, continuer.

## Étape 1 — Contexte ciblé (conditionnel, délégué)

Si `.claude/fablewise-lessons.md` existe dans le projet, en tenir compte. Seulement si la demande porte sur le projet courant : lancer `plan-explorer` (sinon `Explore`/`general-purpose`, `model: sonnet`) en exploration **étroite** — uniquement les fichiers/conventions que le prompt devra citer. Synthèse ≤ 300 mots. La session ne lit pas les fichiers elle-même. Demande générique : sauter cette étape.

## Étape 2 — Rechallenge éclair et rédaction (par cette session)

1. **Rechallenge éclair** : si la demande contient une ambiguïté qui changerait le prompt du tout au tout, UNE question fermée avec options (AskUserQuestion) — sinon ne pas questionner.
2. **Modèle recommandé** : `haiku` (mécanique, transformation simple), `sonnet` (défaut code/rédaction), `opus` (raisonnement difficile localisé) — une ligne de justification. Jamais fable en exécution.
3. **Le prompt**, autoporteur : objectif précis, contexte embarqué (chemins, signatures, conventions — tout ce que l'exécutant ne doit pas avoir à chercher), contraintes et interdits (pas de hors-périmètre), rendu attendu, et un critère d'auto-vérification que l'exécutant doit constater et rapporter. Pas de code tout fait : des directives. Ne jamais citer une référence absente de la synthèse d'exploration — `⚠ à vérifier` à la place.

## Étape 3 — Restitution

Rendre à l'utilisateur, sans créer de fichier :

- **Modèle recommandé** : `{modèle}` — {justification en une ligne}.
- **Le prompt** dans un bloc de code, copiable tel quel.
- La proposition : « Je l'exécute maintenant via un agent {modèle} ? » — si oui, lancer `task-executor` (sinon `general-purpose`) avec `model:` = le modèle recommandé et le prompt tel quel ; rapporter le résultat et le critère d'auto-vérification constaté.

## Règles

- Pas de fichier plan, pas de Journal — c'est le format jetable. Si pendant le cadrage la tâche se révèle multi-étapes ou risquée, le dire et proposer `/plan` à la place plutôt que de forcer un prompt unique.
- Un seul aller-retour utilisateur maximum (le rechallenge éclair).

## Récap de consommation (obligatoire, dernière action de la commande)

Volumétrie hors cache des sous-agents (`subagent_tokens` par modèle et par appel) + coût réel cache inclus depuis le transcript si l'environnement le permet (même commande bash que `/plan`), sinon `n/d` — jamais inventé. La consommation de la session Fable n'est visible que dans le transcript : le dire tel quel.
