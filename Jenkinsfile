pipeline {
    agent any
    tools {
        nodejs 'Node-24' // Configurez cette tool dans Jenkins
    }
    environment {
            SONAR_TOKEN = credentials('sonar-token-front') // Créez cette credential dans Jenkins

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

        /*stage('Build') {
            steps {
                sh 'npm install'
                sh 'npm run build -- --configuration=production'
            }
        }*/

        // Étape 4: Analyse SonarQube
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh 'npx sonar-scanner ' +
                    '-Dsonar.projectKey=devopsfront ' +
                    /* groovylint-disable-next-line GStringExpressionWithinString */
                    '-Dsonar.login=${SONAR_TOKEN} ' +
                    '-Dsonar.sources=src ' +
                    '-Dsonar.javascript.lcov.reportPaths=coverage/lcov.info'
                }
            }
        }
    }
}
