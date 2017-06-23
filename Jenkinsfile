pipeline {
  agent {
    docker {
      image 'ruby:latest'
    }
    
  }
  stages {
    stage('1') {
      steps {
        parallel(
          "bundle": {
            sh '''ls -la
ruby --version

bundle install'''
            
          },
          "222": {
            sh 'echo 2'
            
          },
          "1111": {
            build '1'
            waitUntil()
            
          }
        )
      }
    }
    stage('2323') {
      steps {
        sh 'echo 3'
      }
    }
  }
}