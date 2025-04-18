pipeline {
    agent any

    environment {
        MAVEN_HOME = tool name: "Maven 3.9.9"
        DOCKER_HUB_USER = "ramu7"
        IMAGE_NAME = "application"
        WAR_NAME = "maven-web-application"
    }

    stages {
        stage('✅ Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: '9c54f3a6-d28e-4f8f-97a3-c8e939dcc8ff',
                    url: 'https://github.com/ramu0709/pipeline4.git'
            }
        }

        stage('✅ Build WAR') {
            steps {
                sh '''
                    ${MAVEN_HOME}/bin/mvn clean package
                    ls -lh target/
                '''
            }
        }

        stage('✅ Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    script {
                        def imageTag = "${DOCKER_HUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}"

                        writeFile file: 'Dockerfile', text: """
                        FROM tomcat:9.0
                        COPY target/${WAR_NAME}.war /usr/local/tomcat/webapps/ROOT.war
                        """

                        sh """
                            echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                            docker build -t ${imageTag} .
                            docker push ${imageTag}
                        """
                    }
                }
            }
        }

        stage('✅ Run Docker Container') {
            steps {
                script {
                    def imageTag = "${DOCKER_HUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}"

                    sh """
                        docker stop ${IMAGE_NAME}-${BUILD_NUMBER} || true
                        docker rm ${IMAGE_NAME}-${BUILD_NUMBER} || true
                        docker run -d --name ${IMAGE_NAME}-${BUILD_NUMBER} -p 8082:8080 ${imageTag}
                    """

                    echo """
                    🌐 Your app is now accessible at:
                    👉 http://172.21.40.70:8082/
                    """
                }
            }
        }
    }

    post {
        always {
            echo "📦 Job completed: ${env.JOB_NAME} [Build #${env.BUILD_NUMBER}]"
        }
    }
}
