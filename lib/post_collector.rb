require 'net/imap'
require File.dirname(__FILE__) + '/model'

class PostCollector
  
  IMAP_SERVER = 'imap.gmail.com'
  IMAP_PORT = 993
  IMAP_MBOX = 'INBOX'
  IMAP_USER = '######'
  IMAP_PASSWORD = '######'
  
  def initialize
    @imap = Net::IMAP.new(IMAP_SERVER, IMAP_PORT, true)
  end
  
  def run
      
    @imap.login(IMAP_USER, IMAP_PASSWORD)
    
    posts = []
    
    @imap.select(IMAP_MBOX)
    @imap.search(["NOT", "DELETED"]).each do |m|
      
      post_data = @imap.fetch(m, ['ENVELOPE', 'BODYSTRUCTURE']).first.attr
      envelope = post_data['ENVELOPE']
      structure = post_data['BODYSTRUCTURE']
      
      puts structure.inspect
      
      caption_part = structure.parts.select { |p| p.media_type == 'TEXT' and p.subtype == 'PLAIN' }.first
      image_part = structure.parts.select { |p| p.media_type == 'IMAGE' and (p.subtype == 'JPEG' || p.subtype == 'JPG') }.first
      author_part = envelope.from.first
      
      if (author = get_author_id(author_part))
      
        title = envelope.subject
        caption = get_body_contents(structure.parts.index(caption_part),m).strip()
        image_binary = get_body_contents(structure.parts.index(image_part),m)
      
        posts << {  :title => title,
                    :caption => caption,
                    :image_binary => image_binary,
                    :author_id => author.id,
                    :posted_at => Time.now.to_i  }
                    
      end
      
      #@imap.store(m, "+FLAGS", [:Deleted])
      
    end
    
    Post.multi_insert(posts)
    
    @imap.logout()
    
  end
  
  private
  
  def get_body_contents(index,m)
    contents = ''
    unless index.nil?
      attribute = "BODY[%d]" % [index+1]
      contents = @imap.fetch(m, attribute).first.attr[attribute]
    end
    contents
  end
  
  def get_author_id(author_part)
    email = author_part.mailbox + '@' + author_part.host
    Author.select(:id).where('email = ?', [email]).first
  end
  
end