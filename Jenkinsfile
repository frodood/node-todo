node {
stage('Preparation') {
      //Installing kubectl in Jenkins agent
      sh 'curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl'
  sh 'chmod +x ./kubectl && mv kubectl /usr/local/sbin'
//Clone git repository
  git url:'https://github.com/frodood/node-todo.git'
   }
stage('Integration') {

      withKubeConfig([credentialsId: 'jenkins-deployer-credentials', serverUrl: 'https://E390067DC6C0C2E5169857FB6519932C.yl4.us-east-1.eks.amazonaws.com']) {

         sh 'kubectl apply -f node-todo/k8s-mainfest/ --namespace=myapp-integration'
         try{
          //Gathering Node.js app's external IP address
          def ip = ''
          def count = 0
          def countLimit = 10

          //Waiting loop for IP address provisioning
          println("Waiting for IP address")
          while(ip=='' && count<countLimit) {
           sleep 30
           ip = sh script: 'kubectl get svc --namespace=myapp-integration -o jsonpath="{.items[?(@.metadata.name==\'web-frontend-lb\')].status.loadBalancer.ingress[*].ip}"', returnStdout: true
           ip=ip.trim()
           count++
          }

    if(ip==''){
     error("Not able to get the IP address. Aborting...")
        }
    else{
                //Executing tests
     sh "chmod +x tests/integration_test.sh && ./tests/integration_test.sh ${ip}"

     //Cleaning the integration environment
     println("Cleaning integration environment...")
     sh 'kubectl delete -f deploy --namespace=myapp-integration'
         println("Integration stage finished.")
    }

         }
    catch(Exception e) {
     println("Integration stage failed.")
      println("Cleaning integration environment...")
      sh 'kubectl delete -f deploy --namespace=myapp-integration'
          error("Exiting...")
         }
}
   }
 stage('Production') {
      withKubeConfig([credentialsId: 'jenkins-deployer-credentials', serverUrl: 'https://E390067DC6C0C2E5169857FB6519932C.yl4.us-east-1.eks.amazonaws.com']) {


      sh 'kubectl apply -f deploy/ --namespace=myapp-production'


      //Gathering Node.js app's external IP address
         def ip = ''
         def count = 0
         def countLimit = 10

         //Waiting loop for IP address provisioning
         println("Waiting for IP address")
         while(ip=='' && count<countLimit) {
          sleep 30
          ip = sh script: 'kubectl get svc --namespace=myapp-production -o jsonpath="{.items[?(@.metadata.name==\'web-frontend-lb\')].status.loadBalancer.ingress[*].ip}"', returnStdout: true
          ip = ip.trim()
          count++
     }

   if(ip==''){
    error("Not able to get the IP address. Aborting...")

   }
   else{
               //Executing tests
    sh "chmod +x tests/production_test.sh && ./tests/production_test.sh ${ip}"
          }
      }
   }
}
