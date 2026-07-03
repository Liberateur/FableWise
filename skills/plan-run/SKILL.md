---
name: plan-run
description: Exécuter un plan produit par /plan, tâche par tâche, avec le modèle assigné à chaque tâche, vérification indépendante, escalade Fable sur blocage et progression écrite dans le fichier plan. Déclencher avec "/plan-run" suivi du chemin du plan, "exécute le plan", "lance le run du plan X". Re-entrant - relancer /plan-run reprend là où le plan s'était arrêté.
---

# /plan-run — Exécution orchestrée d'un plan

Exécuter le fichier plan passé en argument (format `plan-template.md` du skill plan, produit par `/plan`). Le fichier plan est **la source de vérité** : le relire avant chaque décision, y écrire chaque progression. Un run interrompu (crash, compaction, stop utilisateur) doit pouvoir reprendre par un simple `/plan-run` relancé.

**Principe de coût** : la session orchestre, les agents travaillent. Ne jamais faire le travail d'une tâche dans la session principale. Ne jamais remonter de logs bruts dans la session — les agents rendent des synthèses.

## Étape 0 — GARDE-FOU MODÈLE (bloquant, avant toute autre action)

Identifier le modèle de la session courante. Si famille **Fable/Mythos** ou **Opus** : **STOP IMMÉDIAT**, afficher exactement :

> ⛔ **fablewise bloqué** : cette session tourne sur **{modèle}**. Un run orchestré depuis ce modèle facture toute la coordination au tarif premium. Relance `/plan-run` depuis une session **Sonnet** — Fable n'intervient que comme conseiller ponctuel via `fable-advisor`.

Sinon, continuer.

## Leçons projet — `.claude/fablewise-lessons.md`

Au lancement (juste après le garde-fou) : si le projet a un dossier `.claude/`, vérifier l'existence de `.claude/fablewise-lessons.md` (une leçon par ligne : `- [date] contexte → leçon`). S'il existe, l'inclure dans les briefs destinés à l'architecte et au développeur. Si le projet a en plus son propre fichier de pitfalls (ex. `.claude/memory/pitfalls.md`), le faire balayer par l'exploration et inclure les entrées pertinentes en synthèse — jamais le fichier brut.

Alimentation en fin de commande : si des leçons généralisables ont émergé (erreurs récurrentes, réassignations, pièges), les PROPOSER à l'utilisateur (une ligne chacune) — n'écrire dans le fichier qu'après son GO explicite. Écriture sous `.claude/` : si Write échoue (« protected location »), passer par bash (`cat >>`).

Pour /plan-run : inclure les leçons pertinentes dans les briefs d'escalade `fable-advisor`, et proposer les nouvelles leçons dans le résumé de fin de run — dont les **réassignations de modèle appuyées par les taux du Rapport de run** (ex. « les tâches d'authoring scripté échouent en sonnet → opus », « les purges mécaniques passent en haiku du premier coup → haiku par défaut »). Ces leçons remontent dans les briefs architecte des prochains /plan : les assignations s'ajustent sur les données du projet, pas sur la doctrine.

## Notifications (opt-in)

Si le fichier `.claude/fablewise-notify` existe dans le projet (contenu : une URL ntfy/webhook), envoyer un POST court (`curl -s -d "<message>" <url>`) à chaque événement où l'utilisateur est attendu ou doit savoir : GATE de validation, escalade `fable-advisor`, tâche passée `⏸`, fin ou interruption de run. Message : nom du plan, événement, action attendue — une ligne, jamais de contenu de code. Absence du fichier = aucune notification, aucun message à ce sujet.

## Étape 1 — Chargement et état du plan

