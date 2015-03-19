module Backup
  class Uploads
    attr_reader :app_uploads_dir, :backup_uploads_dir, :backup_dir

    def initialize
      @app_uploads_dir = File.realpath(Rails.root.join('public', 'uploads'))
      @backup_dir = Gitlab.config.backup.path
      @backup_uploads_dir = File.join(Gitlab.config.backup.path, 'uploads')
    end

    # Copy uploads from public/uploads to backup/uploads
    def dump
      FileUtils.mkdir_p(backup_uploads_dir)
      FileUtils.cp_r(app_uploads_dir, backup_dir)
    end

    def restore
      backup_existing_uploads_dir

      FileUtils.cp_r(backup_uploads_dir, app_uploads_dir)
    end

    def backup_existing_uploads_dir
      timestamped_uploads_path = File.join(app_uploads_dir, '..', "uploads.#{Time.now.to_i}")
      if File.exists?(app_uploads_dir)
        FileUtils.mv(app_uploads_dir, timestamped_uploads_path)
      end
    end
  end
end
