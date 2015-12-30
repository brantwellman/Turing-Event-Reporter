require 'csv'
require 'terminal-table'
require 'pry'

class EventReporter

  attr_reader :opened_file, :current_queue

  def initialize
    @current_queue = []
    @opened_file = []
  end

  def find(column_name_and_row_value)
    column_name = column_name_and_row_value.first
    row_value = column_name_and_row_value[1..-1].join(" ")
    @current_queue = opened_file.select do |row|
      cleanse(row[column_name.to_sym]) == cleanse(row_value)
    end
  end

  def queue(secondary_commands)
    second_command = secondary_commands[0]
    case second_command
    when "count"
      current_queue.count
    when "clear"
      @current_queue = []
    when "print"
      print_table(secondary_commands)
    when "save"
      save_file(secondary_commands)
    end
  end

  def headers
    ["FIRST NAME","LAST NAME","EMAIL","PHONE","CITY","STATE","ADDRESS","ZIPCODE"]
  end

  def save_file(secondary_commands)
    filename = secondary_commands.last

    printable_queue = @current_queue.map do |hash|
      hash.delete_if{|k,_| k == :id || k == :regdate}
      hash
    end

    CSV.open(filename, "wb") do |csv|
      csv << headers
      printable_queue.each do |hash|
        csv << hash.values
      end
    end
  end


  def print_table(secondary_commands)
    if secondary_commands.size != 1
      key = secondary_commands.last.to_sym
      @current_queue.sort_by! do |row|
        row[key]
      end
    end

    rows = @current_queue.map do |row|
      row.values[2..-1]
    end

    rows.unshift(:separator)
    rows.unshift(headers)

    Terminal::Table.new :rows => rows
  end

  def cleanse(string)
    string.downcase.strip if string
  end

  def load(file = nil)
    file = file[0]
    file = "lib/event_attendees.csv" if file.nil?
    csv_file = CSV.open(file, headers: true, header_converters: :symbol)
    @opened_file = csv_file.to_a.map(&:to_h)
    "loaded #{file}!"
  end

  def help(secondary_commands)
    help_query = secondary_commands.join(" ")
    if help_query == ""
      available_methods.join("\n")
    else
      help_commands[help_query]
    end
  end

  def help_commands
    h = Hash.new("Not a command")

    x = available_methods.zip(
    ["outputs a description of how to use <command>.",
      "erase any loaded data and parse <filename>.  If no filename given default to event_attendees.csv.",
      "output number of records in current queue.",
      "empty the queue.",
      "print out a tab delimited data table.",
      "print the data table sorted by <attribute>.",
      "export current queue to <filename> as csv.",
      "load the queue with all records matching <criteria> for <attribute>."
    ]).to_h

    h.merge(x)
  end

  def available_methods
    ["help <command>",
    "load <filename>",
    "queue count",
    "queue clear",
    "queue print",
    "queue print by <attribute>",
    "queue save to <filename.csv>",
    "find <attribute> <criteria>"]
  end

  def ultimate_method(cli_input)
    commands = cli_input.split
    initial_command = commands.first
    secondary_commands = commands[1..-1]
    if respond_to?(initial_command)
      send(initial_command, secondary_commands)
    else
      "Not a legit command, try again (see help for options)."
    end
  end
end

if __FILE__ == $0
  e = EventReporter.new
  loop do
    puts "Enter command: type 'help' for list of commands, and 'exit' to quit."
    x = gets.strip
    break if x.downcase == "exit"
    puts e.ultimate_method(x)
  end
end
