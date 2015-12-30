require 'minitest/autorun'
require_relative '../lib/event_reporter'
require 'pry'

class EventReporterTest < Minitest::Test

  def test_exists
    assert EventReporter
  end

  def test_loads_a_file
    e = EventReporter.new
    e.load(['test/fixtures/event_attendees_sample.csv'])

    expected = {:id=>"1",
                :regdate=>"11/12/08 10:47",
                :first_name=>"Allison",
                :last_name=>"Nguyen",
                :email_address=>"arannon@jumpstartlab.com",
                :homephone=>"6154385000",
                :street=>"3155 19th St NW",
                :city=>"Washington",
                :state=>"DC",
                :zipcode=>"20010"}

    assert_equal 19, e.opened_file.length
    assert_equal expected, e.opened_file.first
  end

  def test_can_load_fixture_through_ultimate
    e = EventReporter.new
    e.ultimate_method("load test/fixtures/event_attendees_sample.csv")

    assert_equal 19, e.opened_file.length
  end

  def test_can_load_event_attendees_by_default_through_ultimate
    e = EventReporter.new
    e.ultimate_method("load")

    assert_equal 5175, e.opened_file.length
  end

  def test_returns_all_available_commands
    e = EventReporter.new
    expected = "help <command>\nload <filename>\nqueue count\nqueue clear\nqueue print\nqueue print by <attribute>\nqueue save to <filename.csv>\nfind <attribute> <criteria>"
    assert_equal expected, e.help
  end

  def test_returns_all_available_commands
    e = EventReporter.new
    expected = "help <command>\nload <filename>\nqueue count\nqueue clear\nqueue print\nqueue print by <attribute>\nqueue save to <filename.csv>\nfind <attribute> <criteria>"
    assert_equal expected, e.ultimate_method("help")
  end

  def test_returns_all_available_command_descriptions
    e = EventReporter.new
    e.available_methods.each do |description|
      assert_equal e.help_commands[description], e.ultimate_method("help #{description}")
    end
  end

  def test_finds_by_column_value
    e = EventReporter.new
    e.load(['test/fixtures/event_attendees_sample.csv'])
    expected = [{:id=>"1", :regdate=>"11/12/08 10:47", :first_name=>"Allison",
                :last_name=>"Nguyen", :email_address=>"arannon@jumpstartlab.com",
                :homephone=>"6154385000", :street=>"3155 19th St NW",
                :city=>"Washington", :state=>"DC", :zipcode=>"20010"},
                {:id=>"2", :regdate=>"11/12/08 13:23", :first_name=>"SArah",
                :last_name=>"Hankins", :email_address=>"pinalevitsky@jumpstartlab.com",
                :homephone=>"414-520-5000", :street=>"2022 15th Street NW",
                :city=>"Washington", :state=>"DC", :zipcode=>"20009"}]
    assert_equal expected, e.find(["city"," washingTon "])
  end

  def test_finds_by_column_value_through_ultimate
    e = EventReporter.new
    e.load(['test/fixtures/event_attendees_sample.csv'])
    expected = [{:id=>"1", :regdate=>"11/12/08 10:47", :first_name=>"Allison",
                :last_name=>"Nguyen", :email_address=>"arannon@jumpstartlab.com",
                :homephone=>"6154385000", :street=>"3155 19th St NW",
                :city=>"Washington", :state=>"DC", :zipcode=>"20010"},
                {:id=>"2", :regdate=>"11/12/08 13:23", :first_name=>"SArah",
                :last_name=>"Hankins", :email_address=>"pinalevitsky@jumpstartlab.com",
                :homephone=>"414-520-5000", :street=>"2022 15th Street NW",
                :city=>"Washington", :state=>"DC", :zipcode=>"20009"}]
    assert_equal expected, e.ultimate_method("find city washingTon ")
  end

  def test_counts_records_in_the_queue
    e = EventReporter.new
    e.load(['test/fixtures/event_attendees_sample.csv'])
    queue = e.find(["city"," washingTon "])

    assert_equal 2, e.ultimate_method("queue count")
  end

  def test_empties_records_in_the_queue
    e = EventReporter.new
    e.load(['test/fixtures/event_attendees_sample.csv'])
    queue = e.find(["city"," washingTon "])

    assert_equal 2, e.ultimate_method("queue count")

    e.ultimate_method("queue clear")

    assert_equal 0, e.ultimate_method("queue count")
  end

  def test_prints_table_records_from_the_queue
    e = EventReporter.new
    e.load(['test/fixtures/event_attendees_sample.csv'])
    queue = e.find(["city"," washingTon "])

    assert_equal 3, e.print_table(["print"]).rows.count
    assert_equal 8, e.print_table(["print"]).number_of_columns
    puts e.print_table(["print"])
  end

  def test_prints_table_records_after_sorting_by_attribute
    e = EventReporter.new
    e.load(['test/fixtures/event_attendees_sample.csv'])
    queue = e.find(["city"," washingTon "])

    table = e.print_table(["print"])
    assert_equal "Nguyen", table.rows[1].cells[1].value
    assert_equal "Hankins", table.rows[2].cells[1].value
    puts table

    table = e.print_table(["print", "by", "last_name"])
    puts table
    assert_equal "Hankins", table.rows[1].cells[1].value
    assert_equal "Nguyen", table.rows[2].cells[1].value
  end

  def test_saves_table_to_new_file
    e = EventReporter.new
    e.load(['test/fixtures/event_attendees_sample.csv'])
    queue = e.find(["city"," washingTon "])

    e.save_file(["save","to","does_it_work.csv"])
  end

end
