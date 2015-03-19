class RegistrationsController < Devise::RegistrationsController
  def destroy
    current_user.destroy

    respond_to do |format|
      format.html { redirect_to new_user_session_path, notice: "Account successfully removed." }
    end
  end

  protected

  def build_resource(hash=nil)
    super
    self.resource.with_defaults
  end
end