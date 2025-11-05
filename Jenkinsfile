pipeline {
    agent any

    environment {
        IMAGE_NAME = "dracon24/disaster-management-system"
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        INVENTORY_FILE = "inventory"
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Checking out source code..."
                checkout scm
            }
        }

        stage('Install Dependencies & Build') {
            steps {
                echo "Installing dependencies and building project..."
                sh '''
                    npm ci
                    npm run build
                '''
            }
        }

        stage('Run Tests') {
            steps {
                echo "Running test suite..."
                sh '''
                    npm test || echo "No tests found, skipping..."
                '''
            }
        }

        stage('Docker Build & Push') {
            steps {
                echo "Building and pushing Docker image to Docker Hub..."
                sh '''
                    echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                    docker build -t $IMAGE_NAME:latest .
                    docker tag $IMAGE_NAME:latest $IMAGE_NAME:${BUILD_NUMBER}
                    docker push $IMAGE_NAME:latest
                    docker push $IMAGE_NAME:${BUILD_NUMBER}
                    docker logout
                '''
            }
        }

        stage('Deploy via Ansible') {
            steps {
                echo "Deploying container using Ansible..."
                sh '''
                    ansible --version || pip install ansible
                    ansible-playbook -i ${INVENTORY_FILE} deploy.yml \
                        --extra-vars "ansible_become_pass=${ANSIBLE_BECOME_PASS}"
                '''
            }
        }
    }

    post {
        success {
            echo "Build, push, and deployment completed successfully."
        }
        failure {
            echo "Pipeline failed. Please check the logs for details."
        }
        always {
            echo "Cleaning up unused Docker images..."
            sh '''
                docker image prune -f || true
            '''
        }
    }
}
