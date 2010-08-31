class MessageGateway
  module Logging
    attr_accessor :gateway
    
    def log
      gateway.log
    end
    
    def log_mo_start(message)
      gateway.logger.record_status(message, :mo_start)
    end
    
    def log_mo_success(message)
      gateway.logger.record_status(message, :mo_success)
    end
    
    def log_mo_failure(message, err = nil)
      gateway.logger.record_status(message, :mo_failure, err)
    end

    def log_mo_permanent_failure(message, err = nil)
      gateway.logger.record_status(message,:mo_permanent_failure, err)
    end

    def log_mt_start(message)
      gateway.logger.record_status(message, :mt_start)
    end

    def log_mt_success(message)
      gateway.logger.record_status(message, :mt_success)
    end

    def log_mt_failure(message, err = nil)
      gateway.logger.record_status(message, :mt_failure, err)
    end

    def log_mt_permanent_failure(message, err = nil)
      gateway.logger.record_status(message, :mt_permanent_failure, err)
    end

  end
end