# You can set the Swift version to what you need for your app. Versions can be found here: https://hub.docker.com/_/swift
FROM swift:5.1.3 as builder

# For local build, add `--build-arg env=docker`
# In your application, you can use `Environment.custom(name: "docker")` to check if you're in this env
ARG env

RUN apt-get -qq update && apt-get install -y \
  libssl-dev zlib1g-dev \
  && rm -r /var/lib/apt/lists/*
WORKDIR /app
COPY . .
RUN swift build -c release && ln -s `swift build -c release --show-bin-path` /build/bin

# Production image
FROM swift:5.1.3-slim
ARG env
WORKDIR /app
COPY --from=builder /build/bin ./bin
COPY --from=builder /app/Public ./Public
COPY --from=builder /app/Resources ./Resources
ENV ENVIRONMENT=$env

ENTRYPOINT ./bin/Run serve --env $ENVIRONMENT --hostname 0.0.0.0 --port 80