1. Lire le fichier plan en entier. S'il n'existe pas ou ne suit pas le template : le signaler et s'arrêter. Compatibilité : un plan ancien sans lignes Méthode/Mode opératoire/Plan B reste exécutable — l'exécuteur traite alors Quoi + Contexte comme directive.
2. Vérifier le statut d'en-tête : si `🟡 en attente de validation`, demander la validation à l'utilisateur avant tout (GATE). Si `✅ terminé`, le dire et s'arrêter.
   **Ordre inter-plans** : si l'en-tête porte une ligne `À exécuter après : <plan>`, lire le statut de ce plan préalable. S'il n'est pas `✅ terminé` : STOP, l'expliquer (les deux plans partagent des ressources ou un état dont ce plan dépend), et ne continuer que sur GO explicite de l'utilisateur — noter ce GO dans le Journal.
3. Inventorier les tâches : faites (`✅`), bloquées (`⏸`), restantes (`⬜`/`🔄`), budget d'escalades restant. Une tâche `🔄` orpheline (run précédent interrompu) est retraitée comme `⬜` — le noter dans son Journal.
4. Passer le statut d'en-tête à `🔄 en cours`. Annoncer brièvement le point de reprise.

## Étape 2 — Boucle d'exécution

Répéter tant qu'il reste des tâches `⬜` dont toutes les dépendances sont `✅` :

1. **Sélection** : identifier toutes les tâches prêtes (deps satisfaites).
2. **Parallélisation — calcul mécanique sur les tags `[touche:]`** : deux tâches prêtes se lancent en parallèle (même bloc d'appels) si et seulement si l'intersection de leurs `[touche:]` est VIDE. Règles absolues : **JAMAIS d'`isolation: worktree`** (beaucoup de projets ont un éditeur, moteur ou serveur vivant branché sur le dossier de travail — une copie git isolée ne peut ni compiler ni tester) ; **chaque ressource exclusive nommée est un mutex global** (`editor`, `db`, `device`… : un éditeur/moteur vivant ou une base partagée n'accepte pas d'appels concurrents) — au plus UNE tâche touchant une ressource exclusive donnée à la fois, quel que soit le reste ; une tâche sans tag `[touche:]` (plan ancien) retombe sur la règle prudente : fichiers manifestement disjoints ou séquencer.
   **Groupes** : les tâches consécutives d'un même `[groupe: X]` prêtes ensemble partent dans UN SEUL exécuteur (économie d'amorçage) — qui rend un compte-rendu séparé par tâche ; la vérification rend un verdict PASS/FAIL par tâche du groupe (un seul appel vérifieur possible). Un FAIL dans le groupe ne bloque que la tâche concernée et ses dépendantes.
   **Pipeline vérification/exécution** : la vérification d'une tâche T (lecture seule) peut partir dans le même bloc que l'exécution de tâches prêtes qui (a) ne dépendent pas de T et (b) ont un `[touche:]` disjoint de T. JAMAIS lancer une tâche dépendante de T avant son PASS — exécuter sur du non-vérifié propage les défauts.
   **Ordre cache-friendly** : à contraintes égales (deps, `[touche:]`, groupes), ordonnancer les tâches du même modèle dos à dos et enchaîner les dispatches sans pause — le cache des sous-agents est par modèle, à préfixe exact, TTL ~5 minutes. Structurer chaque prompt d'exécuteur avec le boilerplate partagé (contexte commun du plan, consignes) VERBATIM identique en tête, et la section tâche variable en queue : les dispatches successifs relisent alors le cache au lieu de payer l'input plein tarif.
