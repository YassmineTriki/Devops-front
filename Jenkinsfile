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
                    // 1. Vérifier que le dossier dist existe
                    sh 'ls -la dist/ || { echo "ERREUR: Dossier dist introuvable"; exit 1; }'
                    
                    // 2. Créer l'archive avec un nom clair
                    def artifactName = "kaddem-front-${BUILD_NUMBER}.tar.gz"
                    sh "tar -czf ${artifactName} -C dist/ ."
                    
                    // 3. Debug: Vérifier que le fichier existe
                    sh "ls -lh ${artifactName}"
                    
                    // 4. Upload vers Nexus avec authentification sécurisée
                    withCredentials([usernamePassword(
                        credentialsId: 'front-nexus',
                        usernameVariable: 'NEXUS_USER',
                        passwordVariable: 'NEXUS_PASS'
                    )]) {
                        sh '''
                            curl -v -u \${NEXUS_USER}:\${NEXUS_PASS} \
                                -X POST "${NEXUS_URL}/repository/${NEXUS_REPO}/" \
                                -H "Content-Type: application/gzip" \
                                --data-binary "@${artifactName}"
                        '''
                    }
                    
                    // 5. Nettoyage
                    sh "rm ${artifactName}"
                }
            }
        }
    }
}
