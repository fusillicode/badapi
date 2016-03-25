defmodule Badapi do
  use Application
  require Logger

  def start(_type, _args) do
    Badapi.Supervisor.start_link
  end

  def main(args) do
    args
      |> parse_args
      |> read_file
      |> parse_file
      |> extract_requests
      |> start_testers
  end

  def extract_requests(%{"requests" => requests}), do: requests

  def start_testers([]), do: :ok
  def start_testers([h|t]) do
    IO.inspect h
    start_testers t
  end

  defp parse_args(args) do
    case args do
      [h|_] -> h
      _ -> Logger.info 'No argument supplied'; exit(:normal);
    end
  end

  defp read_file(file) do
    case File.read file  do
      {:ok, body} -> {file, body}
      {:error, reason} ->
        Logger.info "Error in reading file '#{file}', reason: '#{reason}'."
        exit(:normal)
    end
  end

  defp parse_file({file, body}) do
    try do Poison.Parser.parse! body
    rescue Poison.SyntaxError ->
      Logger.info "File '#{file}' has some syntax errors."; exit(:normal);
    end
  end
end
