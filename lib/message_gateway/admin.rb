require 'sinatra'
require 'will_paginate/view_helpers'
require 'padrino-helpers'

class MessageGateway
  class Admin
    
    def initialize(gateway)
      @gateway, @app = gateway, SinatraApp
      puts "Starting admin console"
    end
    
    def call(env)
      env['message_gateway'] = @gateway
      @app.call(env)
    end

    class SinatraApp < Sinatra::Base
      
      register Padrino::Helpers
      
      set :root, File.join(File.dirname(__FILE__), 'admin')
      set :logging, true
      set :dump_errors, true
      enable :sessions
      
      layout :application

      def url_for(*args)
        "/admin/messages?#{Rack::Utils.build_query(args.last)}"
      end

      include WillPaginate::ViewHelpers

      before do
        @gateway = env['message_gateway']
        @prefix = '/admin'
        @notice = session.delete('notice')
      end

      get '/?' do
        redirect "#{@prefix}/dashboard"
      end

      get '/dashboard' do
        @states = Logger::State.find(:all, :order => "id desc", :limit => 30)
        @mo_graph_data = @gateway.processors.map do |name, processor|
          [name, processor.mo_success_buckets]
        end unless @gateway.processors.empty?
        @mt_graph_data = @gateway.dispatchers.map do |name, dispatcher|
          [name, dispatcher.mt_success_buckets]
        end unless @gateway.dispatchers.empty?
        haml :dashboard
      end

      get '/log' do
        @states = Logger::State.find(:all, :order => "id desc", :limit => 30)
        haml :log
      end
      
      get '/messages/:id' do
        @state = Logger::State.find(params[:id])
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
        @states = Logger::State.paginate @conditions.merge(:page => params[:page])
        
        if params[:reply]
          @states.each do |state|
            puts "STATE #{state.inspect} MT #{state.mt?.inspect} MO #{state.mo?.inspect}"
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
      
      get '/processor/:name' do |name|
        @processor = @gateway.processors[name] or raise
        @events = Logger::Event.find_by_sql(["select events.* from events, states where events.state_id = states.id and states.source = ? order by events.id desc limit 30", name])
        haml :processor
      end

      get '/dispatcher/:name' do |name|
        @dispatcher = @gateway.dispatchers[name] or raise
        @events = Logger::Event.find_by_sql(["select events.* from events, states where events.state_id = states.id and states.source = ? and events.status like 'mt_%' order by events.id desc limit 30", name])
        haml :dispatcher
      end

      post '/processor/:name/simulate' do |name|
        @processor = @gateway.processors[name] or raise
        @processor.process @processor.message(params[:from], params[:to], params[:body])
        session['notice'] = "Message <em>#{params[:body]}</em> has been simulated."
        redirect "#{@prefix}/processor/#{name}"
      end

    end
    
    
  end
end