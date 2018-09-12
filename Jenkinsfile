node {
stage('Preparation') {

//Clone git repository
  git url:'https://github.com/frodood/node-todo.git'
   }
stage('Integration') {

         sh 'kubectl --kubeconfig /tmp/kubeconfig apply -f k8s-mainfest/'
         try{
          //Gathering Node.js app's external IP address
          def ip = ''
          def count = 0
          def countLimit = 10

          //Waiting loop for IP address provisioning
          println("Waiting for IP address")
          while(ip=='' && count<countLimit) {
           sleep 30
           ip = sh script: 'kubectl --kubeconfig /tmp/kubeconfig get svc --namespace=myapp-integration -o jsonpath="{.items[?(@.metadata.name==\'web-frontend-lb\')].status.loadBalancer.ingress[*].ip}"', returnStdout: true
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
     sh 'kubectl --kubeconfig /tmp/kubeconfig delete -f deploy --namespace=myapp-integration'
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
 stage('Production') {
    
      sh 'kubectl --kubeconfig /tmp/kubeconfig apply -f k8s-mainfest/ --namespace=myapp-production'


      //Gathering Node.js app's external IP address
         def ip = ''
         def count = 0
         def countLimit = 10

         //Waiting loop for IP address provisioning
         println("Waiting for IP address")
         while(ip=='' && count<countLimit) {
          sleep 30
          ip = sh script: 'kubectl --kubeconfig /tmp/kubeconfig get svc --namespace=myapp-production -o jsonpath="{.items[?(@.metadata.name==\'web-frontend-lb\')].status.loadBalancer.ingress[*].ip}"', returnStdout: true
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
