# frozen_string_literal: true

# It is a controller to work with the settings for the system requirements
class SamplesController < ApplicationController
  before_action :new_setting, only: %i(new)
  before_action :set_os_names
  before_action { authorize! ['manage-utilities', 'manage-roles'] }

  def index
    @denylist_windows = Sample.win32.order_by_name
    @denylist_mac = Sample.darwin.order_by_name
  end

  def new; end

  def create
    @sample = Sample.new sample_params
    if @sample.save
      flash[:success] = "Unpermitted Application created."
      redirect_to samples_path
    else
      render 'new'
    end
  end

  def destroy
    @sample = Sample.find(params[:id])
    @sample.destroy
    flash[:success] = I18n.t('controllers.samples.deleted')
    redirect_to samples_path
  end

  def update
    @sample = Sample.find(params[:id])

    if @sample.update(one_time_shutdown: !@sample.one_time_shutdown)
      render json:   { message: t('controllers.samples.update.success') },
             status: 200
    else
      render json: { message: t('controllers.samples.update.error',
        errors: @sample.errors.full_messages.join('\n\n  ')) }, status: 400
    end
  end

  private

  def set_os_names
    @os_names ||= Sample.os_names.keys.map { |x| [x.titleize, x] }
  end

  def new_setting
    @sample = Sample.new
  end

  def sample_params
    params.require(:sample).permit(:os_name, :unpermitted_application)
  end
end