3. **Exécution** : pour chaque tâche, un agent `task-executor` (sinon `general-purpose`) avec `model:` = le modèle assigné dans le plan. Prompt = la section complète de la tâche (Quoi / Méthode / **Mode opératoire** / Contexte / Rendu attendu / Critère, et Plan B si `[risque: haut]`) + la section Contexte du plan + « Réalise cette tâche exactement. Rends compte : ce qui a été fait, fichiers touchés, comment constater le critère de complétion. Si tu es bloqué ou face à un choix non couvert par le plan, n'improvise pas : rends un rapport de blocage (nature, ce que tu as tenté, options envisagées). » **Dispatch minimal** : le prompt de l'exécuteur ne contient QUE cela — jamais l'historique du run, jamais les comptes-rendus des tâches passées (au besoin, seulement les interfaces/signatures produites par les tâches dont celle-ci dépend).
4. **Vérification** : agent `task-verifier` (sinon `general-purpose` avec `model: haiku`), lecture seule. Prompt = la liste des critères de complétion + le CHECKPOINT de l'exécuteur + « Vérifie sur pièces, critère par critère : constat d'abord, verdict PASS/FAIL/UNKNOWN ensuite ; contrôle l'intégrité des tests figés (diff vierge) ; dernière ligne VERDICT GLOBAL. » UNKNOWN sur un critère = traiter comme FAIL (signal d'escalade). Ne jamais laisser l'exécuteur s'auto-valider.
   **Vérification visuelle (screenshots)** : si le critère l'exige, surcharger le vérifieur à `model: sonnet` (Haiku est trop juste en vision ; jamais opus/fable pour analyser une image). Screenshots à coût minimal : résolution la plus basse qui permet de trancher le critère (ordre de grandeur 640×360 pour une scène, moins pour un oui/non), cadrés sur la zone concernée, un seul par vérification — pas de rafale, pas de plein écran haute résolution. Le critère du plan doit dire *quoi* regarder ; le vérifieur ne capture que ça.
5. **Échec** : FAIL du vérifieur → 1 retry par l'exécuteur avec le feedback du vérifieur en entrée. Second FAIL : **si la tâche a un Plan B** (`[risque: haut]`), l'appliquer d'abord — nouvel exécuteur avec le mode opératoire de repli, sans consommer d'escalade ; c'est le changement de cap que l'architecte a déjà décidé. **Verdict pairwise** : si la tentative principale avait produit un résultat partiel et que le Plan B rend le sien, faire juger les DEUX candidats par le vérifieur en comparatif (A vs B, critère par critère, désigner le meilleur) — le jugement comparatif est plus fiable qu'un score absolu. Si pas de Plan B, si le Plan B échoue aussi, ou face à un choix non couvert → **Étape 3 (escalade)**.
6. **Clôture de tâche** : sur PASS → mettre à jour le fichier plan : `[statut: ✅]` coché, Journal complété (bloc CHECKPOINT de l'exécuteur recopié, tentatives, écarts vs plan, tokens consommés par les agents de la tâche — l'outil Agent les retourne). Si le projet est un repo git : proposer un commit de la tâche (message : `fablewise: T<n> <titre>`) — le faire si l'utilisateur a préautorisé les commits, sinon le noter au rapport.

## Étape 3 — Escalade `fable-advisor`

Conditions : 2 échecs de vérification, rapport de blocage, ou choix non couvert par le plan.

1. **Budget** : si le budget d'escalades du plan est épuisé → statut `🔴 interrompu`, rapport, main à l'utilisateur. Sinon mettre à jour l'en-tête du plan : « Consommées : +1 » (le budget reste la référence ; l'utilisateur peut le relever à la main pour débloquer un run interrompu).
2. **Brief synthétique** (c'est lui qui contrôle le coût — le rédiger court et complet) : tâche concernée (section du plan), erreur/choix formulé en 3 lignes, historique des tentatives (quoi, résultat), extraits strictement nécessaires (diff, message d'erreur — pas de logs entiers), options envisagées.
3. Lancer l'agent `fable-advisor` (sinon `general-purpose` avec `model: fable`). L'advisor n'utilise aucun outil : tout ce qu'il doit savoir est dans le brief — y inclure les **points critiques et le Plan B de la tâche** (déjà tentés ou non) et les leçons projet pertinentes. Sa réponse est de l'un de ces trois types :
   - `DIRECTIVE:` — décision + justification 3 lignes + étapes concrètes → relancer l'exécuteur avec, puis vérification normale.
   - `INVESTIGUER:` — UNE question précise typée `[projet]` ou `[web]` qu'il lui faut avant de trancher → l'orchestrateur la fait chercher par Sonnet, puis répond **en CONTINUATION de la même conversation advisor** (la réponse seule, jamais le brief re-envoyé — relance complète seulement si continuation indisponible). Un seul aller-retour, le tout compte pour UNE escalade.
   - `REDÉCOUPER:` — la tâche est mal conçue ; il rend un mini-squelette de remplacement (1-N tâches : titre, objectif, méthode, modèle, deps, critère). L'orchestrateur fait développer les modes opératoires par `plan-developer` (opus — pour 1-N tâches de remplacement, le rendu en chat est acceptable), passe les nouvelles tâches au gate anti-hallucination (vérifieur haiku, références réelles, vérification en UNE passe scriptée), puis remplace la tâche dans le plan : l'originale passe `❌` avec renvoi, les remplaçantes sont numérotées `T<n>.1`, `T<n>.2`… (jamais de renumérotation globale — les journaux et commits passés y font référence). La boucle reprend — c'est le changement de cap formalisé, tracé dans le plan.
