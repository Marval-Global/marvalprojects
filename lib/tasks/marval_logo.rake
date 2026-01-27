# frozen_string_literal: true

#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

namespace :marval do
  desc "Set Marval logo as PDF export logo"
  task set_export_logo: :environment do
    custom_style = CustomStyle.current || CustomStyle.create!

    logo_path = Rails.root.join("app/assets/images/Marval_logo_colour.svg")

    unless File.exist?(logo_path)
      puts "❌ Error: Logo file not found at #{logo_path}"
      exit 1
    end

    File.open(logo_path, 'rb') do |file|
      uploadable_file = OpenProject::Files.build_uploaded_file(
        file,
        'image/svg+xml',
        file_name: 'Marval_logo_colour.svg'
      )

      custom_style.export_logo = uploadable_file

      if custom_style.save
        puts "✅ Successfully set Marval logo as PDF export logo"
      else
        puts "❌ Failed to save custom style: #{custom_style.errors.full_messages.join(', ')}"
        exit 1
      end
    end
  end
end