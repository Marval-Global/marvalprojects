module Interceptors
  module DefaultHeaders
    module_function

    def delivering_email(mail)
      mail.headers(default_headers)
    end

    def default_headers
      {
        "X-Mailer" => "MarvalProjects",
        "X-MarvalProjects-Host" => Setting.host_name,
        "X-MarvalProjects-Site" => Setting.app_title,
        "Precedence" => "bulk",
        "Auto-Submitted" => "auto-generated"
      }
    end
  end
end