4. **Application** : selon le type ci-dessus. Toute modification du plan (REDÉCOUPER) est notée dans le Journal et visible dans le Rapport de run.
5. **Échec persistant** : marquer `[statut: ⏸]`, archiver le brief + la directive dans le Journal de la tâche, et **enchaîner** sur la prochaine tâche prête non dépendante. Les tâches dépendantes d'une `⏸` sont gelées, pas abandonnées.

## Étape 4 — Fin de run et rapport

Quand plus aucune tâche n'est prête (tout `✅`, ou restantes gelées/bloquées) :

1. Statut d'en-tête : `✅ terminé` si tout est fait, sinon `🔄 en cours` (reprise possible) ou `🔴 interrompu` (budget épuisé / stop).
2. Remplir la section **Rapport de run** du fichier plan : date, tâches faites / bloquées / gelées, escalades consommées (et sur quoi), total tokens par tâche et par modèle, écarts notables, reste à faire — et les **taux par modèle** : pour chaque modèle assigné (haiku/sonnet/opus), nombre de tâches, PASS du premier coup, retries, Plans B appliqués, escalades. C'est la donnée qui permet d'ajuster les assignations sur des faits : un modèle qui passe tout du premier coup est peut-être surdimensionné, un modèle qui escalade coûte du Fable.
3. Présenter à l'utilisateur un résumé court : l'essentiel du rapport + les tâches `⏸` avec leur brief (ce sont ses décisions à prendre) + la commande de reprise si pertinent.

## Règles transverses

