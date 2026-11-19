# Planif'Live

L'agenda partagé des créateurs TikTok : lives, battles, collabs, Q&A, défis et meetups IRL.
Chacun peut publier un événement, s'inscrire avec son @pseudo, copier une annonce pour sa bio
et ajouter l'événement à Google Agenda. Aucun compte n'est demandé aux visiteurs.

Site en ligne : https://menacebks.github.io/planif-live/

- `index.html` : le site (une seule page, sans étape de build)
- `config.js` : la configuration publique de ton projet Firebase
- `firestore.rules` : les règles de sécurité de la base
- `.github/workflows/pages.yml` : met le site en ligne à chaque envoi sur `main`

Tant que `config.js` n'est pas rempli, le site tourne en **mode démo** : les événements restent sur l'appareil.

## Configurer Firebase (gratuit, avec ton compte Google)

1. Va sur https://console.firebase.google.com et clique sur **Créer un projet**.
   Nomme-le `planif-live`. Tu peux désactiver Google Analytics.
2. **Créer > Authentication > Commencer**, onglet **Mode de connexion** : active **Anonyme** et enregistre.
3. **Créer > Firestore Database > Créer une base de données** : choisis l'emplacement `eur3 (europe)`,
   puis **Démarrer en mode production**.
4. Onglet **Règles** de Firestore : remplace tout par le contenu de `firestore.rules` puis clique sur **Publier**.
5. Roue dentée **Paramètres du projet > Général**, en bas : clique sur l'icône **</>** (Web),
   nomme l'appli `planif-live` (sans cocher Hosting), puis copie l'objet `firebaseConfig` dans `config.js`.
6. **Authentication > Paramètres > Domaines autorisés** : ajoute `menacebks.github.io`.

## Tester en local

```bash
python3 -m http.server 8000
```

Puis ouvre http://localhost:8000.

## Sécurité et modération

- Tout le monde peut lire l'agenda. Chacun ne peut supprimer que ses propres événements et inscriptions.
- Les champs sont vérifiés côté serveur (longueurs, types d'événement, dates).
- La limite de places est vérifiée dans la page, pas par le serveur : un visiteur malin pourrait la dépasser.
- Pour retirer un événement abusif : **Firestore Database > Données > events**, supprime le document.
- Contre les robots, tu peux activer **App Check** dans la console Firebase.
