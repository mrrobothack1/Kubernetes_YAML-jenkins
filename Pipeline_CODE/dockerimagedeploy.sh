#!/bin/bash +x 
         echo "Deploying Docker Image ..."
         if [[ dev == "dev" || dev == "qa" || dev == "svc" ]] 
         then 
           no=$(curl http://${JENKINS_LLE_MASTER_IP}/record/dockerimagecount/get/r19-8-mui-cache-dev | tr -d '"') 
           rand=$(curl http://${JENKINS_LLE_MASTER_IP}/record/dockerimagerand/get/r19-8-mui-cache-dev | tr -d '"') 
           echo "RAND-------------->$rand" 
         else 
           no=$(curl http://${JENKINS_LLE_MASTER_IP}/record/dockerimagecount/get/r19-8-mui-cache-reldev | tr -d '"') 
           rand=$(curl http://${JENKINS_LLE_MASTER_IP}/record/dockerimagerand/get/r19-8-mui-cache-reldev | tr -d '"') 
           echo "RAND-------------->$rand" 
         fi 
         if [[ cache-redesign == *"master"* ]] 
         then 
            rm -rf Dockerfile 
            mv ./node/Dockerfile . 
            docker build -t cache-redesign-mui-dev:cache-redesign-nodeserver-${no}-${rand} . 
            gcloud container clusters get-credentials mobileservices-dev-lle-usc1-1 --zone=us-central1-b --project=soju-mobile-lle
            docker tag cache-redesign-mui-dev:cache-redesign-nodeserver-${no}-${rand} us.gcr.io/soju-mobile-lle/mui:cache-redesign-nodeserver-${no}-${rand} 
            gcloud docker -- push us.gcr.io/soju-mobile-lle/mui:cache-redesign-nodeserver-${no}-${rand} 
            docker rmi -f $(docker images --quiet cache-redesign-mui-dev:cache-redesign-nodeserver-${no}-${rand}) 
         else 
            cd node-dockerfile
            docker build -t cache-redesign-mui-dev:cache-redesign-nodeserver-${no}-${rand} . 
            gcloud container clusters get-credentials mobileservices-dev-lle-usc1-1 --zone=us-central1-b --project=soju-mobile-lle
            docker tag cache-redesign-mui-dev:cache-redesign-nodeserver-${no}-${rand} us.gcr.io/soju-mobile-lle/mui:cache-redesign-nodeserver-${no}-${rand} 
            gcloud docker -- push us.gcr.io/soju-mobile-lle/mui:cache-redesign-nodeserver-${no}-${rand} 
            docker rmi -f $(docker images --quiet cache-redesign-mui-dev:cache-redesign-nodeserver-${no}-${rand}) 
         fi
