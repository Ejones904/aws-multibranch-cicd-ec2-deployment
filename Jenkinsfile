#!/usr/bin/env groovy

library identifier: 'jenkins-shared-library@main', retriever: modernSCM(
    [$class: 'GitSCMSource',
     remote: 'https://github.com/Ejones904/jenkins-shared-library.git',
     credentialsId: 'github-credentials'
    ]
)

pipeline {
    agent any

    tools {
        maven 'Maven'
    }

    stages {

        stage('increment version') {
            steps {
                script {
                    echo 'Incrementing application version...'

                    sh '''
                        mvn build-helper:parse-version versions:set \
                        -DnewVersion=${parsedVersion.majorVersion}.${parsedVersion.minorVersion}.${parsedVersion.nextIncrementalVersion} \
                        versions:commit
                    '''

                    def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
                    def version = matcher[0][1]

                    env.IMAGE_NAME = "ejones904/demo-app:${version}-${BUILD_NUMBER}"

                    echo "Docker image version: ${env.IMAGE_NAME}"
                }
            }
        }

        stage('build app') {
            steps {
                echo 'Building application JAR...'
                buildJar()
            }
        }

        stage('build image') {
            steps {
                script {
                    echo 'Building Docker image...'

                    buildImage(env.IMAGE_NAME)
                    dockerLogin()
                    dockerPush(env.IMAGE_NAME)
                }
            }
        }

        stage('deploy') {
            steps {
                script {
                    echo 'Deploying Docker image to AWS EC2...'

                    def shellCmd = "bash /home/ec2-user/server-cmds.sh ${env.IMAGE_NAME}"
                    def ec2Instance = "ec2-user@3.16.99.36"

                    sshagent(credentials: ['EC2-server-key']) {

                        sh """
                            scp -o StrictHostKeyChecking=no \
                            server-cmds.sh \
                            ${ec2Instance}:/home/ec2-user/server-cmds.sh
                        """

                        sh """
                            scp -o StrictHostKeyChecking=no \
                            docker-compose.yaml \
                            ${ec2Instance}:/home/ec2-user/docker-compose.yaml
                        """

                        sh """
                            ssh -o StrictHostKeyChecking=no \
                            ${ec2Instance} \
                            '${shellCmd}'
                        """
                    }
                }
            }
        }

        stage('commit version update') {
            steps {
                script {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'github-credentials',
                            usernameVariable: 'GITHUB_USER',
                            passwordVariable: 'GITHUB_TOKEN'
                        )
                    ]) {

                        sh '''
                            git config user.name "Jenkins"
                            git config user.email "jenkins@local"

                            git add pom.xml
                            git commit -m "ci: version bump [skip ci]" || echo "No version change to commit"

                            git remote set-url origin https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/Ejones904/aws-multibranch-cicd-ec2-deployment.git

                            git push origin HEAD:${BRANCH_NAME}
                        '''
                    }
                }
            }
        }
    }
}
