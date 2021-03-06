class VoterFile::CSVDriver::RecordMatcher

  attr_accessor :target_table, :source_table, :exact_match_groups,
                :column_constraints, :working_source_table, :join_clauses

  SOURCE_KEY_NAME = "working_source_id"
  TARGET_KEY_NAME = "working_target_id"

  def initialize(&block)
    @exact_match_groups = []
    @column_constraints = []
    @join_clauses = []
    @working_source_table = block.call if block_given?
  end

  def exact_match_group(*col_names)
    self.exact_match_groups << col_names.map(&:to_sym)
  end

  def foreign_key_match(map)
    exact_match_groups << [ map ]
  end

  def constrain_column(col_name, constraint)
    column_constraints << [col_name, constraint]
  end

  def join_table(*clause)
    join_clauses << clause
  end

  def match_commands
    raise "Target table must have a primary key" unless target_table.primary_key
    ([create_working_source_table_sql] + find_exact_match_commands).compact
  end

  def create_working_source_table_sql
    name = working_source_table.name
    source_name = source_table.name
    %Q{
      DROP TABLE IF EXISTS #{name};
      CREATE TEMPORARY TABLE #{name} ( LIKE #{source_name} );
      ALTER TABLE #{name} ADD COLUMN #{SOURCE_KEY_NAME} SERIAL;
      ALTER TABLE #{name} ADD COLUMN #{TARGET_KEY_NAME} #{target_table.primary_key_type};
      INSERT INTO #{name} ( SELECT * from #{source_name} );}
  end

  def find_exact_match_commands
    commands = exact_match_groups.map do |group|
      case group
        when Array
          find_exact_match_sql(group)
        when VoterFile::CSVDriver::RecordMatcher
          group.find_exact_match_commands
      end
    end
    commands.flatten
  end

  def find_exact_match_sql(column_group)
    match_conditions = exact_match_conditions(column_group)
    match_conditions += " AND #{column_constraint_conditions}" if column_constraint_conditions

    %Q{
      UPDATE #{working_source_table.name} s
        SET #{TARGET_KEY_NAME} = t.#{target_table.primary_key}
        FROM #{target_table.name} t #{join_sql}
        WHERE s.#{TARGET_KEY_NAME} IS NULL AND #{match_conditions} }
  end

  def exact_match_conditions(column_group)
    conditions = column_group.map do |c|
      case c
        when Hash
          "( s.#{c[:source_key]} = t.#{c[:target_key]} )"
        else
          "( s.#{c} = t.#{c} )"
      end
    end
    "( #{conditions.join(" AND ")} )"
  end

  def column_constraint_conditions
    return nil if column_constraints.empty?
    "( " + column_constraints.map{|c| c[1].gsub('$S', "s.#{c[0]}").gsub('$T', "t.#{c[0]}") }.join(" AND ") + " )"
  end

  def join_sql
    join_clauses.map{|clause| "JOIN #{clause[0].name} ON ( #{clause[1]} )"}.join(' ')
  end

  def find_exact_matches
    matcher = VoterFile::CSVDriver::RecordMatcher.new
    matcher.working_source_table = working_source_table
    matcher.target_table = target_table
    matcher.source_table = source_table

    yield matcher

    self.exact_match_groups << matcher
    return matcher
  end

end