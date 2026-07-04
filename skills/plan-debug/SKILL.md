---
name: plan-debug
description: Investigation Opus d'un plan en difficulté (bugs, blocages, effets nuls), dans une session Opus. Déclencher avec "/plan-debug" suivi du chemin du plan, "debug ce plan avec fablewise", "analyse les blocages du plan X". Opus TIENT le volume (relit le plan, rejoue les tests, prend les captures, inspecte le système vivant) sans facturer Fable, puis rend UNIQUEMENT un condensé problème→cause, une phrase de reco de modèle (debuggable Opus vs intervention Fable), et un long prompt de debug autoporteur pour une session neuve. Lecture seule, ne modifie aucun fichier, n'exécute jamais le debug.
---

# /plan-debug — Investigation Opus d'un plan en difficulté (session Opus)

Un plan bloque, un bug résiste, un effet reste nul : au lieu d'envoyer Fable prendre des captures et rejouer des tests (volume au tarif premium), **Opus absorbe l'investigation** et ne remonte à Fable que si la réparation l'exige vraiment. La commande lit le plan passé en argument (+ le problème décrit au lancement), investigue sur pièces, et rend trois choses : un **condensé problème→cause**, une **phrase de reco de modèle**, et un **prompt de debug autoporteur**. Aucun fichier créé ni modifié, aucune exécution du debug.

**Principe** : cette session est l'enquêteur. Contrairement à la session Fable de `/plan`, elle TIENT le volume — c'est sa raison d'être : lire tout le plan, rejouer les tests, charger les captures, dumper le système vivant. Opus est moins cher que Fable et absorbe cette masse ; Fable n'est appelé qu'au bout, sur un condensé, et seulement si le jugement frontier est réellement nécessaire.

## Étape 0 — GARDE-FOU MODÈLE (bloquant, avant toute autre action)

Identifier le modèle de la session courante (contexte système, ex. `Model: claude-opus-4-8`). Si le modèle n'est **PAS Opus** : **STOP IMMÉDIAT**, ne rien exécuter d'autre (aucune lecture, aucun agent, aucune écriture), afficher exactement :

> ⛔ **fablewise bloqué** : cette session tourne sur **{modèle}**. `/plan-debug` doit tourner sur **Opus** — c'est lui qui absorbe le volume d'investigation (plan entier, tests, captures, système vivant) sans le facturer à Fable, et qui juge ensuite si un simple debug Opus suffit ou si Fable doit trancher. Relance `/plan-debug` depuis une session **Opus**.

Sinon, continuer.

## Étape 1 — Chargement du plan et cadrage du problème

1. Lire le fichier plan en entier (chemin passé en argument). Inexistant ou hors template : le signaler et s'arrêter.
2. En extraire les problèmes : statut d'en-tête (`🔴 interrompu`, `⏸`, `🔄`…), toute `Synthèse de blocage` présente, le Journal des tâches (tentatives, écarts, CHECKPOINT), les tâches `⏸`/en échec, le pre-mortem, les tests figés. Croiser avec ce que l'utilisateur a décrit au lancement (le symptôme vécu prime sur le statut du fichier).
3. Si `.claude/fablewise-lessons.md` existe, en tenir compte (pièges d'outillage déjà payés).
4. Dresser en interne la liste des problèmes/blocages/difficultés/bugs à investiguer, du plus bloquant au moins.

## Étape 2 — Investigation (en session Opus, volume assumé)

Pour chaque problème, chercher la cause **sur pièces** — la session lit, rejoue, inspecte elle-même :

- rejouer le smoke-test / les tests d'acceptation, lire les diffs, reproduire le bug ;
- inspecter le système vivant par outils MCP (éditeur/moteur, BDD, device) — dumps, captures — et charger ce qui est nécessaire (le volume est ici assumé, pas délégué) ;
- lire les fichiers/fonctions exacts en cause (chemins du plan + Journal), ancre par ancre.

Discipline de cause (reprise de `/plan-run`) : **constat d'abord, verdict ensuite** ; un symptôme n'est pas une cause ; **cause prouvée ≠ hypothèse** — noter pour chacune si elle est prouvée sur pièce ou reste à tester. **Effet nul = canal suspect** : une modification qui s'est appliquée sans rien changer d'observable ne se re-tune pas — auditer le canal d'observation (rendu/visible/bindé/tické) par un test discriminant à effet grossier. Ce qui reste non prouvé est **signalé, jamais comblé en silence** (`⚠ à vérifier`).

Investigation en session (défaut). Un lot mécanique franchement parallèle et volumineux (ex. rejeu de N scénarios indépendants) PEUT partir dans un sous-agent `general-purpose` (`model: sonnet`) rendant une synthèse compressée — mais ce n'est pas le mode par défaut : l'intérêt de la commande est justement qu'Opus tienne la masse.

## Étape 3 — Condensé problème → cause

Rédiger un condensé **compact** (pas un dump). Un bloc par problème, ordonné par gravité :

- **Symptôme** : ce qui est observé (1 ligne).
- **Cause** : prouvée `[prouvé]` ou hypothèse `[hypothèse]` — la plus probable, en 1-2 lignes.
- **Pièce** : l'extrait strictement nécessaire (message d'erreur, diff court, réf de capture) — jamais de log entier.

