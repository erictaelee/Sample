# frozen_string_literal: true

# It is a controller to work with the settings for the system requirements
class GuardianBrowserDenylistsController < ApplicationController
  before_action :new_setting, only: %i(new)
  before_action :set_os_names
  before_action { authorize! ['manage-utilities', 'manage-roles'] }

  def index
    @denylist_windows = GuardianBrowserDenylist.win32.order_by_name
    @denylist_mac = GuardianBrowserDenylist.darwin.order_by_name
  end

  def new; end

  def create
    @guardian_browser_denylist = GuardianBrowserDenylist.new guardian_browser_denylist_params
    if @guardian_browser_denylist.save
      flash[:success] = "Unpermitted Application created."
      redirect_to guardian_browser_denylists_path
    else
      render 'new'
    end
  end

  def destroy
    @guardian_browser_denylist = GuardianBrowserDenylist.find(params[:id])
    @guardian_browser_denylist.destroy
    flash[:success] = I18n.t('controllers.guardian_browser_denylists.deleted')
    redirect_to guardian_browser_denylists_path
  end

  def update
    @guardian_browser_denylist = GuardianBrowserDenylist.find(params[:id])

    if @guardian_browser_denylist.update(one_time_shutdown: !@guardian_browser_denylist.one_time_shutdown)
      render json:   { message: t('controllers.guardian_browser_denylists.update.success') },
             status: 200
    else
      render json: { message: t('controllers.guardian_browser_denylists.update.error',
        errors: @guardian_browser_denylist.errors.full_messages.join('\n\n  ')) }, status: 400
    end
  end

  private

  def set_os_names
    @os_names ||= GuardianBrowserDenylist.os_names.keys.map { |x| [x.titleize, x] }
  end

  def new_setting
    @guardian_browser_denylist = GuardianBrowserDenylist.new
  end

  def guardian_browser_denylist_params
    params.require(:guardian_browser_denylist).permit(:os_name, :unpermitted_application)
  end
end
