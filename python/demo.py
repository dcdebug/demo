# Simple Number Guessing Game
import random

# Welcome message
print("Welcome to the Number Guessing Game!")
print("I'm thinking of a number between 1 and 100.")

# Generate a random number
secret_number = random.randint(1, 100)
attempts = 0

# Main game loop
while True:
    # Get player's guess
    try:
        guess = int(input("Enter your guess: "))
        attempts += 1
        
        # Check if guess is correct
        if guess == secret_number:
            print(f"Congratulations! You found the number in {attempts} attempts!")
            break
        elif guess < secret_number:
            print("Too low! Try a higher number.")
        else:
            print("Too high! Try a lower number.")
            
    except ValueError:
        print("Please enter a valid number!")
