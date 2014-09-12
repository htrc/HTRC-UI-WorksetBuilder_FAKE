class Registry

  # Create or update a workset
  def create_workset (username, token, workset_name, description, availability, tags, volume_ids)
    Rails.logger.debug("create_workset #{username}, #{workset_name}, #{description}, #{availability}, #{tags}")

    workset_xml =
        "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" +
        " <workset xmlns=\"http://registry.htrc.i3.illinois.edu/entities/workset\">" +
        "  <metadata>" +
        "    <name>#{workset_name}</name>" +
        "    <description>#{description}</description>" +
        "    <author>#{username}</author>" +
        #"    <availability>#{availability}</availability>" +
        "    <tags><tag>#{tags}</tag></tags>" +
        "  </metadata>"

    volumes_xml = "    <volumes>"
    for id in volume_ids
      volumes_xml += "<volume><id>#{id}</id></volume>"
    end
    volumes_xml += "</volumes>"

    workset_xml += "<content> " + volumes_xml + "</content></workset>"

    public = 'false'
    if (availability == "public")
      public = 'true'
    end

    url = URI.parse("#{APP_CONFIG['registry_url']}/worksets?public=#{public}")
    http = Net::HTTP.new(url.host, url.port)
    http.set_debug_output($stdout)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url.request_uri)
    request["Content-Type"] = "application/vnd.htrc-workset+xml"
    request.add_field("Authorization", "Bearer #{token}")
    request.body = workset_xml

    response = http.request(request)

    # response_xml = response.body
    #Rails.logger.debug(response_xml)

    case response
      when Net::HTTPUnauthorized then
        raise Exceptions::SessionExpiredError.new("Session expired")
      when Net::HTTPSuccess then
        # Do nothing
      else
        raise Exceptions::SystemError.new("System error")
    end
  end

  def update_workset (username, token, workset_name, description, availability, tags)
    Rails.logger.debug("update_workset #{username}, #{workset_name}, #{description}, #{availability}, #{tags}")

    workset_xml =
        "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" +
            " <workset xmlns=\"http://registry.htrc.i3.illinois.edu/entities/workset\">" +
            "  <metadata>" +
            "    <name>#{workset_name}</name>" +
            "    <description>#{description}</description>" +
            "    <author>#{username}</author>" +
            #"    <availability>#{availability}</availability>" +
            "    <tags><tag>#{tags}</tag></tags>" +
            "  </metadata>"+
            " </workset>"


    public = 'false'
    if (availability == "public")
      public = 'true'
    end

    url = URI.parse("#{APP_CONFIG['registry_url']}/worksets/#{workset_name}?public=#{public}")
    http = Net::HTTP.new(url.host, url.port)
    http.set_debug_output($stdout)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Put.new(url.request_uri)
    request["Content-Type"] = "application/vnd.htrc-workset+xml"
    request.add_field("Authorization", "Bearer #{token}")
    request.body = workset_xml

    response = http.request(request)

    #response_xml = response.body
    #Rails.logger.debug(response_xml)

    case response
      when Net::HTTPUnauthorized then
        raise Exceptions::SessionExpiredError.new("Session expired. Please login again")
      when Net::HTTPSuccess then
        # Do nothing
      else
        raise Exceptions::SystemError.new("Error retrieving worksets (HTTP #{response.code})")
    end
  end

  # Update volumes associated with the workset
  def update_volumes(username, token, workset_name, volume_ids)

    #<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    #<volumes xmlns="http://registry.htrc.i3.illinois.edu/entities/workset">
    #  <volume>
    #   <id>9999999</id>
    #  </volume>
    #  <volume>
    #   <id>3333333</id>
    #  </volume>
    # </volumes>
    volumes_xml =
        "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" +
        "<volumes xmlns=\"http://registry.htrc.i3.illinois.edu/entities/workset\">";

    for id in volume_ids
      volumes_xml += "<volume><id>#{id}</id></volume>"
    end
    volumes_xml += "</volumes>"


    # curl -v --data @new_volumes.xml -X PUT \
    #   -H "Content-Type: application/vnd.htrc-volume+xml" \
    #   -H "Accept: application/vnd.htrc-volume+xml" \
    #   http://localhost:9763/ExtensionAPI-0.1.0/services/worksets/workset1/volumes?user=fred

    url = URI.parse("#{APP_CONFIG['registry_url']}/worksets/#{workset_name}/volumes")
    http = Net::HTTP.new(url.host, url.port)
    http.set_debug_output($stdout)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Put.new(url.request_uri)
    request["Content-Type"] = "application/vnd.htrc-volume+xml"
    request.add_field("Authorization", "Bearer #{token}")

    request.body = volumes_xml
    response = http.request(request)

    #xml = response.body

    case response
      when Net::HTTPUnauthorized then
        raise Exceptions::SessionExpiredError.new("Session expired. Please login again")
      when Net::HTTPSuccess then
        # Do nothing
      else
        raise Exceptions::SystemError.new("Error retrieving worksets (HTTP #{response.code})")
    end

  end

  # Create or update volumes associated with the workset
  def create_update_volumes(username, token, workset_name, volume_ids)

    #<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    #<volumes xmlns="http://registry.htrc.i3.illinois.edu/entities/workset">
    #  <volume>
    #   <id>9999999</id>
    #  </volume>
    #  <volume>
    #   <id>3333333</id>
    #  </volume>
    # </volumes>
    volumes_xml =
        "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" +
            "<volumes xmlns=\"http://registry.htrc.i3.illinois.edu/entities/workset\">";

    for id in volume_ids
      volumes_xml += "<volume><id>#{id}</id></volume>"
    end
    volumes_xml += "</volumes>"


    # curl -v --data @new_volumes.xml -X PUT \
    #   -H "Content-Type: application/vnd.htrc-volume+xml" \
    #   -H "Accept: application/vnd.htrc-volume+xml" \
    #   http://localhost:9763/ExtensionAPI-0.1.0/services/worksets/workset1/volumes?user=fred

    url = URI.parse("#{APP_CONFIG['registry_url']}/worksets/#{workset_name}")
    http = Net::HTTP.new(url.host, url.port)
    http.set_debug_output($stdout)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Put.new(url.path)
    request["Content-Type"] = "application/vnd.htrc-volume+xml"
    request.add_field("Authorization", "Bearer #{token}")

    request.body = volumes_xml
    response = http.request(request)

    #xml = response.body

    case response
      when Net::HTTPUnauthorized then
        raise Exceptions::SessionExpiredError.new("Session expired. Please login again")
      when Net::HTTPSuccess then
        # Do nothing
      else
        raise Exceptions::SystemError.new("Error retrieving worksets (HTTP #{response.code})")
    end
  end


  # List  worksets accessible by the specified user
  def list_worksets (username, token, include_public)
    Rails.logger.debug "list_public_worksets #{username}"

    url = URI.parse("#{APP_CONFIG['registry_url']}/worksets?public=#{include_public}")
    http = Net::HTTP.new(url.host, url.port)
    http.set_debug_output($stdout)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url.request_uri)
    request.add_field("Authorization", "Bearer #{token}")
    request.add_field("Accept", "application/vnd.htrc-workset+xml")
    response = http.request(request)
    Rails.logger.debug "Response Code: #{response.code}"



    case response
      when Net::HTTPUnauthorized then
        raise Exceptions::SessionExpiredError.new("Session expired. Please login again")
      when Net::HTTPSuccess then
        # Do nothing
      else
        raise Exceptions::SystemError.new("Error retrieving worksets (HTTP #{response.code})")
    end

    response_xml = response.body
    #Rails.logger.debug response_xml

    worksets = Array.new

    doc = REXML::Document.new(response_xml)

    doc.elements.each('worksets/workset/metadata') { |metadata|
        hash = Hash.new
        hash['name'] = metadata.elements['name'].text
        hash['description'] = metadata.elements['description'].text
        hash['author'] = metadata.elements['author'].text

        if (hash['author'] == username)
          worksets.unshift(hash)
        else
          worksets.push(hash)
        end
      }

    id = 1
    worksets.each { |w|
      w['id'] = id;
      id = id+1

    }

    return worksets
   end



    # Get the attributes of the specified workset
    def get_workset  (token, author, workset_name)
      Rails.logger.debug "get_workset  #{author}, #{workset_name}"

      #curl -v -X GET -H "Accept: application/vnd.htrc-workset+xml" \
      # http://localhost:9763/ExtensionAPI-0.1.0/services/worksets/workset1?user=fred

      url = URI.parse("#{APP_CONFIG['registry_url']}/worksets/#{workset_name}?author=#{author}")
      http = Net::HTTP.new(url.host, url.port)
      http.set_debug_output($stdout)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(url.request_uri)
      request.add_field("Authorization", "Bearer #{token}")
      request.add_field("Accept", "application/vnd.htrc-workset+xml")
      response = http.request(request)
      #Rails.logger.debug "Response Code: #{response.code}"

      case response
        when Net::HTTPUnauthorized then
          raise Exceptions::SessionExpiredError.new("Session expired. Please login again")
        when Net::HTTPSuccess then
          # Do nothing
        else
          raise Exceptions::SystemError.new("Error retrieving worksets (HTTP #{response.code})")
      end

      response_xml = response.body
      #Rails.logger.debug response_xml

      doc = REXML::Document.new(response_xml)
      workset = Hash.new
      doc.elements.each("/workset/metadata") { |metadata|

      workset['name'] = metadata.elements['name'].text
      workset['description'] = metadata.elements['description'].text
      workset['author'] = metadata.elements['author'].text

    }
    return workset

  end


  # Get the volume IDs for the specified workset
  def get_workset_volumes  (author, token, workset_name)
    Rails.logger.debug "get_workset_volumes  #{author}, #{workset_name}"
    url = URI.parse("#{APP_CONFIG['registry_url']}/worksets/#{workset_name}/volumes?author=#{author}")
    http = Net::HTTP.new(url.host, url.port)
    http.set_debug_output($stdout)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url.request_uri)
    request.add_field("Authorization", "Bearer #{token}")
    request.add_field("Accept", "application/vnd.htrc-workset+xml")
    response = http.request(request)

    case response
      when Net::HTTPUnauthorized then
        raise Exceptions::SessionExpiredError.new("Session expired. Please login again")
      when Net::HTTPSuccess then
        # Do nothing
      else
        raise Exceptions::SystemError.new("Error retrieving worksets (HTTP #{response.code})")
    end

    #Rails.logger.debug "Response Code: #{response.code}"

    volumes = response.body
    ids = volumes.split(" ")
    return ids
  end


  # Delete the specified workset
  def delete_workset  (token, workset_name)
    Rails.logger.debug "delete_workset #{workset_name}"

    url = URI.parse("#{APP_CONFIG['registry_url']}/worksets/#{workset_name}")
    http = Net::HTTP.new(url.host, url.port)
    http.set_debug_output($stdout)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Delete.new(url.request_uri)
    request.add_field("Authorization", "Bearer #{token}")
    request.add_field("Accept", "application/vnd.htrc-workset+xml")
    response = http.request(request)

    case response
      when Net::HTTPUnauthorized then
        raise Exceptions::SessionExpiredError.new("Session expired. Please login again")
      when Net::HTTPSuccess then
        # Do nothing
      else
        raise Exceptions::SystemError.new("Error deleting workset (HTTP #{response.code})")
    end

  end
end
