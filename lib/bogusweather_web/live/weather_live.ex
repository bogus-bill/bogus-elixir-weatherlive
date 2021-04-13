defmodule BogusweatherWeb.WeatherLive do
  use BogusweatherWeb, :live_view

  defp fetch(socket) do
    {:ok, assign(socket, query: "", results: %{}, cities: Cities.get_all())}
  end

  def mount(_parmas, _session, socket) do
    fetch(socket)
  end

  def handle_event("search", %{"q" => query}, socket) do
    case search(query) do
      {:ok, result} ->
        {:noreply,
         socket
         |> put_flash(:error, "")
         |> assign(results: %{(query) => result}, query: query)}
      {_, text}->
        {:noreply,
         socket
         |> put_flash(:error, ":'( #{text}")
         |> assign(results: %{}, query: text)}
    end
  end

  defp search(city_name) do
    api_key = "e512d4ffd3b26e43f12f4421b28dfb6b"
    url = "https://api.openweathermap.org/data/2.5/weather?q=#{city_name}&appid=#{api_key}"

    HTTPoison.start()
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok,
         Poison.decode!(body)
         |> Map.get("weather")
         |> List.first()
         |> Map.get("description")}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:notfound, "404: No city that match #{city_name}"}
      {:ok, _} ->
        {:notfound, "Got something else than 200 or 404.."}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
