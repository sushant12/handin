# Handin

The handin system allows the setup of multiple modules on which lecturers or TA's can create programming assignments that students can submit code to.


### Installation

Before you run any installation steps, make sure you have the asdf tool and docker installed.

- run `asdf install`
- run `mix deps.get`
- run `mix ecto.setup`
- run `cd assets && npm i`
- run `mix phx.server` from the project root
- visit `localhost:4000` on your browser
