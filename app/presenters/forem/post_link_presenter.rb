require 'action_view/helpers/date_helper'

module Forem
  class PostLinkPresenter
    include ActionView::Helpers::DateHelper # time_ago_in_words

    def initialize(context, post, alternate_text = nil)
      self.context = context
      self.post = post
      self.alternate_text = alternate_text || ::I18n.t('forem.forums.index.none')
    end

    def to_s
      return alternate_text unless post

      text = [link_to(EmojiPresenter.new(context, post.topic.subject).to_s,
                      forem.forum_topic_path(post.forum, post.topic))]
      text << ::I18n.t('by')
      text << post.user
      text << time_ago_in_words(post.created_at)
      text.join(' ').html_safe
    end

    protected
    attr_accessor :context, :post, :alternate_text
    delegate :forem, :link_to, :to => :context

  end
end
