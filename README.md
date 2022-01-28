# wordle_solver

A fun little project that can assist in solving the daily wordle at: https://www.powerlanguage.co.uk/wordle/ written 100% in [Crystal](https://crystal-lang.org/)

## Installation

1. Clone repo
2. Compile using: `crystal build wordle_solver.cr`
3. Run the binary: `./worlde_solver`

Note that the previous_words.txt file must be in same directory as the binary in current version

## Usage

When the program runs you have the following options from the command line:

1. eliminate characters `-e 's e p b y s p a c e s'`
    - Provide the characters that are not present in the word separated by whitespace
2. make a guess: `-w 's u g? a! r`
    - Tell the program what you guessed. Single characters are eliminated, characters followed by an exclamation point are in the correct position in the word, characters followed by a questionmark are in the word, but not in the correct position.
    - Note that the program currently doesn't support words with characters in more than one position.
3. use the "hack": `-x` this finds the daily word in the wordlist that was scraped from the .js on the website.

## Development

All code so far was written offline on an airplane surrounded by screaming kids. Quality is obviously affacted and the code could do with some cleaning, linting and coverage.

## Contributing

1. Fork it (<https://github.com/Lillevang/wordle_solver/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Jeppe Lillevang Salling](https://github.com/Lillevang) - creator and maintainer
