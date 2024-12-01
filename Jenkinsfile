pipeline {
    agent any
	tools {
		maven 'Maven'
	}
	
	environment {
		PROJECT_ID = 'jenkins-435307'
                CLUSTER_NAME = 'k8s-cluster'
                LOCATION = 'us-central1-c'
                CREDENTIALS_ID = '9ea5a090-a34f-4855-bf08-dd01eeb1a7ee'	
	}
	
    stages {
	    stage('Scm Checkout') {
		    steps {
			    checkout scm
		    }
	    }


	     stage('SonarQube analysis') {
            steps {
                withSonarQubeEnv('Sonar-server') {
                    sh 'mvn sonar:sonar \
                        -Dsonar.projectKey=MCI \
                        -Dsonar.projectName="MCI" \
                        -Dsonar.host.url=http://34.42.239.16:9000 \
                        -Dsonar.login=sqp_b74069b12d4462e3ed5afcc8d99b01d18d0bad09'
                }
            }
        }

		
            
       
	stage('Snyk Analysis') {
	steps {
	      snykSecurity(
        	snykInstallation: 'Snyk CLI',
          	snykTokenId: 'snyk-token',
        	additionalArguments: '--all-projects --detection-depth=3'
        		)
      		}
   	}
	    stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

	    stage('Build') {
		    steps {
			    sh 'mvn clean package'
		    }
	    }
	    	    
	    	    stage('Test') {
		    steps {
			    echo "Testing..."
			    sh 'mvn test'
		    }
	    }
	    
	    stage('Build Docker Image') {
		    steps {
			    sh 'whoami'
			    script {
				    myimage = docker.build("nantenaina181/devops:${env.BUILD_ID}")
			    }
		    }
	    }


	stage("Push Docker Image") {
    steps {
        script {
            echo "Push Docker Image"
            withCredentials([string(credentialsId: 'nantenaina181', variable: 'nantenaina181')]) {
                sh "docker login -u nantenaina181 -p ${nantenaina181}"
            }
            myimage.push("${env.BUILD_ID}")
            myimage.push("latest")  // Pousser aussi un tag 'latest'
        }
    }
}


	    
	 
	    
	    stage('Deploy to K8s') {
		    steps{
			    echo "Deployment started ..."
			    sh 'ls -ltr'
			    sh 'pwd'
			    sh "sed -i 's/tagversion/${env.BUILD_ID}/g' serviceLB.yaml"
				sh "sed -i 's/tagversion/${env.BUILD_ID}/g' deployment.yaml"
			    echo "Start deployment of serviceLB.yaml"
			    step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT_ID, clusterName: env.CLUSTER_NAME, location: env.LOCATION, manifestPattern: 'serviceLB.yaml', credentialsId: env.CREDENTIALS_ID, verifyDeployments: true])
				echo "Start deployment of deployment.yaml"
				step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT_ID, clusterName: env.CLUSTER_NAME, location: env.LOCATION, manifestPattern: 'deployment.yaml', credentialsId: env.CREDENTIALS_ID, verifyDeployments: true])
			    echo "Deployment Finished ..."
		    }
	   }
    }
}
