require 'sinatra'
require 'sinatra/async'
require 'padrino-helpers'
require 'will_paginate'
require 'will_paginate/active_record'
require 'will_paginate/view_helpers/sinatra'

class MessageGateway
  class Admin

    def initialize(gateway, options={})
      @gateway, @app, @options = gateway, ( options[:class] || SinatraApp ), options
      puts "Starting admin console"
    end

    def call(env)
      env['message_gateway'] = @gateway
      env["user_options"] = @options
      @app.call(env)
    end

    # Define a Sinatra (with Padrino helpers!) app for administrative purposes.
    # Launch this by calling MessageGateway#admin (have your rackup file in place!)
    class SinatraApp < Sinatra::Base

      register Padrino::Helpers
      register Sinatra::Async

      include WillPaginate::Sinatra::Helpers


      use MessageGateway::Middleware::KeepDbConnectionAlive

      set :root, File.join(File.dirname(__FILE__), 'admin')
      set :logging, true
      set :dump_errors, true
      #enable :sessions

      attr_reader :prefix
      layout :application

      def url_for(*args)
        "/#{@prefix}/messages?#{Rack::Utils.build_query(args.last)}"
      end

      before do
        @gateway = env['message_gateway']
        @prefix = '/message_gateway'
        @prefix = env['user_options'][:prefix] if env['user_options']

        @notice = session.delete('notice') if session
      end

      get '/?' do
        redirect "#{@prefix}/dashboard"
      end

      get '/dashboard' do
        @states = MessageLogger::State.find(:all, :order => "id desc", :limit => 30)
        @mo_graph_data = @gateway.processors.map do |name, processor|
          [name, processor.mo_success_buckets]
        end unless @gateway.processors.empty?
        @mo_graph_data = [] unless @mo_graph_data

        @mt_graph_data = @gateway.dispatchers.map do |name, dispatcher|
          [name, dispatcher.mt_success_buckets]
        end unless @gateway.dispatchers.empty?
        @mt_graph_data = [] unless @mt_graph_data

        haml :dashboard
      end

      get '/log' do
        @states = MessageLogger::State.find(:all, :order => "id desc", :limit => 30)
        haml :log
      end

      get '/messages/:id' do
        @state = MessageLogger::State.find(params[:id])
        haml :message
      end

      get '/messages' do
        @conditions = {:per_page => 30, :order => 'id DESC'}
        @conditions[:per_page] = Integer(params[:per_page]) if params[:per_page]
        if params[:order]
          order_parts = params[:order].split
          order_parts[0] = "`#{order_parts[0]}`"
          @conditions[:order] = order_parts.join(' ')
        end
        if params[:status]
          @conditions[:conditions] ||= {}
          @conditions[:conditions][:status] = params[:status] if params[:status] && !params[:status].empty?
        end
        if params[:source]
          @conditions[:conditions] ||= {}
          @conditions[:conditions][:source] = params[:source] if params[:source] && !params[:source].empty?
        end
        @description = "Showing <strong>#{@conditions[:per_page]}</strong> messages ordered by <strong>#{@conditions[:order]}</strong>"
        if @conditions[:conditions]
          parts = []
          parts << "with status <strong>#{@conditions[:conditions][:status]}</strong>" if @conditions[:conditions][:status]
          parts << "with source <strong>#{@conditions[:conditions][:source]}</strong>" if @conditions[:conditions][:source]
          @description << " " << parts.join(' and ')
        end
        @states = MessageLogger::State.paginate @conditions.merge(:page => params[:page])

        if params[:reply]
          @states.each do |state|
            if state.mt?
              @gateway.replay_mt(state.to_message)
            elsif state.mo?
              @gateway.replay_mo(state.to_message)
            end
          end
          session['notice'] = "Replayed!"
          redirect "#{@prefix}/messages"
        else
          haml :messages
        end
      end

      aget '/processor/:name' do |name|
        @processor = @gateway.processors[name] or raise
        @events = MessageLogger::Event.find_by_sql(["select events.* from events, states where events.state_id = states.id and states.source = ? order by events.id desc limit 30", name])

        jack = EMJack::Connection.new(:host => @gateway.beanstalk_host)

        r = jack.stats(:tube, @processor.tube_name)
        r.callback {|stats|
          @total_jobs = stats["total-jobs"]
          body {haml :processor}
        }

        r.errback {|err|
          @total_jobs = "(error: #{err})"
          body {haml :processor}
        }
        #haml :processor
      end

      get '/dispatcher/:name' do |name|
        @dispatcher = @gateway.dispatchers[name] or raise
        @events = MessageLogger::Event.find_by_sql(["select events.* from events, states where events.state_id = states.id and states.source = ? and events.status like 'mt_%' order by events.id desc limit 30", name])
        haml :dispatcher
      end

      post '/processor/:name/simulate' do |name|
        @processor = @gateway.processors[name] or raise
        @processor.process @processor.message(params[:from], params[:to], params[:body])
        session['notice'] = "Message <em>#{params[:body]}</em> has been simulated."
        redirect "#{@prefix}/processor/#{name}"
      end

      post "/debug" do
        # this block is to help you debug your Sender requests: you can see what parameters you are
        # posting in this block

        MessageGateway::SysLogger.info "Params are:"
        MessageGateway::SysLogger.info params.inspect

        MessageGateway::SysLogger.info "Request.body:"
        MessageGateway::SysLogger.info request.body.read

        MessageGateway::SysLogger.info "request.query:"
        MessageGateway::SysLogger.info request.query_string

        "OK"
      end
    end


  end
end

require 'will_paginate/view_helpers/link_renderer'

WillPaginate::ViewHelpers::LinkRenderer.class_eval do
  protected
  def url(page)
    url = "/#{@template.prefix}#{@template.request.path}"
    if page == 1
      # strip out page param and trailing ? if it exists
      url.gsub(/page=[0-9]+/, '').gsub(/\?$/, '')
    else
      if url =~ /page=[0-9]+/
        url.gsub(/page=[0-9]+/, "page=#{page}")
      else
        url + "?page=#{page}"
      end
    end
  end
end
