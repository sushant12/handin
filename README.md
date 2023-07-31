# Handin

The handin system allows the setup of multiple modules on which lecturers or TA's can create programming assignments that students can submit code to.

## Up and Running
Make sure you have docker installed.

Clone the repo and run `docker compose up`. In next tab run `docker compose exec web run priv/repo/seeds.exs`


## Development

### Installation

Before you run any installation steps, make sure you have the asdf tool and docker installed.

- run `asdf install`
- run `mix deps.get`
- run `mix ecto.setup`
- run `mix phx.server`
- visit `localhost:4000` on your browser
