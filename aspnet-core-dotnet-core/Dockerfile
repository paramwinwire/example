#####
FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build-env


#FROM mcr.microsoft.com/dotnet/sdk:6.0-buster AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY aspnet-core-dotnet-core/*.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY aspnet-core-dotnet-core/ ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim 
#FROM mcr.microsoft.com/dotnet/aspnet:6.0-buster-slim
WORKDIR /app
COPY --from=build-env /app/out .


ENTRYPOINT ["dotnet", "aspnet-core-dotnet-core.dll"]


