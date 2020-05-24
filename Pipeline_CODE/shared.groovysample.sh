@Library('cx-shared-libraries@master')_
import org.k9.*

//Global Parameters
String buildNo = "${env.BUILD_NUMBER}"

//Name Spaces
String appNamespace = "cx-stores-test-kdcs"
String imageNamespace = "cx-stores-test-kdcs"
String buildNameSpace = "cx-management-lle"
//String qaNameSpace = "cx-stores-ppd-qa"


String APP_RELEASE_VERSION = "R19_4"
//App Configs
String appName = "kdcs"
String project = "kdcs"
String env = "dev"
String channel = "stores"
String cloudProvider = "openshift"

//DevOps Repo
String cicdRepo = "git@github.soju.com:Mobile/cx-os-cicd.git"
String cicdBranch = "CXDEV-1676"

//Github Configs
String scmUrl = "git@github.soju.com:StoresEngineering/soju-soju-Device-Configuration-Service"
String scmBranch = "CXDEV-1676"
String credentialID = "ef8b2b3a-ffa7-4043-890c-73adf6666602"

//Build Config parameters
String contextDir = "${project}/${appName}"--??
String imageStream = "${appName}:${scmBranch}-${buildNo}"1
String outputImage = "docker-registry.default.svc:5000/${imageNamespace}/${imageStream}"
String dockerSCMUrl = "git@github.soju.com:Mobile/cx-os-infra.git"
String dockerSCMBranch = "CXDEV-1676"
String baseImage = "docker-registry.default.svc:5000/k-images/k-rhel7-base:latest"
String ndArtifactUrl = "${NEXUS_URL}/nexus/content/repositories/snapshots/com/soju/mobile/cmon"--??
String ndFileName = "netdiagnostics.4.1.12.42.tar.gz"

//Artifact Storage parameters
String artifactsType = "zip"
String artifactFile = "${appName}-${scmBranch}-${buildNo}.${artifactsType}"
String artifactUrl = "${NEXUS_URL}/nexus/content/repositories/snapshots/com/soju/${channel}/${project}/service/${env}"

//Maven parameters
String globalsettingsID = "7318cf0a-32fc-4625-b38e-a04e5ceccf9f"
String globalsettingName = "MyGlobalSettings"
String userParam = ""
String mvnTestCase = true
String customMvn = "mvn clean install -Dmaven.test.skip=true"

//AppConfig
//String configAppPath = 'store-service-api/src/main/resources'
String configAppPath = 'freight-service-api/target/classes/'--??
String configEnvPath = 'openshift/planning-productivity-dashboard/configs/endpoints'
String configSecretPath = 'openshift/planning-productivity-dashboard/configs/credentials'

//App Deployment Config
String podCpuLimit = "500m"
String podMemoryLimit = "1500Mi"
String podCpuRequest = "150m"
String podMemoryRequest = "750Mi"
String appPort = "5000"
String appReplicaSet = "1"
String appDeploymentStrategy = "Rolling"
String appConfigPath = "/soju/config/application/"
String envConfigPath = "/soju/config/environment/"
String secretConfigPath = "/soju/config/secrets/"
String appConfigFilePath = "/soju/config/application/application.properties"
String envConfigFilePath = "/soju/config/environment/environment.properties"
String secretConfigFilePath = "/soju/config/secrets/secret.properties"
String certPath = "/soju/config/certs/"
String jwsCertPath = "/soju/config/certs/jwt/"
String log4jPath = "/soju/config/application/log4j2.xml"
String typeOfService = "api"
String buildStrategy = "git"
String startupScript = "export http_proxy=http://proxy-gcp-central.soju.com:8080"