- **Jamais** d'exécution de tâche par la session principale, **jamais** de modèle fable/opus pour exécuter, **jamais** d'auto-validation par l'exécuteur, **jamais** de modification des tests d'acceptation figés (toute modif non prévue par le plan = FAIL immédiat).
- Toute mutation inattendue hors périmètre du plan : ne pas la faire, la traiter comme un choix → escalade ou question à l'utilisateur.
- Si le contexte de session approche la saturation en cours de run : finir la tâche en cours, écrire l'état dans le plan, puis proposer à l'utilisateur de relancer `/plan-run` (la re-entrance rend l'opération sans perte).
- **Après toute compaction de contexte ou reprise de session : relire ENTIÈREMENT le fichier plan avant la moindre action.** Les résumés de compaction perdent en premier les contraintes négatives (« ne pas faire X ») — le fichier plan sur disque est la seule mémoire fiable.

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
> **Fable : {n} appel(s) · {n}k in · {n}k out** ← la métrique pilotée (escalades)

**KPI Fable** : cette dernière ligne est TOUJOURS affichée (0 appel = l'écrire aussi, c'est la bonne nouvelle) — l'objectif premier du plugin est de minimiser la consommation Fable ABSOLUE ; l'alerte >35 % ne sert que de détecteur de fuite.

Méthode de calcul (appliquer telle quelle) : coût estimé = tokens × tarif blended par Mtok, hypothèse 80 % input / 20 % output. Blended : fable $18 · opus $9 · sonnet $5.40 · haiku $1.80 (dérivés des tarifs API in/out $ par Mtok : fable 10/50, opus 5/25, sonnet 3/15, haiku 1/5 — tarifs constatés mi-2026, à rafraîchir en cas de doute). « Sans le plugin » = total tokens × $18 (la même volumétrie si Fable avait tout fait lui-même). Omettre les lignes de modèles non utilisés.

Règles d'honnêteté : ce tableau est une volumétrie hors cache — le trafic réel (écritures de cache à 1,25× le tarif input, lectures à 10 %) est typiquement **plusieurs fois supérieur** (×4-5 observé sur des runs mesurés). Ne JAMAIS le présenter comme un majorant ni comme le facturé. Le comparatif « sans le plugin » utilise la même base hors cache : il compare des volumétries, pas des factures. Coordination de session (Sonnet) non incluse, visible via /context. Valeur d'usage manquante = « n/d », jamais inventée. **Si la part fable dépasse ~35 % du coût total, le signaler ET détailler chaque appel Fable (mission, tokens)** pour localiser la fuite ; qualifier la cause : brief qui fuit (un appel anormalement gros vs les autres) ou part structurelle (commande courte où les passes Fable obligatoires dominent le dénominateur — le dire tel quel). Une alerte sans détail par appel n'est pas actionnable.

**Coût réel (cache inclus) — best effort** : si l'environnement le permet (CLI Claude Code, `jq` présent), calculer le coût réel de la session depuis son transcript et l'afficher sous le tableau (`Coût réel cache inclus : $n (transcript)`), sinon afficher `Coût réel : n/d (transcript non accessible)`. Commande (le transcript courant = le `.jsonl` le plus récent du projet ; inclure les sous-agents) :

```bash
D=~/.claude/projects/$(pwd | tr '/' '-'); S=$(ls -t "$D"/*.jsonl 2>/dev/null | head -1)
cat "$S" "${S%.jsonl}/subagents/"*.jsonl 2>/dev/null | jq -r 'select(.type=="assistant" and .message.usage!=null) | [.message.model, .message.usage.input_tokens//0, .message.usage.cache_creation_input_tokens//0, .message.usage.cache_read_input_tokens//0, .message.usage.output_tokens//0] | @tsv' | awk -F'\t' '{i[$1]+=$2;cw[$1]+=$3;cr[$1]+=$4;o[$1]+=$5} END{split("fable:10 opus:5 sonnet:3 haiku:1",T," "); for(m in i){r=3; for(t in T){split(T[t],p,":"); if(index(m,p[1]))r=p[2]}; c=(i[m]*r+cw[m]*r*1.25+cr[m]*r*0.10+o[m]*r*5)/1e6; printf "%s $%.2f\n",m,c; tot+=c} printf "TOTAL $%.2f\n",tot}'
```

(Tarifs in $/MTok fable 10, opus 5, sonnet 3, haiku 1 ; out = 5× in ; cache write = 1,25× in ; cache read = 0,10× in — constatés mi-2026, à rafraîchir en cas de doute.)

Pour /plan-run : ce tableau complète le Rapport de run écrit dans le fichier plan (qui garde le détail par tâche).


**Cumul par plan (sans fichier annexe)** : le fichier plan porte la ligne « Conso cumulée » dans son en-tête. En fin de commande, y additionner le coût estimé de cette commande (champ conception pour /plan et /plan-rework, champ runs pour /plan-run), puis afficher dans le récap la ligne : `Cumul de ce plan : conception $n · runs $n · total $n · dont Fable {n}k tokens`. Le champ « dont Fable » cumule les tokens Fable (in+out) de toutes les commandes ayant touché ce plan — c'est le compteur de la ressource contingentée. Le plan est le seul support de persistance — aucun registre ni fichier annexe. Un plan ancien sans cette ligne d'en-tête : l'ajouter à la première commande qui le touche.