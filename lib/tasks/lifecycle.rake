namespace :lifecycle do
  desc "This task aborts rake flow if webcat is NOT installed"
  task :ensure_installed => :environment do
    safe_execute_task do
      unless ActiveRecord::Base.connection.active?
        log_error("ABORT: Database does not exist")
      end
    end
  end

  desc "This task aborts rake flow if webcat is installed"
  task :ensure_db_conditions => :environment do
    safe_execute_task do
      if ActiveRecord::Base.connection.active?
        result = ActiveRecord::Base.connection.execute("show tables")
        if(result.size > 0)
          log_error("ABORT: Database is not empty")
        end

        packet_size_result = ActiveRecord::Base.connection.execute("show variables like 'max_allowed_packet'")
        packet_size = packet_size_result.first[1].to_i
        if(packet_size < 546308096)
          log_error("ABORT: Database global setting 'max_allowed_packet' does not meet requirements")
        end
      end
    end
  end

  task :fix_db => :environment do
    safe_execute_task do
      if ActiveRecord::Base.connection.active?
        ActiveRecord::Base.connection.execute("set global max_allowed_packet = 546308096")
      end
    end
  end

  task :fix_collate => :environment do
    safe_execute_task do
      if ActiveRecord::Base.connection.active?
        ActiveRecord::Base.connection.execute("alter database webcat character set utf8 collate utf8_general_ci")
      end
    end
  end

  task :fix_builds_table => :environment do
    safe_execute_task do
      if ActiveRecord::Base.connection.active?
        ActiveRecord::Base.connection.execute("alter table builds convert to character set utf8 collate utf8_general_ci")
      end
    end
  end

  task :install => [:ensure_db_conditions, "db:create", :fix_collate, "db:schema:load", :fix_builds_table, "db:seed"]
  task :update => [:ensure_installed, "db:migrate"]
end

def safe_execute_task
  begin
    yield
  rescue
    log_error("ABORT: Database does not exist")
  end
end

def log_error(msg)
  ActiveRecord::Base.logger.error(msg)
  abort(msg)
end