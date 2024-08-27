pipeline {
    agent any
    
    tools {
        jdk 'jdk17'
        maven 'maven3'
    }
    
    environment {
        SONAR_AUTH_TOKEN = credentials('SONAR_AUTH_TOKEN') // Assumes you have stored your token in Jenkins Credentials
        DOCKER_REGISTRY_CREDENTIALS = credentials('docker-credentials')
        Receiver_email = credentials('Receiver_email')
    }
    
    stages {
        stage('compile') {
            steps {
                sh 'mvn compile'
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                script {
                    // Run Maven with SonarQube plugin for analysis
                    withSonarQubeEnv('SonarQubeScanner') {
                        sh """
                            mvn sonar:sonar -Dsonar.login="${SONAR_AUTH_TOKEN}" \
                            -Dsonar.projectName=spring-petclinic \
                            -Dsonar.java.binaries=. \
                            -Dsonar.projectKey=spring-petclinic
                        """
                    }
                }
            }
        }
        
        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    script {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }
        stage('OWASP Dependency-Check') {
            when {
                branch 'Dev1' // Run this stage only if the branch is 'main'
            }
            
            steps {
                dependencyCheck additionalArguments: '--scan target/', odcInstallation: 'OWASP Check'
            }
        }
        
        stage('Maven Package') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
        stage('Building Docker Image') {
            
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-credentials', toolName: 'Docker') {
                        sh "docker build -t prasannakumarsinganamalla431/petclinic:${BUILD_NUMBER} ."

                    }
                }
            }    
        }
        stage('pushing image to Docker hub') {
            
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-credentials', toolName: 'Docker') {
                        sh "docker push prasannakumarsinganamalla431/petclinic:${BUILD_NUMBER}"
                    }
                }
            }    
        }
    }

        post {
        always {
            emailext (
                subject: "Pipeline Status: ${BUILD_NUMBER}",
                body: """
                    <html>
                        <body>
                            <p>Build Status: ${BUILD_STATUS}</p>
                            <p>Build Number: ${BUILD_NUMBER}</p>
                            <p>Check the <a href="${BUILD_URL}">console output</a>.</p>
                        </body>
                    </html>
                """,
                mimeType: 'text/html',
                to: "${Receiver_email}",
                from: 'jenkins@example.com',
                replyTo: 'jenkins@example.com'
            )
        }
    }

}

