require 'digest'

class Encryptor
  def initialize
    puts "Please enter a password for "

  def run
    puts "Welcome to Encryptor."
    while true
      print "Enter command: "
      command = gets.chomp
      case command
      when 'quit'
        print "Goodbye."
      when "help"
        puts "
        // quit: exits the program
        // e (message): encrypts a message with the current rotation values
        // eran (message, rotation1, rotation2, rotation3): encrypts a message with the given rotation values
        // d (message): decrypts a message with teh current rotation values
        // dran (message, rotation1, rotation2, rotation3): decrypts a message with the given rotation values
        // c (message): attempts to crack a message "
    def interactive_encrypt
      rotation = rand(supported_characters.size) + 1
      puts "The rotation value is: #{rotation}"
      while true
        print "Enter a message to be encrypted ('q' to quit): "
        message = gets.chomp
        break unless message != 'q'
        puts "The encrypted message: #{encrypt(message, rotation)}"
      end
      puts "Goodbye."
    end

    def interactive_decrypt
      while true
        print "Enter an encrypted message ('q' to quit): "
        message = gets.chomp
        break unless message != 'q'
        print "What is the rotation value? "
        rotation = gets.chomp.to_i
        puts "The decrypted message is: #{decrypt(message, rotation)}"
      end
      puts "Goodbye"
    end

  def supported_characters
    (' '..'z').to_a
  end

  def cipher(rotation)
    characters = (' '..'z').to_a
    rotated_characters = characters.rotate(rotation)
    Hash[characters.zip(rotated_characters)]
  end

  def encrypt(word, rotation)
    split_word = word.split("")
    result = split_word.collect {|letter| encrypt_letter(letter, rotation)}
    result.join
  end

  def encrypt_letter(letter, rotation)
    rotated_cipher = cipher(rotation)
    rotated_cipher[letter]
  end

  def decrypt(word, rotation)
    encrypt(word, rotation * -1)
  end

  def encrypt_file(filename, rotation)
    input = File.open(filename, 'r')
    input = input.read
    output = encrypt(input, rotation)
    output_file = File.open(filename + '.encrypted', 'w')
    output_file.write(output)
    output_file.close
  end

  def decrypt_file(filename, rotation)
    input = File.open(filename, 'r')
    input = input.read
    output = decrypt(input, rotation)
    output_filename = filename.gsub('encrypted', 'decrypted')
    output_file = File.open(output_filename, 'w')
    output_file.write(output)
    output_file.close
  end

  def crack(message)
    supported_characters.count.times.collect do |attempt|
      decrypt(message, attempt)
    end
  end
end
