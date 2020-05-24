
node: {
stage 'application'

build job: 'nifi',
parameters: [
string(name: 'Cluster', value: cluster),
string(name: 'namespace-nifi', value: namespace-nifi)
]

build job: 'zk',
parameters: [
string(name: 'Cluster', value: cluster),
string(name: 'namespace-zk', value: namespace-zk)
]

build job: 'kafka',
parameters: [
string(name: 'KAFKA_ZOOKEEPER_CONNECT', value: kafka_zookeeper_connect),
string(name: 'Cluster', value: cluster)
string(name: 'namespace-kafka', value: namespace-kafka)
]

build job: 'k-stream',
parameters: [
string(name: 'topicpod', value: Topicpod),
string(name: 'topicproject', value: Topicproject)
string(name: 'topicservice', value: Topicservice)
string(name: 'topicrps', value: Topicrps)
string(name: 'topicheap', value: Topicheap)
string(name: 'topicoutput', value: Topicoutput)
string(name: 'Cluster', value: cluster),
string(name: 'namespace-kstreams', value: Namespace-kstreams),
]

build job: 'd-stream',
parameters: [
string(name: 'mongoips', value: Mongoips),
string(name: 'mongouser', value: Mongouser)
string(name: 'mongopassword', value: Mongopassword)
string(name: 'kafkaoutputtopic', value: Kafkaoutputtopic)
string(name: 'databasename', value: Databasename)
string(name: 'collectionname', value: Collectionname)
string(name: 'cluster', value: Cluster)
string(name: 'namespace-dstreams', value: Namespace-dstreams)
]


}
