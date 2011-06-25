require 'spec_helper'

describe "topics" do
  before do
    User.delete_all
    ::Forem::Forum.delete_all
    ::Forem::Topic.delete_all
    ::Forem::View.delete_all
  end

  let(:forum) { Factory(:forum) }
  let(:topic) { Factory(:topic, :forum => forum) }
  let(:first_user) { Factory(:user, :login => 'first_forem_user') }
  let(:user) { Factory(:user, :login => 'other_forem_user') }
  let(:other_topic) { Factory(:topic, :subject => 'Another forem topic', :user => user, :forum => forum) }

  context "not signed in" do
    before do
      sign_out!
    end
    it "cannot create a new topic" do
      visit new_forum_topic_path(forum)
      flash_error!("You must sign in first.")
    end

    it "cannot delete topics" do
      delete forum_topic_path(topic.forum, topic), :id => topic.id.to_s
      response.should redirect_to(sign_in_path)
      flash[:error].should == "You must sign in first."
    end
  end

  context "signed in" do
    before do
      sign_in!
      visit new_forum_topic_path(forum)
    end

    context "creating a topic" do
      it "is valid with subject and post text" do
        fill_in "Subject", :with => "FIRST TOPIC"
        fill_in "Text", :with => "omgomgomgomg"
        click_button 'Create Topic'

        flash_notice!("This topic has been created.")
        assert_seen("FIRST TOPIC", :within => :topic_header)
        assert_seen("omgomgomgomg", :within => :post_text)
        assert_seen("forem_user", :within => :post_user)

      end

      it "is invalid without subject but with post text" do
        click_button 'Create Topic'

        flash_error!("This topic could not be created.")
        find_field("topic_subject").value.should eql("")
        find_field("topic_posts_attributes_0_text").value.should eql("")
      end
    end

    context "deleting a topic" do
      before do
        sign_in!
      end

      it "can delete their own topics" do
        visit forum_topic_path(topic.forum, topic)
        within(selector_for(:topic_menu)) do
          click_link("Delete")
        end
        flash_notice!("Your topic has been deleted.")
      end

      it "cannot delete topics by others" do
        first_user.id # Generate the first user that corresponds to the logged in user
        delete forum_topic_path(other_topic.forum, other_topic), :id => other_topic.id.to_s
        response.should redirect_to(forum_path(other_topic.forum))
        flash[:error].should == "You cannot delete a topic you do not own."
      end
    end

    context "creating a topic" do
      before do
        sign_in!
      end

      it "creates a view" do
        lambda do
          visit forum_topic_path(forum, topic)
        end.should change(Forem::View, :count).by(1)
      end

      it "increments a view" do
        pending "ryan helping me with tests because sqlite nested transaction fail"
        # register a view
        visit forum_topic_path(forum, topic)

        view = ::Forem::View.last

        expect do
          visit forum_topic_path(forum, topic)
        end.to change(::Forem::View.find(view.id), :count)
      end
    end
  end

  context "viewing a topic" do
    # Todo: Factory'ize
    let(:topic) do
      attributes = { :subject => "FIRST TOPIC",
        :posts_attributes => {
          "0" => {
            :text => "omgomgomg",
            :user => User.first
          }
        }
      }

      forum.topics.create(attributes)
    end

    it "is free for all" do
      visit forum_topic_path(forum, topic)
      assert_seen("FIRST TOPIC", :within => :topic_header)
      assert_seen("omgomgomg", :within => :post_text)
    end
  end
end
