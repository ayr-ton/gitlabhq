module Clusters
  module Applications
    class Ingress < ActiveRecord::Base
      self.table_name = 'clusters_applications_ingress'

      include ::Clusters::Concerns::ApplicationCore
      include ::Clusters::Concerns::ApplicationStatus
      include ::Clusters::Concerns::ApplicationData
      include AfterCommitQueue

      default_value_for :ingress_type, :nginx
      default_value_for :version, :nginx

      enum ingress_type: {
        nginx: 1
      }

      FETCH_IP_ADDRESS_DELAY = 30.seconds

      state_machine :status do
        before_transition any => [:installed] do |application|
          application.run_after_commit do
            ClusterWaitForIngressIpAddressWorker.perform_in(
              FETCH_IP_ADDRESS_DELAY, application.name, application.id)
          end
        end
      end

      def chart
        'stable/nginx-ingress'
      end

      def install_command
        Gitlab::Kubernetes::Helm::InstallCommand.new(
          name,
          chart: chart,
          values: values,
          extra_env: extra_env,
        )
      end

      def schedule_status_update
        return unless installed?
        return if external_ip

        ClusterWaitForIngressIpAddressWorker.perform_async(name, id)
      end

      def extra_env
        {
          "CA_CERT" => cluster.application_helm.ca_cert,
          "HELM_CERT" => cluster.application_helm.client_cert,
          "HELM_KEY" => cluster.application_helm.client_key,
        }
      end
    end
  end
end
