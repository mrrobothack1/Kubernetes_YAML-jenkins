#!/bin/bash +x 

 if [[ dev == "dev" || dev == "qa" || dev == "svc" ]] 
 then 
     no=$(curl http://${JENKINS_LLE_MASTER_IP}/record/dockerimagecount/get/r19-8-adaptive-poc-dev | tr -d '"') 
     rand=$(curl http://${JENKINS_LLE_MASTER_IP}/record/dockerimagerand/get/r19-8-adaptive-poc-dev | tr -d '"') 
     docno=$no-$rand 
 else 
     no=$(curl http://${JENKINS_LLE_MASTER_IP}/record/dockerimagecount/get/r19-8-adaptive-poc-reldev | tr -d '"') 
     rand=$(curl http://${JENKINS_LLE_MASTER_IP}/record/dockerimagerand/get/r19-8-adaptive-poc-reldev | tr -d '"') 
     docno=$no-$rand 
     echo $docno 
 fi 
 if [[ aem-pmp-poc == *"master"* ]] 
 then 
     echo "Deploying App ..." 
     gcloud config set project soju-mobile-lle 
     gcloud config set account mdop-admin@soju-mobile-lle.iam.gserviceaccount.com 
     gcloud auth activate-service-account mdop-admin@soju-mobile-lle.iam.gserviceaccount.com --key-file=$HOME/soju-mobile-lle.json 
     export GOOGLE_APPLICATION_CREDENTIALS="$HOME/soju-mobile-lle.json" 
     gcloud auth list 
     #gsutil cp gs://automata-cli-bucket/deployment_yamls/browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml $HOME/r19-8-adaptive-poc-dev-workspace/browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml 
     cp ${WORKSPACE}/gcp/browse/deployments/browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml $HOME/r19-8-adaptive-poc-dev-workspace/browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml 
     sed -i "s,DEPNO,$no,g" $HOME/r19-8-adaptive-poc-dev-workspace/browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml 
     sed -i "s,DOCNO,$docno,g" $HOME/r19-8-adaptive-poc-dev-workspace/browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml 
     gcloud config set project soju-mobile-lle 
     gcloud config set account mdop-admin@soju-mobile-lle.iam.gserviceaccount.com 
     gcloud auth activate-service-account mdop-admin@soju-mobile-lle.iam.gserviceaccount.com --key-file=$HOME/soju-mobile-lle.json 
     export GOOGLE_APPLICATION_CREDENTIALS="$HOME/soju-mobile-lle.json" 
     gcloud auth list 
     gcloud container clusters get-credentials mobileservices-dev-lle-usc1-1 --zone=us-central1-b --project=soju-mobile-lle 
     kubectl config set-context mobileservices-dev-lle-usc1-1 --namespace=r19-8-browse-adaptive-poc-dev 
     app_name=browse 
     namespace=r19-8-browse-adaptive-poc-dev 
     # Getting OpenAPI domain value and storing in variable 
     OAPI_DOMAIN=$(kubectl get configmap envconfig-$no --namespace=$namespace -o yaml | grep openapi.baseurl | cut -f2 -d"=" | sed "s/# OAPI//g" | sed "s/http:\/\///g" | sed 's/\\n//g') 
     WAlleT_DOMAIN=$(kubectl get configmap envconfig-$no --namespace=$namespace -o yaml | grep wallet.domain | cut -f2 -d"=" | sed "s/# OAPI//g" | sed "s/http:\/\///g" | sed "s/https:\/\///g" | sed 's/\\n//g') 
     echo "OAPI_DOMAIN --> $OAPI_DOMAIN" 
     echo "WAlleT_DOMAIN --> $WAlleT_DOMAIN" 
     # Getting Egress_LB_IP value and storing in variable 
     region=us-central1-b 
     reg=${region::${#region}-2} 
     EGRESS_LB_IP=$(gcloud compute forwarding-rules list | grep egress-gw-service | gcloud compute forwarding-rules describe `awk '{print $1}'` --region=$reg  | grep IPAddress |  awk '{print $2}') 
     echo "EGRESS_LB_IP --> $EGRESS_LB_IP" 
     sed -i "s/EGRESS_LB_IP/${EGRESS_LB_IP}/g" $HOME/r19-8-adaptive-poc-dev-workspace/browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml 
     sed -i "s/OAPI_DOMAIN/${OAPI_DOMAIN}/g" $HOME/r19-8-adaptive-poc-dev-workspace/browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml 
     sed -i "s/WAlleT_DOMAIN/${WAlleT_DOMAIN}/g" $HOME/r19-8-adaptive-poc-dev-workspace/browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml 
 else 
     gcloud config set project soju-mobile-lle 
     gcloud config set account mdop-admin@soju-mobile-lle.iam.gserviceaccount.com 
     gcloud auth activate-service-account mdop-admin@soju-mobile-lle.iam.gserviceaccount.com --key-file=$HOME/soju-mobile-lle.json 
     export GOOGLE_APPLICATION_CREDENTIALS="$HOME/soju-mobile-lle.json" 
     gcloud auth list 
     #gsutil cp gs://automata-cli-bucket/deployment_yamls/aem-pmp-poc-browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml $HOME/r19-8-adaptive-poc-dev-workspace/aem-pmp-poc-browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml 
     cp ${WORKSPACE}/gcp/browse/deployments/aem-pmp-poc-browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml $HOME/r19-8-adaptive-poc-dev-workspace/aem-pmp-poc-browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml 
     sed -i "s,DEPNO,$no,g" $HOME/r19-8-adaptive-poc-dev-workspace/aem-pmp-poc-browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml 
     sed -i "s,DOCNO,$docno,g" $HOME/r19-8-adaptive-poc-dev-workspace/aem-pmp-poc-browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml 
     echo "Deploying App Properties ..." 
     gcloud config set project soju-mobile-lle 
     gcloud config set account mdop-admin@soju-mobile-lle.iam.gserviceaccount.com 
     gcloud auth activate-service-account mdop-admin@soju-mobile-lle.iam.gserviceaccount.com --key-file=$HOME/soju-mobile-lle.json 
     export GOOGLE_APPLICATION_CREDENTIALS="$HOME/soju-mobile-lle.json" 
     gcloud auth list 
     gcloud container clusters get-credentials mobileservices-dev-lle-usc1-1 --zone=us-central1-b --project=soju-mobile-lle 
     kubectl config set-context mobileservices-dev-lle-usc1-1 --namespace=r19-8-browse-adaptive-poc-dev 
     app_name=browse 
     namespace=r19-8-browse-adaptive-poc-dev 
     # Getting OpenAPI domain value and storing in variable 
     OAPI_DOMAIN=$(kubectl get configmap envconfig-$no --namespace=$namespace -o yaml | grep openapi.baseurl | cut -f2 -d"=" | sed "s/# OAPI//g" | sed "s/http:\/\///g" | sed 's/\\n//g') 
     WAlleT_DOMAIN=$(kubectl get configmap envconfig-$no --namespace=$namespace -o yaml | grep wallet.domain | cut -f2 -d"=" | sed "s/# OAPI//g" | sed "s/http:\/\///g" | sed "s/https:\/\///g" | sed 's/\\n//g') 
     echo "OAPI_DOMAIN --> $OAPI_DOMAIN" 
     echo "WAlleT_DOMAIN --> $WAlleT_DOMAIN" 
     # Getting Egress_LB_IP value and storing in variable 
     region=us-central1-b 
     reg=${region::${#region}-2} 
    #EGRESS_LB_IP=$(gcloud compute forwarding-rules list | grep egress-gw-service | gcloud compute forwarding-rules describe `awk '{print $1}'` --region=$reg  | grep IPAddress |  awk '{print $2}') 
     EGRESS_LB_IP=$(kubectl get svc egproxy -o=custom-columns=NAME:.spec.clusterIP --namespace=$(kubectl get ns|grep egproxy|`awk '{print $1}'`) | grep -v NAME) 
     echo "EGRESS_LB_IP --> $EGRESS_LB_IP" 
     sed -i "s/EGRESS_LB_IP/${EGRESS_LB_IP}/g" $HOME/r19-8-adaptive-poc-dev-workspace/aem-pmp-poc-browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml 
     sed -i "s/OAPI_DOMAIN/${OAPI_DOMAIN}/g" $HOME/r19-8-adaptive-poc-dev-workspace/aem-pmp-poc-browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml 
     sed -i "s/WAlleT_DOMAIN/${WAlleT_DOMAIN}/g" $HOME/r19-8-adaptive-poc-dev-workspace/aem-pmp-poc-browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml 
 fi 
 if [[ $(kubectl get deployment --namespace=$namespace -l app-name=$app_name,stage=c-3  | wc -c) -eq 0 ]]  
 then 
 	if [[ $(kubectl get deployment --namespace=$namespace -l app-name=$app_name,stage=c-2  | wc -c) -eq 0 ]] 
 	then 
 	  	if [[ $(kubectl get deployment --namespace=$namespace -l app-name=$app_name,stage=c-1  | wc -c) -eq 0 ]] 
 	  	then 
 	  		if [[ $(kubectl get deployment --namespace=$namespace -l app-name=$app_name,stage=c  | wc -c) -eq 0 ]] 
 	  		then 
 	  			if [[ $(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=true,stage=latest  | wc -c) -eq 0 ]] 
 	  			then 
                     if [[ aem-pmp-poc == *"master"* ]] 
                     then 
 	  				    kubectl apply -f $HOME/r19-8-adaptive-poc-dev-workspace/browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml 
                     else 
                         kubectl apply -f $HOME/r19-8-adaptive-poc-dev-workspace/aem-pmp-poc-browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml 
                     fi 
 					newdepname=$(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=true,stage=latest  -o json | jq '.items[] | .metadata .name' | tr -d '"') 
                     autoscale = "false" 
                     if [[ $autoscale == "true" ]] 
                     then 
                         kubectl autoscale deploy $newdepname --namespace=$namespace --cpu-percent=45 --min=1 --max=1 
                     else 
                         echo "Autoscaling Not Enabled" 
                     fi 
 				else 
 					echo "* is present, create c, deploy latest" 
                     olddepname=$(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=true,stage=latest  -o json | jq '.items[] | .metadata .name' | tr -d '"') 
                     rslist=$(kubectl get rs  --namespace=$namespace -l app-name=$app_name,isLive=true,stage=latest  -o json | jq '.items[] | .metadata .name' | tr -d '"') 
                     if [[ aem-pmp-poc == *"master"* ]] 
                     then 
 	  				    newdepname=$(kubectl apply -f $HOME/r19-8-adaptive-poc-dev-workspace/browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml -o json | jq '.metadata .name' | tr -d '"') 
                     else 
                         newdepname=$(kubectl apply -f $HOME/r19-8-adaptive-poc-dev-workspace/aem-pmp-poc-browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml -o json | jq '.metadata .name' | tr -d '"') 
                     fi 
                     autoscale="false" 
                     if [[ $autoscale == "true" ]] 
                     then 
                         kubectl autoscale deploy $newdepname --namespace=$namespace --cpu-percent=45 --min=1 --max=1 
                     else 
                         echo "Autoscaling Not Enabled" 
                     fi 
                     #count=0 
                     #while [[ $count -lt 1 ]] 
                     #do 
                     #count=$(kubectl get deploy $olddepname --namespace=$namespace -o json | jq '.status .readyReplicas' | tr -d '"') 
                     #done 
                     sleep 45 
                     kubectl patch deployment --namespace=$namespace $olddepname -p '{"metadata":{"labels":{"isLive":"false","stage":"c"}},"spec":{"selector":{"matchLabels":{"isLive":"false","stage":"c"}},"template":{"metadata":{"labels":{"isLive":"false","stage":"c"}}}}}' 
                     for replica in $rslist; do 
                         deploy=$olddepname 
                         if [[ $replica == *$deploy* ]]; then 
                             kubectl delete rs --namespace=$namespace $replica 
                         fi 
                     done 
                     kubectl scale deployment $olddepname --namespace=$namespace --replicas=0 
 				fi 
 			else 
 				echo "c is present, create c-1, deploy latest" 
                 cdepname1=$(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c  -o json | jq '.items[] | .metadata .name' | tr -d '"') 
 				kubectl patch deployment --namespace=$namespace $(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c  -o json | jq '.items[] | .metadata .name' | tr -d '"') -p '{"metadata":{"labels":{"isLive":"false","stage":"c-1"}},"spec":{"selector":{"matchLabels":{"isLive":"false","stage":"c-1"}},"template":{"metadata":{"labels":{"isLive":"false","stage":"c-1"}}}}}' 
 				kubectl delete rs --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c  
 				kubectl scale deployment $cdepname1 --namespace=$namespace --replicas=0 
                 colddepname=$(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=true,stage=latest  -o json | jq '.items[] | .metadata .name' | tr -d '"') 
                 rslist=$(kubectl get rs  --namespace=$namespace -l app-name=$app_name,isLive=true,stage=latest  -o json | jq '.items[] | .metadata .name' | tr -d '"') 
                 if [[ aem-pmp-poc == *"master"* ]] 
                 then 
                     cnewdepname=$(kubectl apply -f $HOME/r19-8-adaptive-poc-dev-workspace/browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml -o json | jq '.metadata .name ' | tr -d '"') 
                 else 
                     cnewdepname=$(kubectl apply -f $HOME/r19-8-adaptive-poc-dev-workspace/aem-pmp-poc-browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml -o json | jq '.metadata .name ' | tr -d '"') 
                 fi 
                 autoscale="false" 
                 if [[ $autoscale == "true" ]] 
                 then 
                     kubectl autoscale deploy $cnewdepname --namespace=$namespace --cpu-percent=45 --min=1 --max=1 
                 else 
                     echo "Autoscaling Not Enabled" 
                 fi 
                 #count=0 
                 #while [[ $count -lt 1 ]] 
                 #do 
                 #count=$(kubectl get deploy $colddepname --namespace=$namespace -o json | jq '.status .readyReplicas' | tr -d '"') 
                 #done 
                 sleep 45 
                 kubectl patch deployment --namespace=$namespace $colddepname -p '{"metadata":{"labels":{"isLive":"false","stage":"c"}},"spec":{"selector":{"matchLabels":{"isLive":"false","stage":"c"}},"template":{"metadata":{"labels":{"isLive":"false","stage":"c"}}}}}' 
                 for replica in $rslist; do 
                     deploy=$colddepname 
                     if [[ $replica == *$deploy* ]]; then 
                         kubectl delete rs --namespace=$namespace $replica 
                     fi 
                 done 
                 kubectl scale deployment $colddepname --namespace=$namespace --replicas=0 
 			fi 
 		else 
 			echo "c-1 is present" 
             c1depname1=$(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c-1  -o json | jq '.items[] | .metadata .name' | tr -d '"') 
 			kubectl patch deployment --namespace=$namespace $(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c-1  -o json | jq '.items[] | .metadata .name' | tr -d '"') -p '{"metadata":{"labels":{"isLive":"false","stage":"c-2"}},"spec":{"selector":{"matchLabels":{"isLive":"false","stage":"c-2"}},"template":{"metadata":{"labels":{"isLive":"false","stage":"c-2"}}}}}' 
 			kubectl delete rs --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c-1  
 			kubectl scale deployment $c1depname1 --namespace=$namespace --replicas=0 
             c1olddepname2=$(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c  -o json | jq '.items[] | .metadata .name' | tr -d '"') 
             kubectl patch deployment --namespace=$namespace $(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c  -o json | jq '.items[] | .metadata .name' | tr -d '"') -p '{"metadata":{"labels":{"isLive":"false","stage":"c-1"}},"spec":{"selector":{"matchLabels":{"isLive":"false","stage":"c-1"}},"template":{"metadata":{"labels":{"isLive":"false","stage":"c-1"}}}}}' 
 			kubectl delete rs --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c  
             kubectl scale deployment $c1olddepname2 --namespace=$namespace --replicas=0 
             c1olddepname=$(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=true,stage=latest  -o json | jq '.items[] | .metadata .name' | tr -d '"') 
             rslist=$(kubectl get rs --namespace=$namespace -l app-name=$app_name,isLive=true,stage=latest  -o json | jq '.items[] | .metadata .name' | tr -d '"') 
             if [[ aem-pmp-poc == *"master"* ]] 
             then 
                 c1newdepname=$(kubectl apply -f $HOME/r19-8-adaptive-poc-dev-workspace/browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml -o json | jq '.metadata .name' | tr -d '"') 
             else 
                 c1newdepname=$(kubectl apply -f $HOME/r19-8-adaptive-poc-dev-workspace/aem-pmp-poc-browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml -o json | jq '.metadata .name' | tr -d '"') 
             fi 
             autoscale="false" 
             if [[ $autoscale == "true" ]] 
             then 
                 kubectl autoscale deploy $c1newdepname --namespace=$namespace --cpu-percent=45 --min=1 --max=1 
             else 
                 echo "Autoscaling Not Enabled" 
             fi 
             #count=0 
             #while [[ $count -lt 1 ]] 
             #do 
             #count=$(kubectl get deploy $c1olddepname --namespace=$namespace -o json | jq '.status .readyReplicas' | tr -d '"') 
             #done 
             sleep 45 
             kubectl patch deployment --namespace=$namespace $c1olddepname -p '{"metadata":{"labels":{"isLive":"false","stage":"c"}},"spec":{"selector":{"matchLabels":{"isLive":"false","stage":"c"}},"template":{"metadata":{"labels":{"isLive":"false","stage":"c"}}}}}' 
             for replica in $rslist; do 
                 deploy=$c1olddepname 
                 if [[ $replica == *$deploy* ]]; then 
                     kubectl delete rs --namespace=$namespace $replica 
                 fi 
             done 
             kubectl scale deployment $c1olddepname --namespace=$namespace --replicas=0 
 		fi 
 	else 
 		echo "c-2 is present" 
 		c2depname1=$(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c-2  -o json | jq '.items[] | .metadata .name' | tr -d '"') 
         kubectl patch deployment --namespace=$namespace $(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c-2  -o json | jq '.items[] | .metadata .name' | tr -d '"') -p '{"metadata":{"labels":{"isLive":"false","stage":"c-3"}},"spec":{"selector":{"matchLabels":{"isLive":"false","stage":"c-3"}},"template":{"metadata":{"labels":{"isLive":"false","stage":"c-3"}}}}}' 
 		kubectl delete rs --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c-2  
         kubectl scale deployment $c2depname1 --namespace=$namespace --replicas=0 
         c2depname2=$(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c-1  -o json | jq '.items[] | .metadata .name' | tr -d '"') 
         kubectl patch deployment --namespace=$namespace $(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c-1  -o json | jq '.items[] | .metadata .name' | tr -d '"') -p '{"metadata":{"labels":{"isLive":"false","stage":"c-2"}},"spec":{"selector":{"matchLabels":{"isLive":"false","stage":"c-2"}},"template":{"metadata":{"labels":{"isLive":"false","stage":"c-2"}}}}}' 
 		kubectl delete rs --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c-1  
 		kubectl scale deployment $c2depname2 --namespace=$namespace --replicas=0 
         c2depname3=$(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c  -o json | jq '.items[] | .metadata .name' | tr -d '"') 
         kubectl patch deployment --namespace=$namespace $(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c  -o json | jq '.items[] | .metadata .name' | tr -d '"') -p '{"metadata":{"labels":{"isLive":"false","stage":"c-1"}},"spec":{"selector":{"matchLabels":{"isLive":"false","stage":"c-1"}},"template":{"metadata":{"labels":{"isLive":"false","stage":"c-1"}}}}}' 
 		kubectl delete rs --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c  
 		kubectl scale deployment $c2depname3 --namespace=$namespace --replicas=0 
         c2olddepname=$(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=true,stage=latest  -o json | jq '.items[] | .metadata .name' | tr -d '"') 
         rslist=$(kubectl get rs --namespace=$namespace -l app-name=$app_name,isLive=true,stage=latest  -o json | jq '.items[] | .metadata .name' | tr -d '"') 
         if [[ aem-pmp-poc == *"master"* ]] 
         then 
             c2newdepname=$(kubectl apply -f $HOME/r19-8-adaptive-poc-dev-workspace/browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml -o json | jq '.metadata .name' | tr -d '"') 
         else 
             c2newdepname=$(kubectl apply -f $HOME/r19-8-adaptive-poc-dev-workspace/aem-pmp-poc-browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml -o json | jq '.metadata .name' | tr -d '"') 
         fi 
         autoscale="false" 
         if [[ $autoscale == "true" ]] 
         then 
             kubectl autoscale deploy $c2newdepname --namespace=$namespace --cpu-percent=45 --min=1 --max=1 
         else 
             echo "Autoscaling Not Enabled" 
         fi 
         #count=0 
         #while [[ $count -lt 1 ]] 
         #do 
         #count=$(kubectl get deploy $c2olddepname --namespace=$namespace -o json | jq '.status .readyReplicas' | tr -d '"') 
         #done 
         sleep 45 
         kubectl patch deployment --namespace=$namespace $c2olddepname -p '{"metadata":{"labels":{"isLive":"false","stage":"c"}},"spec":{"selector":{"matchLabels":{"isLive":"false","stage":"c"}},"template":{"metadata":{"labels":{"isLive":"false","stage":"c"}}}}}' 
         for replica in $rslist; do 
             deploy=$c2olddepname 
             if [[ $replica == *$deploy* ]]; then 
                 kubectl delete rs --namespace=$namespace $replica 
             fi 
         done 
         kubectl scale deployment $c2olddepname --namespace=$namespace --replicas=0 
 	fi 
 else 
 	echo "c-3 is present, need to delete it" 
     c_3dep=$(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c-3  -o json | jq '.items[] | .metadata .name' | tr -d '"') 
 	kubectl delete deployments --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c-3  
     kubectl delete hpa $c_3dep --namespace=$namespace 
     c3depname1=$(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c-2  -o json | jq '.items[] | .metadata .name' | tr -d '"') 
 	kubectl patch deployment --namespace=$namespace $(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c-2  -o json | jq '.items[] | .metadata .name' | tr -d '"') -p '{"metadata":{"labels":{"isLive":"false","stage":"c-3"}},"spec":{"selector":{"matchLabels":{"isLive":"false","stage":"c-3"}},"template":{"metadata":{"labels":{"isLive":"false","stage":"c-3"}}}}}' 
 	kubectl delete rs --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c-2  
 	kubectl scale deployment $c3depname1 --namespace=$namespace --replicas=0 
     c3depname2=$(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c-1  -o json | jq '.items[] | .metadata .name' | tr -d '"') 
     kubectl patch deployment --namespace=$namespace $(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c-1  -o json | jq '.items[] | .metadata .name' | tr -d '"') -p '{"metadata":{"labels":{"isLive":"false","stage":"c-2"}},"spec":{"selector":{"matchLabels":{"isLive":"false","stage":"c-2"}},"template":{"metadata":{"labels":{"isLive":"false","stage":"c-2"}}}}}' 
 	kubectl delete rs --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c-1  
 	kubectl scale deployment $c3depname2 --namespace=$namespace --replicas=0 
     c3depname3=$(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c  -o json | jq '.items[] | .metadata .name' | tr -d '"') 
     kubectl patch deployment --namespace=$namespace $(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c  -o json | jq '.items[] | .metadata .name' | tr -d '"') -p '{"metadata":{"labels":{"isLive":"false","stage":"c-1"}},"spec":{"selector":{"matchLabels":{"isLive":"false","stage":"c-1"}},"template":{"metadata":{"labels":{"isLive":"false","stage":"c-1"}}}}}' 
 	kubectl delete rs --namespace=$namespace -l app-name=$app_name,isLive=false,stage=c  
 	kubectl scale deployment $c3depname3 --namespace=$namespace --replicas=0 
     c3olddepname=$(kubectl get deployment --namespace=$namespace -l app-name=$app_name,isLive=true,stage=latest  -o json | jq '.items[] | .metadata .name' | tr -d '"') 
 	rslist=$(kubectl get rs --namespace=$namespace -l app-name=$app_name,isLive=true,stage=latest  -o json | jq '.items[] | .metadata .name' | tr -d '"') 
     if [[ aem-pmp-poc == *"master"* ]] 
     then 
         c3newdepname=$(kubectl apply -f $HOME/r19-8-adaptive-poc-dev-workspace/browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml -o json | jq '.metadata .name' | tr -d '"')  
     else 
         c3newdepname=$(kubectl apply -f $HOME/r19-8-adaptive-poc-dev-workspace/aem-pmp-poc-browse-lle-dev-r19-8-browse-adaptive-poc-dev-deployment.yaml -o json | jq '.metadata .name' | tr -d '"')  
     fi 
     autoscale="false" 
     if [[ $autoscale == "true" ]] 
     then 
         kubectl autoscale deploy $c3newdepname --namespace=$namespace --cpu-percent=45 --min=1 --max=1 
     else 
         echo "Autoscaling Not Enabled" 
     fi 
     #count=0 
     #while [[ $count -lt 1 ]] 
     #do 
     #count=$(kubectl get deploy $c3olddepname --namespace=$namespace -o json | jq '.status .readyReplicas' | tr -d '"') 
     #done 
     sleep 45 
     kubectl patch deployment --namespace=$namespace $c3olddepname -p '{"metadata":{"labels":{"isLive":"false","stage":"c"}},"spec":{"selector":{"matchLabels":{"isLive":"false","stage":"c"}},"template":{"metadata":{"labels":{"isLive":"false","stage":"c"}}}}}' 
     for replica in $rslist; do 
         deploy=$c3olddepname 
         if [[ $replica == *$deploy* ]]; then 
             kubectl delete rs --namespace=$namespace $replica 
         fi 
     done 
     kubectl scale deployment $c3olddepname --namespace=$namespace --replicas=0  
 fi 
 kubectl patch service browse --namespace=$namespace -p '{"spec":{"selector":{"version": "R19_8_'$no'"}}}'