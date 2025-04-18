pipeline {
    agent any

    environment {
        MAVEN_HOME = tool name: "Maven 3.9.9"
        DOCKER_HUB_USER = "ramu7"
        IMAGE_NAME = "application"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '2'))
    }

    triggers {
        githubPush()
    }

    stages {
        stage('✅ Checkout Code') {
            steps {
                git branch: 'main',
                    credentialsId: '9c54f3a6-d28e-4f8f-97a3-c8e939dcc8ff',
                    url: 'https://github.com/ramu0709/pipeline4.git'
            }
        }

        stage('✅ Build') {
            steps {
                script {
                    def branchName = env.BRANCH_NAME ?: sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()
                    env.BRANCH_NAME = branchName
                    echo "✅ Git Branch: ${branchName}"
                }

                sh '''
                    ${MAVEN_HOME}/bin/mvn clean package -X
                    ls -l target/
                '''
            }
        }

        stage('✅ SonarQube') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                        sh '''
                            ${MAVEN_HOME}/bin/mvn sonar:sonar -Dsonar.login=$SONAR_TOKEN
                        '''
                    }
                }
            }
        }

        stage('✅ Code Coverage - JaCoCo') {
            steps {
                jacoco buildOverBuild: true,
                    changeBuildStatus: true,
                    minimumBranchCoverage: '80',
                    minimumClassCoverage: '80',
                    minimumMethodCoverage: '80',
                    minimumLineCoverage: '80',
                    minimumInstructionCoverage: '80',
                    minimumComplexityCoverage: '80'
            }
        }

        stage('✅ Upload to Nexus') {
            steps {
                script {
                    def isMain = (env.BRANCH_NAME == "main" || env.BRANCH_NAME == "master")
                    def repository = isMain ? "sample-release" : "sample-snapshot"
                    def version = isMain ? "1.0" : "1.0-SNAPSHOT"
                    def warFile = "target/maven-web-application.war"

                    if (fileExists(warFile)) {
                        nexusArtifactUploader(
                            artifacts: [[
                                artifactId: 'application',
                                classifier: '',
                                file: warFile,
                                type: 'war'
                            ]],
                            credentialsId: 'nexus-credentials',
                            groupId: 'Batman',
                            version: version,
                            repository: repository,
                            nexusUrl: '172.21.40.70:8081',
                            nexusVersion: 'nexus3',
                            protocol: 'http'
                        )
                    } else {
                        error "WAR file not found: ${warFile}"
                    }
                }
            }
        }

        stage('✅ Docker Build & Push to Docker Hub') {
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

        stage('✅ Run in Docker Container') {
            steps {
                script {
                    def imageTag = "${DOCKER_HUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}"

                    sh """
                        docker stop ${IMAGE_NAME}-${BUILD_NUMBER} || true
                        docker rm ${IMAGE_NAME}-${BUILD_NUMBER} || true
                        docker run -d --name ${IMAGE_NAME}-${BUILD_NUMBER} -p 9073:8080 ${imageTag}
                    """

                    echo """
                    🌐 Your application is now running in a Docker container.

                    You can access it in your browser at:
                    👉 http://localhost:9073 (if running locally)
                    👉 http://172.21.40.70:9073 (if running on your Jenkins host)

                    Make sure port 9073 is accessible.
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
