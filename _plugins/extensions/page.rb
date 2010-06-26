module Jekyll

  class Page
    def to_liquid
      self.data.deep_merge({
        "url" => File.join(@dir, self.url),
        "content" => self.content,
        "dir" => @dir,
        "dirs" => self.dirs,
        "last_dir" => self.dirs.last,
        "first_dir" => self.dirs.first,
        "html?" => self.html?,
        "index?" => self.index?,
        "basename" => self.basename
      })
    end
    def dirs
      @dirs ||=  @dir.gsub(/\/\/|\\/, "/").split("/")
    end
  end
end
