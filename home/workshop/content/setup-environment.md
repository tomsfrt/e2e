Welcome to the Tanzu End to End demo!  In this session, we'll be exploring some of the various capabilitites of Tanzu.

We're going to be using Tanzu to deploy an application, deploy dependent services for that application, observe the metrics for that application and supporting infrastructure, and manage the cluster hosting that application.

# Fork Spring Pet Clinic
To get started, you need to clone Spring Pet Clinic to you can make some changes to it as part of the demo process.  Click the icon in the upper right of the box below to open a new browser tab so that you can fork the Spring Pet Clinic repo into your Github account.
```dashboard:open-url
url: https://github.com/tanzu-end-to-end/spring-petclinic/fork
```
After forking, navigate to the `/src/main/resources/messages/messages.properties` file in your forked repo.  We want to pre-stage this tab so that you are ready to make an edit to this file to trigger a build later on.

# Access vSphere Client Console
```dashboard:open-url
url: https://pacific-vcsa.haas-432.pez.vmware.com/ui
```

# Access NSX-T Managment Console
```dashboard:open-url
url: https://pacific-nsx-ua.haas-432.pez.vmware.com/nsx
```

# Access KubeApps
We'll be logging into KubeApps next.  To do that, we'll need to grab our user token to use to login.  Copy your user token below to use to login to kubeapps in the next step.
```workshop:copy
text: {{ user_token }}
```

Now, click the following link to open a new tab to Kubeapps pointing to a DB deployment that was created for you when you launched this environment. In the login screen, paste your token into the text field, and click "Login".  
```dashboard:open-url
url: https://kubeapps.{{ ingress_domain }}/#/c/default/ns/{{ session_namespace }}/apps
```
You should see a MySQL Deployment called `petclinic-db`.  It may still be starting when you first examine it, but it should go to 1 pod active fairly quickly.  Leave this view on the "Apps" tab so it is staged properly.

# Harbor
Next, click the link below and login to Harbor with the user "admin" and password "{{ ENV_HARBOR_PASSWORD }}".  If you login and aren't redirected to your project, then simply close the Harbor tab that was opened, and reopen it with the link below.
```dashboard:open-url
url: https://harbor.e2e.tsfrt.info/harbor/projects/{{ harbor_project_id }}/repositories
```

# Enterprise Observability
```dashboard:open-url
url: https://grafana.e2e.haas-432.pez.vmware.com
```

# Concourse
When your session was created, we logged into Concourse and added your pipeline.  Since you need to point to your fork of Spring Pet Clinic, we need to create some secrets for your Concourse pipeline.  You will need to paste the url for your PetClinic fork into the terminal prompt after clicking the box below.
```terminal:execute
command: |-
  read -p "Enter the Git URL of your fork of Pet Clinic: " PETCLINIC_GIT_URL; \
  ytt -f pipeline/secrets.yaml -f pipeline/values.yaml \
  --data-value commonSecrets.harborDomain=harbor.e2e.tsfrt.info \
  --data-value commonSecrets.kubeconfigBuildServer=$(yq d ~/.kube/config 'clusters[0].cluster.certificate-authority' | yq w - 'clusters[0].cluster.certificate-authority-data' "$(cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt | base64 -w 0)" | yq r - -j) \
  --data-value commonSecrets.kubeconfigAppServer=$(yq d ~/.kube/config 'clusters[0].cluster.certificate-authority' | yq w - 'clusters[0].cluster.certificate-authority-data' "$(cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt | base64 -w 0)" | yq r - -j) \
  --data-value commonSecrets.concourseHelperImage=harbor.e2e.tsfrt.info/concourse/concourse-helper \
  --data-value petclinic.wavefront.deployEventName=petclinic-deploy \
  --data-value petclinic.configRepo=https://github.com/tanzu-end-to-end/spring-petclinic-config \
  --data-value petclinic.host=petclinic-{{ session_namespace }}.{{ ingress_domain }} \
  --data-value petclinic.image=harbor.e2e.tsfrt.info/{{ session_namespace }}/spring-petclinic \
  --data-value petclinic.tbs.namespace={{ session_namespace }} \
  --data-value petclinic.wavefront.applicationName=petclinic-{{ session_namespace }} \
  --data-value "petclinic.codeRepo=${PETCLINIC_GIT_URL}" \
   | kubectl apply -f- -n concourse-{{ session_namespace }}
session: 1
```
The pipeline starts off paused, so let's unpause it now that we've created secrets for it.
```terminal:execute
command: fly -t concourse unpause-pipeline -p spring-petclinic
session: 1
```

Now, let's open a browser window to your pipeline.  Login with user "{{ ENV_CONCOURSE_USERNAME }}" and password "{{ ENV_CONCOURSE_PASSWORD }}"
```dashboard:open-url
url: https://concourse.{{ ingress_domain }}/teams/{{ session_namespace }}/pipelines/spring-petclinic
```
Validate that it is picking up your code and doing the first build.  It is important to let this process complete so that it can pre-cache all your dependencies and allow your builds to execute much faster.  This will take a while the first time.


# Spring Pet Clinic App
Open a tab to your deployed Pet Clinic instance
```dashboard:open-url
url: https://petclinic-{{ session_namespace }}.{{ ingress_domain }}
```
If you don't see the Pet Clinic interface at first, go back to your Concourse tab and ensure that the `continuous-delivery` job completed successfully.  The first build can take a few minutes to complete and deploy.



# Spring and/or Steeltoe Starters
Click the links below to open up to the project generators for Spring and Steeltoe for .NET
```dashboard:open-url
url: https://start.spring.io
```

```dashboard:open-url
url: https://start.steeltoe.io
```


# Tab Staging
Reorder your tabs in this way so that your demo flow goes left to right:
* start.spring.io and/or start.steeltoe.io
* Pet Clinic
* GitHub
* Concourse
  * Make sure to go back to the pipeline overview to be staged on your "continuous-integration" and "continuous-delivery" jobs.
* Harbor
  * Make sure to refresh the list of repositories after your app is deployed so that you are staged showing the "spring-petclinic" and "spring-petclinic-source" repositories.
* Kubeapps
* TAC
* This workshop tab on the "Console" section
* TMC
* TO
* TSM