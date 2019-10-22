pipeline {
  agent {
    node {
      label 'haimaxy-jnlp'
    }

  }
  stages {
  stage('Init') {
		steps{
			script{
			
				println "welcome to Nick learn"
				println env.WORKSPACE
				module_test = load env.WORKSPACE + "/groovy/jenkins-module.groovy"
				sh 'mkdir workplace'
			}
		}
	}
	 stage('Git Source') {
		steps{
                script{
                	dir("${env.WORKSPACE}/workplace"){  
                	    git branch: 'env/dev', credentialsId: '11111',url: 'git@192.168.108.132:root/jenkins_slave_k8s.git'
                	}

                      
                    
              }
                
         }
    
	}
    stage('Maven Build') {
      steps {
        script {
        
          container('maven') {
	          dir("${env.WORKSPACE}/workplace"){
	         	 sh 'mvn clean package'
	          }
            
          }
        }

      }
    }
    stage('Docker Build') {
      steps {
        script {
          container('docker') {
			sh 'docker login -u ' + HARBOR_CREDS_USR  + ' -p ' + HARBOR_CREDS_PSW + ' ' + HARBOR_HOST
            sh "docker build --build-arg JAR_FILE=`ls workplace/target/*.jar |cut -d '/' -f2` -t " + HARBOR_HOST + "/" + DOCKER_IMAGE + ":" + GIT_TAG + " --no-cache ."
            sh "docker push " + HARBOR_HOST + "/" + DOCKER_IMAGE + ":" + GIT_TAG
            sh "docker rmi " + HARBOR_HOST + "/" + DOCKER_IMAGE + ":" + GIT_TAG
          }
        }
      }
    }
    stage('K8s Deploy') {
      steps {
        script {
          container('kubectl') {
            sh "sed -e 's#{IMAGE_URL}#" + HARBOR_HOST + "/" + DOCKER_IMAGE + "#g;s#{IMAGE_TAG}#" + GIT_TAG + "#g;s#{APP_NAME}#" + APP_NAME + "#g;s#{SPRING_PROFILE}#k8s-test#g' k8s-deployment.tpl > k8s-deployment.yml"
			sh "sed -e 's#{APP_NAME}#" + APP_NAME + "#g;s#{NODE_PORT}#" + NODE_PORT + "#g' k8s-deployment-svc.tpl > k8s-deployment-svc.yml"
            try{
                sh "kubectl delete rc " + APP_NAME + " --namespace=" + K8S_NAMESPACE	
            }catch (Exception e) {
				println e
			}
			try{
                sh "kubectl delete svc " + APP_NAME + " --namespace=" + K8S_NAMESPACE	
            }catch (Exception e) {
				println e
			}
            sh "kubectl apply -f k8s-deployment.yml --namespace=" + K8S_NAMESPACE
			sh "kubectl apply -f k8s-deployment-svc.yml --namespace=" + K8S_NAMESPACE
          }
        }

      }
    }
    stage('API Test') {
      steps {
        script {
 			container('newman') {
 			 dir("${env.WORKSPACE}/workplace"){
 			 try{
 			 	sleep 5
 			   sh 'newman run postman/jenkins_demo_test.postman_collection.json'  
 			 }catch (Exception e) {
					println e
				}

           	 }
          } 
        }

      }
    }
  }
 post{
		failure {
			script {
				module_test.send_email_results("Failed","Master","1006953115@qq.com")
			
			}
		}
		success {
			script {
			
				module_test.send_email_results("Success","Master","1006953115@qq.com")
			}
		}
	}

 environment {
        HARBOR_CREDS = credentials('jenkins-harbor-creds')
//        K8S_CONFIG = credentials('jenkins-k8s-config')
		GIT_TAG = sh(returnStdout: true,script: 'echo ' + BUILD_NUMBER ).trim()
    }
  parameters {
    string(name: 'HARBOR_HOST', defaultValue: '192.168.108.131', description: 'harbor仓库地址')
    string(name: 'DOCKER_IMAGE', defaultValue: 'library/jenkins_demo', description: 'docker镜像名')
    string(name: 'APP_NAME', defaultValue: 'jenkinsdemo', description: 'k8s中标签名')
    string(name: 'NODE_PORT', defaultValue: '30000', description: 'Service端口')
    string(name: 'K8S_NAMESPACE', defaultValue: 'default', description: 'k8s的namespace名称')
  }
}