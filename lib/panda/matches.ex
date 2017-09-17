defmodule Panda.Matches do
  @doc """
  Store matches.

  The match_id is given as a name so we can identify data from specific match
  """
  def start_link(match_id) do
    Agent.start_link(fn -> [] end, name: match_id)
  end

  @doc """
  Get the data for the match
  """
  def get(match_id) do
    Agent.get(match_id, fn list -> list end)
  end

  @doc """
  Pushes data into the match_id
  """
  def push(match_id, data) do
    Agent.update(match_id, fn list -> [data | list] end)
  end

  @doc """
  Pops data
  """
  def pop(match_id) do
    Agent.get_and_update(match_id, fn
      []      -> {:error, []}
      [h | t] -> {{:ok, h}, [h] ++ t}
    end)
  end
end
