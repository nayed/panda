defmodule Panda do
  @moduledoc """
  Documentation for Panda.
  """

  @api_url Application.get_env(:panda, :api_url)

  @doc """
  Fetch Pandascore API's future matches
  """
  def upcoming_matches do
    "#{@api_url}/matches?sort=begin_at&filter[future]=true&token=#{System.get_env("PANDASCORE_TOKEN")}"
    |> HTTPoison.get
    |> handle_response
    |> next_matches
  end

  defp handle_response({:ok, %{status_code: 200, body: body}}) do
    {:ok, Poison.Parser.parse!(body)}
  end

  defp handle_response({_, %{status_code: status, body: body}}) do
    IO.puts "Error, code #{status}"
    {:error, Poison.Parser.parse!(body)}
  end

  defp next_matches({:ok, body}) do
    body
    |> Enum.take(5)
    |> Enum.map(fn(x) -> %{"begin_at" => x["begin_at"], "id" => x["id"], "name" => x["name"] } end)
  end

  defp next_matches({:error, body}) do
    {:error, body}
  end
end
