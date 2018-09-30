defmodule Hangman do
  @moduledoc """
  Documentation for Hangman.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Hangman.hello()
      :world

  """
  defstruct(
    game_state: :initializing,
    turns_left: 7,
    used: [],
    word: "",
    word_letters: [],
    letters: []
  )

  def new_game() do
    new_word = Dictionary.random_word()
    word_letters = string_to_list(new_word)
    game = %Hangman{
      word: new_word, 
      word_letters: word_letters, 
      letters: populate_letters(string_to_list(new_word), [])
    }
    # tally(game)
  end

  def string_to_list(word) do
    word |> String.codepoints()
  end

  def populate_letters([], letters) do letters end
  def populate_letters([_h | t], letters) do
    populate_letters(t, ["_" | letters])
  end

  def tally_checkstate(:won, _letters, word_letters) do word_letters end
  def tally_checkstate(:lost, _letters, word_letters) do word_letters end
  def tally_checkstate(_, letters, _word_letters) do letters end
  def tally(game) do
    %{
      game_state: game.game_state,
      turns_left: game.turns_left,
      letters: tally_checkstate(game.game_state, game.letters, game.word_letters),
      used: game.used
    }
  end

end
