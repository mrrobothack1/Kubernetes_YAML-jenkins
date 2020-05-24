status=`systemctl status docker | grep Active  | awk '{print $2}' `

if [ "$status" != "active" ]
 then
    sudo systemctl start docker
    sudo chmod 777 /var/run/docker.sock
 else
   echo "docker already started"
fi

################################## to deploy NIFI into k8s cluster ##############################################
cd ${WORKSPACE}/Yamls/nifi
gcloud container clusters get-credentials ${Cluster} --project soju-mobile-lle
a=kubectl get ns | grep ${Namespace-nifi}|awk '{print $1}'
 echo $a
#if [ "$?" -ne 0 ]
if [ -z "$a" ]
 then
   kubectl create ns ${Namespace-nifi}
 else
   echo "namespace ${Namespace-nifi} is already created"
fi

 kubectl apply -f nifi-deploy.yaml -n ${Namespace-nifi}
 kubectl apply -f nifi-svc.yaml -n ${Namespace-nifi}
 kubectl apply -f nifi-lb.yaml -n ${Namespace-nifi}
 sleep 60s

###################to failsafe k8s cluster#################################
 kubectl get deploy -n ${Namespace-nifi} --no-headers| awk '$5!=0' | awk '{print $2}' > deploy.txt

for deploy in deploy.txt
 do
  deploy_name=kubectl describe deploy -n $Namespace-nifi --no-headers| awk '$5!=0' | awk '{print $2}'
  echo "status is $deploy_name"
done

if [ "$deploy" != 1/1 ]
  then
   /usr/local/bin/kubectl rollout history deployments  -n ${Namespace-nifi}
   /usr/local/bin/kubectl rollout undo deployments --to-revision=1 -n ${Namespace-nifi}
  else
    echo "deployment is up and running "
fi

################################## to deploy ZK into k8s cluster ##############################################

cd ${WORKSPACE}/Yamls/zk
gcloud container clusters get-credentials ${Cluster} --project soju-mobile-lle
a=kubectl get ns | grep ${Namespace-zk}|awk '{print $1}'
 echo $a
if [ -z "$a" ]
#if [ $? -ne 0 ]
 then
   kubectl create ns ${Namespace-zk}
 else
   echo "namespace ${Namespace-zk} is already created"
fi
   /usr/local/bin/kubectl apply -f zk-deploy.yaml -n ${Namespace-zk}
   /usr/local/bin/kubectl apply -f zk-svc.yaml -n ${Namespace-zk}
   /usr/local/bin/kubectl apply -f zk-env.yaml -n ${Namespace-zk}


###################to failsafe k8s cluster#################################
kubectl get deploy -n ${Namespace-zk} --no-headers| awk '$5!=0' | awk '{print $2}' > deploy.txt

for deploy in deploy.txt
 do
    deploy_name=kubectl describe deploy -n $Namespace-zk --no-headers| awk '$5!=0' | awk '{print $2}'
    echo "status is $deploy_name"
 done

if [ "$deploy" != 1/1 ]
 then
     /usr/local/bin/kubectl rollout history deployments  -n ${Namespace-zk}
     /usr/local/bin/kubectl rollout undo deployments --to-revision=1 -n ${Namespace-zk}
 else
     echo "deployment is up and running "
fi


######################################### to deploy kafka into k8s cluster #############################################
cd ${WORKSPACE}/Yamls/kafka
#e=`grep -A1 KAFKA_ZOOKEEPER_CONNECT: kafka-stateful.yaml | awk '{print $2}'`
e=`grep -A1 "KAFKA_ZOOKEEPER_CONNECT" kafka-stateful.yaml | grep value | sed 's/.*value: //'`
sed -i "s/$e/${zookeeper-connect}/g" kafka-stateful.yaml
gcloud container clusters get-credentials ${Cluster} --project soju-mobile-lle
a=kubectl get ns | grep ${Namespace-kafka}|awk '{print $1}'
 echo $a
