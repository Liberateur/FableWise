---
name: plan-prompt
description: Version légère de /plan pour une tâche unique - même intelligence de cadrage (exploration ciblée, rechallenge Fable) mais rend UNIQUEMENT un prompt prêt à exécuter avec le modèle recommandé (haiku/sonnet/opus), sans créer de fichier plan. Déclencher avec "/plan-prompt" suivi de la demande, "fais-moi un prompt optimisé pour", "prompt + modèle pour cette tâche". Propose ensuite d'exécuter le prompt via un agent au modèle recommandé.
---

# /plan-prompt — Un prompt optimal, le bon modèle, rien d'autre

Pour les tâches uniques qui ne justifient pas un fichier plan : produire UN prompt autoporteur et le modèle recommandé pour l'exécuter. Aucun fichier créé, aucune exécution automatique.

## Étape 0 — GARDE-FOU MODÈLE (bloquant, avant toute autre action)

Identifier le modèle de la session courante. Si famille **Fable/Mythos** ou **Opus** : **STOP IMMÉDIAT**, afficher exactement :

> ⛔ **fablewise bloqué** : cette session tourne sur **{modèle}**. Relance `/plan-prompt` depuis une session **Sonnet** — Fable n'intervient que dans le sous-agent de rédaction.

Sinon, continuer.

## Étape 1 — Contexte ciblé (conditionnel, Sonnet)

Si `.claude/fablewise-lessons.md` existe dans le projet, inclure les leçons pertinentes dans le brief. Seulement si la demande porte sur le projet courant : lancer `plan-explorer` (sinon `Explore`/`general-purpose`, `model: sonnet`) en exploration **étroite** — uniquement les fichiers/conventions que le prompt devra citer. Synthèse ≤ 300 mots. Pour une demande générique (sans dépendance au projet), sauter cette étape.

## Étape 2 — Rédaction du prompt (Fable)

Lancer `plan-architect` (sinon `general-purpose`, `model: fable`) avec la demande verbatim + la synthèse éventuelle (déjà compacte — c'est le brief). L'architecte n'utilise aucun outil ni ne lit aucun fichier. Attendu :

1. **Rechallenge éclair** : si la demande contient une ambiguïté qui changerait le prompt du tout au tout, la signaler en UNE question fermée avec options — sinon ne pas questionner. (Si question il y a : GATE utilisateur via AskUserQuestion, puis répondre **en continuation de la même conversation** — la réponse seule, jamais la demande re-envoyée ; relance complète seulement si continuation indisponible.)
2. **Le modèle recommandé** : `haiku` (mécanique, transformation simple), `sonnet` (défaut code/rédaction), `opus` (raisonnement difficile localisé) — avec une ligne de justification. Jamais fable.
3. **Le prompt**, autoporteur : objectif précis, contexte embarqué (chemins, signatures, conventions — tout ce que l'exécutant ne doit pas avoir à chercher), contraintes et interdits (pas de hors-périmètre), rendu attendu, et un critère d'auto-vérification que l'exécutant doit constater et rapporter en fin de travail. Pas de code tout fait dans le prompt : des directives.

## Étape 3 — Restitution

Rendre à l'utilisateur, sans créer de fichier :

- **Modèle recommandé** : `{modèle}` — {justification en une ligne}.
- **Le prompt** dans un bloc de code, copiable tel quel.
- La proposition : « Je l'exécute maintenant via un agent {modèle} ? » — si oui, lancer `task-executor` (sinon `general-purpose`) avec `model:` = le modèle recommandé et le prompt tel quel ; rapporter le résultat et le critère d'auto-vérification constaté.

## Règles

- Pas de fichier plan, pas de Journal — c'est le format jetable. Si pendant le cadrage la tâche se révèle multi-étapes ou risquée, le dire et proposer `/plan` à la place plutôt que de forcer un prompt unique.
- Le passage Fable est UN appel : rechallenge éclair + modèle + prompt dans la même réponse. S'il y a une question utilisateur, un seul aller-retour supplémentaire maximum.

## Récap de consommation (obligatoire, dernière action de la commande)

Terminer TOUJOURS la réponse par ce tableau (markdown, rendu graphiquement dans le chat), en additionnant les `subagent_tokens` retournés par chaque appel d'agent — c'est une **volumétrie HORS CACHE** (l'outil Agent ne remonte pas les tokens de cache) :

| Modèle | Appels | Tokens (hors cache) | Coût indicatif |
|---|---|---|---|
| fable | {n} | {n}k | ${n} |
| opus | {n} | {n}k | ${n} |
| sonnet | {n} | {n}k | ${n} |
| haiku | {n} | {n}k | ${n} |
| **Total** | | **{n}k** | **${n}** |

> **Sans le plugin (tout-Fable) : ~${n} — économie estimée ~{n} %**
> `{barre : █ proportionnel à l'économie, sur 10 caractères, ex. ███████░░░ pour 70 %}`
> **Fable : {n} appel(s) · {n}k in · {n}k out** ← la métrique pilotée

Méthode de calcul (appliquer telle quelle) : coût estimé = tokens × tarif blended par Mtok, hypothèse 80 % input / 20 % output. Blended : fable $18 · opus $9 · sonnet $5.40 · haiku $1.80 (dérivés des tarifs API in/out $ par Mtok : fable 10/50, opus 5/25, sonnet 3/15, haiku 1/5 — tarifs constatés mi-2026, à rafraîchir en cas de doute). « Sans le plugin » = total tokens × $18 (la même volumétrie si Fable avait tout fait lui-même). Omettre les lignes de modèles non utilisés.

Règles d'honnêteté : ce tableau est une volumétrie hors cache — le trafic réel (écritures de cache à 1,25× le tarif input, lectures à 10 %) est typiquement plusieurs fois supérieur ; ne JAMAIS le présenter comme un majorant ni comme le facturé. Coordination de session (Sonnet) non incluse, visible via /context. Valeur d'usage manquante = « n/d », jamais inventée. Pas d'alerte de part Fable pour /plan-prompt : Fable y est structurellement dominant (un appel Fable + au plus une exploration Sonnet), c'est normal.
