defmodule Hangman do

  defstruct(
    game_state: :initializing,
    turns_left: 7,
    word: "",
    guess: "",
    used: [],
    word_letters: [],
    letters: []
  )

  # PUBLIC API CALLS

  def new_game() do
    new_word = Dictionary.random_word()
    word_letters = string_to_list(new_word)

    %Hangman{
      word: new_word,
      word_letters: word_letters,
      letters: populate_letters(word_letters, [])
    }
  end

  def tally(game) do
    %{
      game_state: game.game_state,
      turns_left: game.turns_left,
      letters: tally_checkstate(game.game_state, game.letters, game.word_letters),
      used: game.used,
      last_guess: game.guess
    }
  end

  def make_move(game, guess) do
    game = check_game_state(game.game_state, guess, game)
    { game, tally(game) }
  end

  # PRIVATE HELPER FUNCTIONS

  # convert string into list of single characters
  defp string_to_list(word) do
    word |> String.codepoints()
  end

  # check state before making a move
  defp check_game_state(:won, _guess, game), do: game
  defp check_game_state(:lost, _guess, game), do: game
  defp check_game_state(_, guess, game) do
    handle_duplicate(Enum.member?(game.used, guess), guess, game)
  end

  # modify letters in the case of win or loss
  defp tally_checkstate(:won, _letters, word_letters), do: word_letters
  defp tally_checkstate(:lost, _letters, word_letters), do: word_letters
  defp tally_checkstate(_, letters, _word_letters), do: letters

  # handle duplicate letter guessing
  defp handle_duplicate(true, guess, game) do
    %Hangman{ game | 
      guess: guess, 
      game_state: :already_guessed
    }
  end

  defp handle_duplicate(false, guess, game) do
    game = %Hangman{ game | 
      guess: guess, 
      used: [ guess | game.used ] |> Enum.sort()
    }
    handle_guess(game, Enum.member?(game.word_letters, guess))
  end

  # populate letters list with guessed letters and underscores
  defp populate_letters(word_letters, used) do
    Enum.map(word_letters, fn x ->
      if Enum.member?(used, x) do
        x
      else
        "_"
      end
    end)
  end

  # handle good/bad guesses
  defp handle_guess(game, true) do
    handle_good_guess(game) |> handle_game_state
  end

  defp handle_guess(game, false) do
    handle_bad_guess(game) |> handle_game_state
  end

  # update game_state and letters/turns_left based on good or bad guess
  defp handle_good_guess(game) do
    %Hangman{ game | 
      game_state: :good_guess,
      letters: populate_letters(game.word_letters, game.used)
    }
  end

  defp handle_bad_guess(game) do
    %Hangman{ game | 
      game_state: :bad_guess, 
      turns_left: game.turns_left - 1
    }
  end

  # call update game state based on all letters guessed and/or # of turns left
  defp handle_game_state(game) do
    update_game_state(game.letters == game.word_letters, game.turns_left == 0, game)
  end

  # updating game state for win or loss
  defp update_game_state(true, _, game) do
    %Hangman{ game | game_state: :won }
  end

  defp update_game_state(false, true, game) do
    %Hangman{ game | game_state: :lost }
  end

  defp update_game_state(_, _, game), do: game

end
