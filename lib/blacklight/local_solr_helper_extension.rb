# -*- encoding : utf-8 -*-
# LocalSolrHelperExtension extends (locally) SolrHelper, which is a controller layer mixin. It is in the controller scope: request params, session etc.
# 
module LocalSolrHelperExtension
  extend ActiveSupport::Concern
  include Blacklight::SolrHelper
  require 'net/http'

  #     [ local overrides ]

  # intercept "find" call in order to add the header parameters & save query parser value, if any
  def find(*args)
    # response = Blacklight.solr.find(*args)

    # add header-adding override code here
    path, params, opts = request_arguments_for(*args)
    if (opts.has_key?(:headers))
      # if headers hash already exists, add the header parameters we want... NOTE: these headers may be duplicates in existing headers hash
      opts[:headers].merge!(get_header_params[:headers])
    else
      opts.merge!(get_header_params)
    end

    # save query parser value (if it exists) because it can change, depending upon search, and we need it to retrieve ids (in private methods inside
    #    folder_controller.rb)
    if (params.has_key?(:defType))
      session[:search][:defType] = params[:defType]
    else
      session[:search].delete(:defType)
    end
    response = Blacklight.solr.find(path, params, opts)

    force_to_utf8(response)
  rescue Errno::ECONNREFUSED => e
    raise Blacklight::Exceptions::ECONNREFUSED.new("Unable to connect to Solr instance using #{Blacklight.solr.inspect}")
  end

  private

  # Helper method to return the parameters needed for requesting
  # from Solr. (copied from Rsolr::Ext::Client, version 1.0.3)
  def request_arguments_for *args
    [].tap do |arr|
      # remove the handler arg - the first, if it is a string OR set default
      arr << (args.first.is_a?(String) ? args.shift : nil)
      # remove the params - the first, if it is a Hash OR set default
      arr << (args.first.kind_of?(Hash) ? args.shift : {})
      # everything that isn't params is opts
      arr << (args.first.kind_of?(Hash) ? args.shift : {})
    end
  end

end

