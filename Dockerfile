# Étape 1 : Utiliser une image Nginx officielle
FROM nginx:alpine

# Étape 2 : Supprimer les fichiers HTML par défaut
RUN rm -rf /usr/share/nginx/html/*

# Étape 3 : Copier ton build Angular/Vite/React
COPY dist/ /usr/share/nginx/html/

# Étape 4 : Exposer le port (optionnel, pour information)
EXPOSE 80

# Étape 5 : Le conteneur démarre avec Nginx
CMD ["nginx", "-g", "daemon off;"]
