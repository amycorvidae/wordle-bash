#!/bin/bash
# Wordle Clone in Bash

# Constants
WORD_LENGTH=5
MAX_ATTEMPTS=6
WORD_FILE="data/words.txt"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
GREY='\033[0;90m'
RESET='\033[0m'

# Keyboard state tracking
declare -A KEYBOARD_COLORS

# Select a random word from the word list
select_random_word() {
  local word_count=$(wc -l < "$WORD_FILE")
  local random_line=$((RANDOM % word_count + 1))
  SECRET_WORD=$(sed -n "${random_line}p" "$WORD_FILE")
}

# Check guess against secret word and update keyboard
check_guess() {
  local guess=$1
  local result=""

  for ((i=0; i<WORD_LENGTH; i++)); do
    local guess_char="${guess:$i:1}"
    local secret_char="${SECRET_WORD:$i:1}"

    if [[ "$guess_char" == "$secret_char" ]]; then
      result+="${GREEN}${guess_char}${RESET}"  # Correct letter in correct position
      KEYBOARD_COLORS[$guess_char]="green"
    elif [[ "$SECRET_WORD" == *"$guess_char"* ]]; then
      result+="${YELLOW}${guess_char}${RESET}"  # Correct letter in wrong position
      # Only update to yellow if not already green
      if [[ "${KEYBOARD_COLORS[$guess_char]}" != "green" ]]; then
        KEYBOARD_COLORS[$guess_char]="yellow"
      fi
    else
      result+="${GREY}${guess_char}${RESET}"  # Letter not in word
      # Mark as grey (unavailable) if not already green or yellow
      if [[ -z "${KEYBOARD_COLORS[$guess_char]}" ]] || [[ "${KEYBOARD_COLORS[$guess_char]}" == "grey" ]]; then
        KEYBOARD_COLORS[$guess_char]="grey"
      fi
    fi
  done

  echo -e "$result"
}

# Display the keyboard with color coding
display_keyboard() {
  local row1="qwertyuiop"
  local row2="asdfghjkl"
  local row3="zxcvbnm"

  echo "Keyboard:"

  # Row 1
  echo -n "  "
  for ((i=0; i<${#row1}; i++)); do
    local letter="${row1:$i:1}"
    print_key "$letter"
  done
  echo ""

  # Row 2
  echo -n "   "
  for ((i=0; i<${#row2}; i++)); do
    local letter="${row2:$i:1}"
    print_key "$letter"
  done
  echo ""

  # Row 3
  echo -n "     "
  for ((i=0; i<${#row3}; i++)); do
    local letter="${row3:$i:1}"
    print_key "$letter"
  done
  echo ""
}

# Print a single key with appropriate color
print_key() {
  local letter=$1
  local color="${KEYBOARD_COLORS[$letter]}"

  case "$color" in
    green)
      echo -en "${GREEN}${letter}${RESET} "
      ;;
    yellow)
      echo -en "${YELLOW}${letter}${RESET} "
      ;;
    grey)
      echo -en "${GREY}${letter}${RESET} "
      ;;
    *)
      echo -n "${letter} "
      ;;
  esac
}

# Validate user input
validate_guess() {
  local guess=$1

  # Check if guess is exactly 5 letters
  if [[ ${#guess} -ne $WORD_LENGTH ]]; then
    echo "Please enter exactly $WORD_LENGTH letters."
    return 1
  fi

  # Check if guess contains only letters
  if [[ ! "$guess" =~ ^[a-zA-Z]+$ ]]; then
    echo "Please enter only letters."
    return 1
  fi

  return 0
}

# Main game loop
play_game() {
  local attempts=0
  local won=false

  echo "================================"
  echo "  Welcome to Wordle in Bash!"
  echo "================================"
  echo "Guess the $WORD_LENGTH-letter word. You have $MAX_ATTEMPTS attempts."
  echo ""
  echo "Keyboard Legend:"
  echo -e "  White = unused letter (still available)"
  echo -e "  ${GREY}Grey${RESET} = letter already guessed, not in word"
  echo -e "  ${YELLOW}Yellow${RESET} = letter in word, wrong position"
  echo -e "  ${GREEN}Green${RESET} = letter in correct position"
  echo ""

  while [[ $attempts -lt $MAX_ATTEMPTS ]]; do
    echo "Attempt $((attempts + 1))/$MAX_ATTEMPTS"
    read -p "Enter your guess: " guess

    # Convert guess to lowercase
    guess=$(echo "$guess" | tr '[:upper:]' '[:lower:]')

    # Validate the guess
    if ! validate_guess "$guess"; then
      continue
    fi

    # Check the guess
    result=$(check_guess "$guess")
    echo "$result"
    echo ""

    # Display keyboard
    display_keyboard
    echo ""

    # Check if player won
    if [[ "$guess" == "$SECRET_WORD" ]]; then
      won=true
      break
    fi

    ((attempts++))
  done

  # Display end game message
  if [[ "$won" == true ]]; then
    echo "🎉 Congratulations! You guessed the word: $SECRET_WORD"
    echo "You won in $((attempts + 1)) attempts!"
  else
    echo "😞 Game Over! The word was: $SECRET_WORD"
  fi
}

# Initialize and start the game
select_random_word
play_game
