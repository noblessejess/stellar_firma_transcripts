require_relative 'episode'

@ep_dir    = '_posts'


def cleanup_all(fnames=episode_fnames)
  fnames.each_with_index do |fname, i|
    print "\r#{i+1} / #{fnames.count} => #{File.basename(fname)}              "
    cleanup_one(fname)
  end
end

def cleanup_one(fname=episode_fnames[4])
  ep = Episode::from_file(fname)
  md = ep.md

  {
    '<p style="text-align:left;">' => '', 
    '____'                         => '', 
    '__[crosstalk]__'              => '_[crosstalk]_', 
    '__crosstalk]__'               => '_[crosstalk]_', 
  }.each {|k,v| md.gsub!(k,v)}

  md = replace_misformatted_speaker_labels(md)
  md = replace_misformatted_captions(md)
  md = trim_whitespace_from_lines(md)

  ep.md = md
  ep.save
end



def replace_misformatted_speaker_labels(md)
  rx = /\n__([A-Z0-9 ]+)__:/
  while m = rx.match(md)
    md.gsub!(m[0], "\n#### #{m[1]}\n\n".upcase)
  end
  rx = /\n__([A-Z0-9 ]+):__/
  while m = rx.match(md)
    md.gsub!(m[0], "\n#### #{m[1]}\n\n".upcase)
  end

  # # incl lowercase:
  # rx = /\n__([A-Za-z0-9 ]+)__:/
  # while m = rx.match(md)
  #   md.gsub!(m[0], "\n#### #{m[1]}\n\n".upcase)
  # end
  # rx = /\n__([A-Za-z0-9 ]+):__/
  # while m = rx.match(md)
  #   md.gsub!(m[0], "\n#### #{m[1]}\n\n".upcase)
  # end

  return md
end

def replace_misformatted_captions(md)
  rx = /\n__(\[[^\n\]\[]+\])__\n/
  while m = rx.match(md)
    md.gsub!(m[0], "\n##### #{m[1]}\n")
  end
  return md
end

def trim_whitespace_from_lines(md)
  md = md.split("\n").map do |line|
    line.strip.gsub(/[[:blank:]]+/, ' ')
  end.join("\n")
end






def episode_fnames(dir=@ep_dir)
  Dir.glob(File.join(dir, '*.md')).sort
end