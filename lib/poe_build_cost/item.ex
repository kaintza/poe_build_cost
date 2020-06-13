defmodule PoeBuildCost.Item do
  use GenServer
  def start_link(opts) do
    {name, opts} = Keyword.pop(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def init(opts) do
    schedule_next_run(2 * 1000)

    state = %{
      search_url: Keyword.fetch!(opts, :search_url),
    }

    {:ok, state}
  end

  def handle_call(:icon, _from, state = %{search_url: search_url, items: items}) do
    %{"item" => %{"icon" => icon}} = items |> List.first
    search_id = search_url |> String.trim("/") |> String.split("/") |> List.last
    Phoenix.PubSub.broadcast(PoeBuildCost.PubSub, search_id, {__MODULE__, "icon_change", %{icon: icon}})

    {:reply, icon, state}
  end

  def handle_call(:prices, _from, state = %{items: items}) do
    prices = items |> Enum.map(fn %{"listing" => %{"price" => %{"amount" => amount}}} -> amount end)
    avg_price = (prices |> Enum.sum) / (prices |> length)
    [cheapest | tail] = prices
    median = prices |> Enum.at(middle_item_index = (prices |> length) / 2 |> floor)

    {:reply, %{avg_price: avg_price, cheapest: cheapest, median: median}, state}
  end

  def handle_info(:get_item_info, state = %{search_url: search_url}) do
    {:ok, %{body: body}} = HTTPoison.get(search_url)
    search_id = search_url |> String.trim("/") |> String.split("/") |> List.last
    regex = ~r/(?<=\"state\":).+}(?=,)/
    search_partial_query = Regex.run(regex, body) |> Poison.decode!
    query_string = %{query: search_partial_query, sort: %{price: "asc"}} |> Poison.encode!

    api_url =  "https://www.pathofexile.com/api/trade/search/Delirium"
    headers = [{"Content-type", "application/json"}]

    %{body: body} = HTTPoison.post!(api_url, query_string, headers)
    %{"result" => result} = body |> Poison.decode!

    all_items = items(search_id, result, [])
    %{"item" => %{"icon" => icon}} = all_items |> List.first
    Phoenix.PubSub.broadcast(PoeBuildCost.PubSub, search_id, {__MODULE__, "icon_change", %{icon: icon}})

    schedule_next_run(2 * 1000 * 60)

    {:noreply, %{search_url: search_url, items: all_items}}
  end

  def items(search_id, list = [], result), do: result

  def items(search_id, list, result) do
    query = list |> Enum.take(10) |> Enum.join(",")

    url = "https://www.pathofexile.com/api/trade/fetch/#{query}"

    {:ok, %{body: body}} = HTTPoison.get(url, [], params: %{query: search_id})
    %{"result" => new_result} = body |> Poison.decode!

    #items(search_id, list |> Enum.drop(10), result ++ new_result)
    new_result
  end

  defp schedule_next_run(time_in_ms) do
    Process.send_after(self(), :get_item_info, time_in_ms)
  end
end
