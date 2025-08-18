# frozen_string_literal: true

class UpdateSettingsValues < ActiveRecord::Migration[8.0]
  def up
    update_setting('app_title', 'MarvalProjects')
    update_setting('mail_from', 'MarvalProjects@example.net')
    update_setting('software_name', 'MarvalProjects')
    update_setting('welcome_title', 'Welcome to MarvalProjects!')
    update_setting('welcome_text', <<~TEXT)
      <p>MarvalProjects is the leading open source project management software. It supports classic, agile, and hybrid project management and gives you full control over your data.</p>

      <p><strong>Welcome to the future of project management.</strong></p>

      <p>For Admins: You can change this welcome text <a href="{{opSetting:base_url}}/admin/settings/general">here</a>.</p>
    TEXT

    update_user_firstname('admin', 'MarvalProjects')

    new_value = <<~YAML
      ---
      en: |-
        ## Consent

        You need to agree to the [privacy and security policy](https://www.openproject.org/data-privacy-and-security/) of this MarvalProjects instance.
    YAML

    execute <<~SQL
      UPDATE settings
      SET value = '#{new_value.gsub("'", "''")}'
      WHERE name = 'consent_info';
    SQL
    
  end

  def down
    update_setting('app_title', 'MarvalProjects')
    update_setting('mail_from', 'MarvalProjects@example.net')
    update_setting('software_name', 'MarvalProjects')
    update_setting('welcome_title', 'Welcome to MarvalProjects!')
    update_setting('welcome_text', <<~TEXT)
      <p>MarvalProjects is the leading open source project management software. It supports classic, agile, and hybrid project management and gives you full control over your data.</p>

      <p><strong>Welcome to the future of project management.</strong></p>

      <p>For Admins: You can change this welcome text <a href="{{opSetting:base_url}}/admin/settings/general">here</a>.</p>
    TEXT

    previous_value = <<~YAML
      ---
      en: |-
        ## Consent

        You need to agree to the [privacy and security policy](https://www.openproject.org/data-privacy-and-security/) of this MarvalProjects instance.
    YAML

    execute <<~SQL
      UPDATE settings
      SET value = '#{previous_value.gsub("'", "''")}'
      WHERE name = 'consent_info';
    SQL

    update_user_firstname('admin', 'MarvalProjects')
    
    
  end

  def update_setting(name, new_value)
    execute <<-SQL.squish
      UPDATE settings
      SET value = '#{sanitize_sql(new_value)}'
      WHERE name = '#{name}'
    SQL
  end

  def update_user_firstname(old_name, new_name)
    execute <<-SQL.squish
      UPDATE users
      SET firstname = '#{new_name}'
      WHERE login = '#{old_name}'
    SQL
  end


  def sanitize_sql(value)
    value.gsub("'", "''") # escape single quotes for SQL safety
  end

 
end

