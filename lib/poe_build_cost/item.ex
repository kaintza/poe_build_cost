defmodule PoeBuildCost.Item do
  use GenServer
  def start_link(opts) do
    {name, opts} = Keyword.pop(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def init(opts) do
    send(self(), :get_item_info)

    state = %{
      search_id: Keyword.fetch!(opts, :search_id),
    }

    {:ok, state}
  end

  def handle_call(:get_item_info, state = %{search_id: search_id}) do
    Process.send_after(self(), :get_item_info, 2 * 1000 * 60)

    url = "https://www.pathofexile.com/trade/search/Delirium/#{search_id}"
    {:ok, %{body: body}} = HTTPoison.get(url)
    regex = ~r/(?<=\"state\":).+}(?=,)/
    search_partial_query = Regex.run(regex, body) |> Poison.decode!
    query_string = %{"query" => search_partial_query} |> Poison.encode!

    search_url =  "https://www.pathofexile.com/api/trade/search/Delirium"
    headers = [{"Content-type", "application/json"}]

    %{body: body} = HTTPoison.post!(search_url, query_string, headers)
    %{"result" => result} = body |> Poison.decode!

    query = result |> Enum.take(10) |> Enum.join(",")

    url = "https://www.pathofexile.com/api/trade/fetch/#{query}"

    {:ok, %{body: %{"result" => result}} = HTTPoison.get(url, [], params: %{query: search_id})
    %{"result" => result} = body

    {:ok, %{search_id: search_id, }
  end

  defp run_search(search_id) do
    {:ok, 0, 0}
  end
end
