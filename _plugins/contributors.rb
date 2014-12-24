require 'json'
require 'net/http'

class Github
  def self.contributors(repo)
    connection = Net::HTTP.new('api.github.com', 443)
    connection.use_ssl = true
    
    req = Net::HTTP::Get.new("/repos/#{repo}/contributors")
    
    response = connection.request(req)
    
    JSON.parse(response.body)
  end
  
  def self.current_version(repo)
    current_release(repo)['name']
  end
  
  def self.current_release_asset_url(repo, file)
    "https://github.com/#{repo}/releases/download/#{current_version(repo)}/#{file}"
  end
  
  def self.current_release(repo)
    releases(repo).first
  end
  
  def self.releases(repo)
    connection = Net::HTTP.new('api.github.com', 443)
    connection.use_ssl = true
    
    req = Net::HTTP::Get.new("/repos/#{repo}/releases")
    
    response = connection.request(req)
    
    JSON.parse(response.body)
  end
  
end

class RubyGems
  class Gem
    def initialize(name)
      @name = name
    end
    
    def info
      connection = Net::HTTP.new('rubygems.org', 443)
      connection.use_ssl = true
    
      req = Net::HTTP::Get.new("/api/v1/gems/#{@name}.json")
    
      response = connection.request(req)
    
      JSON.parse(response.body)
    end
    
    def version
      info['version']
    end
    
  end
end


module Jekyll
  
  class ContributorsTag < Liquid::Tag
    def initialize(tag_name, arguments, tokens)
      super
      arguments = arguments.strip.split(' ')
      @repo = arguments[0]
    end

    def render(context)
      html = ''
      
      Github.contributors(@repo).each do |contributor|
        html += <<-HTML
          <div class="contributor">
            <a href="#{contributor['html_url']}">
              <img src=\"#{contributor["avatar_url"]}\">
              <span class="name">#{contributor['login']}</span>
            </a>
          </div>
          HTML
      end
      
      html
    end
  end
  
  class CurrentVersion < Liquid::Tag
    def initialize(tag_name, arguments, tokens)
      super
      arguments = arguments.strip.split(' ')
      @gem = RubyGems::Gem.new(arguments[0])
    end

    def render(context)
      @gem.version
    end
  end
  
  class CurrentReleaseAssetUrl < Liquid::Tag
    def initialize(tag_name, arguments, tokens)
      super
      arguments = arguments.strip.split(' ')
      @repo = arguments[0]
      @file = arguments[1]
    end    

    def render(context)
      Github.current_release_asset_url(@repo, @file)
    end
  end
  
end

Liquid::Template.register_tag('contributors', Jekyll::ContributorsTag)
Liquid::Template.register_tag('gem_version', Jekyll::CurrentVersion)
Liquid::Template.register_tag('asset_url', Jekyll::CurrentReleaseAssetUrl)