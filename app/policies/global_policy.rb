# frozen_string_literal: true

class GlobalPolicy < BasePolicy
  desc "User is an internal user"
  with_options scope: :user, score: 0
  condition(:internal) { @user&.internal? }

  desc "User's access has been locked"
  with_options scope: :user, score: 0
  condition(:access_locked) { @user&.access_locked? }

  condition(:can_create_fork, scope: :user) { @user && @user.manageable_namespaces.any? { |namespace| @user.can?(:create_projects, namespace) } }

  condition(:required_terms_not_accepted, scope: :user, score: 0) do
    @user&.required_terms_not_accepted?
  end

  condition(:private_instance_statistics, score: 0) { Gitlab::CurrentSettings.instance_statistics_visibility_private? }

  condition(:project_bot, scope: :user) { @user&.project_bot? }
  condition(:migration_bot, scope: :user) { @user&.migration_bot? }

  rule { admin | (~private_instance_statistics & ~anonymous) }
    .enable :read_instance_statistics

  rule { anonymous }.policy do
    prevent :log_in
    prevent :receive_notifications
    prevent :use_quick_actions
    prevent :create_group
  end

  rule { default }.policy do
    enable :log_in
    enable :access_api
    enable :access_git
    enable :receive_notifications
    enable :use_quick_actions
    enable :use_slash_commands
  end

  rule { inactive }.policy do
    prevent :log_in
    prevent :access_api
    prevent :access_git
    prevent :use_slash_commands
  end

  rule { blocked | internal }.policy do
    prevent :log_in
    prevent :access_api
    prevent :receive_notifications
    prevent :use_slash_commands
  end

  rule { blocked | (internal & ~migration_bot) }.policy do
    prevent :access_git
  end

  rule { project_bot }.policy do
    prevent :log_in
    prevent :receive_notifications
  end

  rule { deactivated }.policy do
    prevent :access_git
    prevent :access_api
    prevent :receive_notifications
    prevent :use_slash_commands
  end

  rule { required_terms_not_accepted }.policy do
    prevent :access_api
    prevent :access_git
  end

  rule { can_create_group }.policy do
    enable :create_group
  end

  rule { can?(:create_group) }.policy do
    enable :create_group_with_default_branch_protection
  end

  rule { can_create_fork }.policy do
    enable :create_fork
  end

  rule { access_locked }.policy do
    prevent :log_in
    prevent :use_slash_commands
  end

  rule { ~(anonymous & restricted_public_level) }.policy do
    enable :read_users_list
  end

  rule { ~anonymous }.policy do
    enable :read_instance_metadata
    enable :create_snippet
  end

  rule { admin }.policy do
    enable :read_custom_attribute
    enable :update_custom_attribute
  end

  # We can't use `read_statistics` because the user may have different permissions for different projects
  rule { admin }.enable :use_project_statistics_filters

  rule { external_user }.prevent :create_snippet
end

GlobalPolicy.prepend_if_ee('EE::GlobalPolicy')
