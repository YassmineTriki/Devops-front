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

        stage('Package') {
            steps {
                script {
                    // Version sémantique + numéro de build
                    FRONTEND_VERSION = "1.0.0.${BUILD_NUMBER}" 
                    ARTIFACT_NAME = "kaddem-frontend-${FRONTEND_VERSION}.tar.gz"
                    
                    // Création de l'archive
                    sh """
                        tar -czvf ${ARTIFACT_NAME} -C dist/ .
                        ls -lh ${ARTIFACT_NAME}  # Vérification
                    """
                }
            }
        }
       stage('Deploy to Nexus') {
            steps {
                script {
                    // 1. Lecture directe du package.json
                    def pkg = readJSON file: 'package.json'
                    
                    // 2. Création de l'artefact en une seule commande
                    sh """
                        tar -czf ${pkg.name}-${pkg.version}.${BUILD_NUMBER}.tar.gz -C dist/${pkg.name}/ .
                    """
                    
                    // 3. Upload minimaliste avec gestion d'erreur intégrée
                    nexusArtifactUploader(
                        artifacts: [[
                                artifactId: pkg.name,
                                file: artifactFile,
                                type: 'tar.gz',
                                classifier: 'dist'
                            ]],
                            credentialsId: 'front-nexus',
                            groupId: "tn.esprit.${pkg.name}",
                            nexusUrl: 'http://localhost:8081',
                            nexusVersion: 'nexus3', // Ce paramètre est CRUCIAL
                            protocol: 'http',
                            repository: 'front-devops',
                            version: "${pkg.version}.${BUILD_NUMBER}"
                    )
                }
            }
        }
    }
}
