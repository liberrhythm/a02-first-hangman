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
    %Hangman{
      word: new_word, 
      word_letters: word_letters, 
      letters: populate_letters(word_letters, [])
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

  # see if letter has been guessed already
  def handle_used(true, game, guess) do
    IO.puts "Letter #{guess} already used!"
    tally(game)
  end

  def handle_used(false, game, guess) do
    game = %Hangman { game | 
      turns_left: turns_left - 1,
      game.used = [guess | game.used] |> Enum.sort()
    })
    handle_guess(Enum.member?(game.word_letters, guess), guess, game)
  end

  def guess_in_word(true, game) do
    %Hangman { game | 
      game_state: :good_guess,
      letters: 
    })
  end
  def guess_in_word(false, game) do
    tally(%Hangman { game | 
      game_state: :bad_guess
    })
  end

  def letter_in_used(letter, used) do 
    Enum.member?(used, letter)
  end

  def replace_letters(used, letters) do
    Enum.map(letters, fn(x) -> 
      if letter_in_used(x, used) do x
      else "_"
      end
    end)
  end 

  def handle_good_guess(game) do
    check_game_state(%Hangman { game | 
      replace_letters(game, game.letters)
    })
  end

  def handle_guess(false, guess, game) do
    tally(%Hangman { game | 
      game_state: :bad_guess
    })
  end
  
  def handle_guess(true, guess, game) do
    tally(%Hangman { handle_good_guess(game) | 
      game_state: :good_guess
    })
  end

  # implement check_game_state and update_game_state

  def make_move(game, guess) do
    handle_used(Enum.member?(game.used, guess), game, guess)
  end

end



