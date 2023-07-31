FROM "hexpm/elixir:1.15.4-erlang-26.0.2-debian-bullseye-20230612-slim"

RUN apt-get update -y && apt-get install -y build-essential git inotify-tools curl \
    && apt-get clean && rm -f /var/lib/apt/lists/*_* && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - &&\
    apt-get install -y nodejs
WORKDIR /app
COPY . .

RUN chmod +x rel/overlays/bin/entrypoint.sh
CMD [ "rel/overlays/bin/entrypoint.sh" ] 
