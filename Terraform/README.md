# Deployer EKS avec Terragrunt

## Prerequis

- Avoir accès à un compte AWS avec les droits nécessaires pour créer un cluster EKS.
- Avoir installé [Terraform](https://www.terraform.io/downloads.html)

## À faire

Vous allez déployer un EKS dans votre compte AWS en utilisant Terragrunt.

> ! Déployez **EKS en version 1.33 ou antérieure**. Nous aurons plus tard dans la formation l'application d'une procédure d'upgrade.

Utiliser le code terragrunt contenu dans les layers `organization`, `network` et `eks`.

Commencez avec la documentation [ici](./docs/005-organization_bootstrap.md).
