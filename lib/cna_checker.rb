# cna_checker.rb usage
#   checker = CnaChecker.new("ca")
#   checker.check("URBARDO", "SAA", "00346525")

require 'mechanize'
require 'yaml'

class CnaChecker
  # set the defaults settings from the yml config file associated with the state
  def initialize(state)
    state_config_file = File.join(File.dirname(__FILE__), "../config/#{state}.yml")
    @config = YAML.load_file(state_config_file)
  end

  # check will return true if the CNA is a valid CNA, false otherwise
  def check(first_name, last_name, cert_number)
    cert, status = query(first_name, last_name)
    (is_active_status?(status) && cert == cert_number) ? true : false
  end

  private
  # return cert_number and status for first_name and last_name
  def query(first_name, last_name)
    #Form params contains:
    #  - default fields defined in the yml config file
    #  - name fields generated from first_name and last_name
    #  - custom fields when necessary
    custom_params = {'__VIEWSTATE' => get_view_state}
    name_params = name_params(first_name, last_name)
    post_params = default_form_params.merge(custom_params).merge(name_params)

    page = agent.post url, post_params

    cert_number = page.root.css(cert_path).text
    status = page.root.css(status_path).text

    return cert_number, status
  end

  def agent
    @agent ||= Mechanize.new
  end

  def url
    @config["url"]
  end

  def defaults
    @config["defaults"]
  end

  def fields
    @config["fields"]
  end

  def cert_path
    @config["cert_path"]
  end

  def status_path
    @config["status_path"]
  end

  def default_form_params
    default_params = {}
    defaults.each_key do |key|
      default_params[fields[key]] = defaults[key]
    end
    default_params
  end

  def get_view_state
    page = agent.get url
    form = page.forms.first
    form.field_with(name: /VIEW/).value
  end

  def is_active_status?(status)
    /ACTIVE/.match(status) if status
  end

  def name_params(first_name, last_name)
    {
        fields['first_name'] => first_name,
        fields['last_name'] => last_name
    }
  end
end