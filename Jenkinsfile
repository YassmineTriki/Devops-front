pipeline {
    agent any
    tools {
        nodejs 'Node-24' // Configurez cette tool dans Jenkins
    }
    environment {
        SONAR_TOKEN = credentials('sonar-token-front') // Créez cette credential dans Jenkins
        NEXUS_URL = 'http://localhost:8081/'
        NEXUS_REPO = 'front-devops'
        NEXUS_CREDS = credentials('front-nexus') // ID des credentials dans Jenkins
    
        IMAGE_NAME = 'yasmine251/kaddemback'
        IMAGE_TAG = 'latest'
        DOCKER_REGISTRY = 'docker.io' // exemple: 'dockerhub' ou vide si pas de push
        DOCKER_HUB_CREDENTALS = credentials('cred_docker')
    }

    stages {
        stage('git') {
            steps {
                git branch: 'master', url: 'https://github.com/YassmineTriki/Devops-front'
            }
        }

        stage('Clean') {
            steps {
                sh 'rm -rf dist/'
            }
        }

        stage('Build') {
            steps {
                sh 'npm install'
                sh 'npm run build -- --configuration=production'
                sh 'ls -al' // Vérifiez le contenu du répertoire
            }
        }

        // Étape 4: Analyse SonarQube
        /*stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh 'npx sonar-scanner ' +
                    '-Dsonar.projectKey=devopsfront ' +
                    // groovylint-disable-next-line GStringExpressionWithinString 
                    '-Dsonar.login=${SONAR_TOKEN} ' +
                    '-Dsonar.sources=src ' +
                    '-Dsonar.javascript.lcov.reportPaths=coverage/lcov.info'
                }
            }
        }*/

       stage('Package and Push to Nexus') {
    steps {
        script {
            // Vérifier que le dossier dist existe
            sh 'test -d dist/ || (echo "ERROR: dist directory not found" && exit 1)'
            
            // Créer l'archive avec le numéro de build
            sh 'tar -czf kaddem-front-${BUILD_NUMBER}.tar.gz -C dist/ .'
            
            // Envoyer à Nexus de manière sécurisée
            withCredentials([usernamePassword(credentialsId: 'front-nexus', passwordVariable: 'NEXUS_PASS', usernameVariable: 'NEXUS_USER')]) {
                sh '''
                    curl -u "$NEXUS_USER:$NEXUS_PASS" \
                         -X POST "${NEXUS_URL}/repository/${NEXUS_REPO}/" \
                         -H "Content-Type: application/gzip" \
                         --data-binary "@kaddem-front-${BUILD_NUMBER}.tar.gz"
                '''
            }
            
            // Nettoyage
            sh 'rm kaddem-front-${BUILD_NUMBER}.tar.gz'
        }
    }
}
    }
}
