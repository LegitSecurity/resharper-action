FROM golang:1.14 AS builder

WORKDIR /build
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w"
RUN ls -lh

FROM mcr.microsoft.com/dotnet/sdk:5.0-alpine
ENV RESHARPER_CLI_VERSION=2020.3.1

RUN apk update && apk upgrade
RUN apk add bash
RUN apk add curl
RUN apk add unzip
RUN curl -o dotnet-install.sh -L -J "https://dot.net/v1/dotnet-install.sh"
RUN chmod +x dotnet-install.sh
RUN /dotnet-install.sh --runtime dotnet --version 3.1.0 --install-dir /usr/share/dotnet

RUN mkdir -p /usr/local/share/dotnet/sdk/NuGetFallbackFolder

WORKDIR /resharper
RUN \
  curl -o resharper.zip -L -J "https://download.jetbrains.com/resharper/dotUltimate.$RESHARPER_CLI_VERSION/JetBrains.ReSharper.CommandLineTools.$RESHARPER_CLI_VERSION.zip" \
  && unzip -q resharper.zip \
  && rm resharper.zip
ENV PATH="$/resharper:${PATH}"

# this is the same as the base image
WORKDIR /

COPY --from=builder /build/resharper-action /usr/bin
CMD resharper-action
