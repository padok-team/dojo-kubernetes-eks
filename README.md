
# Dojo Kubernetes (EKS)

Ce repository contient les ressources et la documentation pour déployer un cluster Kubernetes et travailler dessus dans le cadre du dojo.

Ordre recommandé :

1. Démarrer dans `Docker/` — préparer les images et comprendre l'environnement local.
2. Déployer EKS depuis `Terraform/` — déployer sur AWS (préféré).
    :bulb: Alternative si vous ne pouvez pas déployer sur AWS : déployer un cluster local avec `minikube`.
3. Travailler avec `Kubernetes/` — appliquer les manifests, déployer l'application du dojo et pratiquer.

## 1) Docker/

But : préparer et tester localement les images et composants qui seront déployés sur Kubernetes.

Ouvrir le dossier [`Docker/`](Docker/) et lire le `README.md` qui contient les détails des images et du build.

## 2) Terraform/ — déployer EKS (préféré)

But : déployer un cluster EKS en production ou en environnement cloud pour le dojo.

Ouvrir le dossier [`Terraform/`](Terraform/) et lire le `README.md` qui contient les détails du déploiement d'EKS.

Prérequis :

- Compte AWS avec permissions (IAM) suffisantes pour créer VPC, EKS, IAM, et ressources associées.
- AWS CLI configuré (`aws configure`) ou variables d'environnement AWS définies.
- Terraform installé (version compatible avec les fichiers sous `Terraform/`).

Notes et conseils :

- Les variables AWS (region, profile, etc.) peuvent être passées via `-var` ou un fichier `terraform.tfvars`.
- Vérifiez les quotas et coûts avant de créer des ressources (notamment les nœuds EC2).

### Alternative : Minikube (si vous ne pouvez pas déployer sur AWS)

Si vous n'avez pas accès à AWS, ou voulez travailler localement, utilisez [`minikube`](https://minikube.sigs.k8s.io/docs/).

Prérequis : Virtualisation (Hypervisor) ou driver Docker, `minikube` installé, `kubectl` installé.

Commandes de base :

```bash
# Démarrer minikube avec driver docker
minikube start --driver=docker --memory=4096 --cpus=2

# Vérifier
kubectl get nodes

# Utiliser minikube image load (selon version)
minikube image load dojo-app:local
```

Stop / suppression :

```bash
minikube stop
minikube delete
```

## 3) Kubernetes/

But : déployer l'application du dojo, pratiquer les opérations Kubernetes (manifests, services, ingress, monitoring).

Ouvrir le dossier [`Kubernetes/`](Kubernetes/) et lire le `README.md`.
