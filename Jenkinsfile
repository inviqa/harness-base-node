pipeline {
    agent none
    environment {
        MY127WS_KEY = credentials('base-my127ws-key-20190523')
    }
    options {
        buildDiscarder(logRotator(daysToKeepStr: '30'))
    }
    triggers { cron(env.BRANCH_NAME ==~ /^\d+\.\d+\.x$/ ? 'H H(0-6) * * *' : '') }
    stages {
        stage('BuildAndTest') {
            matrix {
                axes {
                    axis {
                        name 'FRAMEWORK'
                        values 'node', 'spa', 'viper'
                    }
                }
                stages {
                    stage("Test ${FRAMEWORK} (mode=static)") {
                        agent { label "my127ws" }
                        steps { sh './build && ./test $FRAMEWORK static' }
                        post {
                            always {
                                sh 'ws destroy || true'
                                cleanWs()
                            }
                        }
                    }
                    stage("Test ${FRAMEWORK} (mode=dynamic)") {
                        agent { label "my127ws" }
                        steps { sh './build && ./test $FRAMEWORK dynamic' }
                        post {
                            always {
                                sh 'ws destroy || true'
                                cleanWs()
                            }
                        }
                    }
                    stage("Test ${FRAMEWORK} (mode=dynamic, sync=mutagen)") {
                        agent { label "my127ws" }
                        steps { sh './build && ./test $FRAMEWORK dynamic mutagen' }
                        post {
                            always {
                                sh 'ws destroy || true'
                                cleanWs()
                            }
                        }
                    }
                }
            }
        }
    }
}
