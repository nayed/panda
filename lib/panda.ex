defmodule Panda do
  @moduledoc """
  Documentation for Panda.
  """

  @api_url Application.get_env(:panda, :api_url)
  @token_part "token=#{System.get_env("PANDASCORE_TOKEN")}"

  @doc """
  Fetch Pandascore API's future matches
  """
  def upcoming_matches do
    "#{@api_url}/matches?sort=begin_at&filter[future]=true&#{@token_part}"
    |> HTTPoison.get
    |> handle_response
    |> next_matches
  end

  defp handle_response({:ok, %{status_code: 200, body: body, headers: headers}}) do
    {:ok, Poison.Parser.parse!(body), headers}
  end
  defp handle_response({_, %{body: body}}) do
    {:error, Poison.Parser.parse!(body)}
  end

  defp next_matches({:ok, body, _headers}) do
    body
    |> Enum.take(5)
    |> Enum.map(fn(x) -> %{"begin_at" => x["begin_at"], "id" => x["id"], "name" => x["name"] } end)
  end
  defp next_matches({:error, body, _headers}) do
    {:error, body}
  end

  def stats_match(id) do
    fetching_teams = "#{@api_url}/matches/#{id}/teams?#{@token_part}"
    |> HTTPoison.get
    |> handle_response

    case fetching_teams do
      {:ok, body, _headers} ->
        [team_a, team_b] = Enum.map(body, fn(x) ->
          %{"team_id" => x["id"], "team_name" => x["name"]}
        end)

        get_team_special_data(team_a, team_b)

      {_, body, _headers} ->
        body
    end
  end

  def odds_for_match(id) do
    id
    |> stats_match
    |> process_odds
  end

  defp process_odds(data) do
    [team_a, team_b] = data
    odds_a = odds(team_a, team_b)
    odds_b = odds(team_b, team_a)

    %{
      team_a[:team_name] => odds_a,
      team_b[:team_name] => odds_b,
      "no winner" => Float.floor(100 - odds_a - odds_b, 6)
    }
  end

  defp odds(team, opponent) do
    total = team[:number_of_matches]
    wins = team[:matches_won]
    match_vs_opponent = team[String.to_atom("number_matches_vs_#{opponent[:team_name]}")]
    win_vs_opponent = team[String.to_atom("wins_vs_#{opponent[:team_name]}")]

    ((((wins / total * 0.5) + (win_vs_opponent / match_vs_opponent)) / 1.5) * 100) |> Float.floor(6)
  end

  defp get_team_special_data(team_a, team_b) do
    {:ok, _, headers_a} = get_headers(team_a["team_id"])
    {_, nb_matches_a} = get_x_total(headers_a)
    pages_total_a = (div(String.to_integer(nb_matches_a), 50)) + 1

    all_matches_a = data_all_matches_for_team(team_a["team_id"], [], pages_total_a)

    matches_a = get_match_ids(all_matches_a)
    matches_a_won = get_matches_won(team_a["team_id"], all_matches_a)
    wins_a = get_match_ids(matches_a_won)

    {:ok, _, headers_b} = get_headers(team_b["team_id"])
    {_, nb_matches_b} = get_x_total(headers_b)
    pages_total_b = (div(String.to_integer(nb_matches_b), 50)) + 1

    all_matches_b = data_all_matches_for_team(team_b["team_id"], [], pages_total_b)

    matches_b = get_match_ids(all_matches_b)
    matches_b_won = get_matches_won(team_b["team_id"], all_matches_b)
    wins_b = get_match_ids(matches_b_won)

    match_between = get_matches_between(matches_a, matches_b)

    a_win_vs_b = wins_vs_x(match_between, wins_a)
    b_win_vs_a = wins_vs_x(match_between, wins_b)

    special_a = special_data(team_a, matches_a, wins_a, match_between, team_b, a_win_vs_b)
    special_b = special_data(team_b, matches_b, wins_b, match_between, team_a, b_win_vs_a)

    [special_a, special_b]
  end

  defp get_headers(team) do
    "#{@api_url}/teams/#{team}/matches?#{@token_part}"
      |> HTTPoison.get
      |> handle_response
  end

  defp get_x_total(headers) do
    Enum.find(headers, fn({key, val}) ->
      if key == "X-Total" do
        val
      end
    end)
  end

  defp data_all_matches_for_team(_team, result, 0), do: result
  defp data_all_matches_for_team(team, result, page) do
    {:ok, new_result, _} =
      "#{@api_url}/teams/#{team}/matches?page=#{page}&#{@token_part}"
      |> HTTPoison.get
      |> handle_response
    data_all_matches_for_team(team, result ++ new_result, page - 1)
  end

  defp get_match_ids(matches) do
    Enum.map(matches, fn(match) -> match["id"] end)
  end

  defp get_matches_won(team_id, team_matches) do
    Enum.filter(team_matches, fn(match) -> match["winner"]["id"] == team_id end)
  end

  defp get_matches_between(team_a, team_b) do
    (team_a ++ team_b) -- (Enum.uniq(team_a ++ team_b))
  end

  defp wins_vs_x(match_between, win_team) do
    (match_between ++ win_team) -- Enum.uniq(match_between ++ win_team)
  end

  defp special_data(team, matches, wins, matches_between, other_team, win_vs_other) do
    [
      {:team_id, team["team_id"]},
      {:team_name, team["team_name"]},
      {:number_of_matches, length(matches)},
      {:matches_won, length(wins)},
      {String.to_atom("number_matches_vs_#{other_team["team_name"]}"), length(matches_between)},
      {String.to_atom("wins_vs_#{other_team["team_name"]}"), length(win_vs_other)}
    ]
  end
end
