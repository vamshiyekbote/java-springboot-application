pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID="296654683"
        AWS_DEFAULT_REGION="ap-south-1"
        IMAGE_REPO_NAME="java-registry"
        IMAGE_TAG="latest"
        REPOSITORY_URI = "296654683.dkr.ecr.ap-south-1.amazonaws.com/java-registry:latest"
        DEPLOYMENT_FILE = "notes.yaml"
    }
    tools {
        maven "MAVEN"
    }

    stages {
        
        

        stage('Build') {
            steps {
                // Get some code from a GitHub repository
                git credentialsId: '6470348e-689aab9e2551', url: 'https://git-codecommit.ap-south-1.amazonaws.com/v1/repos/java-app'
                sh "pwd"
                // Run Maven on a Unix agent.
                sh "mvn package -DskipTests"

            }
        }
        
        stage('Docker Build') {
            steps {
                script {
                    // Get the current build number
                    def buildNumber = env.BUILD_NUMBER ?: 'latest'
                    
                    // Build the Docker image and tag it with the build number
                    sh "docker build -t notes:${buildNumber} ."
                    sh "pwd"
                }
            }
        }
        stage('Logging into AWS ECR') {
            steps {
                script {
                sh """aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"""
                }
                 
            }
        }
        stage('Push to ECR') {
            steps {
                script {
                    // Get the current build number
                    def buildNumber = env.BUILD_NUMBER ?: 'latest'
                    
                    // Tag the Docker image with the ECR repository URL and build number
                    sh "docker tag notes:${buildNumber} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${buildNumber}"
                    
                    // Push the Docker image to the ECR repository
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${buildNumber}"
                }
            }
        }
        stage('Authenticate with EKS cluster') {
            steps { 
                sh "aws eks update-kubeconfig --name java-cluster --region ap-south-1"
            }
        }
         
        stage('Deploy to EKS') {
            steps {
                sh "echo 'Updating the image version in the deployment file...'"
                sh "sed -i -e 's/image: ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com\\/java-registry:[0-9]*/image: ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com\\/java-registry:${BUILD_NUMBER}/' ${DEPLOYMENT_FILE}"
                
                sh "echo 'Dry run: printing the updated deployment file...'"
                sh "cat ${DEPLOYMENT_FILE}"

                sh "echo 'Applying the updated deployment file...'"
                sh "kubectl apply -f ${DEPLOYMENT_FILE}"
            }
        }
    }
}
