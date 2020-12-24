FROM golang:1.14 AS builder

WORKDIR /build
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w"
RUN ls -lh

FROM mcr.microsoft.com/dotnet/sdk:5.0
ENV RESHARPER_CLI_VERSION=2020.3

RUN mkdir -p /usr/local/share/dotnet/sdk/NuGetFallbackFolder

WORKDIR /resharper
RUN \
  curl -o resharper.tar.gz -L -J "https://download.jetbrains.com/resharper/dotUltimate.$RESHARPER_CLI_VERSION/JetBrains.ReSharper.CommandLineTools.$RESHARPER_CLI_VERSION.tar.gz" \
  && tar -xvf resharper.tar.gz \
  && rm resharper.tar.gz \
  && rm -rf macos-x64
ENV PATH="$/resharper:${PATH}"

# this is the same as the base image
WORKDIR /

COPY --from=builder /build/resharper-action /usr/bin
CMD resharper-action
