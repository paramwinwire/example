name: aspcoresample

on: [push]
  #workflow_dispatch:

jobs:
  docker_build_push_acr:
    name: 'Docker Build and Push to ACR'
    runs-on: ubuntu-latest
    environment: dev
 
    # Use  the Bash shell regardless whether the GitHub Actions runner is ubuntu-latest, macos-latest, or windows-latest
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
        #tags: ${{ secrets.REGISTRY_LOGIN_SERVER }}/chatwithentdemoapi:v${{ github.run_number }}
        tags: ${{ secrets.REGISTRY_LOGIN_SERVER }}/aspcoresample:v${{ github.run_number }}
        #tags: aspcoresample:v${{ github.run_number }}
        file: aspnet-core-dotnet-core/Dockerfile

#    - name: Build and deploy Container App
#      uses: azure/container-apps-deploy-action@v1
#      with:
#        # appSourcePath: ${{ github.workspace }}
#        # acrName: chathpeacr
#        containerAppName: ca-chathpe-dev-001
#        resourceGroup: rg-terraform01
#        imageToDeploy: chathpeacr.azurecr.io/chatwithentdemoapi:v7
#
    - name: Build and deploy Container App
      uses: azure/container-apps-deploy-action@v1
      with:
        # appSourcePath: ${{ github.workspace }}
        # acrName: chathpeacr
        containerAppName: ca-chathpe-dev-001
        resourceGroup: rg-terraform01
        imageToDeploy: chathpeacr.azurecr.io/aspcoresample:v6