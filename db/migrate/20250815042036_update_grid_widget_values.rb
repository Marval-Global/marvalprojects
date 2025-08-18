# frozen_string_literal: true

class UpdateGridWidgetValues < ActiveRecord::Migration[8.0]
  def up
    yaml_content = <<~YAML
      ---
      name: Getting started
      text: |
        We are glad you joined! We suggest to try a few things to get started in MarvalProjects.

        Discover the most important features with our [Guided Tour]({{opSetting:base_url}}/projects/demo-project/work_packages/?start_onboarding_tour=true).

        _Try the following steps:_

        1. *Invite new members to your project*: → Go to [Members]({{opSetting:base_url}}/projects/demo-project/members) in the project navigation.
        2. *View the work in your project*: → Go to [Work packages]({{opSetting:base_url}}/projects/demo-project/work_packages) in the project navigation.
        3. *Create a new work package*: → Go to [Work packages → Create]({{opSetting:base_url}}/projects/demo-project/work_packages/new).
        4. *Create and update a project plan*: → Go to [Project plan]({{opSetting:base_url}}/projects/demo-project/work_packages?query_id=1) in the project navigation.
        5. *Activate further modules*: → Go to [Project settings → Modules]({{opSetting:base_url}}/projects/demo-project/settings/modules).
        6. *Complete your tasks in the project*: → Go to [Work packages → Tasks]({{opSetting:base_url}}/projects/demo-project/work_packages/details/3/overview?query_id=3).

        Here you will find our [User Guides](https://www.openproject.org/docs/user-guide/).
        Please let us know if you have any questions or need support. Contact us: [support[at]marvalprojects.com](mailto:support@marvalglobal.com).
    YAML

    new_yaml = <<~YAML
      ---
      name: Getting started
      text: |
        We are glad you joined! We suggest to try a few things to get started in MarvalProjects.

        _Try the following steps:_

        1. *Invite new members to your project*: → Go to [Members]({{opSetting:base_url}}/projects/your-scrum-project/members) in the project navigation.
        2. *View your Product backlog and Sprint backlogs*: → Go to [Backlogs]({{opSetting:base_url}}/projects/your-scrum-project/backlogs) in the project navigation.
        3. *View your Task board*: → Go to [Backlogs]({{opSetting:base_url}}/projects/your-scrum-project/backlogs) → Click on right arrow on Sprint → Select [Task Board](/projects/your-scrum-project/sprints/3/taskboard).
        4. *Create a new work package*: → Go to [Work packages → Create]({{opSetting:base_url}}/projects/your-scrum-project/work_packages/new).
        5. *Create and update a project plan*: → Go to [Project plan](/projects/your-scrum-project/work_packages?query_id=15) in the project navigation.
        6. *Create a Sprint wiki*: → Go to [Backlogs]({{opSetting:base_url}}/projects/your-scrum-project/backlogs) and open the sprint wiki from the right drop down menu in a sprint. You can edit the [wiki template]({{opSetting:base_url}}/projects/your-scrum-project/wiki/) based on your needs.
        7. *Activate further modules*: → Go to [Project settings → Modules]({{opSetting:base_url}}/projects/your-scrum-project/settings/modules).

        Here you will find our [User Guides](https://www.openproject.org/docs/user-guide/).
        Please let us know if you have any questions or need support. Contact us: [support@marvalprojects.com](mailto:support@marvalglobal.com).
    YAML

    execute <<~SQL
      UPDATE grid_widgets
      SET options = '#{yaml_content.gsub("'", "''")}'
      WHERE id = 20;
    SQL

     execute <<~SQL
      UPDATE grid_widgets
      SET options = '#{new_yaml.gsub("'", "''")}'
      WHERE id = 27;
    SQL
  end

  def down
    # Restore the previous value here. Example:
    previous_content = <<~YAML
      ---
      name: Welcome
       text: |
        We are glad you joined! We suggest to try a few things to get started in MarvalProjects.

        Discover the most important features with our [Guided Tour]({{opSetting:base_url}}/projects/demo-project/work_packages/?start_onboarding_tour=true).

        _Try the following steps:_

        1. *Invite new members to your project*: → Go to [Members]({{opSetting:base_url}}/projects/demo-project/members) in the project navigation.
        2. *View the work in your project*: → Go to [Work packages]({{opSetting:base_url}}/projects/demo-project/work_packages) in the project navigation.
        3. *Create a new work package*: → Go to [Work packages → Create]({{opSetting:base_url}}/projects/demo-project/work_packages/new).
        4. *Create and update a project plan*: → Go to [Project plan]({{opSetting:base_url}}/projects/demo-project/work_packages?query_id=1) in the project navigation.
        5. *Activate further modules*: → Go to [Project settings → Modules]({{opSetting:base_url}}/projects/demo-project/settings/modules).
        6. *Complete your tasks in the project*: → Go to [Work packages → Tasks]({{opSetting:base_url}}/projects/demo-project/work_packages/details/3/overview?query_id=3).

        Here you will find our [User Guides](https://www.openproject.org/docs/user-guide/).
        Please let us know if you have any questions or need support. Contact us: [support[at]marvalprojects.com](mailto:support@marvalglobal.com).
    YAML

    new_yaml = <<~YAML
      ---
      name: Getting started
      text: |
        We are glad you joined! We suggest to try a few things to get started in MarvalProjects.

        _Try the following steps:_

        1. *Invite new members to your project*: → Go to [Members]({{opSetting:base_url}}/projects/your-scrum-project/members) in the project navigation.
        2. *View your Product backlog and Sprint backlogs*: → Go to [Backlogs]({{opSetting:base_url}}/projects/your-scrum-project/backlogs) in the project navigation.
        3. *View your Task board*: → Go to [Backlogs]({{opSetting:base_url}}/projects/your-scrum-project/backlogs) → Click on right arrow on Sprint → Select [Task Board](/projects/your-scrum-project/sprints/3/taskboard).
        4. *Create a new work package*: → Go to [Work packages → Create]({{opSetting:base_url}}/projects/your-scrum-project/work_packages/new).
        5. *Create and update a project plan*: → Go to [Project plan](/projects/your-scrum-project/work_packages?query_id=15) in the project navigation.
        6. *Create a Sprint wiki*: → Go to [Backlogs]({{opSetting:base_url}}/projects/your-scrum-project/backlogs) and open the sprint wiki from the right drop down menu in a sprint. You can edit the [wiki template]({{opSetting:base_url}}/projects/your-scrum-project/wiki/) based on your needs.
        7. *Activate further modules*: → Go to [Project settings → Modules]({{opSetting:base_url}}/projects/your-scrum-project/settings/modules).

        Here you will find our [User Guides](https://www.openproject.org/docs/user-guide/).
        Please let us know if you have any questions or need support. Contact us: [support@marvalprojects.com](mailto:support@marvalglobal.com).
    YAML

    execute <<~SQL
      UPDATE grid_widgets
      SET options = '#{previous_content.gsub("'", "''")}'
      WHERE id = 20;
    SQL

     execute <<~SQL
      UPDATE grid_widgets
      SET options = '#{new_yaml.gsub("'", "''")}'
      WHERE id = 27;
    SQL
  end
end
