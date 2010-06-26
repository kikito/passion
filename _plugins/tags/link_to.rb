module Jekyll
  class LinkToTag < Liquid::Tag
    safe true

    StringOrWord = /"[^"]*"|'[^']*'|\S+/
    Syntax = /(#{StringOrWord})\s*#{Liquid::ArgumentSeparator}\s*(#{StringOrWord})/

    def initialize(tag_name, markup, tokens)
      super

      if markup =~ Syntax
        @title = $1
        @url = $2
      else
        raise SyntaxError.new("Syntax Error in 'link_to' - Valid syntax: {% link_to 'title', url %}")
      end

    end

    # if the url is localized (begins with /) and there's a variable called root_path con _config,
    # then prepent the url with it. This is useful on pages for github projects (you dont have to 
    # prepend 'yourproject' on all links
    def render(context)
      url = @url
      if(@url[0,1]=='/' and context['site'] and context['site']['root_path'])
        url = "/#{context['site']['root_path']}/#{@url}".gsub(/\/\/|\\/, "/")
      end
      "<a href='#{url}'>#{@title}</a>"
    end
  end
end

Liquid::Template.register_tag('link_to', Jekyll::LinkToTag)

