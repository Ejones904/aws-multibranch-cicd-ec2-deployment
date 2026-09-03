#!/usr/bin/env groovy

pipeline {   
    agent any
    stages {
        stage("test") {
            steps {
                script {
                    echo "Testing the application..."

                }
            }
        }
        stage("build") {
            steps {
                script {
                    echo "Building the application..."
                }
            }
        }

        stage("deploy") {
            steps {
                script {
                def DockerCmd = 'docker run -p 3000:808-d ejones904/demo-app:1.2.6-45'
                   sshagent(credentials: ['EC2-server-key'], executable: '') {
                    sh "ssh -o StrictHostKeyChecking=no ec2-user@18.191.55.151
                    ${DockerCmd}"
                   }
                }
            }
        }               
    }
} 
