#!/bin/bash

####################Building Docker image and pushing to GCR###############

cd ${WORKSPACE}/prom_svc_heap_metrics
echo ${WORKSPACE}
status=`systemctl status docker | grep Active  | awk '{print $2}' `

if [ "$status" != "active" ]
then
   sudo systemctl start docker
   sudo chmod 777 /var/run/docker.sock
else
   echo "docker already started"
fi

make docker
docker tag aidigke:latest us.gcr.io/soju-mobile-lle/aidi/go/gke_metrics_go-puller/aidigke:v${BUILD_NUMBER}
gcloud auth configure-docker #authication with google container registry
docker push us.gcr.io/soju-mobile-lle/aidi/go/gke_metrics_go-puller/aidigke:v${BUILD_NUMBER}

#docker rmi -f aidigke:latest
#docker rmi -f us.gcr.io/soju-mobile-lle/aidi/go/gke_metrics_go-puller/aidigke:v${BUILD_NUMBER}
#docker rmi $(docker images --quiet --filter "dangling=true")

###################to deploy into k8s cluster#################################

cd ${WORKSPACE}/Yamls/AIDI-PIPELINE

a=`grep us.gcr istio-metrics-puller.yaml | awk '{print $2}' | cut -d "/" -f6`
sed -i "s/$a/${build}/g" istio-metrics-puller.yaml

b=`grep MONGOIP: config-map.yaml | awk '{print $2}'`
sed -i "s/$b/${mongoip}/g" config-map.yaml

e=`grep DATABASE: config-map.yaml | awk '{print $2}'`
sed -i "s/$e/${database}/g" config-map.yaml

f=`grep CLUSTER_NAME: config-map.yaml | awk '{print $2}'`
sed -i "s/$f/${clustername}/g" config-map.yaml

g=`grep PROJECT_NAME: config-map.yaml | awk '{print $2}'`
sed -i "s/$g/${projectname}/g" config-map.yaml

h=`grep PROJECT_ID: config-map.yaml | awk '{print $2}'`
sed -i "s/$h/${projectid}/g" config-map.yaml

c=`grep USERNAME: secret.yaml | awk '{print $2}'`
sed -i "s/$c/${usernameinflux}/g" secret.yaml

d=`grep PASSWORD: secret.yaml | awk '{print $2}'`
sed -i "s/$d/${passwordinflux}/g" secret.yaml

gcloud container clusters get-credentials ${Cluster} --project soju-mobile-lle
/usr/local/bin/kubectl get ns | grep ${Namespace}

if [ $? -ne 0 ]
then
/usr/local/bin/kubectl create ns ${Namespace}
else
echo "namespace ${Namespace} already created"
fi

/usr/local/bin/kubectl apply -f config-map.yaml -n ${Namespace}
/usr/local/bin/kubectl apply -f secret.yaml -n ${Namespace}
/usr/local/bin/kubectl apply -f go-puller.yaml -n ${Namespace} --record
/usr/local/bin/kubectl apply -f aidi-components.yaml -n ${Namespace}

sleep 60s

###################to failsafe k8s cluster#################################
for $Namespace
do
  deploy=kubectl describe deploy -n $ns --no-headers| awk '$5!=0' | awk '{print $1}'
echo "status is $deploy"
done

if [ "$deploy" != 1/1 ]
 then
/usr/local/bin/kubectl rollout history deployments  -n ${Namespace}
/usr/local/bin/kubectl rollout undo deployments --to-revision=1 -n ${Namespace}
 else
   echo "deployment is up and running "
fi
