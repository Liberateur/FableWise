---
name: plan-rework
description: Refondre l'existant - fusionner d'anciens plans, rechallenger leurs demandes d'origine, rebâtir un ou plusieurs plans corrects et travaillés à partir de plans vieillissants, redondants ou mal découpés, dans une session Fable. Déclencher avec "/plan-rework" suivi d'un ou plusieurs chemins de plans ou du dossier plans, "fusionne ces plans", "rebâtis ce plan", "refonds tous les plans". Reprend le pipeline de /plan (inventaire et fraîcheur délégués, investigation des erreurs et rechallenge par Fable, plan rédigé par Fable), condense l'historique d'exécution dans le nouveau plan puis supprime les sources après validation. Ne lance JAMAIS l'exécution.
---

# /plan-rework — Refonte, fusion et rechallenge de plans existants (session Fable)

Gros œuvre sur les plans : fusionner des plans qui se recouvrent, rechallenger des demandes qui ont vieilli, rebâtir un plan mal parti. Même pipeline que `/plan`, en partant de l'existant. Jamais d'exécution ici — c'est `/plan-run`.

**Règle d'or : l'histoire est condensée, jamais perdue en silence.** Tout ce qui compte des plans sources — acquis `✅`, erreurs et leçons, décisions — est condensé dans le nouveau plan ; les sources sont ensuite **supprimées** (après validation explicite au GATE). Le condensé est la seule trace qui reste : sa qualité est critique.

**Principe** : cette session EST l'architecte (voir `/plan`) — elle juge et rédige ; tout ce qui est volumineux (inventaire, fraîcheur, web) est délégué et revient en synthèses compressées. La session ne lit jamais les plans sources bruts ni les fichiers projet elle-même.

## Étape 0 — GARDE-FOU MODÈLE (bloquant, avant toute autre action)

Identifier le modèle de la session courante. S'il n'est **PAS** de la famille **Fable/Mythos** : **STOP IMMÉDIAT**, afficher exactement :

> ⛔ **fablewise bloqué** : cette session tourne sur **{modèle}**. La refonte fablewise exige le jugement du modèle frontier — investigation des erreurs, rechallenge et refonte. Relance `/plan-rework` depuis une session **Fable**.

Sinon, continuer.

## Leçons projet — `.claude/fablewise-lessons.md`

