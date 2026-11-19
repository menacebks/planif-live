# Planif'Live

L'agenda partagé des créateurs TikTok : lives, battles, collabs, Q&A, défis et meetups IRL.
Chacun peut publier un événement, s'inscrire avec son @pseudo, copier une annonce pour sa bio
et ajouter l'événement à Google Agenda. Aucun compte n'est demandé aux visiteurs.

- `index.html` : le site (une seule page, sans étape de build)
- `config.js` : l'adresse et la clé publique de ton projet Supabase
- `supabase/schema.sql` : les tables, les règles de sécurité et les limites anti-abus

Tant que `config.js` n'est pas rempli, le site tourne en **mode démo** : les événements restent sur l'appareil.

## 1. Créer la base Supabase (gratuit)

1. Crée un compte sur https://supabase.com puis un nouveau projet.
2. **SQL Editor > New query** : colle le contenu de `supabase/schema.sql` et clique sur **Run**.
3. **Authentication > Sign In / Providers** : active **Allow anonymous sign-ins**.
   C'est ce qui permet aux visiteurs de publier sans créer de compte, tout en ne pouvant supprimer que leurs propres événements.
4. **Project Settings > API** : copie la **Project URL** et la clé **anon public** dans `config.js`.

## 2. Mettre le site en ligne avec GitHub Pages (gratuit)

1. Crée un dépôt sur GitHub et envoie-y ces fichiers.
2. Dans le dépôt : **Settings > Pages > Source : Deploy from a branch**, branche `main`, dossier `/ (root)`.
3. Après une minute, le site est en ligne à `https://<ton-compte>.github.io/<nom-du-depot>/`.

Netlify fonctionne aussi : glisse le dossier sur https://app.netlify.com/drop.

## Tester en local

```bash
python3 -m http.server 8000
```

Puis ouvre http://localhost:8000.

## Sécurité et modération

- Tout le monde peut lire l'agenda. Chacun ne peut supprimer que ses propres événements et inscriptions.
- 10 événements maximum par personne et par jour, et une inscription est refusée quand l'événement est complet.
- Pour retirer un événement abusif : **Supabase > Table Editor > events**, supprime la ligne.
- Pour limiter les robots, tu peux activer un captcha dans **Authentication > Attack Protection**
  (il faudra alors ajouter le widget captcha à la page).
