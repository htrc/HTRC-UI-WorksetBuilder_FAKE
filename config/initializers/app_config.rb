APP_CONFIG = YAML.load_file("#{Rails.root}/config/htrc.yml")[Rails.env]

# Put in any constants for HTRC here...
$MAX_SINGLE_SEARCH_FOR_FOLDER          = 5000