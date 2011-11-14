require 'digest/md5'
class MessageGateway
  class MessageLogger
    class State < ActiveRecord::Base
      has_many :events, :class_name => 'MessageGateway::MessageLogger::Event'
      has_one :replied_from, :class_name => 'MessageGateway::MessageLogger::State', :primary_key => 'reply_to_id', :foreign_key => 'id'
      has_one :reply, :class_name => 'MessageGateway::MessageLogger::State', :foreign_key => 'reply_to_id'

      def self.find_by_message(message)
        message.id && find(message.id)
      end

      def to_message
        data = {'body' => body, 'to' => to, 'from' => from, 'source' => source, 'carrier_id' => carrier_id}
        data.merge!(JSON.parse(extra)) if extra
        message = MessageGateway::Message.from_hash(data)
        message.id = id
        message
      end

      def mt?
        !status[/^mt_/].nil?
      end

      def mo?
        !status[/^mo_/].nil?
      end

      def self.record_status(message, status, err = nil)
        state = message.id ? find(message.id) : State.new
        if state.new_record?
          state.body = message.body
          state.to = message.to
          state.from = message.from
          state.source = message.source
          state.reply_to_id = message.in_reply_to if message.in_reply_to
          state.extra = message.extra && message.extra.to_json

          state.carrier_id = message.carrier_id if message.respond_to?(:carrier_id)
        end
        state.update_status(message, status, err)
        state
      end

      def update_status(message, status, err)
        self.status = status
        save!
        message.id = id
        events.create(:status => status, :error => err).save!
      end

      def self.find_extra_for_number(number)
        find(:first, :conditions => ["state is not null and to = ?", sanitize_phone_number(number)], :order => 'id desc')
      end
    end
  end
end
