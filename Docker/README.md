# GuestBook docker-compose Dojo

<details>

<summary>Sommaire</summary>

- [GuestBook docker-compose Dojo](#guestbook-docker-compose-dojo)
  - [0. Préparer votre environnement](#0-préparer-votre-environnement)
  - [1. Conteneuriser l'application guestbook](#1-conteneuriser-lapplication-guestbook)
    - [Pourquoi](#pourquoi)
    - [Comment](#comment)
    - [Vérifications](#vérifications)
    - [Construire l'image de conteneur (Docker)](#construire-limage-de-conteneur-docker)
    - [Pourquoi](#pourquoi-1)
    - [Quoi](#quoi)
    - [Comment](#comment-1)
    - [Vérifications](#vérifications-1)
    - [Exécuter localement avec docker compose](#exécuter-localement-avec-docker-compose)
    - [Pourquoi](#pourquoi-2)
    - [Quoi](#quoi-1)
    - [Comment](#comment-2)
    - [Vérifications](#vérifications-2)
  - [2. Ajouter une base de données à votre service](#2-ajouter-une-base-de-données-à-votre-service)
    - [Pourquoi](#pourquoi-3)
    - [Quoi](#quoi-2)
    - [Comment](#comment-3)
    - [Vérifications](#vérifications-3)
  - [3. Ajouter de la persistance et du hot-reloading au guestbook](#3-ajouter-de-la-persistance-et-du-hot-reloading-au-guestbook)
    - [Pourquoi](#pourquoi-4)
    - [Comment](#comment-4)
      - [Persistance des données Redis](#persistance-des-données-redis)
      - [Hot-reloading pour l'application Go](#hot-reloading-pour-lapplication-go)
    - [Indices](#indices)
    - [Vérifications](#vérifications-4)
  - [7. (Optionnel) Ouvrir le guestbook sur le réseau](#7-optionnel-ouvrir-le-guestbook-sur-le-réseau)
    - [Pourquoi](#pourquoi-5)
    - [Comment](#comment-5)
      - [Étape 1 : Ajouter un service de gestion des utilisateurs](#étape-1--ajouter-un-service-de-gestion-des-utilisateurs)
      - [Étape 2 : Rendre l'application accessible sur le réseau local](#étape-2--rendre-lapplication-accessible-sur-le-réseau-local)
    - [Indices](#indices-1)
    - [Vérifications](#vérifications-5)
  - [8. Valider la portabilité de vos projets](#8-valider-la-portabilité-de-vos-projets)
    - [Pourquoi](#pourquoi-6)
    - [Comment](#comment-6)
    - [Vérifications](#vérifications-6)
    - [Conseils finaux](#conseils-finaux)
</details>

Votre objectif est de déployer une application web simple avec Docker-compose, et d'apprendre le maximum pendant cette session.

C'est pourquoi il est essentiel que :

- Vous expérimentiez et essayiez des choses qui peuvent casser.
- Mais gardez aussi le focus sur votre objectif : avoir une application qui fonctionne, morceau par morceau. Ne vous bloquez pas dès le début sur un détail.
- Pour continuer à avancer ou apprendre davantage, n'hésitez pas à _demander de l'aide_ ! Cela signifie que chaque fois que vous avez une question, un doute, un retour, vous pouvez me demander ou demander à un collègue étudiant. Nous sommes là pour vous aider !

## 0. Préparer votre environnement

Vérifiez que vous avez les outils suivants installés :

- `git` : Versionnez votre code et collaborez
- [`docker`](https://docs.docker.com/get-docker/) : Construisez et exécutez des images de conteneurs
- [`docker-compose`](https://docs.docker.com/compose/install/#install-compose) : Exécutez plusieurs conteneurs localement

## 1. Conteneuriser l'application guestbook

### Pourquoi

Si vous voulez vraiment vous immerger dans la vie d'un développeur, vous devrez être capable d'itérer rapidement sur l'application localement.

### Comment

Exécutez l'application localement et essayez de modifier quelque chose dans le code.
Utilisez cette commande pour lancer l'application :

```bash
sudo go run main.go
```

Quand vous êtes satisfait du résultat, vous pouvez lancer l'application avec `sudo go run main.go`, ou construire un binaire avec `sudo go build`.

### Vérifications

- [ ] Je peux exécuter l'application localement et voir l'interface web.
- [ ] J'ai implémenté un petit changement dans l'application et elle fonctionne toujours

### Construire l'image de conteneur (Docker)

### Pourquoi

Pendant que vous construisez et itérez sur votre application localement, vous devez être capable de la déployer sur un vrai environnement de production.

Puisque vous ne savez pas où elle va s'exécuter (dans une machine virtuelle isolée ?, quels packages sont installés ?), nous voulons assurer la reproductibilité et l'isolation de l'application. C'est pour cela que les conteneurs, que `docker` aide à construire et exécuter, sont faits !

C'est une API standard pour construire et livrer des applications à travers diverses charges de travail. Quel que soit le serveur sur lequel elle s'exécute, votre _image_ devrait toujours construire le même environnement isolé.

De plus, c'est bien moins coûteux en ressources (CPU, RAM) qu'une Machine Virtuelle, qui réalise une isolation en réinstallant un OS complet.

### Quoi

Nous devons _construire_ une _image_ de conteneur à partir du code dans ce dépôt. Pour cela, la commande `docker build -t <nom-image>:<version> .` construit une image à partir d'une _recette_ locale `Dockerfile`.

> :info: À noter ! il est important de tagger son image avec un tag unique et non le tag `latest`. Cela permet de s'assurer que vous savez exactement quelle version de l'image vous utilisez, et d'éviter des comportements inattendus.

Par exemple, pour une application python simple, cela pourrait être :

```Dockerfile
FROM python:3.8

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY main.py main.py

CMD ["python", "main.py"]
```

Vous pouvez trouver la [référence Dockerfile complète](https://docs.docker.com/engine/reference/builder/) ici.

Ici nous avons un _webservice_ écrit en _golang_, qui exécute un serveur HTTP sur le port `3000`.
Il sert quelques fichiers statiques (stockés dans `/public`) pour l'UI. Vous y accéderez principalement via un `GET /` pour l'UI, mais il y a d'autres routes pour gérer l'état de l'application.

### Comment

Vous pouvez suivre [ce tutoriel](https://docs.docker.com/language/golang/build-images/) pour voir comment construire une image golang

1. Écrivez un `Dockerfile`. Vous devez commencer par une _image de base_, idéalement avec golang déjà installé.
2. Définissez un répertoire de travail.
3. Dans le `Dockerfile`, téléchargez les dépendances du microservice en utilisant la commande `go mod download`. Depuis les dernières versions de golang, nous n'avons besoin que de `go.mod` et `go.sum` pour cette tâche.
4. Dans le `Dockerfile`, construisez le microservice. Vous avez besoin de la commande `go build` pour cela.
5. Dans le `Dockerfile`, ajoutez le dossier `public` à l'intérieur du conteneur, dans le même dossier `public`.
6. Quand le conteneur démarre, exécutez le microservice.
7. Construisez une image de conteneur : `docker build -t guestbook:v0.1.0 .`
8. Exécutez le conteneur.

   Vous devez _exposer_ le port de votre application, qui s'exécute sur le port `3000`. Pour cela, vous devez ajouter l'option `--publish <port-externe>:<port-interne>` à la commande `docker run`.

   ```bash
   docker run --publish 3000:3000 guestbook:v0.1.0
   ```

Implémentez quelques bonnes pratiques, comme les "builds multi-étapes". Cela aide à réduire la taille de vos images et augmente la sécurité.

L'image que vous avez construite jusqu'à présent est assez grosse car elle contient tout le toolkit Go. Il est temps de la rendre plus petite. Beaucoup plus petite. Voici ce que vous devez faire :

1. Vérifiez la taille de votre image de conteneur.
2. Changez la commande `go build` pour rendre le binaire lié statiquement (si vous ne savez pas ce que cela signifie, demandez !). Vous pourriez avoir besoin d'ajouter une commande `go mod tidy`.
3. Dans votre `Dockerfile`, créez une seconde étape qui commence à partir de `scratch`.
4. Copiez le binaire de la première étape vers la seconde.
5. Dans la seconde étape, exécutez le microservice.
6. Construisez votre image de conteneur à nouveau.
7. Vérifiez la taille de l'image maintenant.

### Vérifications

- [ ] Je peux construire une image localement
- [ ] Je peux exécuter le conteneur localement
- [ ] La taille de l'image est inférieure à 20MB

### Exécuter localement avec docker compose

### Pourquoi

Vous avez un environnement local qui fonctionne, cependant vous devez déjà enchaîner quelques commandes, et comme votre application va devenir plus complexe, la configuration sera plus difficile à maintenir.

Au lieu d'avoir à taper une chaîne de commandes _impérative_, vous pouvez avoir une description _déclarative_ de votre application locale _docker/conteneur_. C'est pour cela que `docker compose` est fait : il lit cette configuration et exécute les bonnes `commandes docker` pour vous.

### Quoi

Nous devons être capable de lancer le conteneur actuel avec seulement la commande `docker compose up`.

Le fichier `docker-compose.yaml` contiendra tout ce qui est nécessaire :

- comment construire l'image
- comment exécuter le conteneur, y compris la configuration du port
- comment le lier à un autre conteneur
- comment persister un stockage

### Comment

Il y a un [article _pour commencer_](https://docs.docker.com/compose/gettingstarted/), ou la [spécification complète](https://docs.docker.com/compose/compose-file/)

- définissez votre service guestbook
- vous pouvez utiliser l'image que vous avez construite, mais vous pouvez aussi spécifier comment la reconstruire !
- n'oubliez pas d'exposer le port nécessaire pour votre application

### Vérifications

- [ ] Je peux lancer localement l'application avec `docker compose up`
- [ ] Je peux voir l'UI dans mon navigateur à `localhost:3000`

## 2. Ajouter une base de données à votre service

### Pourquoi

Si vous testez votre application, vous pouvez voir un gros **⚠️ Aucune connexion à la base de données... ⚠️**. De plus, quand vous essayez d'ajouter quelque chose au guestbook, ça reste en attente (⌛) sans l'enregistrer (essayez de rafraîchir la page).

L'application est en fait sans état, et a besoin d'un backend Redis pour sauvegarder son état. Pour éviter d'interférer avec votre installation locale, nous allons l'exécuter dans un conteneur, en utilisant une fois de plus `docker` et `docker compose`.

### Quoi

Nous avons simplement besoin d'ajouter un nouveau service dans notre fichier docker-compose, et d'avoir un moyen pour l'application de l'utiliser.

### Comment

1. Ajoutez un service `redis` dans votre application. Ne construisez pas redis localement, mais utilisez l'image publique `redis:7` ou supérieure.
2. Exposez son port redis `6379`.
3. Faites en sorte que l'application guestbook l'utilise :

   L'application Guestbook utilise des _variables d'environnement_ pour sa configuration. Ici vous devez configurer la variable `REDIS_HOST` avec le nom d'hôte de votre cluster redis. Dans un environnement docker-compose, chaque service peut être appelé avec son nom.
4. Essayez de l'exécuter : l'application stocke-t-elle l'état ?

### Vérifications

- [ ] L'application enregistre effectivement les messages
- [ ] (Optionnel) Si vous exécutez `docker compose down`, vous ne perdez pas les données quand vous relancez l'application.

## 3. Ajouter de la persistance et du hot-reloading au guestbook

### Pourquoi

Maintenant que votre application fonctionne avec une base de données, vous voulez améliorer l'expérience de développement. Deux aspects sont importants :

1. **Persistance des données** : Éviter de perdre vos données de test à chaque redémarrage
2. **Hot-reloading** : Voir vos modifications de code instantanément sans reconstruire l'image

### Comment

#### Persistance des données Redis

1. **Créer un volume Docker** pour persister les données Redis :

   Dans votre `docker-compose.yaml`, ajoutez une section `volumes` et configurez Redis pour utiliser ce volume.
2. **Tester la persistance** :
   - Ajoutez quelques messages dans le guestbook
   - Exécutez `docker compose down`
   - Relancez avec `docker compose up`
   - Vérifiez que vos messages sont toujours là

#### Hot-reloading pour l'application Go

1. **Installer Air** (outil de hot-reloading pour Go) dans votre conteneur :

   Modifiez votre `Dockerfile` pour inclure Air

2. **Créer un fichier de configuration Air** `.air.toml` :

3. **Configurer docker-compose pour le développement** :

### Indices

- Pour utiliser la configuration de développement : `docker compose -f docker-compose.dev.yaml up`
- Air détectera automatiquement les changements dans vos fichiers `.go` et redémarrera l'application
- Les volumes Docker sont persistés même après `docker compose down`
- Vous pouvez aussi utiliser des volumes nommés ou des bind mounts selon vos besoins

### Vérifications

- [ ] Les données Redis persistent après un `docker compose down` et `up`
- [ ] Les modifications du code Go sont automatiquement rechargées sans reconstruire l'image
- [ ] L'application reste accessible sur `localhost:3000`
- [ ] Les logs montrent qu'Air détecte et recompile lors des changements de fichiers

## 7. (Optionnel) Ouvrir le guestbook sur le réseau

### Pourquoi

Maintenant que votre application fonctionne localement, vous voulez la partager avec vos collègues. Cela implique de la rendre accessible depuis l'extérieur et d'ajouter potentiellement une couche de sécurité.

### Comment

#### Étape 1 : Ajouter un service de gestion des utilisateurs

1. **Ajouter Authelia ou OAuth2 Proxy** :

2. **Configurer un reverse proxy** avec Nginx :

#### Étape 2 : Rendre l'application accessible sur le réseau local

1. **Modifier la configuration réseau** :
   - Dans votre `docker-compose.yaml`, exposez les ports sur toutes les interfaces

2. **Trouver votre IP locale** :

3. **Partager l'URL** avec vos collègues : `http://VOTRE_IP:3000`

### Indices

- Assurez-vous que votre pare-feu autorise les connexions entrantes sur le port choisi
- OAuth2 nécessite la création d'une application GitHub/GitLab dans les paramètres développeur
- Testez d'abord l'accès direct avant d'ajouter l'authentification

### Vérifications

- [ ] L'application est accessible depuis une autre machine du réseau
- [ ] L'authentification fonctionne correctement
- [ ] Les utilisateurs autorisés peuvent accéder au guestbook

## 8. Valider la portabilité de vos projets

### Pourquoi

Un des avantages majeurs de Docker est la portabilité. Votre projet devrait fonctionner de manière identique sur n'importe quelle machine ayant Docker d'installé.

### Comment

1. **Échanger les projets** :
   - Récupérez le `docker-compose.yaml` d'un collègue
   - Assurez-vous d'avoir tous les fichiers nécessaires (Dockerfile, configuration, etc.)

2. **Tester le déploiement** :
   ```bash
   docker compose down  # Arrêter votre version
   git clone URL_DU_PROJET_collègue
   cd projet-collègue
   docker compose up
   ```

3. **Identifier les problèmes potentiels** :
   - Chemins en dur dans les configurations
   - Dépendances système manquantes
   - Variables d'environnement non définies
   - Ports déjà utilisés

4. **Corriger et améliorer** :
   - Documenter les prérequis dans le README
   - Utiliser des variables d'environnement avec des valeurs par défaut
   - Ajouter des vérifications de santé (healthchecks)

### Vérifications

- [ ] Le projet d'un collègue se lance sans modification
- [ ] Votre projet fonctionne chez un collègue
- [ ] La documentation est suffisante pour un déploiement autonome
- [ ] Les données sont correctement isolées entre les déploiements

### Conseils finaux

- Utilisez des tags de version spécifiques pour vos images (évitez `latest`)
- Documentez les ports utilisés et les variables d'environnement
- Testez votre configuration sur une machine "propre"
- Considérez l'utilisation de `.env` files pour la configuration locale
