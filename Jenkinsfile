pipeline {
  agent any

  environment {
    REGISTRY    = "docker.io/yunusemretosun"         // Docker Registry adresin (örn docker.io/kullanici)
    IMAGE_NAME  = "example-app"
    CHART_PATH  = "helm-charts/application"
  }

  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/yunusemretosun/devops-challenge.git',
            branch: 'main',
            credentialsId: 'git-creds'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh """
          docker build \
            -t \$REGISTRY/\$IMAGE_NAME:\${BUILD_NUMBER} \
            applications/example-app
        """
      }
    }

    stage('Push to Registry') {
      steps {
        withCredentials([usernamePassword(
            credentialsId: 'docker-creds',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
        )]) {
          sh """
            echo \$DOCKER_PASS | docker login \$REGISTRY -u \$DOCKER_USER --password-stdin
            docker push \$REGISTRY/\$IMAGE_NAME:\${BUILD_NUMBER}
          """
        }
      }
    }

    stage('Deploy with Helm') {
      steps {
        sh """
          helm upgrade --install example-app \$CHART_PATH \
            --namespace default \
            --set image.repository=\$REGISTRY/\$IMAGE_NAME \
            --set image.tag=\${BUILD_NUMBER} \
            --wait --timeout 2m
        """
      }
    }
  }

  post {
    success {
      echo "✅ Deploy başarılı! http://\$NODE_IP:\$NODE_PORT adresinden test edebilirsiniz."
    }
    failure {
      echo "❌ Bir hata oluştu, console output’a bakın."
    }
  }
}

