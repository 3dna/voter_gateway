require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe VoterFile::CSVDriver::CSVFile do

  let(:test_file_path) { Tempfile.new('test').path }
  let(:working_table) { stub(name: 'working_table') }
  let(:subject) { VoterFile::CSVDriver::CSVFile.new(test_file_path, working_table) }

  after(:all) do
    File.delete(test_file_path)
  end

  after(:each) do
    subject.close
  end

  describe '#initialize' do
    its(:original) { should == test_file_path }
    its(:delimiter) { should == ',' }
    its(:quote) { should == "\x00" }
    its(:working_table) { should == working_table }
    its(:working_files) { should be_empty }
    its(:custom_headers) { should be_empty }
  end

  describe '#path' do
    its(:path) { should == test_file_path }

    it 'returns path of file, preferring processed to original' do
      subject.instance_variable_set(:@processed, '/other/path')
      subject.path.should == '/other/path'
    end
  end

  describe '#remove_expression' do
    it 'returns path to processed file' do
      File.open(test_file_path, 'w') { |f| f << 'header 1,header 2,header 3' }
      subject.remove_expression '\^'
      subject.path.should == "#{test_file_path}.stripped"
    end

    it 'saves the stripped file in the working files' do
      File.open(test_file_path, 'w') { |f| f << "^header 1^,^header 2^,^header 3^\ndata 1,data 2,data 3\n" }
      subject.remove_expression '\^'
      subject.working_files.should include("#{test_file_path}.stripped")
    end

    it 'creates a corrected file in which the character is removed' do
      File.open(test_file_path, 'w') { |f| f << "^header 1^,^header 2^,^header 3^\ndata 1,data 2,data 3\n" }
      subject.remove_expression '\^'
      File.open(subject.path, 'r').read.should == "header 1,header 2,header 3\ndata 1,data 2,data 3\n"
    end
  end

  describe '#remove_malformed_rows' do
    it 'returns path to processed file' do
      File.open(test_file_path, 'w') { |f| f << 'header 1,header 2,header 3' }
      subject.remove_malformed_rows
      subject.path.should == "#{test_file_path}.corrected"
    end

    it 'saves the corrected file in the working files' do
      File.open(test_file_path, 'w') { |f| f << 'header 1,header 2,header 3' }
      subject.remove_malformed_rows
      subject.working_files.should include("#{test_file_path}.corrected")
    end

    it 'creates a corrected file from which rows with extra fields are removed' do
      File.open(test_file_path, 'w') { |f| f << "header 1,header 2,header 3\ndata 1,data 2,data 3\nd1,d2,d3,d4\n" }
      subject.remove_malformed_rows
      File.open(subject.path, 'r').read.should == "header 1,header 2,header 3\ndata 1,data 2,data 3\n"
    end

    it 'creates a corrected file from which malformed rows are removed' do
      File.open(test_file_path, 'w') { |f| f << "header 1,header 2,header 3\ndata 1,data 2,data 3\nd\x001,d\x002,d3\n" }
      subject.remove_malformed_rows
      File.open(subject.path, 'r').read.should == "header 1,header 2,header 3\ndata 1,data 2,data 3\n"
    end

    it 'ignores the delimiter inside quoted fields' do
      File.open(test_file_path, 'w') { |f| f << "'header 1','header 2','header 3'\n'data, 1','data, 2','data, 3'" }
      subject.delimiter = ","
      subject.quote = "'"
      subject.remove_malformed_rows
      File.open(subject.path, 'r').read.should == "header 1,header 2,header 3\n'data, 1','data, 2','data, 3'\n"
    end

    it 'matches on mixed quoted and unquoted fields' do
      File.open(test_file_path, 'w') { |f| f << "'header 1',header 2,'header 3'\ndata 1,'data, 2',data 3" }
      subject.delimiter = ","
      subject.quote = "'"
      subject.remove_malformed_rows
      File.open(subject.path, 'r').read.should == "header 1,header 2,header 3\ndata 1,'data, 2',data 3\n"
    end
  end

  describe '#load_file_commands' do
    it 'returns the sql to create a temporary table' do
      File.open(test_file_path, 'w') { |f| f << "header 1,header 2,header 3\n" }
      file_commands = subject.load_file_commands
      file_commands[0].should include 'DROP TABLE IF EXISTS working_table'
      file_commands[0].should include 'CREATE TEMPORARY TABLE working_table ("header 1" TEXT, "header 2" TEXT, "header 3" TEXT)'
    end
  end

  describe '#import_rows' do
    it 'returns the sql to insert each field in each row if no converters defined' do
      File.open(test_file_path, 'w') do |f|
        f << "header 1,header 2,header 3\n"
        f << "row 1 value 1,row 1 value 2,row 1 value 3\n"
        f << "row 2 value 2,row 2 value 2,row 2 value 3\n"
      end

      expected_sql = [
          "INSERT INTO working_table VALUES ('row 1 value 1', 'row 1 value 2', 'row 1 value 3')",
          "INSERT INTO working_table VALUES ('row 2 value 2', 'row 2 value 2', 'row 2 value 3')"
      ]
      i = 0

      subject.import_rows do |sql|
        expected_sql[i].should == sql
        i += 1
      end
    end

    it 'escapes the quotes in the returned sql' do
      File.open(test_file_path, 'w') do |f|
        f << "header 1,header 2,header 3\n"
        f << "value with 'quotes',value 2,value 3\n"
      end

      expected_sql = [
          "INSERT INTO working_table VALUES ('value with ''quotes''', 'value 2', 'value 3')",
      ]
      i = 0

      subject.import_rows do |sql|
        expected_sql[i].should == sql
        i += 1
      end
    end

    it 'returns the sql to insert fields using a conversion block' do
      File.open(test_file_path, 'w') do |f|
        f << "header 1,header 2,header 3\n"
        f << "value 1,value 2,value 3\n"
      end

      expected_sql = [
          "INSERT INTO working_table VALUES ('1 eulav', 'value 2', 'value 3')",
      ]
      i = 0

      subject.field 'header 1', as: lambda { |f| f.reverse }
      subject.import_rows do |sql|
        expected_sql[i].should == sql
        i += 1
      end
    end

    it 'returns the sql to insert fields using a conversion value' do
      File.open(test_file_path, 'w') do |f|
        f << "header 1,header 2,header 3\n"
        f << "value 1,value 2,value 3\n"
      end

      expected_sql = [
          "INSERT INTO working_table VALUES ('converted value', 'value 2', 'value 3')",
      ]
      i = 0

      subject.field 'header 1', as: 'converted value'
      subject.import_rows do |sql|
        expected_sql[i].should == sql
        i += 1
      end
    end

    it 'returns the sql to insert extra fields' do
      File.open(test_file_path, 'w') do |f|
        f << "value 1,value 2,value 3\n"
      end

      expected_sql = [
          "INSERT INTO working_table VALUES ('value 1', 'value 2', 'value 3', 'value for the extra column')",
      ]
      i = 0

      subject.custom_headers = %w{header1 header2 header3 header4}
      subject.field 'header4', as: 'value for the extra column'
      subject.import_rows do |sql|
        expected_sql[i].should == sql
        i += 1
      end
    end
  end
end
