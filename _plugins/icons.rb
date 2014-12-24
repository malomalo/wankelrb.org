class Icons
  
  def self.parse
    data = JSON.parse(File.read("#{File.dirname(__FILE__)}/../_assets/fonts/selection.json"))
    icon_hash = {}
    data["icons"].each do |icon|
      icon_hash[icon["properties"]["name"].gsub("-", "_").to_sym] = icon["properties"]["code"].to_s(16)
    end
    icon_hash
  end

  def self.mapping
    @@mapping ||= parse
  end
  
  def self.symbol(name)
    mapping[name]
  end
  
end

module Jekyll
  class IconTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @name = text.strip.split(' ')[0]
    end

    def render(context)
      "<span class=\"icon\">#{icon(@name)}</span>"
    end
    
    def icon(name)
      "&#x#{Icons.symbol(name.to_sym)};"
    end
    
  end
end

Liquid::Template.register_tag('icon', Jekyll::IconTag)