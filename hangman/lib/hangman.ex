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
    word: "",
    guess: "",
    used: [],
    word_letters: [],
    letters: []
  )

  def new_game() do
    new_word = Dictionary.random_word()
    word_letters = string_to_list(new_word)
    %Hangman{
      word: new_word, 
      word_letters: word_letters, 
      letters: populate_letters(word_letters, [])
    }
  end

  defp string_to_list(word) do
    word |> String.codepoints()
  end

  defp populate_letters([], letters), do: letters
  defp populate_letters([_h | t], letters) do
    populate_letters(t, ["_" | letters])
  end

  # replace letters if won or lost
  defp tally_checkstate(:won, _letters, word_letters) do word_letters end
  defp tally_checkstate(:lost, _letters, word_letters) do word_letters end
  defp tally_checkstate(_, letters, _word_letters) do letters end
  def tally(game) do
    %{
      game_state: game.game_state,
      turns_left: game.turns_left,
      letters: tally_checkstate(game.game_state, game.letters, game.word_letters),
      used: game.used,
      last_guess: game.guess
    }
  end

  # see if letter has been guessed already
  defp handle_used(true, guess, game) do
    %Hangman { game | 
      game_state: :already_guessed,
      guess: guess
    }
  end

  defp handle_used(false, guess, game) do
    %Hangman { game | 
      used: [guess | game.used] |> Enum.sort(),
      guess: guess
    }
  end

  defp letter_in_used(letter, used) do 
    Enum.member?(used, letter)
  end

  defp replace_letters(used, word_letters) do
    Enum.map(word_letters, fn(x) -> 
      if letter_in_used(x, used) do x
      else "_"
      end
    end)
  end 

  defp handle_good_guess(game) do
    %Hangman { game | 
      game_state: :good_guess,
      letters: replace_letters(game.used, game.word_letters)
    }
  end

  defp handle_bad_guess(game) do
    %Hangman { game | 
      turns_left: game.turns_left - 1,
      game_state: :bad_guess
    }
  end

  # handle a guess -- good or bad
  defp handle_guess(true, game) do
    handle_game_state(handle_good_guess(game))
  end

  defp handle_guess(false, game) do
    handle_game_state(handle_bad_guess(game))
  end

  defp update_game_state(true, _, game) do
    %Hangman { game | 
      game_state: :won
    }
  end

  defp update_game_state(false, true, game) do
    %Hangman { game | 
      game_state: :lost
    }
  end 

  defp update_game_state(_, _, game) do game end

  defp handle_game_state(game) do
    # out of guesses: game.turns_left == 0
    # letters match: game.letters == game.word_letters
    update_game_state(game.letters == game.word_letters, game.turns_left == 0, game)
  end

  def make_move(game, guess) do
    game = handle_used(Enum.member?(game.used, guess), guess, game)
    game = handle_guess(Enum.member?(game.word_letters, guess), game)
    {game, tally(game)}
  end

end



