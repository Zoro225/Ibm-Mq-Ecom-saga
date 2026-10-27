
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        DOCKERHUB_USER = 'aj12321'
        IMAGE_TAG = "build-${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Maven Services') {
            steps {
                sh '''
                    set -eu

                    for service in \
                        order-producer-service \
                        order-inventory-service \
                        order-payment-service \
                        order-notification-service
                    do
                        echo "Building $service"
                        cd "debezium/$service"
                        mvn -B clean package
                        cd ../..
                    done
                '''
            }
        }

        stage('Build Docker Images') {
            steps {
                sh '''
                    set -eu

                    for service in \
                        order-producer-service \
                        order-inventory-service \
                        order-payment-service \
                        order-notification-service
                    do
                        docker build \
                            -t "$DOCKERHUB_USER/$service:$IMAGE_TAG" \
                            "debezium/$service"
                    done
                '''
            }
        }

        stage('Push Images to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DH_USER',
                        passwordVariable: 'DH_TOKEN'
                    )
                ]) {
                    sh '''
                        set -eu
                        set +x
                        echo "$DH_TOKEN" | docker login \
                            --username "$DH_USER" \
                            --password-stdin

                        for service in \
                            order-producer-service \
                            order-inventory-service \
                            order-payment-service \
                            order-notification-service
                        do
                            docker push \
                                "$DOCKERHUB_USER/$service:$IMAGE_TAG"
                        done

                        docker logout
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'All four services built and pushed successfully.'
        }

        failure {
            echo 'Pipeline failed. Check the stage logs.'
        }

        always {
            sh 'docker logout >/dev/null 2>&1 || true'
        }
    }
}

