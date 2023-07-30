#!/bin/bash
set -e

MIX_ENV=dev mix do deps.get, compile, ecto.create, ecto.migrate
cd assets && npm install
cd .. &&  mix phx.server