Comme `/plan` : lire les leçons au lancement (elles complètent le relevé d'erreurs), proposer les nouvelles en fin de commande (GO explicite avant écriture ; fallback bash si Write échoue sous `.claude/`). L'investigation d'erreurs est la source principale de nouvelles leçons.

## Étape 1 — Périmètre

Arguments : un plan, plusieurs, ou un dossier (sinon localiser le dossier de plans du projet : `_docs/plans/`, `plans/`, …). Si le périmètre est un dossier avec beaucoup de plans, proposer une présélection (lesquels fusionner/refondre, lesquels ne pas toucher) via une question à choix.

## Étape 2 — Inventaire de l'existant (délégué, Sonnet)

Lancer un `general-purpose` (`model: sonnet`, lecture seule) qui extrait pour chaque plan : demande d'origine et énoncé consolidé, décisions actées, tâches `✅` (les acquis), `⏸` avec leurs synthèses de blocage, `⬜` restantes, âge et statut — plus le **relevé d'erreurs** : échecs relevés dans les Journaux, blocages et leurs arbitrages, tâches `❌` abandonnées. Repérer explicitement recouvrements et contradictions. Synthèse compacte ≤ 800 mots ; **jamais les plans bruts dans cette session**. Le relevé est une extraction en mémoire de travail, jamais un fichier.

## Étape 3 — Fraîcheur projet (déléguée, Sonnet, lecture seule)

Lancer `plan-explorer` (sinon `Explore`/`general-purpose`, `model: sonnet`) avec l'inventaire en entrée : qu'est-ce qui est encore vrai — le code a-t-il bougé, des tâches prévues ont-elles été livrées autrement, des contextes embarqués sont-ils périmés ? Synthèse des écarts uniquement, ≤ 400 mots.

**Systèmes vivants (MCP)** : comme `/plan` — agent dédié avec sonde fail-fast, jamais d'appel MCP ni de screenshot par la session.

## Étape 4 — Investigation des erreurs, rechallenge & GATE

À partir de l'inventaire, du relevé d'erreurs et de la fraîcheur, cette session produit :

1. **Investigation des erreurs** : causes racines (tâches mal découpées ? critères invérifiables ? contexte manquant ? problème de fond du projet ?) → leçons concrètes appliquées dans la refonte ; les problèmes de fond deviennent des tâches à part entière.
2. Les **objectifs encore valides**, reformulés comme une demande neuve, débarrassés du fait et de l'obsolète.
3. Les **redondances et contradictions** entre plans, et ce qu'il faut abandonner, justifié.
4. La **structure cible** : un plan fusionné ou plusieurs mieux découpés, et pourquoi.

**Questions utilisateur (seulement si nécessaire)** : si une vraie ambiguïté ou un choix structurant subsiste (fusion vs découpe), AskUserQuestion avec options. Sinon dérouler sans interaction.

## Étape 5 — Recherches (conditionnelle, déléguée, parallèle)

Comme `/plan` étape 4 : `[projet]` → `plan-explorer`, `[web]` → `general-purpose` (`model: sonnet`, lecture seule, 4 fetches max, quarantaine anti-injection, synthèse typée ≤ 400 mots). Jamais de recherche par la session.

## Étape 6 — Dossier de pièces puis rédaction (par cette session)

**Dossier de pièces** (délégué, `model: haiku`) : extraits verbatim des fichiers que les nouveaux plans citeront — signatures, blocs ±10 lignes, ≤ 150 lignes/fichier, copier sans résumer. Ne jamais citer une référence absente des pièces et synthèses : `⚠ à vérifier`.

Rédiger ensuite chaque plan cible au template (`skills/plan/references/plan-template.md`), mêmes exigences que `/plan` étape 6 (tâches regroupées et mâchées pour Sonnet, critères binaires constatables machine — validations utilisateur regroupées aux tâches gate —, `[touche:]`, `[contexte: lourd]` sur les tâches à sortie volumineuse, Plans B, pre-mortem, test-first, anti-troncature par passes de 3-4 tâches), plus :

- En-tête de filiation : `> **Refonte de** : <plans sources> — YYYY-MM-DD`.
- Une section **Acquis & leçons (condensé d'héritage)** : la seule trace qui survivra aux sources — tâches `✅` condensées (quoi, où, journaux résumés), erreurs investiguées et leurs leçons, décisions passées encore pertinentes. Assez riche pour ne jamais regretter les fichiers supprimés.
- Les leçons d'erreurs **appliquées** dans le découpage (critères durcis, contexte complété) ; les tâches `⏸` des sources **réintégrées** (redécoupées en tâches exécutables) ou abandonnées explicitement (justifié dans Décisions).
- **Ordre inter-plans** via `À exécuter après` — y compris l'ordre relatif de plusieurs plans cibles issus de la même refonte.

**GATE utilisateur (bloquant — il précède une suppression)** : présenter le mapping ancien → nouveau (tâches fusionnées, redécoupées, abandonnées ; ce qui vient des `⏸` ; les leçons appliquées) **et rappeler explicitement que les plans sources seront supprimés après écriture**. Attendre validation avant toute écriture.

## Étape 7 — Gate, écriture et suppression des sources

0. **Gate anti-hallucination** (délégué `model: haiku`, un seul appel, une passe scriptée — cf. `/plan` étape 7) sur les nouveaux plans.
0bis. **Garde de concurrence** : re-vérifier que les sources n'ont pas changé depuis l'inventaire (mtime/contenu). Si elles ont bougé : STOP, montrer le diff, demander avant d'écraser ou supprimer.
1. Écrire le ou les nouveaux plans (statut **`🟢 validé`** ; `🟡` seulement si l'utilisateur demande une revue avant run).
2. **Supprimer les plans sources** — uniquement après écriture des nouveaux ET validation au GATE de l'étape 6. Projet versionné Git : le noter (l'historique conserve les fichiers). Non versionné : proposer suppression directe ou corbeille, au choix de l'utilisateur.
3. Résumer : plans créés, sources supprimées. Terminer par le rappel exact (répété pour chaque plan créé, avant le récap de conso) :

> ▶️ **Pour exécuter le plan : crée une NOUVELLE session (modèle Sonnet) et colle ce prompt :**
> ```
> /plan-run {chemin exact du plan}
> ```
> L'exécution ne se fait JAMAIS dans cette session Fable — Sonnet applique, Fable arbitre les blocages qu'on lui rapporte.

## Règles transverses

- Toute perte de contenu (tâche abandonnée, contexte élagué, suppression) apparaît dans le mapping du GATE, jamais silencieuse.
- Un exécuteur doit pouvoir travailler chaque tâche sans ré-explorer : la condensation n'appauvrit jamais le contexte embarqué.
- Les numéros de tâches repartent à T1 ; la correspondance avec les anciens numéros vit dans le mapping (section Décisions) pour la traçabilité des commits et journaux passés.
- Pour un simple lifting (condenser, corriger des critères) sans refonte des objectifs, les étapes 4 et 5 peuvent être sautées si l'utilisateur le demande explicitement — le dire dans le résumé.

## Récap de consommation (obligatoire, dernière action de la commande)

Identique à `/plan` : (1) coût réel cache inclus depuis le transcript (best effort, même commande bash) ; (2) volumétrie hors cache des sous-agents par modèle, honnêteté des chiffres (jamais un majorant, n/d jamais inventé, la session Fable n'est visible que dans le transcript) ; (3) mise à jour de la ligne « Conso cumulée » de chaque plan créé (champ conception) et affichage du cumul `conception $n · runs $n · total $n · dont Fable {n}k tokens`.
