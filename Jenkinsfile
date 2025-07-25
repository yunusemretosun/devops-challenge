pipeline {
  agent {
    kubernetes {
      yaml '''
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins-deployer
  containers:
    - name: jnlp
      image: jenkins/inbound-agent:latest
      args: ['$(JENKINS_SECRET)', '$(JENKINS_NAME)']
      volumeMounts:
        - name: workspace-volume
          mountPath: /home/jenkins/agent

    - name: docker
      image: docker:24.0.5-dind
      securityContext:
        privileged: true

    - name: helm
      image: alpine/helm:3.14.4
      command:
        - cat
      tty: true
  volumes:
    - name: workspace-volume
      emptyDir: {}
'''
    }
  }

  environment {
    REGISTRY    = "yunusemretosun"
    IMAGE_NAME  = "example-app"
    CHART_ROOT  = "helm-charts"
    CHART_NAME  = "application"
    CHART_PATH  = "${CHART_ROOT}/${CHART_NAME}"
    NAMESPACE   = "default"
    RELEASE     = "example-app"
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
              -t $REGISTRY/$IMAGE_NAME:${BUILD_NUMBER} \
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
              echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
              docker push \$REGISTRY/\$IMAGE_NAME:\${BUILD_NUMBER}
            """
          }
        }
      }
    }

    stage('Deploy with Helm') {
      steps {
        container('helm') {
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
}

