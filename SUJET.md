
# GuestBook Kubernetes

Votre objectif est de déployer le guestbook du Jour 2 sur Kubernetes, et d'apprendre un maximum pendant cette session.

## Fiche d'apprentissages

Pour l'évaluation, merci de remplir une fiche d'apprentissage pour chaque exercice réalisé.
Cette fiche aura le template suivant :

```markdown
# Apprentissages

## Titre d'exo

Court résumé de l’objectif visé

### Problème rencontré et pourquoi il est survenu

### Solution appliquée et pourquoi cette solution fonctionne

### Ce que j'ai appris

```

## N'oubliez pas !

Créez-vous une doc en markdown dans ce dépôt, pour garder une trace de ce que vous faites, des commandes que vous utilisez, des erreurs que vous rencontrez et comment vous les avez résolues.

---

## 0. Préparer votre environnement

### Pourquoi

Pour pouvoir manipuler Kubernetes en local, il vous faut un cluster local, des outils pour interagir avec lui, et de quoi observer ce qui s'y passe.

### Comment

1. Installez les outils suivants :

  - [minikube](https://minikube.sigs.k8s.io/docs/start/): pour créer un cluster Kubernetes local
  - [kubectl](https://kubernetes.io/docs/tasks/tools/): pour piloter Kubernetes en ligne de commande
  - [Docker](https://docs.docker.com/get-docker/): pour construire et stocker vos images de conteneurs
  - [Helm](https://helm.sh/docs/intro/install/): pour gérer des applications complexes via des charts
  - [k9s](https://k9scli.io/topics/install/): pour observer et interagir avec le cluster en mode TUI
  - [stern](https://github.com/stern/stern): pour suivre les logs de plusieurs pods en même temps
  - [kubens](https://github.com/ahmetb/kubectx#kubens): pour changer rapidement de namespace dans kubectl
  - [kubectx](https://github.com/ahmetb/kubectx#kubectx): pour changer rapidement de contexte dans kubectl

2. Vérifiez l'installation de chaque outil avec :

  ```bash
  minikube version
  kubectl version --client
  docker --version
  helm version
  k9s version
  stern --version
  kubectx --help
  kubens --help
  ```

### Indices

- Suivez les guides d'installation officiels pour chaque outil (liens ci-dessus)

### Vérifications

- [ ] Tous les outils sont installés et fonctionnels
- [ ] Vous pouvez lancer `minikube start` sans erreur
- [ ] Vous pouvez exécuter `kubectl get nodes` et voir le nœud minikube

## 1. Explorer minikube et les bases de Kubernetes

### Pourquoi

Avant de déployer des applications, il est essentiel de comprendre l'état de votre cluster et de manipuler les ressources de base de Kubernetes.

### Comment

Testez les commandes suivantes et observez leur sortie :

- `kubectl get all`: liste toutes les ressources principales du namespace courant
- `kubectl get nodes`: affiche les nœuds du cluster
- `kubectl get namespaces`: liste les namespaces disponibles
- `kubectl config view`: affiche la configuration kubectl
- `kubectl config current-context`: affiche le contexte courant
- `kubectl describe node minikube`: détails sur le nœud minikube
- `kubectl cluster-info`: informations sur le cluster
- `kubectl get events --sort-by='.metadata.creationTimestamp' -A`: derniers événements du cluster dans tous les namespaces
- `kubectl get pods --all-namespaces`: liste tous les pods de tous les namespaces
- `kubectl get pods -o yaml`: affiche la description YAML des pods
- `kubectl explain pods`: documentation sur la ressource Pod

Puis rangez le cluster: créez deux namespaces, `guestbook` pour l'application et `data` pour sa base de données.

- Créez-les avec `kubectl create namespace` (ou en YAML)
- Placez-vous dans `guestbook` avec `kubens guestbook`: `kubectl get pods` est maintenant vide
- Toute la suite du TP se fait dans ces deux namespaces

### Indices

- Utilisez l'auto-complétion de kubectl (`kubectl <TAB><TAB>`) pour découvrir d'autres commandes
- Essayez d'explorer avec l'outil `k9s` pour une vue interactive

### Vérifications

- [ ] Vous savez lister les ressources principales du cluster
- [ ] Vous savez afficher les détails d'un nœud ou d'un pod
- [ ] Vous savez trouver le contexte courant et les namespaces
- [ ] Les namespaces `guestbook` et `data` existent et `guestbook` est le namespace courant


## 2. Déployer le guestbook (Pod)

### Pourquoi

Au Jour 2, vous avez conteneurisé le guestbook (image `guestbook:v0.1.0`, serveur HTTP sur le port `3000`) et l'avez lancé avec docker compose. L'étape suivante est de le déployer sur Kubernetes. Le Pod est l'unité de base d'exécution sur Kubernetes: il permet de lancer un ou plusieurs conteneurs ensemble.

### Comment

1. Rendez votre image disponible dans minikube: le cluster ne voit pas les images de votre Docker local.

   ```bash
   minikube image load guestbook:v0.1.0
   ```

1. Créez un fichier `pod.yaml` décrivant un Pod minimal :
  - Donnez-lui un nom
  - Définissez un conteneur avec un nom, l'image `guestbook:v0.1.0` et le port `3000`

2. Déployez le pod

1. Vérifiez son état et ses logs, dans le namespace `guestbook`
1. Testez l'accès à l'application (via port-forward)
1. Supprimez le pod si besoin

### Indices

- Essayez de déployer une image qui n'existe pas pour voir le comportement de Kubernetes
- Sans Redis, l'UI affiche **⚠️ Aucune connexion à la base de données... ⚠️** comme au Jour 2: c'est normal, Redis arrive à l'étape 5
- Utilisez l'extension VSCode Kubernetes pour générer des manifests YAML
- Observez ce qui se passe si vous modifiez le nom ou l'image du conteneur

### Vérifications

- [ ] Mon pod est en état "Running" et je peux suivre ses logs
- [ ] J'accède à l'interface web via le port-forward


## 3. Déployer le guestbook (Deployment + Service)

### Pourquoi

Un seul pod, c'est bien, mais si le nœud tombe, votre application n'est plus disponible. Les Deployments permettent de gérer la réplication, la mise à jour sans interruption et la robustesse. Les Services permettent d'accéder à n'importe quel pod via un point d'entrée unique (load balancing interne).

### Comment

1. **Transformez votre pod en Deployment** :
   - Créez un fichier `deployment.yaml` avec un template de pod et un nombre de replicas.
2. **Déployez le Deployment** :
3. **Créez un Service pour exposer l'application** (attention au selector)
4. **Testez l'accès à l'application**
5. **Expérimentez** :
   - Supprimez un pod et observez le redémarrage automatique
   - Modifiez l'image ou le nombre de replicas et observez le rolling update
   - Essayez de casser le service (mauvais label) et observez le résultat

### Indices

- Les labels sont essentiels pour l'association entre Service et Pods
- Le champ `selector` du Service doit correspondre aux labels du template du Deployment
- Utilisez `kubectl describe` pour comprendre le lien entre les ressources
- Comparez `kubectl get pods -n default` et `kubectl get pods -n guestbook`: les namespaces séparent les ressources

### Vérifications

- [ ] J'accède à une des réplicas via port-forward
- [ ] J'ai listé ou décrit mon Deployment
- [ ] J'accède à l'UI via le port-forward du Service

## 4. Déployer le guestbook (Helm Chart)

### Pourquoi

Helm est le gestionnaire de packages pour Kubernetes. Il permet de déployer facilement des applications complexes avec leurs dépendances, de gérer les versions et de paramétrer les déploiements selon l'environnement.

### Comment

1. **Créez la structure d'un chart Helm**
     - Consultez la [documentation officielle Helm](https://helm.sh/docs/) pour les bonnes pratiques

2. **Modifiez les templates** :
   - Remplacez le contenu de `templates/deployment.yaml` par votre deployment
   - Remplacez le contenu de `templates/service.yaml` par votre service
   - Modifiez `values.yaml` pour paramétrer votre application :

3. **Utilisez les valeurs dans vos templates** :
   - `{{ .Values.replicaCount }}`
   - `{{ .Values.service.port }}`
   - `{{ .Values.image.repository }}`
   - `{{ .Values.image.tag }}`

4. **Déployez avec Helm** dans le namespace `guestbook`

5. **Mettez à jour le déploiement**

### Indices

- Utilisez `helm template` pour prévisualiser les manifests générés
- Les templates Helm utilisent la syntaxe Go template

### Vérifications

- [ ] Mon chart Helm se déploie sans erreur
- [ ] Je peux modifier les paramètres via values.yaml
- [ ] Je peux mettre à jour le déploiement avec helm upgrade

## 5. Ajouter une base de données (Redis)

### Pourquoi

Le guestbook a besoin d'une base de données Redis pour persister les messages. Comme au Jour 2, nous utilisons l'image publique `redis:7`, cette fois avec vos propres manifests Kubernetes. La base de données vit dans son propre namespace `data`, séparée de l'application.

### Comment

1. **Créez un Deployment Redis** (`redis-deployment.yaml`) dans le namespace `data`:
   - 1 replica, image `redis:7`, port `6379`

2. **Créez un Service Redis** (`redis-service.yaml`) dans le namespace `data`:
   - Nommez-le `redis` et exposez le port `6379` (attention au selector)

3. **Vérifiez le déploiement Redis**
   - `kubectl exec -n data -it deploy/redis -- redis-cli ping` doit répondre `PONG`

4. **Connectez le guestbook à Redis avec une ConfigMap**
   - Ajoutez à votre chart un template `configmap.yaml` qui contient la variable `REDIS_HOST`, avec une valeur venant de `values.yaml`
   - Chargez cette ConfigMap dans votre Deployment (`envFrom`)
   - Trouvez la bonne valeur pour `REDIS_HOST`: le guestbook et Redis ne sont pas dans le même namespace

5. **Redéployez le guestbook** avec `helm upgrade`

6. **Modifiez la configuration**
   - Changez la valeur de `REDIS_HOST` (par exemple une valeur fausse) et faites un `helm upgrade`: les pods prennent-ils la nouvelle valeur ?
   - Faites en sorte que les pods redémarrent automatiquement quand la ConfigMap change

7. **Testez la persistance**
   - Ajoutez un message via l'interface web
   - Redémarrez le pod guestbook
   - Vérifiez que le message est toujours là

8. **Persistez les données de Redis**
   - Supprimez le pod Redis: les messages sont perdus, le système de fichiers d'un conteneur est éphémère
   - Ajoutez un PersistentVolumeClaim monté sur `/data` (minikube fournit une StorageClass par défaut) et refaites le test

9. **(Optionnel) Passez Redis en StatefulSet**
   - Remplacez le Deployment et le PVC par un StatefulSet avec un `volumeClaimTemplates`
   - Comparez le nom des pods et des PVC avec ceux du Deployment
   - Passez le StatefulSet à 2 replicas, ajoutez des messages et rafraîchissez la page plusieurs fois: que se passe-t-il, et pourquoi ?

### Indices

- Dans Kubernetes, un Service est joignable par son nom, comme un service docker compose... mais seulement depuis son propre namespace. Depuis un autre namespace: `<service>.<namespace>.svc.cluster.local`
- Utilisez `kubectl logs` et l'endpoint `/env` de l'application pour diagnostiquer les problèmes de connexion
- Les variables d'environnement sont lues au démarrage du conteneur
- Cherchez "Automatically Roll Deployments" dans la documentation Helm (annotation `checksum/config`)
- Après un `helm upgrade --set ...`, un `helm upgrade` sans option réutilise les valeurs précédentes: regardez l'option `--reset-values`

### Vérifications

- [ ] Redis est déployé et fonctionne dans le namespace `data`
- [ ] Le guestbook se connecte à Redis sans erreur, sa configuration vient d'une ConfigMap
- [ ] Les pods redémarrent automatiquement quand la configuration change
- [ ] Les messages sont persistés entre les redémarrages du guestbook
- [ ] Les messages survivent à la suppression du pod Redis
- [ ] (Optionnel) Je sais expliquer la différence entre un Deployment avec un PVC et un StatefulSet

## 6. Rendre l'application robuste avec les probes

### Pourquoi

Sans Redis, l'application ne fonctionne pas correctement mais Kubernetes ne le sait pas. Les probes permettent à Kubernetes de vérifier continuellement la santé de vos applications et de prendre des mesures correctives (redémarrage, arrêt du trafic, etc.).

### Comment

1. **Comprenez les types de probes** :
   - **Liveness probe**: vérifie si l'application est vivante (redémarre le pod si échec)
   - **Readiness probe**: vérifie si l'application peut recevoir du trafic
   - **Startup probe**: vérifie si l'application a bien démarré (pour les apps lentes)

2. **Ajoutez des probes à votre deployment**
   - **Readiness**: `httpGet` sur `/healthz` (port `3000`), qui vérifie la connexion à Redis
   - **Liveness**: un test qui ne dépend pas de Redis, par exemple `tcpSocket` sur le port `3000`

3. **Déployez sans Redis d'abord** (par exemple en passant le Deployment Redis à 0 replica dans le namespace `data`)

4. **Observez le comportement**

5. **Testez l'accès**

6. **Remettez Redis en place**

### Indices

- L'endpoint `/healthz` du guestbook retourne 500 si Redis n'est pas accessible
- Ne mettez pas `/healthz` en liveness: si Redis tombe, tous les pods redémarreraient en boucle alors qu'ils ne sont pas cassés (cf. cours)
- Les probes échouent si l'application retourne un code d'erreur HTTP (≥400)
- Utilisez `kubectl get events` pour voir les actions de Kubernetes

### Vérifications

- [ ] Mes pods sont "Not Ready" quand Redis est absent
- [ ] L'application redevient accessible automatiquement quand Redis revient
- [ ] Mes pods ne redémarrent pas quand Redis est absent
- [ ] Je comprends la différence entre liveness et readiness probes

## 7. Exposer le guestbook avec un Ingress

### Pourquoi

Jusqu'ici, on accède au guestbook avec `kubectl port-forward`: pratique pour tester, mais pas pour de vrais utilisateurs. Un Ingress route les requêtes HTTP qui viennent de l'extérieur vers les Services, selon le nom de domaine et le chemin.

### Comment

1. **Installez un Ingress controller**: `minikube addons enable ingress`

2. **Ajoutez un template `ingress.yaml` à votre chart**
   - Activable depuis `values.yaml` (`ingress.enabled`)
   - Host `guestbook.local`, chemin `/`, vers le Service du guestbook

3. **Déployez** avec `helm upgrade`

4. **Testez l'accès** sans port-forward

### Indices

- `kubectl get ingress` affiche l'adresse de l'Ingress
- Le nom `guestbook.local` n'existe pas dans un DNS: ajoutez-le à votre fichier `/etc/hosts`, ou utilisez `curl --resolve guestbook.local:80:$(minikube ip) http://guestbook.local/`
- Avec le driver docker sous macOS ou Windows, l'IP de minikube n'est pas joignable: lancez `minikube tunnel` et utilisez `127.0.0.1`
- N'oubliez pas l'`ingressClassName`

### Vérifications

- [ ] J'accède au guestbook sur `http://guestbook.local` sans port-forward
- [ ] Je peux désactiver l'Ingress depuis `values.yaml`
- [ ] Je sais expliquer le chemin d'une requête: navigateur → Ingress controller → Service → pod

## 8. Faire monter en charge automatiquement (HPA)

### Pourquoi

Quand la charge augmente, il faut plus de pods pour maintenir les performances. Le Horizontal Pod Autoscaler (HPA) surveille les métriques (CPU, mémoire, métriques custom) et ajuste automatiquement le nombre de replicas.

### Comment

1. **Activez les metrics server** (requis pour HPA)

2. **Ajoutez des resource requests à votre deployment**

3. **Créez un HPA** :

4. **Écrivez un test de charge avec [k6](https://grafana.com/docs/k6/latest/)** (`load-test.js`) :
   ```javascript
   import http from 'k6/http';
   import { check, sleep } from 'k6';

   const BASE_URL = __ENV.GUESTBOOK_URL || 'http://guestbook:3000';

   export const options = {
     scenarios: {
       visitors: {
         executor: 'ramping-arrival-rate', // un nombre de requêtes/s, pas d'utilisateurs
         startRate: 10,
         timeUnit: '1s',
         preAllocatedVUs: 50,
         maxVUs: 300,
         stages: [
           { duration: '1m', target: 200 },
           { duration: '3m', target: 200 },
           { duration: '1m', target: 0 },
         ],
       },
     },
     thresholds: {
       http_req_failed: ['rate<0.01'],   // moins de 1% d'erreurs
       http_req_duration: ['p(95)<500'], // 95% des requêtes en moins de 500 ms
     },
   };

   // Une visite = ce que fait le navigateur
   export default function () {
     const page = http.get(`${BASE_URL}/`);
     check(page, { 'ui is 200': (r) => r.status === 200 });
     // TODO: récupérer aussi les messages, comme le fait l'UI
     sleep(0.1);
   }
   ```

5. **Lancez le test depuis le cluster** avec un Job qui utilise l'image `grafana/k6` :
   - Mettez le script dans une ConfigMap: `kubectl create configmap k6-script --from-file=load-test.js`
   - Écrivez un Job qui monte cette ConfigMap et exécute `k6 run /scripts/load-test.js`
   - Le Job joint le guestbook par le nom de son Service, comme le ferait n'importe quel autre pod

6. **Observez** dans d'autres terminaux :
   ```bash
   kubectl get hpa -w
   kubectl get pods -w
   kubectl logs -f job/<nom-du-job>   # résumé et thresholds à la fin
   ```

### Indices

- Le HPA met quelques minutes à réagir et stabiliser
- Utilisez `kubectl top pods` pour voir la consommation des ressources
- Les resource requests sont obligatoires pour que le HPA fonctionne
- Avec un HPA, retirez `replicas` du Deployment dans votre chart: sinon chaque `helm upgrade` écrase le nombre de replicas choisi par le HPA
- Pourquoi `ramping-arrival-rate` ? Avec un nombre fixe d'utilisateurs virtuels, chacun attend sa réponse: plus l'application ralentit, moins elle reçoit de requêtes. Un débit fixe garde la pression, comme de vrais utilisateurs
- Pourquoi depuis le cluster ? Le trafic passe par le Service et est réparti sur tous les pods. `kubectl port-forward` enverrait tout vers un seul pod
- Alternative en local: installez k6, passez le Service en `NodePort`, récupérez l'URL avec `minikube service guestbook --url` et lancez `k6 run -e GUESTBOOK_URL=<url> load-test.js`

### Vérifications

- [ ] Le HPA est créé et fonctionne
- [ ] Sous charge, le nombre de pods augmente automatiquement
- [ ] Après la charge, le nombre de pods redescend
- [ ] J'ai analysé les thresholds k6: à quel moment la latence ou les erreurs ont-elles dépassé les seuils, et pourquoi ?

## 9. Gérer deux environnements

### Pourquoi

La même application tourne en général dans plusieurs environnements (dev, staging, prod), avec les mêmes manifests et quelques valeurs différentes. Les namespaces isolent les environnements, Helm évite de copier-coller le YAML.

### Comment

1. **Créez les namespaces** `guestbook-dev`, `data-dev`, `guestbook-prod` et `data-prod`

2. **Déployez un Redis par environnement**, avec les manifests de l'exercice 5, dans `data-dev` et `data-prod`

3. **Écrivez un fichier de valeurs par environnement**
   - `values-dev.yaml`: 1 replica, pas de HPA, host `dev.guestbook.local`
   - `values-prod.yaml`: HPA activé, requests plus élevées, host `prod.guestbook.local`
   - Chaque environnement pointe vers son propre Redis

4. **Déployez le même chart deux fois**, une fois par environnement

5. **Vérifiez l'isolation**
   - Ajoutez un message en dev: il ne doit pas apparaître en prod

### Indices

- `helm install` accepte `-n <namespace>` et `-f <fichier de valeurs>`
- Utilisez `helm template` avec chaque fichier de valeurs pour comparer ce qui sera déployé
- Depuis `guestbook-dev`, essayez de joindre le Redis de prod: que remarquez-vous ? (cf. cours: un namespace n'est pas une frontière de sécurité à lui seul)

### Vérifications

- [ ] Les deux environnements tournent avec le même chart et des valeurs différentes
- [ ] Les messages de dev n'apparaissent pas en prod
- [ ] Je sais pourquoi un namespace seul n'isole pas le réseau

## 10. Sauvegarder Redis avec un CronJob

### Pourquoi

Les données ont maintenant de la valeur: il faut les sauvegarder régulièrement, et savoir les restaurer. Un CronJob crée un Job selon un planning, comme une crontab.

### Comment

1. **Créez un PVC** `redis-backup` dans le namespace `data` pour stocker les sauvegardes

2. **Créez un CronJob** `redis-backup` (une fois par nuit) qui:
   - utilise l'image `redis:7`
   - exécute `redis-cli --rdb` vers le Service Redis pour récupérer un dump
   - écrit le dump dans le PVC `redis-backup`

3. **Lancez une sauvegarde à la main** sans attendre la nuit

4. **Testez la restauration**
   - Notez les messages présents, puis supprimez-les (`redis-cli del guestbook`)
   - Arrêtez Redis, copiez le dump dans le volume de Redis avec un Job, redémarrez Redis
   - Les messages sont revenus

### Indices

- `kubectl create job --from=cronjob/redis-backup <nom>` lance un CronJob immédiatement
- Regardez `backoffLimit`, `concurrencyPolicy` et `successfulJobsHistoryLimit`
- Redis charge `/data/dump.rdb` au démarrage. Redis écrit aussi ce fichier à l'arrêt: arrêtez-le avant de restaurer
- Un PVC `ReadWriteOnce` peut être monté par plusieurs pods s'ils sont sur le même nœud (c'est le cas avec minikube)

### Vérifications

- [ ] Le CronJob crée un Job selon le planning, et je peux le déclencher à la main
- [ ] Un dump est présent dans le PVC `redis-backup`
- [ ] J'ai restauré des messages supprimés à partir d'une sauvegarde

## 11. (Optionnel) Charger les secrets depuis External Secrets

### Pourquoi

En production, les secrets (mots de passe, clés API) ne doivent pas être stockés dans le code ou les manifests. External Secrets Operator synchronise des secrets depuis un coffre-fort externe (Vault, AWS Secrets Manager, GCP Secret Manager, ...) vers des Secrets Kubernetes.

### Comment

1. **Installez External Secrets Operator** [https://charts.external-secrets.io](https://charts.external-secrets.io)

2. **Configurez un SecretStore**: sans compte cloud, on utilise le provider `fake`, qui simule un coffre-fort externe :
   ```yaml
   apiVersion: external-secrets.io/v1
   kind: SecretStore
   metadata:
     name: fake-store
   spec:
     provider:
       fake:
         data:
         - key: "/guestbook/api-key"
           value: "s3cr3t"
   ```

3. **Créez un ExternalSecret** :
   ```yaml
   apiVersion: external-secrets.io/v1
   kind: ExternalSecret
   metadata:
     name: guestbook-api-key
   spec:
     refreshInterval: 1m
     secretStoreRef:
       name: fake-store
       kind: SecretStore
     target:
       name: guestbook-secret
       creationPolicy: Owner
     data:
     - secretKey: API_KEY
       remoteRef:
         key: /guestbook/api-key
   ```

4. **Injectez le Secret dans le guestbook** en variable d'environnement, et vérifiez sa présence via l'endpoint `/env` de l'application

### Indices

- Vérifiez la version d'API servie par votre installation: `kubectl api-resources | grep external-secrets`

### Vérifications

- [ ] External Secrets Operator est installé et fonctionne
- [ ] Le Secret `guestbook-secret` est créé automatiquement depuis le SecretStore
- [ ] Le guestbook reçoit la variable `API_KEY`

## 12. (Optionnel) Stratégies de déploiement avancées

### Blue-Green Deployment

1. **Créez deux versions de votre application** :
   - Version "blue" (actuellement en production)
   - Version "green" (nouvelle version)

2. **Basculez le trafic instantanément** via les labels du service

## 13. (Optionnel) Un agent sur chaque nœud (DaemonSet)

### Pourquoi

Certains outils doivent tourner sur chaque nœud du cluster: collecte de logs, monitoring, réseau. Un DaemonSet place un pod sur chaque nœud, y compris sur les nœuds ajoutés plus tard.

### Comment

1. **Créez un cluster multi-nœuds** à côté du premier: `minikube start -p multinode --nodes 3`

2. **Créez un DaemonSet** dans un namespace `logging`:
   - image `busybox`
   - monte le dossier `/var/log/pods` du nœud (volume `hostPath`)
   - affiche régulièrement le nom du nœud et le nombre de pods dont il voit les logs

3. **Observez** sur quels nœuds tournent les pods

4. **Ajoutez un nœud** (`minikube node add -p multinode`) et observez

5. **Comparez** avec un Deployment de 3 replicas

### Indices

- `kubectl get pods -o wide` affiche le nœud de chaque pod
- Le nom du nœud est disponible dans le pod grâce à la downward API (`spec.nodeName`)
- Le control plane a un taint: regardez si votre DaemonSet y place un pod
- Supprimez le cluster à la fin: `minikube delete -p multinode`

### Vérifications

- [ ] Un pod de l'agent tourne sur chaque nœud
- [ ] Un nouveau nœud reçoit automatiquement son pod
- [ ] Je sais quand utiliser un DaemonSet plutôt qu'un Deployment

## 14. (Optionnel) Observer avec Kube-shark

### Pourquoi

Kube-shark permet d'observer le trafic réseau dans votre cluster, utile pour déboguer les problèmes de connectivité.

### Comment

1. **Installez la CLI kubeshark**: [https://docs.kubeshark.co](https://docs.kubeshark.co)

2. **Lancez la capture** (elle déploie ses composants dans le cluster) :
   ```bash
   kubeshark tap
   ```

3. **Observez le trafic** dans l'interface web qui s'ouvre automatiquement

### Vérifications

- [ ] Je peux observer le trafic HTTP entre mes pods
- [ ] Je comprends les communications dans mon cluster

## Objectifs pédagogiques

### Savoir

- [ ] Je sais expliquer la différence entre scale vertical et scale horizontal
- [ ] Je sais expliquer l'état désiré et la boucle de réconciliation
- [ ] Je connais le rôle du control plane et des workers
- [ ] Je sais à quoi servent un Pod, un Deployment, un Service et un HPA
- [ ] Je connais la différence entre liveness et readiness probes
- [ ] Je sais à quoi servent les requests et les limits
- [ ] Je sais ce qu'est un chart Helm
- [ ] Je sais à quoi servent les namespaces, et leurs limites
- [ ] Je sais séparer la configuration du code avec une ConfigMap
- [ ] Je connais la différence entre Deployment, StatefulSet, DaemonSet et CronJob

### Savoir-faire

- [ ] Je sais lancer un cluster local et inspecter ses ressources avec `kubectl`
- [ ] Je sais déployer une application avec un Deployment et l'exposer avec un Service
- [ ] Je sais diagnostiquer un pod en erreur (`describe`, `logs`, `events`)
- [ ] Je sais packager et déployer une application avec Helm
- [ ] Je sais ajouter des probes et des requests à un Deployment
- [ ] Je sais mettre en place un HPA et le tester sous charge
- [ ] Je sais exposer une application avec un Ingress
- [ ] Je sais déployer la même application dans plusieurs environnements
- [ ] Je sais sauvegarder et restaurer des données avec un CronJob

## Conseils pour aller plus loin

### Ressources d'apprentissage
- **Documentation officielle**: <https://kubernetes.io/docs/>
- **Kubernetes The Hard Way**: <https://github.com/kelseyhightower/kubernetes-the-hard-way>
- **Helm Best Practices**: <https://helm.sh/docs/chart_best_practices/>

### Prochaines étapes
1. **Pratiquez sur un vrai cluster** (EKS, GKE, AKS)
2. **Apprenez Istio** pour la gestion du service mesh
3. **Étudiez les opérateurs Kubernetes** pour automatiser la gestion d'applications

### Bonnes pratiques à retenir
- Utilisez toujours des resource requests et limits
- Implémentez des probes pour toutes vos applications
- Versionnez vos images de conteneurs (évitez `latest`)
- Utilisez des namespaces pour isoler vos environnements