pipeline {
    agent {
        label 'SLAVE-02'
    }
    environment {
        CLUSTER_DOMAIN = "${NEW_LLE_CENTRAL_CLUSTER_URL}"
        CLUSTER_TOKEN = "NEW_LLE_CENTRAL_CLUSTER_TOKEN"
        CLUSTER_DSL = "${NEW_LLE_CENTRAL_CLUSTER_CONFIGNAME}"--??
    }
    stages {
        stage('Workspace Cleanup'){--??
            steps {
                deleteDir()
            }
        }
        stage('Git Initiation') {
            steps {
                script {
                    param = [
                        scm_url: "${scmUrl}",
                        scm_branch: "${scmBranch}",
                        credentialID: "${credentialID}"
                    ]
                    sourceBranch = new scm.Git(this,param).gitClone()
                }
            }
        }
        stage('DotNet Build') {
            steps {
                    script {
                        sh '''
                            pwd
                            mkdir -p target
                            dotnet restore --configfile nuget.config --ignore-failed-sources --verbosity d --source //nwc00888.cp.ad.soju.com/Packages
                            dotnet build --configfile nuget.config --ignore-failed-sources --verbosity d --source //nwc00888.cp.ad.soju.com/Packages
                            dotnet publish --configuration Release --output test2/ --framework netcoreapp2.2 --no-restore
                            zip -r target/art-test.zip soju.Device.Configuration.Service/
                            ls -ltr
                        '''
                }
            }
        }
        stage('Nexus Upload') {
            steps {
                    script {
                        param = [
                            nexus_user: "${NEXUS_USER}",
                            nexus_pass: "${NEXUS_PASSWORD}",
                            artifacts_file: "${artifactFile}",
                            artifacts_url: "${artifactUrl}",
                            artifacts_type: "${artifactsType}",
                            targetPath: "target"
                        ]
                        new storage.ArtifactStorage(this,param).upload()
                }
            }
        }
        stage('BuildConfig') {
            steps {
                    script {
                        param = [
                            buildNameSpace: "${buildNameSpace}",
                            buildStrategy: "${buildStrategy}",
                            buildAppName: "${appName}",
                            buildContextDir: "${contextDir}",
                            buildOutputImage: "${outputImage}",
                            buildArtifactUrl: "${artifactUrl}",
                            buildArtifactFile: "${artifactFile}",
                            buildDockerSCMUrl: "${dockerSCMUrl}",
                            buildDockerSCMBranch: "${dockerSCMBranch}",
                            buildBaseImage: "${baseImage}",
                            buildChannel: "${channel}",
                            buildArtifactsType: "${artifactsType}",
                            cluster: "${CLUSTER_DOMAIN}",
                            buildNDArtifactURL: "${ndArtifactUrl}",
                            buildNDFileName: "${ndFileName}",
                            nameSpace: "${buildNameSpace}"
                        ]
                        new openshift.BuildConfig(this, param).buildFromTemplate()--??
                }
            }
        }
        stage('Application Deployment') {
            steps {
                    script {
                        param = [
                            cicdBranch: "${cicdBranch}",
                            env: "${env}",
                            appName: "${appName}", 
                            typeOfService: "${typeOfService}",
                            nameSpace: "${appNamespace}",
                            cluster: "${CLUSTER_DOMAIN}",
                            openshift: true,
                            buildNo: "${buildNo}",
                            imageStream: "${imageStream}",
                            properties: [
                                appPort: "${appPort}", 
                                appName: "${appName}", 
                                appDeploymentStrategy: "${appDeploymentStrategy}", 
                                appReplicaSet: "${appReplicaSet}", 
                                cmdArg: "${startupScript}", 
                                sourceBranch: "${sourceBranch}"
                            ],
                            services: [
                                deploymentConfig: true, 
                                serviceConfig: true, 
                                routeConfig: true, 
                                imageStream: false,
                                hpa: false
                            ],
                            pods: [
                                http: "${appPort}-TCP"
                            ],
                            label: [
                                app: "${appName}",
                                buildno: "${buildNo}",
                                datetime: "${globalConfig.common.currentDate}",
                                releaseVersion: "${APP_RELEASE_VERSION}",
                                appBranch: "${sourceBranch}",
                                environment: "${env}",
                                tier: 'backend',
                                release: 'blue-green',
                                imageRelease: "${appName}-${scmBranch}-${buildNo}"
                            ],
                            resource: [
                                cpuLimit: "${podCpuLimit}", 
                                memoryLimit: "${podMemoryLimit}", 
                                cpuRequest:"${podCpuRequest}", 
                                memoryRequest:"${podMemoryRequest}"
                            ]
                        ]
                        new openshift.AppDeployment(this, param).deployApp()
                }
            }
        }
    }
}
