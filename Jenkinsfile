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
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/spkumar17/spring-petclinic.git'
                echo 'Checkout Code stage completed'
            }
        }

        stage('compile') {
            steps {
                sh 'mvn compile'
                echo 'Compile stage completed'
            }
        }

        stage("Trivy file scan"){
            steps{
                script{
                    sh'trivy fs --format table -o trivyfs.html . '  //scans the filesystem display it in humanreadable format (tabler) stores output in trivyfs.html file in html format scan the fs in current working dir
                    echo 'Trivy file scan stage completed'
                }
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
                        echo 'SonarQube Analysis stage completed'

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
                        echo 'Quality Gate stage completed'

                    }
                }
            }
        }
        // stage('OWASP Dependency-Check') {
        //     // when {
        //     //     branch 'Dev1' // Run this stage only if the branch is 'main'
        //     // }
            
        //     steps {
        //         dependencyCheck additionalArguments: '--scan target/', odcInstallation: 'OWASP Check', outputFile: 'owasp.txt'
        //     }
        // }
        
        stage('Maven Package') {
            steps {
                sh 'mvn clean package -DskipTests'
                echo 'Maven Package stage completed'

            }
        }

        stage("Maven deploy nexus "){
            steps {
                configFileProvider([configFile(fileId: 'da02a396-929b-4f58-8117-a443c901e6cf', variable: 'mavensettings')]) {

                    sh" mvn -s $mavensettings clean deploy -DskipTests=true "
                    echo 'Maven deploy Nexus stage completed'

                }
            }
        }
        stage('Building Docker Image') {
            
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-credentials', toolName: 'Docker') {
                        sh "docker build -t prasannakumarsinganamalla431/petclinic:${BUILD_NUMBER} ."
                        echo 'Building Docker Image stage completed'

                    }
                }
            }    
        }

        stage("Docker Image to Nexus") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'Nexus', usernameVariable: 'USER', passwordVariable: 'PSW')]) {
                    // Log in to Docker registry
                    sh '''
                    echo ${PSW} | docker login -u ${USER} --password-stdin 54.152.237.175:8082
                    '''

                    // Push Docker image
                    sh '''
                    docker build -t 54.152.237.175:8082/petclinic:${BUILD_NUMBER} .

                    docker push 54.152.237.175:8082/petclinic:${BUILD_NUMBER}

                    '''
                    echo 'Docker Image to Nexus stage completed'

                }
            }
        }



        // stage('Trivy Image Scan') {
        //     steps {
        //         script {
        //             // Perform Trivy scan on the Docker image
        //             sh 'trivy image --format table --output trivy-image-scan.txt prasannakumarsinganamalla431/petclinic:${BUILD_NUMBER}'
        //         }
        //     }
        // }

        stage('pushing image to Docker hub') {
            
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-credentials', toolName: 'Docker') {
                        sh "docker push prasannakumarsinganamalla431/petclinic:${BUILD_NUMBER}"
                        echo 'Pushing image to Docker Hub stage completed'

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
                                <p>Hi DevOps team,</p>
                                <p>Please find below the result of the pipeline, which builds the Petclinic application, stores the Docker image in Docker Hub, and integrates several security tools.</p>
                                <p>For more information, please find the console output below.</p>
                                <p>Thank you</p>
                                <p>Job Name: ${JOB_NAME}</p>
                                <p>Build Status: ${currentBuild.currentResult}</p>
                                <p>Build Number: ${BUILD_NUMBER}</p>
                                <p>Check the <a href="${BUILD_URL}">console output</a>.</p>
                                <p>Maven Snapshots Repository: <a href="http://3.81.210.172:8081/#browse/browse:maven-snapshots">Nexus Repository</a></p>
                                <p>Docker Repository: <a href="http://54.152.237.175:8082">Nexus Docker Repository</a></p>


                            </body>
                        </html>
                    """,
                    mimeType: 'text/html',
                    to: "${Receiver_email}",
                    from: 'jenkins@example.com',
                    replyTo: 'jenkins@example.com',
                    attachmentsPattern: 'trivyfs.html,trivy-image-scan.txt,owasp.txt'
                )
            }
        }
}

