pipeline {
    agent any
    tools {
        git 'Default'
    }
    environment {
        DOCKER_IMAGE_NAME = 'cloudyong/banpoxiii-server'
        DOCKER_IMAGE_TAG = "${env.BUILD_NUMBER}"
        REMOTE_DIRECTORY = '/path/to/remote/directory' // 원격 서버의 작업 디렉토리
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                    credentialsId: 'github-ssh', 
                    url: 'git@github.com:beyond08-final-team/be08-4th-BanpoXiii-WajangChang-server.git'
            }
        }
        stage('Build') {
            steps {
                script() {

                    sh 'docker logout'
                    
                    // docker login
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                    }
                    sh 'ls -l'
                    sh 'chmod -R 777 src/main/resources'

                    // add application.yml
                    withCredentials([file(credentialsId: 'banpoxiii-server-properties', variable: 'APP_YML')]) {
                        sh 'cp $APP_YML src/main/resources/application.yml'
                    }

                    withEnv(["DOCKER_IMAGE_TAG=${DOCKER_IMAGE_TAG}"]) {
                        sh 'docker build --no-cache -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ./'
                        sh 'docker image inspect ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}'
                        sh 'docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}'
                    }

                    sh 'docker logout'

                }

            }
        }

        stage('Deploy to Ec2') {
            steps {
                script() {

                    sshPublisher(
                        failOnError: true,
                        publishers: [
                            sshPublisherDesc(
                                configName: 'ec2-banpoxiii-server',
                                verbose: true,
                                transfers: [
                                    sshTransfer(
                                        execCommand: """
                                            sudo docker pull ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                                            sudo docker container rm -f banpoxiii-server || true
                                            sudo docker run -d --name banpoxiii-server -p 30021:80 ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                                        """
                                    )
                                ]
                            )
                        ]
                    )
                    
                }
            }
        }
    }
    post {
        success {
            script() {

            withCredentials([string(credentialsId: 'discord-noti', variable: 'DISCORD')]) {
                echo "DISCORD: ${DISCORD}"
                discordSend description: """
                제목 : "서버 배포 테스트중 성공"
                결과 : ${currentBuild.result}
                실행 시간 : ${currentBuild.duration / 1000}s
                """,
                result: currentBuild.currentResult,
                title: "${env.JOB_NAME} : ${currentBuild.displayName} 성공", 
                webhookURL: "${DISCORD}"
            }
            }
        }

        failure {
            script() {

                withCredentials([string(credentialsId: 'discord-noti', variable: 'DISCORD')]) {
                    echo "DISCORD: ${DISCORD}"
                    discordSend description: """
                    제목 : "서버 배포 테스트중 실패"
                    결과 : ${currentBuild.result}
                    실행 시간 : ${currentBuild.duration / 1000}s
                    """,
                    result: currentBuild.currentResult,
                    title: "${env.JOB_NAME} : ${currentBuild.displayName} 실패", 
                    webhookURL: "${DISCORD}"
                }
            }
        }
    }
}