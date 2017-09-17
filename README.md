# Panda

### Install
Add your Pandascore token in your env (.bashrc/.zshrc) as PANDASCORE_TOKEN="mytoken":

```
$ print 'export PANDASCORE_TOKEN="mytoken"' >> ~/.bashrc
OR
$ print 'export PANDASCORE_TOKEN="mytoken"' >> ~/.zshrc
```

Resource your shell with `source ~/.bashrc` or `source ~/.zshrc`.

Verify that your token is in your system env:

```
$ echo $PANDASCORE_TOKEN
```

If you see your token then you're ready to clone:
````
$ git clone https://github.com/nayed/panda.git
$ cd panda
$ mix deps.get
````

### Usage
```elixir
iex> Panda.upcoming_matches
[%{"begin_at" => "2017-09-23T05:30:00Z", "id" => 18581, "name" => "WE-vs-LYN"},
 %{"begin_at" => "2017-09-23T06:30:00Z", "id" => 18599, "name" => "C9-vs-ONE"},
 %{"begin_at" => "2017-09-23T07:30:00Z", "id" => 18582, "name" => "GMB-vs-LYN"},
 %{"begin_at" => "2017-09-23T08:30:00Z", "id" => 18602, "name" => "DW-vs-C9"},
 %{"begin_at" => "2017-09-23T09:30:00Z", "id" => 18580, "name" => "GMB-vs-WE"}]

iex> Panda.odds_matches 9493
%{"Giants" => 34.619782, "Origen" => 35.563178, "no winner" => 29.81704}

iex> Panda.history_record 9493
[[team_id: 20, team_name: "Origen", number_of_matches: 106, matches_won: 36,
  number_matches_vs_Giants: 11, wins_vs_Giants: 4],
 [team_id: 18, team_name: "Giants", number_of_matches: 106, matches_won: 33,
  number_matches_vs_Origen: 11, wins_vs_Origen: 4]]
 ```
