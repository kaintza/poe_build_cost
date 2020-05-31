mix deps.get
mix ecto.create
QUIET=1 iex -S mix api
