class ErrorMessagesController < ApplicationController
  before_action :set_error_message, only: [:show]

  # GET /error_messages
  # GET /error_messages.json
  def index
    @error_messages = ErrorMessage.all.order('id desc')
  end

  # GET /error_messages/1
  # GET /error_messages/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_error_message
      @error_message = ErrorMessage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def error_message_params
      params.require(:error_message).permit(:message, :backtrace, :class_name, :testrun_id, :test_run_id)
    end
end
