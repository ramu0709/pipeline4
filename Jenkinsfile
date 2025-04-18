pipeline {
    agent any

    environment {
        MAVEN_HOME = tool name: "Maven 3.9.9"
        DOCKER_HUB_USER = "ramu7"
        IMAGE_NAME = "application"
        WAR_NAME = "maven-web-application"
        WAR_FILE = "target/${WAR_NAME}.war"
        TOMCAT_URL = "http://172.21.40.70:8082/manager/text/deploy?path=/&update=true"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '2'))
    }

    stages {
        stage('✅ Checkout Code') {
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

        stage('🚀 Deploy to Tomcat (Running Server)') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'Tomcat-Cred', usernameVariable: 'TOMCAT_USER', passwordVariable: 'TOMCAT_PASS')]) {
                    sh '''
                        echo "➡️ Deploying to Tomcat at $TOMCAT_URL"
                        curl -v --upload-file $WAR_FILE "$TOMCAT_URL" \
                          --user "$TOMCAT_USER:$TOMCAT_PASS"
                    '''
                }
            }
        }

        stage('🐳 Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    script {
                        def imageTag = "${DOCKER_HUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}"
                        sh """
                            echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                            docker build -t ${imageTag} .
                            docker push ${imageTag}
                        """
                    }
                }
            }
        }

        stage('🚀 Run Docker Container on Port 9073') {
            steps {
                script {
                    def imageTag = "${DOCKER_HUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}"
                    sh """
                        docker stop ${IMAGE_NAME}-${BUILD_NUMBER} || true
                        docker rm ${IMAGE_NAME}-${BUILD_NUMBER} || true

                        docker run -d --name ${IMAGE_NAME}-${BUILD_NUMBER} -p 9073:8080 ${imageTag}
                    """
                    echo "🌍 App is running in Docker: http://localhost:9073 or http://<your-ip>:9073"
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful! Access your app:"
            echo "  🔗 Tomcat: http://172.21.40.70:8082/"
            echo "  🔗 Docker: http://<your-ip>:9073/"
        }
        failure {
            echo "❌ Something went wrong!"
        }
    }
}
