def isHarnessChange(harnesses) {
    def harnessLabels = harnesses.collect { "harness-${it}".toString() }
    harnessLabels.add('harness-all')

    return !env.CHANGE_ID || pullRequest.labels.size() == 0 || harnessLabels.any { pullRequest.labels.contains(it) }
}
def failureMessages = []

pipeline {
    agent { label 'linux-amd64' }
    environment {
        COMPOSE_DOCKER_CLI_BUILD = 1
        DOCKER_BUILDKIT = 1
        MY127WS_KEY = credentials('base-my127ws-key-20190523')
        SLACK_NOTIFICATION_CHANNEL = credentials('slack-notification-channel')
        SLACK_TOKEN_CREDENTIAL_ID = credentials('slack-token-credential-id')
    }
    options {
        buildDiscarder(logRotator(daysToKeepStr: '30'))
        parallelsAlwaysFailFast()
    }
    triggers { cron(env.BRANCH_NAME ==~ /^\d+\.\d+\.x$/ ? 'H H(2-6) * * 1' : '') }
    stages {
        stage('Quality Checks') {
            steps {
                sh './build'
                sh './quality'
                milestone(10)
            }
            post { failure { script { failureMessages << 'Global quality checks' } } }
        }
        stage('Build and Test') {
            parallel {
                stage('1. NextJS, Alokai') {
                    agent {
                        docker {
                            // Reuse the same agent selected at the top of the file
                            reuseNode true
                            label 'linux-amd64'
                            alwaysPull true
                            image 'quay.io/inviqa_images/workspace:latest'
                            args '--group-add docker --entrypoint "" --volume /var/run/docker.sock:/var/run/docker.sock --volume "$HOME/.my127:/root/.my127"'
                        }
                    }
                    when {
                        beforeAgent true
                        expression { return isHarnessChange(['nextjs']) }
                    }
                    stages {
                        stage('Prepare') {
                            steps {
                                sh './delete_running_containers.sh'
                            }
                            post { failure { script { failureMessages << 'NextJS prepare' } } }
                        }
                        stage('Quality Tests') {
                            environment {
                                TEARDOWN_ENVIRONMENT = "no"
                                TEST_MODE = "quality"
                            }
                            steps {
                                sh './test nextjs dynamic mutagen'
                                sh './test alokai dynamic mutagen'

                                sh './test nextjs static'
                                sh './test alokai static'

                                sh './test nextjs dynamic'
                                sh './test alokai dynamic'
                            }
                            post { failure { script { failureMessages << 'NextJS and Alokai quality checks' } } }
                        }
                        stage('Acceptance Tests') {
                            environment {
                                REUSE_EXISTING_WORKSPACE = "yes"
                                TEST_MODE = "acceptance"
                            }
                            stages {
                                stage('NextJS Dynamic Mutagen') {
                                    when { expression { return isHarnessChange(['nextjs']) } }
                                    steps { sh './test nextjs dynamic mutagen' }
                                    post { failure { script { failureMessages << 'NextJS mutagen acceptance' } } }
                                }

                                stage('NextJS Static') {
                                    when { expression { return isHarnessChange(['nextjs']) } }
                                    steps { sh './test nextjs static' }
                                    post { failure { script { failureMessages << 'NextJS static acceptance' } } }
                                }

                                stage('NextJS Dynamic') {
                                    when { expression { return isHarnessChange(['nextjs']) } }
                                    steps { sh './test nextjs dynamic' }
                                    post { failure { script { failureMessages << 'NextJS dynamic acceptance' } } }
                                }
                            }
                        }
                    }
                    // No post step, as it will be taken care of in the global cleanup at the bottom
                }
            }
        }
        stage('Success') {
            steps {
                sh 'echo "Success"'
                milestone(100)
            }
        }
    }
    post {
        failure {
            script {
                def message = "${env.JOB_NAME} #${env.BUILD_NUMBER} - Failure after ${currentBuild.durationString.minus(' and counting')} (<${env.RUN_DISPLAY_URL}|View Build>)"
                def fallbackMessages = [ message ]
                def fields = []

                def shortCommitHash = "${GIT_COMMIT}".substring(0, 7)
                def commitLink = "<https://github.com/inviqa/harness-base-php/commit/${GIT_COMMIT}|${shortCommitHash}>"
                def gitMessage = "Branch <https://github.com/inviqa/harness-base-php/tree/${GIT_BRANCH}|${GIT_BRANCH}> @ ${commitLink}"

                if (env.CHANGE_URL) {
                    // Jenkins builds pull requests by merging the pull request branch into the pull request's target branch,
                    // so we build on commits that do not technically exist and can't link to them.
                    gitMessage = "<${env.CHANGE_URL}|Pull Request #${env.CHANGE_ID}> ${env.CHANGE_TITLE} - merged into target branch <https://github.com/inviqa/harness-base-php/tree/${CHANGE_TARGET}|${CHANGE_TARGET}>"
                }
                fields << [
                    title: 'Source',
                    value: gitMessage,
                    short: false
                ]
                fallbackMessages << gitMessage

                def failureMessage = failureMessages.join("\n")
                if (failureMessage) {
                    fields << [
                        title: 'Reason(s)',
                        value: failureMessage,
                        short: false
                    ]
                    fallbackMessages << failureMessage
                }
                def attachments = [
                    [
                        text: message,
                        fallback: fallbackMessages.join("\n"),
                        color: 'danger',
                        fields: fields
                    ]
                ]

                slackSend (channel: env.SLACK_NOTIFICATION_CHANNEL, color: 'danger', attachments: attachments, tokenCredentialId: env.SLACK_TOKEN_CREDENTIAL_ID)
            }
        }
        always {
            sh './delete_running_containers.sh'
            cleanWs()
        }
    }
}
