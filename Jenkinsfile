pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
    # 1) Jenkins inbound agent
    - name: jnlp
      image: jenkins/inbound-agent:latest
      args: ['\\$(JENKINS_SECRET)','\\$(JENKINS_NAME)']
      volumeMounts:
        - name: workspace-volume
          mountPath: /home/jenkins/agent

    # 2) Docker-in-Docker
    - name: docker
      image: docker:24.0.5-dind
      securityContext:
        privileged: true
      volumeMounts:
        - name: dockersock
          mountPath: /var/run/docker.sock

  volumes:
    # Workspace
    - name: workspace-volume
      emptyDir: {}

    # Docker socket
    - name: dockersock
      hostPath:
        path: /var/run/docker.sock
        type: Socket
"""
    }
  }

  environment {
    REGISTRY   = "docker.io/yunusemretosun"
    IMAGE_NAME = "example-app"
    CHART_PATH = "helm-charts/application"
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
        container('docker') {
          sh """
            docker build \
              -t \$REGISTRY/\$IMAGE_NAME:\${BUILD_NUMBER} \
              applications/example-app
          """
        }
      }
    }

    stage('Push to Registry') {
      steps {
        container('docker') {
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
    }

    stage('Deploy with Helm') {
      steps {
        container('docker') {
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

