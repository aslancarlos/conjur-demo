# This file is a template, and might need editing before it works on your project.
# This is a sample GitLab CI/CD configuration file that should run without any modifications.
# It demonstrates a basic 3 stage CI/CD pipeline. Instead of real tests or scripts,
# it uses echo commands to simulate the pipeline execution.
#
# A pipeline is composed of independent jobs that run scripts, grouped into stages.
# Stages run in sequential order, but jobs within stages run in parallel.
#
# For more information, see: https://docs.gitlab.com/ee/ci/yaml/index.html#stages
#
# You can copy and paste this template into a new `.gitlab-ci.yml` file.
# You should not add this template to an existing `.gitlab-ci.yml` file by using the `include:` keyword.
#
# To contribute improvements to CI/CD templates, please follow the Development guide at:
# https://docs.gitlab.com/ee/development/cicd/templates.html
# This specific template is located at:
# https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Getting-Started.gitlab-ci.yml

stages:
  - read-secrets
  - build
  - test
  - deploy

read-secrets:
  tags:
    - jwt
  stage: read-secrets
  script:
    # Way to get the content from JWT. 
    # Use base64 to decode, after just go to jwt.io and explore the claims. 
    - echo $CI_JOB_JWT | base64
    - echo ""
#    - 'export AUTHN_TOKEN=$(curl -sk --header "Content-Type: application/x-www-form-urlencoded" --header "Accept-Encoding: base64" --request POST "https://ec2-177-71-173-255.sa-east-1.compute.amazonaws.com/authn-jwt/gitlab1/cybrlab/authenticate" --data-urlencode "jwt=$CI_JOB_JWT")'

    - 'export AUTHN_TOKEN=$(curl -sk --header "Content-Type: application/x-www-form-urlencoded" --header "Accept-Encoding: base64" --request POST "https://<tenant>.secretsmgr.cyberark.cloud/api/authn-jwt/<Service ID>/conjur/authenticate" --data-urlencode "jwt=$CI_JOB_JWT")'
#    - echo $AUTHN_TOKEN
     
    - echo "Fetching a username"
    - export USERNAME=$(curl -k --header "Authorization:Token token=\"${AUTHN_TOKEN}\"" -X GET "https://latamlab.secretsmgr.cyberark.cloud/api/secrets/conjur/variable/data/<variable path>")
    - echo $USERNAME

    - echo "Fetching a password"
    - export PASSWORD=$(curl -k --header "Authorization:Token token=\"${AUTHN_TOKEN}\"" -X GET "https://latamlab.secretsmgr.cyberark.cloud/api/secrets/conjur/variable/data/<variable path>")
    - echo $PASSWORD
  
    - echo "TESTANDO CONEXAO COM O BANCO DE DADOS E AUTENTICANDO O USUARIO"
     #- mysql -h $ADDRESS --user=$USERNAME --password=$PASSWORD -e 'SHOW DATABASES'
     #- mysql -h 10.78.10.125 -u k8sdemo_user2 --password='UHGMLk1' -e 'show databases;'
 

build-job:       # This job runs in the build stage, which runs first.
  stage: build
  script:
    - echo "Compiling the code..."
    - echo "Compile complete."

unit-test-job:   # This job runs in the test stage.
  stage: test    # It only starts when the job in the build stage completes successfully.
  script:
    - echo "Running unit tests... This will take about 60 seconds."
    - sleep 5
    - echo "Code coverage is 90%"

deploy-job:      # This job runs in the deploy stage.
  stage: deploy  # It only runs when *both* jobs in the test stage complete successfully.
  environment: production
  script:
    - echo "Deploying application..."
    - echo "Application successfully deployed."
