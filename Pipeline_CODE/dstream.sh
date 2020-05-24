#!/bin/bash

####################Archiving the jar file#################################

#cp -R ${WORKSPACE}/sparkStructuredStreaming/target/scala-2.11/sparkStructuredStreaming-assembly-0.1.jar /home/mdop-admin/jenkins-atrifact-archives/scala/scala-spark-standalone/spark-structured-streaming/gke-metrics-structured-streaming/${build}.jar

####################Building Docker image and pushing to GCR##############

status=`systemctl status docker | grep Active  | awk '{print $2}' `

if [ "$status" != "active" ]
then
   sudo systemctl start docker
   sudo chmod 777 /var/run/docker.sock
else
   echo "docker already started"
fi

cp -R ${WORKSPACE}/kstream/mongoIngestion/target/scala-2.11/mongoIngestion-assembly-0.1.jar ${WORKSPACE}/dockerfiles/dstreams/

cd ${WORKSPACE}/dockerfiles/dstreams

docker build -t ${build} .

docker tag ${build} us.gcr.io/soju-mobile-lle/aidi/spark/${build}

gcloud auth configure-docker

docker push us.gcr.io/soju-mobile-lle/aidi/spark/${build}

docker rmi -f ${build}

docker rmi -f us.gcr.io/soju-mobile-lle/aidi/spark/${build}

################# to deploy into k8s cluster #############################

cd ${WORKSPACE}/yamls/dstreams/

a=`grep image gke-dstreams.yaml | awk '{print $2}' | cut -d "/" -f5`

#echo ${a}

sed -i "s/$a/${build}/g" gke-dstreams.yaml

b=`grep MONGOIP env-cm.yaml | awk '{print $2}'`

sed -i "s/$b/${mongoips}/g" env-cm.yaml

c=`grep USERNAME: secret.yaml | awk '{print $2}'`

sed -i "s/$c/${mongouser}/g" secret.yaml

d=`grep PASSWORD: secret.yaml | awk '{print $2}'`

sed -i "s/$d/${mongopassword}/g" secret.yaml

e=`grep KAFKA_OUTPUT_TOPIC: env-cm.yaml | awk '{print $2}'`

sed -i "s/$e/${kafkaoutputtopic}/g" env-cm.yaml

#s=`grep KAFKA_SERVER: env-cm.yaml | awk '{print $2}'`

#sed -i "s/$s/${kafka-server}/g" env-cm.yaml

i=`grep DATABASE: env-cm.yaml | awk '{print $2}'`

sed -i "s/$i/${databasename}/g" env-cm.yaml

j=`grep  COLLECTION: env-cm.yaml | awk '{print $2}'`

sed -i "s/$i/${collectionname}" env-cm.yaml

gcloud container clusters get-credentials ${Cluster} --project soju-mobile-lle

kubectl get ns | grep ${Namespace}

if [ $? -ne 0 ]

then

kubectl create ns ${Namespace}

else

echo "namespace ${Namespace} is already created"

fi

kubectl apply -f env-cm.yaml -n ${Namespace}

kubectl apply -f secret.yaml -n ${Namespace}

kubectl apply -f gke-dstreams.yaml -n ${Namespace}

kubect apply -f dstream-svc.yaml -n ${Namespace}