## Étape 4 — Reco de modèle (une phrase) puis prompt de debug

Juger la complexité de la réparation :

- **Opus suffit** si : cause(s) localisée(s) et prouvée(s), réparation mécanique ou raisonnement local (patch ciblé, config, ancrage clair), sans remise en cause du design du plan.
- **Fable recommandé** si : cause profonde ou non prouvée touchant la conception du plan, arbitrage entre options structurantes, blocages intriqués, hypothèses concurrentes exigeant le jugement frontier, ou effet nul persistant (canal d'observation à repenser).

Puis composer le **prompt de debug**, long et autoporteur, destiné à être collé dans une **session neuve** du modèle recommandé :

- objectif précis (réparer `<quoi>`) ;
- le condensé problème→cause embarqué ;
- tout le contexte nécessaire pour ne rien re-chercher : chemins, signatures, **ancres exactes** (citées verbatim), commandes de repro et de test, réfs de captures, contraintes — **tests figés INTOUCHABLES**, pas de hors-périmètre ;
- la marche à suivre **mâchée** quand la cause est prouvée ; quand elle ne l'est pas, **commencer par l'expérience discriminante** qui la prouve/réfute, à constater avant tout fix ;
- un critère d'auto-vérification que l'exécutant devra **constater sur pièces** et rapporter.

Ne jamais citer dans le prompt une référence non constatée pendant l'investigation — `⚠ à vérifier` à la place.

## Étape 5 — Restitution (lecture seule)

Rendre à l'utilisateur, **sans créer ni modifier aucun fichier** (le plan reste intact ; consigner un blocage dans le plan est le rôle de `/plan-run`, la décision de reprise revient à cette investigation — Fable seulement en dernier recours) :

1. le **condensé problème→cause** ;
2. **une phrase de reco**, juste avant le prompt : « Debuggable en Opus : … » ou « Intervention Fable recommandée : … » — avec le pourquoi en une ligne ;
3. le **prompt de debug** dans un bloc de code, copiable tel quel ;
4. ce rappel exact :

> ▶️ **Pour lancer le debug : crée une NOUVELLE session ({modèle recommandé}) et colle le prompt ci-dessus.** `/plan-debug` n'exécute rien — et une session neuve repart sans le volume d'investigation accumulé ici.

## Règles

- **Lecture seule** : `/plan-debug` ne modifie JAMAIS le plan ni aucun fichier projet — il lit, investigue, restitue.
- **N'exécute jamais le debug** : il rend le prompt pour une session neuve, quel que soit le modèle recommandé (y compris Opus).
- Constat sur pièces, cause prouvée ≠ hypothèse, effet nul = canal suspect ; aucune invention — un manque résiduel est signalé (`⚠ à vérifier`), jamais comblé.
- **Jamais Fable pour cette commande** (garde-fou Opus) : Fable ne tient pas le volume — c'est précisément ce que cette commande lui épargne.
- **Point d'escalade de `/plan-run`** : quand le plan porte une `Synthèse de blocage` (run arrêté), le prompt de debug produit tient lieu de `Directive de reprise` — l'utilisateur le reporte dans le plan et relance `/plan-run`. Si l'investigation conclut qu'il faut le jugement frontier, la reco est **Fable** (dernier recours).

## Récap de consommation (obligatoire, dernière action de la commande)

Coût réel cache inclus depuis le transcript en best-effort (même commande bash que `/plan`), sinon `n/d` — jamais inventé. Cette session Opus tient le volume elle-même : l'essentiel de la conso est le travail in-session, visible uniquement dans le transcript — le dire tel quel. Si un sous-agent a été lancé, ajouter ses `subagent_tokens` par modèle (volumétrie hors cache, jamais un majorant).
