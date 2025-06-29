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
        stage('SonarQube Analysis') {
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
        }

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
      
        stage('Upload Front to Nexus') {
            steps {
                script {
                def nexusRawRepoUrl = 'http://localhost:8081/repository/front-devops/'
                def distDir = 'dist/' // ou le chemin vers ton build front
                def credentialsId = 'front-nexus' // ID Jenkins des credentials Nexus

                withCredentials([usernamePassword(credentialsId: credentialsId, passwordVariable: 'NEXUS_PASS', usernameVariable: 'NEXUS_USER')]) {
                    sh """
                    find ${distDir} -type f | while read file; do
                        relativePath=\$(realpath --relative-to=${distDir} "\$file")
                        curl -u "$NEXUS_USER:$NEXUS_PASS" --upload-file "\$file" "$nexusRawRepoUrl\$relativePath"
                    done
                    """
                }
                }
            }
        }
        stage('Docker Build & Push') {
            steps {
                script {
                def imageName = "yasmine251/front-devops:${env.BUILD_ID}"

                docker.build(imageName)

                docker.withRegistry('https://index.docker.io/v1/', 'cred_docker') {
                    docker.image(imageName).push()
                }
                }
            }
        }


    }
}