if [ -z "$a" ]
#if [ $? -ne 0 ]
then
  kubectl create ns ${Namespace-kafka}
else
  echo "namespace ${Namespace-kafka} is already created"
fi

kubectl apply -f kafka-stateful.yaml -n ${Namespace-kafka}
kubectl apply -f kafka-svc.yaml -n ${Namespace}
sleep 60s

###################to failsafe k8s cluster#################################
kubectl get deploy -n ${Namespace-kafka} --no-headers| awk '$5!=0' | awk '{print $2}' > deploy.txt

for deploy in deploy.txt
do
  deploy_name=kubectl describe deploy -n $Namespace-kafka --no-headers| awk '$5!=0' | awk '{print $2}'
  echo "status is $deploy_name"
done

if [ "$deploy" != 1/1 ]
 then
   /usr/local/bin/kubectl rollout history deployments  -n ${Namespace-kafka}
   /usr/local/bin/kubectl rollout undo deployments --to-revision=1 -n ${Namespace-kafka}
 else
   echo "deployment is up and running "
fi


######################################### to deploy kstreams into k8s cluster #############################################

cp -R ${WORKSPACE}/kstream/kstreams_joins/target/scala-2.11/KStreams-assembly-0.1.jar ${WORKSPACE}/Dockerfiles/kstreams/
cd ${WORKSPACE}/Dockerfiles/kstreams

docker build -t ${build} .
docker tag ${build} us.gcr.io/soju-mobile-lle/aidi-nonistio/${build}
gcloud auth configure-docker #authication with google container registry
echo "docker push us.gcr.io/soju-mobile-lle/aidi-nonistio/${build}"
docker push us.gcr.io/soju-mobile-lle/aidi-nonistio/${build}

################# to deploy into k8s cluster #############################
cd ${WORKSPACE}/Yamls/kstreams/

a=`grep image kstreams.yaml | awk '{print $2}' | cut -d "/" -f4`
sed -i "s/$a/${build}/g" kstreams.yaml

e=`grep KAFKA_TOPIC_POD: kstreams-env.yaml | awk '{print $2}'`
sed -i "s/$e/${topicpod}/g" kstreams-env.yaml

f=`grep KAFKA_TOPIC_PROJECT: kstreams-env.yaml | awk '{print $2}'`
sed -i "s/$f/${topicproject}/g" kstreams-env.yaml

g=`grep KAFKA_TOPIC_SERVICE: kstreams-env.yaml | awk '{print $2}'`
sed -i "s/$g/${topicservice}/g" kstreams-env.yaml

h=`grep KAFKA_TOPIC_RPS: kstreams-env.yaml | awk '{print $2}'`
sed -i "s/$h/${topicrps}/g" kstreams-env.yaml

j=`grep KAFKA_TOPIC_HEAP: kstreams-env.yaml | awk '{print $2}'`
sed -i "s/$j/${topicheap}/g" kstreams-env.yaml

k=`grep KAFKA_OUTPUT_TOPIC: kstreams-env.yaml | awk '{print $2}'`
sed -i "s/$k/${topicoutput}/g" kstreams-env.yaml

gcloud container clusters get-credentials ${Cluster} --project soju-mobile-lle
/usr/local/bin/kubectl get ns | grep ${Namespace-kstreams}
if [ $? -ne 0 ]
then
   /usr/local/bin/kubectl create ns ${Namespace-kstreams}
else
   echo "namespace ${Namespace-kstreams} already created"
fi
/usr/local/bin/kubectl apply -f kstreams-env.yaml -n ${Namespace-kstreams}
/usr/local/bin/kubectl apply -f kstreams.yaml -n ${Namespace-kstreams}
sleep 60s

###################to failsafe k8s cluster#################################

kubectl get deploy -n ${Namespace-kstreams} --no-headers| awk '$5!=0' | awk '{print $2}' > deploy.txt

