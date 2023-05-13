@Library('slack') _

pipeline {
  agent any

  environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "buinguyen/numeric-app:${GIT_COMMIT}"

    applicationURL = "http://dev-ovng-poc2-lead.ovng.dev.myovcloud.com"
    applicationURI = "/increment/99"
    SONARQUBE_URL = "http://dev-ovng-poc2-lead.ovng.dev.myovcloud.com:9000"
    SONARQUBE_LOGIN = "sqp_1248a4562daba1a7572514539d5927f077c710bf"
    SONAR_PROJECT_KEY = 'numeric-application'
  }


  stages {
      stage('Build Artifact') {
            steps {
              sh "/opt/maven/bin/mvn --version"
              sh "/opt/maven/bin/mvn clean package -DskipTests=true"
              archive 'target/*.jar'  // test webhook
            }
        }

      stage('Unit Tests - JUnit and Jacoco') {
        steps {
          sh 'echo "Running Maven test..."'
          sh "/opt/maven/bin/mvn test"

          sh 'echo "Generating code coverage report using Jacoco..."'
          sh '/opt/maven/bin/mvn jacoco:report'
          archiveArtifacts allowEmptyArchive: true, artifacts: 'target/site/jacoco/index.html', onlyIfSuccessful: true

          // archives and publishes JUnit reports generated by Maven during unit tests.
          // jacoco(execPattern: 'target/jacoco.exec')

          // generates a code coverage report using JaCoCo. The report is stored in the target/site/jacoco directory. After that, archive index.html file
          // sh "mvn jacoco:report"
          // archive 'target/site/jacoco/index.html'
        }
      }

      // stage('Mutation Tests - PIT'){
      //   steps {
      //     sh "mvn org.pitest:pitest-maven:mutationCoverage"
      //   }
      // }

      stage('SonarQube - SAST') {
        steps {
          withSonarQubeEnv('SonarQube') {  // lấy từ jenkins/manager/sonarqube
          sh "/opt/maven/bin/mvn sonar:sonar \
            -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
            -Dsonar.host.url=${SONARQUBE_URL} \
            -Dsonar.login=${SONARQUBE_LOGIN}"
          }
        // timeout(time: 2, unit: "MINUTES") {
        //   script {
        //     waitForQualityGate abortPipeline: true
        //   }
        // }
        }
      }

      // dependency plugin và trivy đều dùng cho scan vulnerability nên dùng parallel cho cả 2
      stage('Vulnerability Scan Docker') {
        steps {
          script {
            def mavenHome = tool 'Maven'
            def mvnCmd = "${mavenHome}/bin/mvn"
          parallel(
            "Dependency Scan" : {
              sh 'echo "Generating code coverage report using dependency check..."'
              sh "/opt/maven/bin/mvn dependency-check:check"
              def reportDir = "${env.WORKSPACE}/target"
              def reportFile = "${reportDir}/dependency-check-report.html"


              archiveArtifacts artifacts: "target/dependency-check-report.html", fingerprint: true

              publishHTML(target: [
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: reportDir,
                reportFiles: 'dependency-check-report.html',
                reportName: 'Dependency Check Report'
              ])
            },
            "Trivy Scan" : {
              sh 'echo "Running Trivy docker scan ..."'
              sh "bash trivy-docker-image-scan.sh"
              //  step is archiving the trivy-scan-report-critical.json file and generating a fingerprint for it, making it available for later use
              // /var/lib/jenkins/jobs/devsecops-numeric-application/builds/277/archive/trivy-scan-report-critical.json
              archiveArtifacts artifacts: "trivy-scan-report-critical.json", fingerprint: true
            },

            // OPA scan Dockerfile
            // just test rc.local of ec2
            "OPA Conftest" : {
              sh 'echo "running OPA Conftest for scan Dockerfile" ...'
              sh 'bash opa-conftest-docker.sh'
            }
          )
          }
        }
      }
      stage ('Docker Deployment') {
        environment {
          DOCKER_REPOSITORY = "buinguyen/numeric-app"
          DOCKER_TAG = "${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
          DOCKER_IMAGE_NAME = "${DOCKER_REPOSITORY}:${GIT_COMMIT}"
//        imageName = "buinguyen/numeric-app:${GIT_COMMIT}"
        }
        steps {
          withDockerRegistry([credentialsId: "dockerhub", url: ""]) {
            sh 'printenv'
            sh 'docker build -t ${DOCKER_IMAGE_NAME} .'
            sh 'docker push ${DOCKER_IMAGE_NAME}'
          }
          sh 'echo "Docker image pushed: ${imageName}"'
        }
      }

      stage ('Vulnerability Scan - Kubenertes') {
        steps {
          parallel(
            "OPA Scan": {
              sh 'echo "running OPA Conftest for scan Kubernetes resources" ...'
              sh 'bash opa-conftest-k8s.sh'
            },

            "Kubesec Scan": {
              sh 'echo "prevent security-related risks" ...'
              sh 'bash kubesec-scan.sh'
            },

            "Trivy scan": {
              sh 'bash trivy-k8s-scan.sh'
            }
          )
              // OPA scan kubenertes deployment and service
        }
      }

      stage ('Kubernetes Deployment - DEV') {
        steps {
          parallel (
            "Deployment": {
              withKubeConfig([credentialsId: 'kubeconfig']) {
                sh "bash k8s-deployment.sh"
              }
            },

            "Rollout Status": {
              withKubeConfig([credentialsId: 'kubeconfig']) {
                sh "bash k8s-deployment-rollout-status.sh"
              }
            }
          )
          }
        }

      stage ('Integration Tests - DEV') {
        steps {
          script{
            try {
              withKubeConfig([credentialsId:'kubeconfig']) {
                sh "bash integration-test.sh"
              }
            } catch (e) {
                withKubeConfig([credentialsId:'kubeconfig']) {
                  sh "kubectl -n default rollout undo deploy ${deploymentName}"
                }
                throw e
            }
          }
        }
      }

      stage ('OWASP ZAP') {
        steps {
          withKubeConfig([credentialsId: 'kubeconfig']) {
            sh 'bash zap.sh'
          }
        }
      }

      stage('Testing Slack') {
        steps {
          sh 'exit 0'
        }
      }

      // stage('Prompte to PROD') {
      //   steps {
      //     timeout(time: 1, unit: 'HOURS') {
      //       input 'Do you want to Approve the Deployment to Production Environment?'
      //     }
      //     sh 'exit 0'
      //   }
      // }
  }
  post {
    always {
      // report of jacoco scan phase
      sh 'echo "Publishing JUnit test results..."'

      // archives and publishes the Jacoco coverage report generated by Maven during unit tests.
      junit 'target/surefire-reports/*.xml'
      jacoco execPattern: 'target/jacoco.exec'
      // report of dependency checking
      dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'

      // report of OWASP ZAP
      publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'OWASP ZAP HTML REPORT', reportTitles: 'OWASP ZAP HTML REPORT', useWrapperFileDirectly: true])

      // Use sendNotfitication sendNotification.groovy from shared library and provide current build status as parameter
      sendNotification currentBuild.result
    }

    success {
      script {
        def dashboardUrl = "${env.SONARQUBE_URL}/dashboard?id=numeric-application"
        echo "SonarQube analysis is completed! Check out the report at ${dashboardUrl}"
      }
    }
  }
}
