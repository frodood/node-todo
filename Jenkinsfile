node {
stage('Preparation') {

//Clone git repository
  git url:'https://github.com/frodood/node-todo.git'
   }
stage('Integration') {
        sh 'INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4) && sed -i s,IP,${INTERNAL_IP},g k8s-mainfest/web-frontend-deployment.yaml'

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
           ip = sh script: "kubectl --kubeconfig /tmp/kubeconfig get svc -o jsonpath='{.items[*].status.loadBalancer.ingress[*].hostname}'", returnStdout: true
           ip=ip.trim()
           count++
          }

    if(ip==''){
     error("Not able to get the IP address. Aborting...")
        }
    else{
                //Executing tests
                sleep 30
     sh "chmod +x tests/integration_test.sh && ./tests/integration_test.sh ${ip}"

     //Cleaning the integration environment
     println("Cleaning integration environment...")
     sh 'kubectl --kubeconfig /tmp/kubeconfig delete -f k8s-mainfest'
         println("Integration stage finished.")
    }

         }
    catch(Exception e) {
     println("Integration stage failed.")
      println("Cleaning integration environment...")
      sh 'kubectl --kubeconfig /tmp/kubeconfig delete -f k8s-mainfest'
          error("Exiting...")
         }

   }
 stage('Production') {
      sh 'INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4) && sed -i s,IP,${INTERNAL_IP},g k8s-mainfest/web-frontend-deployment.yaml'
      sh 'kubectl --kubeconfig /tmp/kubeconfig apply -f k8s-mainfest/'


      //Gathering Node.js app's external IP address
         def ip = ''
         def count = 0
         def countLimit = 10

         //Waiting loop for IP address provisioning
         println("Waiting for IP address")
         while(ip=='' && count<countLimit) {
          sleep 30
          ip = sh script: "kubectl --kubeconfig /tmp/kubeconfig get svc -o jsonpath='{.items[*].status.loadBalancer.ingress[*].hostname}'", returnStdout: true
          ip = ip.trim()
          count++
     }

   if(ip==''){
    error("Not able to get the IP address. Aborting...")

   }
   else{
               //Executing tests
               sleep 30
    sh "chmod +x tests/production_test.sh && ./tests/production_test.sh ${ip}"
          }

   }
}