for deploy in deploy.txt
do
  deploy_name=kubectl describe deploy -n $Namespace-kstreams --no-headers| awk '$5!=0' | awk '{print $2}'
  echo "status is $deploy_name"
done

if [ "$deploy" != 1/1 ]
 then
    /usr/local/bin/kubectl rollout history deployments  -n ${Namespace-kstreams}
    /usr/local/bin/kubectl rollout undo deployments --to-revision=1 -n ${Namespace-kstreams}
 else
    echo "deployment is up and running "
fi


######################################### to deploy dstreams into k8s cluster #############################################

cp -R ${WORKSPACE}/kstream/mongoIngestion/target/scala-2.11/mongoIngestion-assembly-0.1.jar ${WORKSPACE}/Dockerfiles/dstreams/
cd ${WORKSPACE}/Dockerfiles/dstreams
docker build -t ${build} .
docker tag ${build} us.gcr.io/soju-mobile-lle/aidi-nonistio/spark/${build}
gcloud auth configure-docker
docker push us.gcr.io/soju-mobile-lle/aidi-nonistio/spark/${build}

docker rmi -f ${build}
docker rmi -f us.gcr.io/soju-mobile-lle/aidi-nonistio/spark/${build}

################# to deploy into k8s cluster #############################
cd ${WORKSPACE}/Yamls/dstreams/

a=`grep image gke-dstreams.yaml | awk '{print $2}' | cut -d "/" -f5`
echo ${a}
sed -i "s/$a/${build}/g" gke-dstreams.yaml

b=`grep MONGOIP env-cm.yaml | awk '{print $2}'`
echo ${b}
sed -i "s/$b/${mongoips}/g" env-cm.yaml

c=`grep USERNAME: secret.yaml | awk '{print $2}'`
echo ${c}
sed -i "s/$c/${mongouser}/g" secret.yaml

d=`grep PASSWORD: secret.yaml | awk '{print $2}'`
echo ${d}
sed -i "s/$d/${mongopassword}/g" secret.yaml

e=`grep KAFKA_OUTPUT_TOPIC: env-cm.yaml | awk '{print $2}'`
echo ${e}
sed -i "s/$e/${kafkaoutputtopic}/g" env-cm.yaml

i=`grep DATABASE: env-cm.yaml | awk '{print $2}'`
echo ${i}
sed -i "s/$i/${databasename}/g" env-cm.yaml

j=`grep  COLLECTION: env-cm.yaml | awk '{print $2}'`
echo ${j}
sed -i "s/$i/${collectionname}/g" env-cm.yaml

gcloud container clusters get-credentials ${Cluster} --project soju-mobile-lle
/usr/local/bin/kubectl get ns | grep ${Namespace-dstreams}

if [ $? -ne 0 ]
then
  /usr/local/bin/kubectl create ns ${Namespace-dstreams}
else
  echo "namespace ${Namespace-dstreams} already created"
fi

/usr/local/bin/kubectl apply -f gke-dstreams.yaml -n ${Namespace-dstreams}
/usr/local/bin/kubectl apply -f secret.yaml -n ${Namespace-dstreams}
sleep 60s

###################to failsafe k8s cluster#################################

kubectl get deploy -n ${Namespace-dstreams} --no-headers| awk '$5!=0' | awk '{print $2}' > deploy.txt

for deploy in deploy.txt
do
  deploy_name=kubectl describe deploy -n $Namespace-dstreams --no-headers| awk '$5!=0' | awk '{print $2}'
  echo "status is $deploy_name"
done

if [ "$deploy" != 1/1 ]
 then
   /usr/local/bin/kubectl rollout history deployments  -n ${Namespace-dstreams}
   /usr/local/bin/kubectl rollout undo deployments --to-revision=1 -n ${Namespace-dstreams}
 else
   echo "deployment is up and running "
fi
