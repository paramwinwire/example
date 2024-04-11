name: demoapi

on: [push]
  #workflow_dispatch:

jobs:
  docker_build_push_acr:
    name: 'Docker Build and Push to ACR'
    runs-on: ubuntu-latest
    environment: dev
 
   
    defaults:
      run:
        shell: bash
 
    steps:
    # Checkout the  repository to the GitHub Actions runner
    - name: Checkout
      uses: actions/checkout@v4

    - name: Cache pip dependencies
      uses: actions/cache@v2
      with:
        path: ~/.cache/pip
        key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
        restore-keys: |
          ${{ runner.os }}-pip-
    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: 'Docker Login'
      uses: azure/docker-login@v1
      with:
        login-server: ${{ secrets.REGISTRY_LOGIN_SERVER }}
        username: ${{ secrets.REGISTRY_USERNAME }}
        password: ${{ secrets.REGISTRY_PASSWORD }}

    - name: Build the frontend image and push it to ACR
      uses: docker/build-push-action@v5
      with:
        push: true
        tags: ${{ secrets.REGISTRY_LOGIN_SERVER }}/chatwithentdemoapi:v${{ github.run_number }}
        file: wwchatwithentdemoapiproject/Dockerfile

  deploy_container_apps:
    name: 'Deploy Container App to Azure Container Apps'
    runs-on: ubuntu-latest
    needs: docker_build_push_acr
    environment: dev

    steps:
    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Get last pushed image reference
      run: |
        last_pushed_image=$(az acr repository show-tags --name chathpeacr --repository chatwithentdemoapi --orderby time_desc --top 1 --query '[0]' -o tsv)
        echo "LAST_PUSHED_IMAGE=$last_pushed_image" >> $GITHUB_ENV
        echo "LAST_PUSHED_IMAGE=$last_pushed_image"

    - name: Deploy Container App 1
      uses: azure/container-apps-deploy-action@v1
      with:
        containerAppName: ca-chathpe-dev-001
        resourceGroup: rg-terraform01
        imageToDeploy: chathpeacr.azurecr.io/chatwithentdemoapi:${{ env.LAST_PUSHED_IMAGE }}

    - name: Deploy Container App 2
      uses: azure/container-apps-deploy-action@v1
      with:
        containerAppName: ca-chathpe-dev-002
        resourceGroup: rg-terraform01
        imageToDeploy: chathpeacr.azurecr.io/chatwithentdemoapi:${{ env.LAST_PUSHED_IMAGE }}