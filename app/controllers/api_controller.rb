require "string_utils"
class ApiController < ApplicationController
  before_action :login_required_api
  params_required :subscribe_id, only: :touch_all
  params_required [:timestamp, :subscribe_id], only: :touch
  params_required :since, only: [:item_count, :unread_count]
  before_action :find_sub, only: [:all, :unread]
  skip_before_action :verify_authenticity_token

  def f2f
    Feedly2fastladder.new(token: ENV["FEEDLY_TOKEN"])
  end

  def all
    render json: f2f.unread(params[:subscribe_id])
  end

  def unread
    render json: f2f.unread(params[:subscribe_id])
  end

  def touch_all
    f2f.touch_all params[:subscribe_id], params[:entry_id]
    render_json_status(true)
  end

  def touch
    # Not Implemented
  end

  def item_count
    render json: count_items(unread: false).to_json
  end

  def unread_count
    render json: count_items(unread: true).to_json
  end

  def subs
    render json: f2f.subs(params[:unread] == "1")
  end

  def lite_subs
    items = []
    @member.subscriptions.includes(:folder, :feed).each do |sub|
      feed = sub.feed
      modified_on = feed.modified_on
      item = {
        subscribe_id: sub.id,
        folder: (sub.folder ? sub.folder.name : "").utf8_roundtrip.html_escape,
        rate: sub.rate,
        public: sub.public ? 1 : 0,
        link: feed.link.html_escape,
        feedlink: feed.feedlink.html_escape,
        title: feed.title.utf8_roundtrip.html_escape,
        icon: feed.favicon.blank? ? "/img/icon/default.png" : "/icon/#{feed.id}",
        modified_on: modified_on ? modified_on.to_time.to_i : 0,
        subscribers_count: feed.subscribers_count,
      }
      if sub.ignore_notify
        item[:ignore_notify] = 1
      end
      items << item
    end
    render json: items.to_json
  end

  def error_subs
  end

  def folders
    names = []
    name2id = {}
    @member.folders.each do |folder|
      name = (folder.name || "").utf8_roundtrip.html_escape
      names << name
      name2id[name] = folder.id
    end
    render json: {
      names: names,
      name2id: name2id,
    }.to_json
  end

  def crawl
    true
  end

protected
  def find_sub
    true
  end

  def count_items(options = {})
    subscriptions = @member.subscriptions
    subscriptions = subscriptions.has_unread if options[:unread]
    stored_on_list = subscriptions.order("id").map do |sub|
      {
        subscription: sub,
        stored_on: sub.feed.items.select("stored_on").order("stored_on DESC").limit(Settings.max_unread_count).map { |item| item.stored_on.to_time },
      }
    end
    counts = []
    params[:since].split(/,/).each do |s|
      param_since = s =~ /^\d+$/ ? Time.new(s.to_i) : Time.parse(s)
      counts << stored_on_list.inject(0) do |sum, pair|
        since = options[:unread] ? [param_since, pair[:subscription].viewed_on.to_time].max : param_since
        sum + pair[:stored_on].find_all { |stored_on| stored_on > since }.size
      end
    end
    if counts.size == 1
      return counts[0]
    end
    counts
  end
end
