## 1. (Optionnel) Formation lab Docker sécurité

### Pourquoi

La sécurité des conteneurs Docker est fondamentale car les vulnérabilités dans les images peuvent compromettre l'ensemble de votre infrastructure. Ce lab pratique vous permet d'apprendre les bonnes pratiques de sécurité Docker.

### Comment

1. **Suivez les instructions du [Formation Lab Docker Sécurité](https://github.com/padok-team/formation-lab-docker-secu)**

Référence :

### Vérifications

- [ ] Vous avez complété les exercices du lab Docker sécurité
- [ ] Vous savez scanner une image pour les vulnérabilités
- [ ] Vous comprenez les bonnes pratiques de construction d'images sécurisées

## 2. Signer une image Docker avec Cosign

### Pourquoi

La signature d'images Docker permet de garantir leur intégrité et leur provenance. [Cosign](https://github.com/sigstore/cosign) fait partie de l'écosystème Sigstore et permet de signer cryptographiquement les artefacts de conteneurs pour assurer la chaîne d'approvisionnement.

### Comment

1. **Installez Cosign** sur votre système
2. **Générez une paire de clés** pour la signature
3. **Afficher la SBOM** de votre image gusestbook
4. **Signez cette image Docker** existante
5. **Vérifiez la signature** de l'image
6. **Testez la vérification** avec une image signée et une image non signée

### Vérifications

- [ ] Une image Docker est signée avec succès
- [ ] La vérification de signature fonctionne correctement
- [ ] Vous comprenez le processus de vérification d'intégrité

## 3. Mettre en place des politiques OPA

### Pourquoi

Open Policy Agent (OPA) permet de définir et d'appliquer des politiques de sécurité de manière déclarative. Dans Kubernetes, OPA Gatekeeper permet de contrôler ce qui peut être déployé selon des règles de sécurité prédéfinies.

### Comment

1. **Installez [OPA Gatekeeper](https://github.com/open-policy-agent/gatekeeper)** dans votre cluster
2. **Écrivez une politique** pour interdire l'utilisation du tag `:latest`
3. **Créez une seconde politique** pour exiger :
   - L'exécution en tant que non-root
   - L'utilisation d'un registry approuvé
4. **Appliquez les politiques** au cluster
5. **Testez les politiques** en tentant de déployer des ressources non conformes

### Vérifications

- [ ] OPA Gatekeeper est déployé et fonctionnel
- [ ] La politique interdisant `:latest` est active et fonctionnelle
- [ ] La politique exigeant non-root et registry approuvé fonctionne
- [ ] Les déploiements non conformes sont rejetés
- [ ] Les déploiements conformes sont acceptés

## 4. Écrire des Network Policies

### Pourquoi

Les Network Policies permettent de contrôler le trafic réseau entre les pods dans Kubernetes. Elles implémentent une micro-segmentation réseau essentielle pour limiter les communications et réduire la surface d'attaque.

### Comment

1. **Activez l'addon ingress controller** via minikube addons
2. **Modifiez le déploiement guestbook** pour séparer les composants :
   - Backend dans le namespace `backend`
   - Redis dans le namespace `database`
3. **Créez des Network Policies** pour :
   - Permettre uniquement au backend d'accéder à la database
   - Permettre l'accès au backend depuis le namespace `ingress-nginx`
4. **Testez la connectivité** pour valider les restrictions

### Vérifications

- [ ] Vous pouvez accéder à l'application via l'ingress
- [ ] Le backend est déployé dans le namespace `backend`
- [ ] Redis est déployé dans le namespace `database`
- [ ] La Network Policy autorise backend → database
- [ ] La Network Policy autorise ingress-nginx → backend
- [ ] Les communications non autorisées sont bloquées (donnez une preuve)

## 5. Construire une matrice de risque

### Pourquoi

L'analyse de risque est fondamentale en sécurité pour identifier, évaluer et prioriser les menaces. Une matrice de risque permet de visualiser et de hiérarchiser les actions de sécurité selon leur impact et leur probabilité.

### Comment

1. **Analysez l'infrastructure** mise en place jusqu'ici
2. **Identifiez les risques potentiels** pour chaque composant
3. **Évaluez l'impact et la probabilité** de chaque risque
4. **Construisez la matrice de risque** selon le modèle fourni
5. **Définissez les remédiations** appropriées pour chaque risque
6. **Priorisez les actions** selon les critères P0 à P4

### Vérifications

- [ ] Vous avez identifié au moins 5 risques pertinents
- [ ] Chaque risque a une évaluation d'impact et de probabilité
- [ ] La matrice de risque est complète et documentée
- [ ] Les remédiations sont définies avec des priorités

### Indices

**Étapes de construction de la matrice :**

    | ID | Risque | Impact | Probabilité | Gestion du risque | Remédiation associée |
    |----|--------|--------|-------------|------------------|----------------------|
    | 1  |        |        |             |                  |                      |

  - **Impact**

      **Low**: A threat event could be expected to have almost no adverse effect on organizational operations, mission capabilities, assets, individuals, customers, or other organizations.

      **Medium**: A threat event could be expected to have a limited adverse effect, meaning: degradation of mission capability yet primary functions can still be performed; minor damage; minor financial loss; or range of effects is limited to some cyber resources but no critical resources.

      **High**: A threat event could be expected to have a severe or catastrophic adverse effect, meaning: severe degradation or loss of mission capability and one or more primary functions cannot be performed; major damage; major financial loss; or range of effects is extensive to most cyber resources and most critical resources.

      **Critical**: A threat event could be expected to have multiple severe or catastrophic adverse effects on organizational operations, assets, individuals, or other organizations. Range of effects is sweeping, involving almost all cyber resources.

  - **Probabilité**

      **Low**: A threat event is so unlikely that it can be assumed that its occurrence may not be experienced. A threat source is not motivated or has no capability, or controls are in place to prevent or significantly impede the vulnerability from being exploited.

      **Medium**: A threat event is unlikely, but there is a slight possibility that its occurrence may be experienced. A threat source lacks sufficient motivation or capability, or controls are in place to prevent or impede the vulnerability from being exploited.

      **High**: A threat event could be expected to have a severe or catastrophic adverse effect, meaning: severe degradation or loss of mission capability and one or more primary functions cannot be performed; major damage; major financial loss; or range of effects is extensive to most cyber resources and most critical resources.

      **Critical**: A threat event could be expected to have multiple severe or catastrophic adverse effects on organizational operations, assets, individuals, or other organizations. Range of effects is sweeping, involving almost all cyber resources.

  - **Gestion du risque** :

      **Acceptation**: Accepter le risque tel quel, sans prendre de mesures supplémentaires.

      **Mitigation**: Prendre des mesures pour réduire la probabilité ou l'impact du risque.

      **Transfert**: Transférer le risque à une autre partie, par exemple en sous-traitant.

      **Évitement**: Modifier les plans pour éliminer le risque ou son impact.

  - **Remédiation associée** : Faire le lien avec une remédiation dans la matrice de remédiation.

Documentez chaque remédiation dans un tableau.

    | Remédiation | Description | Priorité | Estimation en JH |
    |-------------|-------------|----------|------------------|
    |             |             |          |                  |

 - **Priorité:**

     P0 = Essentielles, à mettre en place dès le départ

     P1 = Critiques, à mettre en place avant le déploiement en production

     P2 = Majeures, à mettre en place dans les 3 premier mois du projet

     P3 = Importantes, à mettre en place dans les 6 premiers mois du projet

     P4 = Mineures, à mettre en place par la suite

## 6. (Optionnel) Déployer un WAF avec Safeline

### Pourquoi

Un Web Application Firewall (WAF) protège les applications web contre les attaques courantes comme l'injection SQL, XSS et autres vulnérabilités OWASP Top 10. Safeline est un WAF open-source qui peut être déployé sur Kubernetes.

### Comment

1. **Déployez Safeline WAF** sur votre cluster Kubernetes
2. **Configurez les règles** de protection pour votre application
3. **Intégrez le WAF** avec votre ingress controller
4. **Lancez un smoke test** contre le WAF pour valider la protection
5. **Analysez les logs** et ajustez les règles si nécessaire

Références :
- [Guide de déploiement Safeline sur Kubernetes](https://dev.to/sharon_42e16b8da44dabde6d/deploying-safeline-waf-on-kubernetes-a-beginner-friendly-guide-2dl3)
- [Script de test WAF](https://ridjex.medium.com/testing-your-firewall-in-60-seconds-a-lightweight-waf-testing-script-that-anyone-can-use-a7a725fefcb7)

### Vérifications

- [ ] Safeline WAF est déployé et opérationnel
- [ ] Le WAF intercepte le trafic vers vos applications
- [ ] Les tests de sécurité confirment la protection active
- [ ] Les logs du WAF sont accessibles et informatifs
- [ ] Les règles de sécurité sont adaptées à votre contexte

## 7. (Optionnel) Sécuriser votre cluster Kubernetes avec Boundary et Vault

### Pourquoi

La sécurisation de l'accès au cluster Kubernetes est cruciale. Boundary fournit un accès sécurisé basé sur l'identité, tandis que Vault gère les secrets de manière centralisée. Cette combinaison permet un contrôle d'accès granulaire et une gestion sécurisée des credentials.

### Comment

1. **Déployez Boundary** dans votre environnement
2. **Configurez Vault** pour la gestion des secrets
3. **Intégrez Boundary avec Kubernetes** pour autoriser l'accès au cluster
4. **Configurez les politiques d'accès** appropriées
5. **Testez l'accès sécurisé** au cluster minikube via Boundary et Vault

Référence : [Boundary Kubernetes Tutorial](https://developer.hashicorp.com/boundary/tutorials/kubernetes-connect/kubernetes-getting-started-config)

### Vérifications

- [ ] Boundary est déployé et fonctionnel
- [ ] Vault est configuré pour gérer les secrets Kubernetes
- [ ] L'accès au cluster minikube est contrôlé par Boundary
- [ ] Les politiques d'accès sont correctement définies
