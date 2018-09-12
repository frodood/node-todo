node {
stage('Preparation') {

//Clone git repository
  git url:'https://github.com/frodood/node-todo.git'
   }
stage('Integration') {

      withKubeConfig([credentialsId: 'jenkins-deployer-credentials', caCertificate: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRFNE1Ea3hNakExTURrME5Gb1hEVEk0TURrd09UQTFNRGswTkZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTDBMCjF5cXphRjVTUXpTRUtDRzQ2cEdBM2VSRWlXQkU1bVh4eTZIaWdhRU4xZHY3TERvV2hGTGtIbUJPSVhNSHdrb1cKVUEzVlYwV1p5TW1nM3VUeEZ3OHF5bzA3VXpwUEFVMkVGTEdKTGF4cFVxSjlROE4zUjJLOGVQWlVVZzFBSFBOMApBV3JlZDBOdjkzMk5vdFVwUk1zRE1IQ3Fyc2tkdGd2SUFIZ2hwZE82cERTaFJqelBraWVXOXhJLy9iNkd3Yk5CCkNobE9kNkZjL29MN3JzZHBMRk1aSkVreUpxdmZLS2wzVVgyYmE0cWN1aXJxRUFmbjZvM3Vsc2lyRkpnRmFINWcKV0UzUkV1MmdLczM1V3FiVWs3Ri9DakpPRVhDUFVGYU1KUEhnak82WHNxWjVlbWtoRGZMSHdlUkQ5UWwzSnFvZgptSklGa21PbUR4NzFlQmZVOHRjQ0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFCT1c3bkJkZThjdkhuNnBTVGJmSXNkc0FDNWYKMFl4WmUzSHZPUjlzU0ZHazdpZmYwYWg2MDZXVU9WenQ2dkxQUVM3QXJHMzJLOWE4L21rZUgzME11RWtyUkQ4dgpZSW1lekRISnVBNVJYdFpOUlk0RTNCR01tRWthQXZFRlBwQm9Fb1VwS1VNVVIxQWozbURhUGgrWXdlYW5sK2Y1CkFkQS9zekszMUlCMDBma0g1Qmo2ZEFSKzJsTG9mTGsyOWNIcElBWmZGKytzajBXMCtQTk5IU0Nhbm5FakJxdTQKK0lIUnU5U3BFcjAzcHVsbFBRMlFTempGS2JmUFZ4MGxoRCsrSVlnR2pEdHMrcHdNU3lLS0ZFQVFwSDNZRXgwUQpLdFc2Y2J1Y1Nta3Q2OEpVMDBteFBaWjVCVm5qZ3RwVkptN3lJYlQ1MXc4enhjSXBSdmJzSi90RnkxTT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=', serverUrl: 'https://E390067DC6C0C2E5169857FB6519932C.yl4.us-east-1.eks.amazonaws.com']) {

          sh 'kubectl apply -f k8s-mainfest/ --namespace=myapp-integration'
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


      sh 'kubectl apply -f k8s-mainfest/ --namespace=myapp-production'


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
