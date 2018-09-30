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
    {game, tally(game)}
  end

  def handle_used(false, game, guess) do
    %Hangman { game | 
      used: [guess | game.used] |> Enum.sort()
    }
  end

  def letter_in_used(letter, used) do 
    Enum.member?(used, letter)
  end

  def replace_letters(used, word_letters) do
    Enum.map(word_letters, fn(x) -> 
      if letter_in_used(x, used) do x
      else "_"
      end
    end)
  end 

  def handle_good_guess(game) do
    %Hangman { game | 
      game_state: :good_guess,
      letters: replace_letters(game.used, game.word_letters)
    }
  end

  def handle_bad_guess(game) do
    %Hangman { game | 
      turns_left: game.turns_left - 1,
      game_state: :bad_guess
    }
  end

  # handle a guess -- good or bad
  def handle_guess(true, game) do
    handle_game_state(handle_good_guess(game))
  end

  def handle_guess(false, game) do
    handle_game_state(handle_bad_guess(game))
  end

  def update_game_state(true, _, game) do
    %Hangman { game | 
      game_state: :won
    }
  end

  def update_game_state(false, true, game) do
    %Hangman { game | 
      game_state: :lost
    }
  end 

  def update_game_state(_, _, game) do game end

  def handle_game_state(game) do
    # out of guesses: game.turns_left == 0
    # letters match: game.letters == game.word_letters
    update_game_state(game.letters == game.word_letters, game.turns_left == 0, game)
  end


  # check to see if already won or lost...
  def make_move(game, guess) do
    game = handle_used(Enum.member?(game.used, guess), game, guess)
    game = handle_guess(Enum.member?(game.word_letters, guess), game)
    {game, tally(game)}
  end

end



