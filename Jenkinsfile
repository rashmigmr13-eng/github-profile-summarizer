pipeline {
    agent any

    environment {
        IMAGE_NAME = "madhusudhanap05/github-profile-summarizer"
        IMAGE_TAG = "v${env.BUILD_NUMBER}"
        MAX_REPOS = "50"
    }

    stages {

        // 1️⃣ Checkout code from GitHub
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // 2️⃣ Build Node.js frontend inside Docker (avoids npm permission issues)
        stage('Build (Node)') {
            steps {
                sh 'docker run --rm -u $(id -u):$(id -g) -v $PWD:/app -w /app node:20-alpine sh -c "rm -rf node_modules && npm install --cache /tmp/.npm && npm run build"'
            }
        }

        // 3️⃣ Build Docker image with GitHub token and max repos
        stage('Docker Build') {
            steps {
                withCredentials([string(credentialsId: 'github-token-secret', variable: 'GITHUB_TOKEN_VALUE')]) {
                    sh """
                        docker build \
                        --build-arg VITE_GITHUB_TOKEN=${GITHUB_TOKEN_VALUE} \
                        --build-arg VITE_MAX_REPOS=${MAX_REPOS} \
                        -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    """
                }
            }
        }

        // 4️⃣ Docker login and push to Docker Hub
        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DockerHub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
                sh """
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                    docker push ${IMAGE_NAME}:latest
                """
            }
        }

        // 5️⃣ Deploy Docker container (port 8081)
        stage('Deploy Image') {
            steps {
                sh """
                    # Stop previous container if running
                    docker rm -f github-profile-summarizer || true
                    # Run new container
                    docker run -d --name github-profile-summarizer -p 8081:80 ${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }
    }

    post {
        always {
            echo "✅ Docker image pushed and deployed: ${IMAGE_NAME}:${IMAGE_TAG}"
        }
    }
}
