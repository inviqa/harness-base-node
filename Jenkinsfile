pipeline {
    agent none
    environment {
        COMPOSE_DOCKER_CLI_BUILD = 1
        DOCKER_BUILDKIT = 1
        MY127WS_KEY = credentials('base-my127ws-key-20190523')
    }
    options {
        buildDiscarder(logRotator(daysToKeepStr: '30'))
        parallelsAlwaysFailFast()
    }
    triggers { cron(env.BRANCH_NAME ==~ /^\d+\.\d+\.x$/ ? 'H H(0-6) * * *' : '') }
    stages {
        stage('Build and Test') {
            parallel {
                stage('1. Node, Node-Spa, Viper') {
                    agent {
                        docker {
                            label 'my127ws'
                            alwaysPull true
                            image 'quay.io/inviqa_images/workspace:latest'
                            args '--entrypoint "" --volume /var/run/docker.sock:/var/run/docker.sock --volume "$HOME/.my127:/root/.my127"'
                        }
                    }
                    stages {
                        stage('Prepare') {
                            steps {
                                sh './delete_running_containers.sh'
                                sh './build'
                            }
                        }
                        stage('Node Static') {
                            steps { sh './test node static' }
                        }
                        stage('Node-Spa Static') {
                            steps { sh './test node-spa static' }
                        }
                        stage('Viper Static') {
                            steps { sh './test viper static' }
                        }
                        stage('Node Dynamic') {
                            steps { sh './test node dynamic' }
                        }
                        stage('Node-Spa Dynamic') {
                            steps { sh './test node-spa dynamic' }
                        }
                        stage('Viper Dynamic') {
                            steps { sh './test viper dynamic' }
                        }
                        stage('Node Dynamic Mutagen') {
                            steps { sh './test node dynamic mutagen' }
                        }
                        stage('Node-Spa Dynamic Mutagen') {
                            steps { sh './test node-spa dynamic mutagen' }
                        }
                        stage('Viper Dynamic Mutagen') {
                            steps { sh './test viper dynamic mutagen' }
                        }
                    }
                    post {
                        always {
                            sh '(cd tmp-test && ws destroy) || true'
                            sh 'ws destroy || true'
                            sh './delete_running_containers.sh'
                            cleanWs()
                        }
                    }
                }
            }
        }
    }
}
